#include "c_api.h"
#include "napi/native_api.h"
#include <cstring>
#include <map>
#include <rawfile/raw_file.h>
#include <rawfile/raw_file_manager.h>
#include "platform.h"
#include "cpu.h"
// #include "yolov4.h"  // YOLOv4已移除，只使用YOLOv8
#include "nanodet.h"
#include "yolov8.h"
#include "benchmark_ncnn.h"

#include "hilog/log.h"

#undef LOG_TAG
#define LOG_TAG "Tncnn"

#define DECLARE_NAPI_FUNCTION(name, func)                                                                              \
    { name, nullptr, func, nullptr, nullptr, nullptr, napi_default, nullptr }

// static yolo::YOLOv4 *g_yolov4 = nullptr;  // YOLOv4已移除
static nanodet::NanoDet *g_nanodet = nullptr;
static yolo::YOLOv8 *g_yolov8 = nullptr;

/**
 * 从 napi 转换字符串到 cpp
 * @param env
 * @param value
 * @return
 */
static std::string value_to_string(napi_env env, napi_value value) {
    size_t stringSize = 0;
    napi_get_value_string_utf8(env, value, nullptr, 0, &stringSize); // 获取字符串长度
    std::string valueString;
    valueString.resize(stringSize + 1);
    napi_get_value_string_utf8(env, value, &valueString[0], stringSize + 1, &stringSize); // 根据长度传换成字符串
    return valueString.c_str();
}

/**
 * 获取文件内容
 * example: const char* param_ptr = readFileContent(mNativeResMgr, "yolov4-tiny.param");
 * @param mNativeResMgr
 * @param file_name 包含文件扩展名
 * @return
 */
const char *read_file_content(NativeResourceManager *native_res_mgr, std::string file_name) {
    // 通过资源对象打开文件
    RawFile *raw_file = OH_ResourceManager_OpenRawFile(native_res_mgr, file_name.c_str());
    if (raw_file != nullptr) {
        OH_LOG_DEBUG(LogType::LOG_APP, "%{public}s open success", file_name.c_str());
    } else {
        OH_LOG_DEBUG(LogType::LOG_APP, "%{public}s open fail", file_name.c_str());
    }

    // 获取rawfile大小并申请内存
    long len = OH_ResourceManager_GetRawFileSize(raw_file);
    OH_LOG_DEBUG(LogType::LOG_APP, "%{public}s len:%{public}ld", file_name.c_str(), len);
    std::unique_ptr<uint8_t[]> data = std::make_unique<uint8_t[]>(len);

    // 一次性读取rawfile全部内容
    int res = OH_ResourceManager_ReadRawFile(raw_file, data.get(), len);

    // 将数据转换为const unsigned char*并确保32位对齐
    const char *aligned_ptr = reinterpret_cast<const char *>(data.get());

    // 检查是否32位对齐
    if (reinterpret_cast<uintptr_t>(aligned_ptr) % 4 != 0) {
        OH_LOG_DEBUG(LogType::LOG_APP, "memory pointer must be 32-bit aligned");
    }

    OH_ResourceManager_CloseRawFile(raw_file);
//     OH_ResourceManager_ReleaseNativeResourceManager(native_res_mgr);

    return aligned_ptr;
}

// ==========================================================================================================
// ============================================[ ncnn api start ]============================================
// ==========================================================================================================

/**
 * 参数获取
 */
ncnn::Option get_option_from_napi(napi_env env, napi_value args_option, napi_value args_config) {
    // option 参数
    napi_value v_mempool;
    napi_value v_winograd;
    napi_value v_sgemm;
    napi_value v_pack4;
    napi_value v_bf16_storage;
    napi_value v_fp16_packed;
    napi_value v_fp16_storage;
    napi_value v_fp16_arithmetic;
    napi_value v_light_mode;
    napi_get_named_property(env, args_option, "mempool", &v_mempool);
    napi_get_named_property(env, args_option, "winograd", &v_winograd);
    napi_get_named_property(env, args_option, "sgemm", &v_sgemm);
    napi_get_named_property(env, args_option, "pack4", &v_pack4);
    napi_get_named_property(env, args_option, "bf16Storage", &v_bf16_storage);
    napi_get_named_property(env, args_option, "fp16Packed", &v_fp16_packed);
    napi_get_named_property(env, args_option, "fp16Storage", &v_fp16_storage);
    napi_get_named_property(env, args_option, "fp16Arithmetic", &v_fp16_arithmetic);
    napi_get_named_property(env, args_option, "lightMode", &v_light_mode);
    bool mempool;
    bool winograd;
    bool sgemm;
    bool pack4;
    bool bf16_storage;
    bool fp16_packed;
    bool fp16_storage;
    bool fp16_arithmetic;
    bool light_mode;
    napi_get_value_bool(env, v_mempool, &mempool);
    napi_get_value_bool(env, v_winograd, &winograd);
    napi_get_value_bool(env, v_sgemm, &sgemm);
    napi_get_value_bool(env, v_pack4, &pack4);
    napi_get_value_bool(env, v_bf16_storage, &bf16_storage);
    napi_get_value_bool(env, v_fp16_packed, &fp16_packed);
    napi_get_value_bool(env, v_fp16_storage, &fp16_storage);
    napi_get_value_bool(env, v_fp16_arithmetic, &fp16_arithmetic);
    napi_get_value_bool(env, v_light_mode, &light_mode);

    // config 参数
    napi_value v_is_gpu;
    napi_value v_core;
    napi_value v_thread;
    napi_get_named_property(env, args_config, "isGPU", &v_is_gpu);
    napi_get_named_property(env, args_config, "core", &v_core);
    napi_get_named_property(env, args_config, "thread", &v_thread);
    bool is_gpu;
    int core;
    int thread;
    napi_get_value_bool(env, v_is_gpu, &is_gpu);
    napi_get_value_int32(env, v_core, &core);
    napi_get_value_int32(env, v_thread, &thread);

    ncnn::UnlockedPoolAllocator *blob_pool_allocator = 0;
    ncnn::UnlockedPoolAllocator *workspace_pool_allocator = 0;

#if NCNN_VULKAN
    ncnn::VulkanDevice *vkdev = 0;
    ncnn::VkBlobAllocator *blob_vkallocator = 0;
    ncnn::VkStagingAllocator *staging_vkallocator = 0;
#endif

    ncnn::Option option;
    option.lightmode = light_mode;
#if NCNN_VULKAN
    option.num_threads = (thread == 0) ? ncnn::get_gpu_count() : thread;
#endif
    if (mempool) {
        blob_pool_allocator = new ncnn::UnlockedPoolAllocator;
        workspace_pool_allocator = new ncnn::UnlockedPoolAllocator;

        option.blob_allocator = blob_pool_allocator;
        option.workspace_allocator = workspace_pool_allocator;
    }
#if NCNN_VULKAN
    if (is_gpu) {
        const int gpu_device = 0;
        vkdev = ncnn::get_gpu_device(0);

        blob_vkallocator = new ncnn::VkBlobAllocator(vkdev);
        staging_vkallocator = new ncnn::VkStagingAllocator(vkdev);

        option.blob_vkallocator = blob_vkallocator;
        option.workspace_vkallocator = blob_vkallocator;
        option.staging_vkallocator = staging_vkallocator;
    }
#endif
    option.use_winograd_convolution = winograd;
    option.use_sgemm_convolution = sgemm;

    option.use_vulkan_compute = is_gpu;

    option.use_bf16_storage = bf16_storage;
    option.use_fp16_packed = fp16_packed;
    option.use_fp16_storage = fp16_storage;
    option.use_fp16_arithmetic = fp16_arithmetic;
    option.use_int8_storage = true;
    option.use_int8_arithmetic = false;

//     option.use_shader_pack8 = gpupack8;
    ncnn::set_cpu_powersave(core);
    return option;
}

/**
 * ncnn版本号
 */
static napi_value NcnnVersion(napi_env env, napi_callback_info info) {
    const char *ncnn_ver_str = ncnn_version();
#if NCNN_VULKAN
    std::string ver_vulkan(ncnn_ver_str);
    ncnn_ver_str = (ver_vulkan + " vulkan").c_str();
#endif
    OH_LOG_DEBUG(LogType::LOG_APP, "ncnn version:%{public}s", ncnn_ver_str);
    napi_value version_str;
    napi_create_string_utf8(env, ncnn_ver_str, strlen(ncnn_ver_str), &version_str);
    return version_str;
}

// --------------------------------------------[ yolo start ]--------------------------------------------
// 转换增强的BoxInfo到JavaScript对象
napi_value convert_boxinfo_to_js_yolo(napi_env env, const yolo::BoxInfo &box) {
    napi_value js_object;
    napi_create_object(env, &js_object);

    // 创建键
    napi_value kx1, ky1, kx2, ky2, kx_center, ky_center;
    napi_value kscore, klabel, klabel_name, kuuid, ktime_sent, kimglabel;
    
    napi_create_string_utf8(env, "x1", NAPI_AUTO_LENGTH, &kx1);
    napi_create_string_utf8(env, "y1", NAPI_AUTO_LENGTH, &ky1);
    napi_create_string_utf8(env, "x2", NAPI_AUTO_LENGTH, &kx2);
    napi_create_string_utf8(env, "y2", NAPI_AUTO_LENGTH, &ky2);
    napi_create_string_utf8(env, "x_center", NAPI_AUTO_LENGTH, &kx_center);
    napi_create_string_utf8(env, "y_center", NAPI_AUTO_LENGTH, &ky_center);
    napi_create_string_utf8(env, "score", NAPI_AUTO_LENGTH, &kscore);
    napi_create_string_utf8(env, "label", NAPI_AUTO_LENGTH, &klabel);
    napi_create_string_utf8(env, "labelName", NAPI_AUTO_LENGTH, &klabel_name);
    napi_create_string_utf8(env, "uuid", NAPI_AUTO_LENGTH, &kuuid);
    napi_create_string_utf8(env, "timeSent", NAPI_AUTO_LENGTH, &ktime_sent);
    napi_create_string_utf8(env, "imglabel", NAPI_AUTO_LENGTH, &kimglabel);

    // 创建值
    napi_value x1, y1, x2, y2, x_center, y_center, score, label, label_name, uuid, time_sent, imglabel;
    napi_create_double(env, box.x1, &x1);
    napi_create_double(env, box.y1, &y1);
    napi_create_double(env, box.x2, &x2);
    napi_create_double(env, box.y2, &y2);
    napi_create_double(env, box.x_center, &x_center);
    napi_create_double(env, box.y_center, &y_center);
    napi_create_double(env, box.score, &score);
    napi_create_int32(env, box.label, &label);
    napi_create_string_utf8(env, box.label_name.c_str(), NAPI_AUTO_LENGTH, &label_name);
    napi_create_string_utf8(env, box.uuid.c_str(), NAPI_AUTO_LENGTH, &uuid);
    napi_create_string_utf8(env, box.time_sent.c_str(), NAPI_AUTO_LENGTH, &time_sent);
    napi_create_string_utf8(env, box.imglabel.c_str(), NAPI_AUTO_LENGTH, &imglabel);

    // 设置属性
    napi_set_property(env, js_object, kx1, x1);
    napi_set_property(env, js_object, ky1, y1);
    napi_set_property(env, js_object, kx2, x2);
    napi_set_property(env, js_object, ky2, y2);
    napi_set_property(env, js_object, kx_center, x_center);
    napi_set_property(env, js_object, ky_center, y_center);
    napi_set_property(env, js_object, kscore, score);
    napi_set_property(env, js_object, klabel, label);
    napi_set_property(env, js_object, klabel_name, label_name);
    napi_set_property(env, js_object, kuuid, uuid);
    napi_set_property(env, js_object, ktime_sent, time_sent);
    napi_set_property(env, js_object, kimglabel, imglabel);

    return js_object;
}

// YOLOv4已移除，只使用YOLOv8
// 如需使用YOLOv4，请参考git历史记录

// --------------------------------------------[ yolo end ]--------------------------------------------

// --------------------------------------------[ nanodet start ]--------------------------------------------
napi_value convert_boxinfo_to_js_nanodet(napi_env env, const nanodet::BoxInfo &box) {
    napi_value js_object;
    napi_create_object(env, &js_object);

    napi_value kx1, ky1, kx2, ky2, kscore, klabel;
    napi_create_string_utf8(env, "x1", NAPI_AUTO_LENGTH, &kx1);
    napi_create_string_utf8(env, "y1", NAPI_AUTO_LENGTH, &ky1);
    napi_create_string_utf8(env, "x2", NAPI_AUTO_LENGTH, &kx2);
    napi_create_string_utf8(env, "y2", NAPI_AUTO_LENGTH, &ky2);
    napi_create_string_utf8(env, "score", NAPI_AUTO_LENGTH, &kscore);
    napi_create_string_utf8(env, "label", NAPI_AUTO_LENGTH, &klabel);

    napi_value x1, y1, x2, y2, score, label;
    napi_create_double(env, box.x1, &x1);
    napi_create_double(env, box.y1, &y1);
    napi_create_double(env, box.x2, &x2);
    napi_create_double(env, box.y2, &y2);
    napi_create_double(env, box.score, &score);
    napi_create_int32(env, box.label, &label);

    napi_set_property(env, js_object, kx1, x1);
    napi_set_property(env, js_object, ky1, y1);
    napi_set_property(env, js_object, kx2, x2);
    napi_set_property(env, js_object, ky2, y2);
    napi_set_property(env, js_object, kscore, score);
    napi_set_property(env, js_object, klabel, label);

    return js_object;
}

/**
 * 初始化
 */
static napi_value NanoDetInit(napi_env env, napi_callback_info info) {
    size_t argc = 4;
    napi_value args[4] = {nullptr};
    // 获取参数信息
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // 将传入的resource manager对象转换为Native对象
    NativeResourceManager *mNativeResMgr = OH_ResourceManager_InitNativeResourceManager(env, args[0]);
    if (mNativeResMgr != nullptr) {
        OH_LOG_DEBUG(LogType::LOG_APP, "NativeResourceManager success");
    } else {
        OH_LOG_DEBUG(LogType::LOG_APP, "NativeResourceManager fail");
    }

    napi_value str = args[1];
    std::string sanbox_path = value_to_string(env, str);
    OH_LOG_DEBUG(LogType::LOG_APP, "sanbox path:%{public}s", sanbox_path.c_str());

    // 参数
    ncnn::Option option = get_option_from_napi(env, args[2], args[3]);

    if (g_nanodet != nullptr) {
        OH_LOG_DEBUG(LogType::LOG_APP, "delete g_nanodet");
        delete g_nanodet;
    }
    g_nanodet = new nanodet::NanoDet();
    int r = g_nanodet->init(option, (sanbox_path + "/nanodet-m.param").c_str(),
                            (sanbox_path + "/nanodet-m.bin").c_str(), "nanodet-m");

    const char *r_str = r == 0 ? "success" : "fail";
    napi_value nr_str;
    napi_create_string_utf8(env, r_str, strlen(r_str), &nr_str);
    return nr_str;
}

/**
 * 识别
 */
static napi_value NanoDetRun(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    // 获取参数信息
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    void *data = nullptr;
    size_t byte_length = 0;
    // 获取ArrayBuffer的底层数据缓冲区和长度
    napi_status status = napi_get_arraybuffer_info(env, args[0], &data, &byte_length);
    if (status != napi_ok) {
        OH_LOG_DEBUG(LogType::LOG_APP, "Failed to get ArrayBuffer info");
        return nullptr;
    }
    OH_LOG_DEBUG(LogType::LOG_APP, "byte length:%{public}zu", byte_length);
    int width;
    int height;
    napi_get_value_int32(env, args[1], &width);
    napi_get_value_int32(env, args[2], &height);
    OH_LOG_DEBUG(LogType::LOG_APP, "image size:%{public}d x %{public}d", width, height);

    ncnn::Mat input = ncnn::Mat(width, height, 4, data);
    OH_LOG_DEBUG(LogType::LOG_APP, "mat size:%{public}d x %{public}d x %{public}d", input.w, input.h, input.c);

    std::vector<nanodet::BoxInfo> objects;
    objects = g_nanodet->run(input, width, height, "nanodet-m");

    napi_value js_array;
    napi_create_array_with_length(env, objects.size(), &js_array);
    for (size_t i = 0; i < objects.size(); i++) {
        napi_value js_box = convert_boxinfo_to_js_nanodet(env, objects[i]);
        napi_set_element(env, js_array, i, js_box);
    }

    return js_array;
}

// --------------------------------------------[ nanodet end ]--------------------------------------------

// --------------------------------------------[ yolov8 start ]--------------------------------------------
/**
 * 初始化YOLOv8
 */
static napi_value YOLOv8Init(napi_env env, napi_callback_info info) {
    size_t argc = 5;
    napi_value args[5] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // 将传入的resource manager对象转换为Native对象
    NativeResourceManager *mNativeResMgr = OH_ResourceManager_InitNativeResourceManager(env, args[0]);
    if (mNativeResMgr != nullptr) {
        OH_LOG_DEBUG(LogType::LOG_APP, "NativeResourceManager success");
    } else {
        OH_LOG_DEBUG(LogType::LOG_APP, "NativeResourceManager fail");
    }

    napi_value str = args[1];
    std::string sanbox_path = value_to_string(env, str);
    OH_LOG_DEBUG(LogType::LOG_APP, "sanbox path:%{public}s", sanbox_path.c_str());

    // 获取模型类型（如"yolov8n", "yolov8s"等）
    napi_value model_type_value = args[2];
    std::string model_type = value_to_string(env, model_type_value);
    OH_LOG_DEBUG(LogType::LOG_APP, "model type:%{public}s", model_type.c_str());

    // 参数
    ncnn::Option option = get_option_from_napi(env, args[3], args[4]);

    if (g_yolov8 != nullptr) {
        OH_LOG_DEBUG(LogType::LOG_APP, "delete g_yolov8");
        delete g_yolov8;
    }
    g_yolov8 = new yolo::YOLOv8();
    
    // 构建模型文件路径
    std::string param_path = sanbox_path + "/" + model_type + ".param";
    std::string bin_path = sanbox_path + "/" + model_type + ".bin";
    
    int r = g_yolov8->init(option, param_path.c_str(), bin_path.c_str(), model_type.c_str());

    const char *r_str = (r == 0) ? "fail" : "success";
    napi_value nr_str;
    napi_create_string_utf8(env, r_str, strlen(r_str), &nr_str);
    return nr_str;
}

/**
 * YOLOv8识别（增强版，支持透传数据和SNHA标签映射）
 */
static napi_value YOLOv8Run(napi_env env, napi_callback_info info) {
    size_t argc = 7;  // 增加参数数量
    napi_value args[7] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    void *data = nullptr;
    size_t byte_length = 0;
    napi_status status = napi_get_arraybuffer_info(env, args[0], &data, &byte_length);
    if (status != napi_ok) {
        OH_LOG_DEBUG(LogType::LOG_APP, "Failed to get ArrayBuffer info");
        return nullptr;
    }
    OH_LOG_DEBUG(LogType::LOG_APP, "byte length:%{public}zu", byte_length);
    
    int width;
    int height;
    napi_get_value_int32(env, args[1], &width);
    napi_get_value_int32(env, args[2], &height);
    OH_LOG_DEBUG(LogType::LOG_APP, "image size:%{public}d x %{public}d", width, height);

    // 获取模型类型（可选，默认yolov8n）
    std::string model_type = "yolov8n";
    if (argc > 3 && args[3] != nullptr) {
        model_type = value_to_string(env, args[3]);
    }
    
    // 获取透传数据（可选）
    std::string user_id = "";
    if (argc > 4 && args[4] != nullptr) {
        user_id = value_to_string(env, args[4]);
    }
    
    std::string uuid = "";
    if (argc > 5 && args[5] != nullptr) {
        uuid = value_to_string(env, args[5]);
    }
    
    std::string time_sent = "";
    if (argc > 6 && args[6] != nullptr) {
        time_sent = value_to_string(env, args[6]);
    }
    
    OH_LOG_DEBUG(LogType::LOG_APP, "model:%{public}s, userId:%{public}s", 
                 model_type.c_str(), user_id.c_str());

    ncnn::Mat input = ncnn::Mat(width, height, 4, data);
    OH_LOG_DEBUG(LogType::LOG_APP, "mat size:%{public}d x %{public}d x %{public}d", input.w, input.h, input.c);

    // 执行推理，传入透传数据
    std::vector<yolo::BoxInfo> objects;
    objects = g_yolov8->run(input, width, height, model_type.c_str(), 
                           user_id.c_str(), uuid.c_str(), time_sent.c_str());

    napi_value js_array;
    napi_create_array_with_length(env, objects.size(), &js_array);
    for (size_t i = 0; i < objects.size(); i++) {
        napi_value js_box = convert_boxinfo_to_js_yolo(env, objects[i]);
        napi_set_element(env, js_array, i, js_box);
    }

    return js_array;
}

// --------------------------------------------[ yolov8 end ]--------------------------------------------

// --------------------------------------------[ benchmark start ]--------------------------------------------

static const std::map<std::string, int> g_models_size = {
    // {"YOLOv4-tiny", 416},  // YOLOv4已移除
    {"nanodet-m", 320},
    {"yolov8n", 640},
    {"yolov8s", 640},
    {"yolov8m", 640},
    {"yolov8l", 640},
    {"yolov8x", 640},
};

napi_value convert_benchmark_to_js(napi_env env, const benchmark::BenchmarkResult &result) {
    napi_value js_object;
    napi_create_object(env, &js_object);

    napi_value kloop, kmin, kmax, kavg, kwidth, kheight;
    napi_create_string_utf8(env, "loop", NAPI_AUTO_LENGTH, &kloop);
    napi_create_string_utf8(env, "min", NAPI_AUTO_LENGTH, &kmin);
    napi_create_string_utf8(env, "max", NAPI_AUTO_LENGTH, &kmax);
    napi_create_string_utf8(env, "avg", NAPI_AUTO_LENGTH, &kavg);
    napi_create_string_utf8(env, "width", NAPI_AUTO_LENGTH, &kwidth);
    napi_create_string_utf8(env, "height", NAPI_AUTO_LENGTH, &kheight);

    napi_value loop, min, max, avg, width, height;
    napi_create_double(env, result.loop, &loop);
    napi_create_double(env, result.min, &min);
    napi_create_double(env, result.max, &max);
    napi_create_double(env, result.avg, &avg);
    napi_create_double(env, result.width, &width);
    napi_create_int32(env, result.height, &height);

    napi_set_property(env, js_object, kloop, loop);
    napi_set_property(env, js_object, kmin, min);
    napi_set_property(env, js_object, kmax, max);
    napi_set_property(env, js_object, kavg, avg);
    napi_set_property(env, js_object, kwidth, width);
    napi_set_property(env, js_object, kheight, height);

    return js_object;
}

static napi_value BenchmarkNCNN(napi_env env, napi_callback_info info) {
    size_t argc = 6;
    napi_value args[6] = {nullptr};
    // 获取参数信息
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value str0 = args[0];
    std::string sanbox_path = value_to_string(env, str0);
    napi_value str1 = args[1];
    std::string model_name = value_to_string(env, str1);
    napi_value str2 = args[2];
    std::string param_name = value_to_string(env, str2);
    OH_LOG_DEBUG(LogType::LOG_APP, "sanbox path:%{public}s, model name:%{public}s, param name:%{public}s",
                 sanbox_path.c_str(), model_name.c_str(), param_name.c_str());

    // 参数
    ncnn::Option option = get_option_from_napi(env, args[3], args[4]);

    int loop;
    napi_get_value_int32(env, args[5], &loop);
    
    double time_min = 0;
    double time_max = 0;
    double time_avg = 0;
    int input_width = 0, input_height = 0;
    benchmark::BenchmarkNet net;
    benchmark::DataReaderFromEmpty dr;
    net.opt = option;
    std::string model_path = sanbox_path + "/" + param_name;
    OH_LOG_DEBUG(LogType::LOG_APP, "model path:%{public}s", model_path.c_str());
    int rp = net.load_param(model_path.c_str());
    int rm = net.load_model(dr);
    OH_LOG_DEBUG(LogType::LOG_APP, "benchmark load:%{public}d %{public}d", rp, rm);
    benchmark::BenchmarkResult benchmarkResult =
        net.run(loop, time_min, time_max, time_avg, input_width, input_height, g_models_size.at(model_name));
    net.clear();

    OH_LOG_DEBUG(LogType::LOG_APP, "benchmark min:%{public}f max:%{public}f avg:%{public}f", time_min, time_max,
                 time_avg);

    napi_value js_result = convert_benchmark_to_js(env, benchmarkResult);

    return js_result;
}

// --------------------------------------------[ benchmark end ]--------------------------------------------


// ==========================================================================================================
// ============================================[  ncnn api end  ]============================================
// ==========================================================================================================


EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
//         DECLARE_NAPI_FUNCTION("ncnn_version", NcnnVersion), // 声明文件 Index.d.ts 会报红，实际是能运行的
        {"ncnn_version", nullptr, NcnnVersion, nullptr, nullptr, nullptr, napi_default, nullptr},
        // YOLOv4已移除
        // {"yolov4_tiny_init", nullptr, YOLOv4TinyInit, nullptr, nullptr, nullptr, napi_default, nullptr},
        // {"yolov4_tiny_run", nullptr, YOLOv4TinyRun, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"nanodet_init", nullptr, NanoDetInit, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"nanodet_run", nullptr, NanoDetRun, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"yolov8_init", nullptr, YOLOv8Init, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"yolov8_run", nullptr, YOLOv8Run, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"benchmark_ncnn", nullptr, BenchmarkNCNN, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module tncnnModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "tncnn",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterTncnnModule(void) { napi_module_register(&tncnnModule); }
