#include "yolov8.h"
#include <map>
#include <algorithm>
#include <cmath>
#include <cfloat>
#include <sstream>

#include "hilog/log.h"

#undef LOG_TAG
#define LOG_TAG "Tncnn"

namespace yolo {

// COCO类别名称（80类）
static const std::map<int, std::string> COCO_LABELS = {
    {0, "person"}, {1, "bicycle"}, {2, "car"}, {3, "motorcycle"}, {4, "airplane"},
    {5, "bus"}, {6, "train"}, {7, "truck"}, {8, "boat"}, {9, "traffic light"},
    {10, "fire hydrant"}, {11, "stop sign"}, {12, "parking meter"}, {13, "bench"}, {14, "bird"},
    {15, "cat"}, {16, "dog"}, {17, "horse"}, {18, "sheep"}, {19, "cow"},
    {20, "elephant"}, {21, "bear"}, {22, "zebra"}, {23, "giraffe"}, {24, "backpack"},
    {25, "umbrella"}, {26, "handbag"}, {27, "tie"}, {28, "suitcase"}, {29, "frisbee"},
    {30, "skis"}, {31, "snowboard"}, {32, "sports ball"}, {33, "kite"}, {34, "baseball bat"},
    {35, "baseball glove"}, {36, "skateboard"}, {37, "surfboard"}, {38, "tennis racket"}, {39, "bottle"},
    {40, "wine glass"}, {41, "cup"}, {42, "fork"}, {43, "knife"}, {44, "spoon"},
    {45, "bowl"}, {46, "banana"}, {47, "apple"}, {48, "sandwich"}, {49, "orange"},
    {50, "broccoli"}, {51, "carrot"}, {52, "hot dog"}, {53, "pizza"}, {54, "donut"},
    {55, "cake"}, {56, "chair"}, {57, "couch"}, {58, "potted plant"}, {59, "bed"},
    {60, "dining table"}, {61, "toilet"}, {62, "tv"}, {63, "laptop"}, {64, "mouse"},
    {65, "remote"}, {66, "keyboard"}, {67, "cell phone"}, {68, "microwave"}, {69, "oven"},
    {70, "toaster"}, {71, "sink"}, {72, "refrigerator"}, {73, "book"}, {74, "clock"},
    {75, "vase"}, {76, "scissors"}, {77, "teddy bear"}, {78, "hair drier"}, {79, "toothbrush"}
};

// SNHA标签映射表（类别ID -> 物料编码）
static const std::map<int, std::string> SNHA_LABEL_DICT = {
    {0, "DTUM2437761"},  // person
    {1, "DTUM2437762"},  // bicycle
    {2, "DTUM2437763"},  // car
    // 根据实际业务需求添加更多映射
};

// SNHA图像级标签映射
static const std::map<int, std::string> SNHA_IMAGE_LABEL = {
    {0, "IMG_PERSON"},
    {1, "IMG_VEHICLE"},
    {2, "IMG_VEHICLE"},
    // 根据实际业务需求添加更多映射
};

YOLOv8::YOLOv8() {
    target_size = 640;
    num_classes = 80;
    reg_max = 16;
    conf_threshold = 0.25f;
    nms_threshold = 0.45f;
    output_format = FORMAT_UNKNOWN;
}

YOLOv8::~YOLOv8() {
    net.clear();
}

inline float YOLOv8::sigmoid(float x) {
    return 1.0f / (1.0f + expf(-x));
}

int YOLOv8::init(ncnn::Option option, const char *param, const char *model, const char *modeltype) {
    net.opt = option;

    // YOLOv8的配置映射
    const std::map<std::string, int> _target_sizes = {
        {"yolov8n", 640},
        {"yolov8s", 640},
        {"yolov8m", 640},
        {"yolov8l", 640},
        {"yolov8x", 640},
    };

    // YOLOv8使用ImageNet归一化
    const std::map<std::string, std::vector<float>> _mean_vals = {
        {"yolov8n", {0.0f, 0.0f, 0.0f}},
        {"yolov8s", {0.0f, 0.0f, 0.0f}},
        {"yolov8m", {0.0f, 0.0f, 0.0f}},
        {"yolov8l", {0.0f, 0.0f, 0.0f}},
        {"yolov8x", {0.0f, 0.0f, 0.0f}},
    };

    const std::map<std::string, std::vector<float>> _norm_vals = {
        {"yolov8n", {1 / 255.f, 1 / 255.f, 1 / 255.f}},
        {"yolov8s", {1 / 255.f, 1 / 255.f, 1 / 255.f}},
        {"yolov8m", {1 / 255.f, 1 / 255.f, 1 / 255.f}},
        {"yolov8l", {1 / 255.f, 1 / 255.f, 1 / 255.f}},
        {"yolov8x", {1 / 255.f, 1 / 255.f, 1 / 255.f}},
    };

    // 设置模型参数
    if (_target_sizes.find(modeltype) != _target_sizes.end()) {
        target_size = _target_sizes.at(modeltype);
        mean_vals[0] = _mean_vals.at(modeltype)[0];
        mean_vals[1] = _mean_vals.at(modeltype)[1];
        mean_vals[2] = _mean_vals.at(modeltype)[2];
        norm_vals[0] = _norm_vals.at(modeltype)[0];
        norm_vals[1] = _norm_vals.at(modeltype)[1];
        norm_vals[2] = _norm_vals.at(modeltype)[2];
    } else {
        // 默认值
        target_size = 640;
        mean_vals[0] = mean_vals[1] = mean_vals[2] = 0.0f;
        norm_vals[0] = norm_vals[1] = norm_vals[2] = 1 / 255.f;
    }

    OH_LOG_DEBUG(LogType::LOG_APP, "load param:%{public}s", param);
    OH_LOG_DEBUG(LogType::LOG_APP, "load bin:%{public}s", model);

    // 加载模型
    int pr, mr;
    pr = net.load_param(param);
    mr = net.load_model(model);

    if (pr != 0 || mr != 0) {
        OH_LOG_DEBUG(LogType::LOG_APP, "load param:%{public}d, load model:%{public}d", pr, mr);
        return 0;
    }

    OH_LOG_DEBUG(LogType::LOG_APP, "load success");

    // 自动检测输出格式
    output_format = detect_output_format();
    OH_LOG_DEBUG(LogType::LOG_APP, "detected output format:%{public}d", output_format);

    return 1;
}

YOLOv8::OutputFormat YOLOv8::detect_output_format() {
    // 创建一个虚拟输入来检测输出格式
    ncnn::Mat dummy_input = ncnn::Mat::from_pixels_resize(
        nullptr, ncnn::Mat::PIXEL_RGB, target_size, target_size, target_size, target_size);
    dummy_input.fill(0.5f);
    dummy_input.substract_mean_normalize(mean_vals, norm_vals);

    ncnn::Extractor ex = net.create_extractor();
    
    // 尝试常见的输入层名称
    const char* input_names[] = {"images", "data", "input", "input.1"};
    bool input_set = false;
    for (const char* name : input_names) {
        if (net.find_blob_index(name) >= 0) {
            ex.input(name, dummy_input);
            input_set = true;
            OH_LOG_DEBUG(LogType::LOG_APP, "using input layer: %{public}s", name);
            break;
        }
    }
    
    if (!input_set) {
        OH_LOG_DEBUG(LogType::LOG_APP, "warning: using default input");
        ex.input("images", dummy_input);
    }

    // 尝试常见的输出层名称
    ncnn::Mat output;
    const char* output_names[] = {"output0", "output", "out"};
    bool output_extracted = false;
    for (const char* name : output_names) {
        if (net.find_blob_index(name) >= 0) {
            ex.extract(name, output);
            output_extracted = true;
            OH_LOG_DEBUG(LogType::LOG_APP, "using output layer: %{public}s", name);
            break;
        }
    }
    
    if (!output_extracted) {
        OH_LOG_DEBUG(LogType::LOG_APP, "warning: using default output");
        ex.extract("output0", output);
    }

    // 检测输出格式
    // YOLOv8输出通常是 [1, 84, 8400] 或 [1, 4+num_classes, num_anchors]
    // 84 = 4*16(DFL) + 80(classes) 或 4 + 80 = 84
    int channels = output.c;
    int height = output.h;
    int width = output.w;

    OH_LOG_DEBUG(LogType::LOG_APP, "output shape: %{public}d x %{public}d x %{public}d", width, height, channels);

    // 判断格式
    if (channels == 4 + num_classes) {
        // 直接坐标格式: [x, y, w, h, class_scores...]
        return FORMAT_DIRECT_COORDS;
    } else if (channels >= 64 + num_classes) {
        // DFL格式: [distance_distribution(16*4=64), class_scores...]
        reg_max = (channels - num_classes) / 4;
        OH_LOG_DEBUG(LogType::LOG_APP, "DFL format detected, reg_max:%{public}d", reg_max);
        return FORMAT_DFL;
    } else {
        // 可能是其他格式，尝试直接坐标
        OH_LOG_DEBUG(LogType::LOG_APP, "unknown format, using direct coords");
        return FORMAT_DIRECT_COORDS;
    }
}

std::vector<BoxInfo> YOLOv8::run(ncnn::Mat &data, int img_w, int img_h, const char *modeltype,
                                 const char *user_id, const char *uuid, const char *time_sent) {
    // Letterbox预处理
    float scale = std::min((float)target_size / img_w, (float)target_size / img_h);
    int w = (int)(img_w * scale);
    int h = (int)(img_h * scale);
    
    // 计算padding
    int wpad = target_size - w;
    int hpad = target_size - h;
    int left_pad = wpad / 2;
    int top_pad = hpad / 2;

    // 缩放图像
    ncnn::Mat resize_input = ncnn::Mat::from_pixels_resize(
        data, ncnn::Mat::PIXEL_RGBA2RGB, img_w, img_h, w, h);

    // Padding
    ncnn::Mat in_pad;
    ncnn::copy_make_border(resize_input, in_pad, top_pad, hpad - top_pad, 
                          left_pad, wpad - left_pad, ncnn::BORDER_CONSTANT, 0.f);

    // 归一化
    in_pad.substract_mean_normalize(mean_vals, norm_vals);

    // 推理
    ncnn::Extractor ex = net.create_extractor();
    
    // 设置输入
    const char* input_names[] = {"images", "data", "input", "input.1"};
    bool input_set = false;
    for (const char* name : input_names) {
        if (net.find_blob_index(name) >= 0) {
            ex.input(name, in_pad);
            input_set = true;
            break;
        }
    }
    if (!input_set) {
        ex.input("images", in_pad);
    }

    // 获取输出
    ncnn::Mat output;
    const char* output_names[] = {"output0", "output", "out"};
    bool output_extracted = false;
    for (const char* name : output_names) {
        if (net.find_blob_index(name) >= 0) {
            ex.extract(name, output);
            output_extracted = true;
            break;
        }
    }
    if (!output_extracted) {
        ex.extract("output0", output);
    }

    // 计算缩放比例（用于坐标转换）
    float scale_x = (float)img_w / target_size;
    float scale_y = (float)img_h / target_size;

    // 根据格式解码
    std::vector<BoxInfo> boxes;
    if (output_format == FORMAT_DIRECT_COORDS) {
        boxes = decode_direct_coords(output, img_w, img_h, scale_x, scale_y);
    } else if (output_format == FORMAT_DFL) {
        boxes = decode_dfl(output, img_w, img_h, scale_x, scale_y);
    }

    // NMS
    nms(boxes, nms_threshold);

    // 判断是否使用SNHA标签映射
    bool use_snha = (user_id != nullptr && std::string(user_id) == "SNHA");
    
    // 为每个检测结果添加增强信息
    for (auto &box : boxes) {
        // 计算中心点坐标
        box.x_center = (box.x1 + box.x2) / 2.0f;
        box.y_center = (box.y1 + box.y2) / 2.0f;
        
        // 设置标签名称
        if (use_snha && SNHA_LABEL_DICT.find(box.label) != SNHA_LABEL_DICT.end()) {
            // 使用SNHA物料编码
            box.label_name = SNHA_LABEL_DICT.at(box.label);
            
            // 设置图像级标签
            if (SNHA_IMAGE_LABEL.find(box.label) != SNHA_IMAGE_LABEL.end()) {
                box.imglabel = SNHA_IMAGE_LABEL.at(box.label);
            } else {
                box.imglabel = "IMG_UNKNOWN";
            }
        } else {
            // 使用COCO标准类别名称
            if (COCO_LABELS.find(box.label) != COCO_LABELS.end()) {
                box.label_name = COCO_LABELS.at(box.label);
            } else {
                box.label_name = "unknown";
            }
            box.imglabel = "";
        }
        
        // 设置透传数据
        box.uuid = (uuid != nullptr) ? std::string(uuid) : "";
        box.time_sent = (time_sent != nullptr) ? std::string(time_sent) : "";
    }

    return boxes;
}

std::vector<BoxInfo> YOLOv8::decode_direct_coords(ncnn::Mat &output, int img_w, int img_h, 
                                                   float scale_x, float scale_y) {
    std::vector<BoxInfo> boxes;
    
    // YOLOv8输出格式: [x_center, y_center, width, height, class_scores...]
    // 输出shape通常是 [1, 84, 8400] 或 [8400, 84]
    int num_detections = output.h > 1 ? output.h : output.w;
    int channels = output.c;

    for (int i = 0; i < num_detections; i++) {
        const float* ptr = output.channel(0).row(i);
        if (output.dims == 3 && output.h > 1) {
            ptr = output.channel(0).row(i);
        } else if (output.dims == 2) {
            ptr = output.row(i);
        }

        // 获取坐标（相对于输入尺寸640x640）
        float x_center = ptr[0];
        float y_center = ptr[1];
        float width = ptr[2];
        float height = ptr[3];

        // 找到最大类别分数
        float max_score = 0;
        int max_class = 0;
        for (int j = 0; j < num_classes; j++) {
            float score = sigmoid(ptr[4 + j]);
            if (score > max_score) {
                max_score = score;
                max_class = j;
            }
        }

        // 过滤低置信度
        if (max_score < conf_threshold) {
            continue;
        }

        // 转换为边界框坐标
        float x1 = (x_center - width / 2) * scale_x;
        float y1 = (y_center - height / 2) * scale_y;
        float x2 = (x_center + width / 2) * scale_x;
        float y2 = (y_center + height / 2) * scale_y;

        // 裁剪到图像范围
        x1 = std::max(0.f, std::min(x1, (float)img_w));
        y1 = std::max(0.f, std::min(y1, (float)img_h));
        x2 = std::max(0.f, std::min(x2, (float)img_w));
        y2 = std::max(0.f, std::min(y2, (float)img_h));

        if (x2 > x1 && y2 > y1) {
            boxes.push_back(BoxInfo{x1, y1, x2, y2, max_score, max_class});
        }
    }

    return boxes;
}

std::vector<BoxInfo> YOLOv8::decode_dfl(ncnn::Mat &output, int img_w, int img_h, 
                                        float scale_x, float scale_y) {
    std::vector<BoxInfo> boxes;
    
    // DFL格式: [distance_distribution(reg_max*4), class_scores...]
    int num_detections = output.h > 1 ? output.h : output.w;
    
    for (int i = 0; i < num_detections; i++) {
        const float* ptr = output.channel(0).row(i);
        if (output.dims == 2) {
            ptr = output.row(i);
        }

        // 解码DFL距离
        float distances[4];
        for (int d = 0; d < 4; d++) {
            float sum = 0;
            float max_val = -FLT_MAX;
            
            // 找到最大值（用于数值稳定性）
            for (int j = 0; j < reg_max; j++) {
                max_val = std::max(max_val, ptr[d * reg_max + j]);
            }
            
            // Softmax并计算期望
            float exp_sum = 0;
            float weighted_sum = 0;
            for (int j = 0; j < reg_max; j++) {
                float exp_val = expf(ptr[d * reg_max + j] - max_val);
                exp_sum += exp_val;
                weighted_sum += j * exp_val;
            }
            
            distances[d] = weighted_sum / exp_sum;
        }

        // 获取类别分数
        float max_score = 0;
        int max_class = 0;
        int class_offset = reg_max * 4;
        for (int j = 0; j < num_classes; j++) {
            float score = sigmoid(ptr[class_offset + j]);
            if (score > max_score) {
                max_score = score;
                max_class = j;
            }
        }

        // 过滤低置信度
        if (max_score < conf_threshold) {
            continue;
        }

        // 计算边界框（这里需要知道anchor位置，简化处理）
        // 注意：实际DFL解码需要结合anchor grid
        // 这里提供简化版本
        float x1 = distances[0] * scale_x;
        float y1 = distances[1] * scale_y;
        float x2 = distances[2] * scale_x;
        float y2 = distances[3] * scale_y;

        // 裁剪
        x1 = std::max(0.f, std::min(x1, (float)img_w));
        y1 = std::max(0.f, std::min(y1, (float)img_h));
        x2 = std::max(0.f, std::min(x2, (float)img_w));
        y2 = std::max(0.f, std::min(y2, (float)img_h));

        if (x2 > x1 && y2 > y1) {
            BoxInfo box;
            box.x1 = x1;
            box.y1 = y1;
            box.x2 = x2;
            box.y2 = y2;
            box.x_center = 0;  // 将在run函数中计算
            box.y_center = 0;
            box.score = max_score;
            box.label = max_class;
            box.label_name = "";  // 将在run函数中设置
            box.uuid = "";
            box.time_sent = "";
            box.imglabel = "";
            boxes.push_back(box);
        }
    }

    return boxes;
}

void YOLOv8::nms(std::vector<BoxInfo> &boxes, float nms_threshold) {
    if (boxes.empty()) {
        return;
    }

    // 按分数排序
    std::sort(boxes.begin(), boxes.end(), 
              [](const BoxInfo &a, const BoxInfo &b) { return a.score > b.score; });

    std::vector<BoxInfo> keep;
    std::vector<bool> suppressed(boxes.size(), false);

    for (size_t i = 0; i < boxes.size(); i++) {
        if (suppressed[i]) {
            continue;
        }

        keep.push_back(boxes[i]);

        float area_i = (boxes[i].x2 - boxes[i].x1) * (boxes[i].y2 - boxes[i].y1);

        for (size_t j = i + 1; j < boxes.size(); j++) {
            if (suppressed[j] || boxes[i].label != boxes[j].label) {
                continue;
            }

            // 计算IoU
            float x1 = std::max(boxes[i].x1, boxes[j].x1);
            float y1 = std::max(boxes[i].y1, boxes[j].y1);
            float x2 = std::min(boxes[i].x2, boxes[j].x2);
            float y2 = std::min(boxes[i].y2, boxes[j].y2);

            float w = std::max(0.f, x2 - x1);
            float h = std::max(0.f, y2 - y1);
            float inter = w * h;

            float area_j = (boxes[j].x2 - boxes[j].x1) * (boxes[j].y2 - boxes[j].y1);
            float iou = inter / (area_i + area_j - inter);

            if (iou > nms_threshold) {
                suppressed[j] = true;
            }
        }
    }

    boxes = keep;
}

} // namespace yolo

