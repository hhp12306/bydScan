#ifndef YOLOV8_H
#define YOLOV8_H

#include "net.h"
#include <string>
#include <vector>

namespace yolo {

// 增强的检测结果结构
typedef struct BoxInfo {
    // 边界框坐标
    float x1;
    float y1;
    float x2;
    float y2;
    float x_center;           // 中心点X坐标
    float y_center;           // 中心点Y坐标
    
    // 检测结果信息
    float score;              // 置信度
    int label;                // 类别ID
    std::string label_name;   // 类别名称（可能是SNHA物料编码）
    
    // 透传数据
    std::string uuid;         // 唯一ID
    std::string time_sent;    // 时间戳
    std::string imglabel;     // 图像级标签
} BoxInfo;

class YOLOv8 {
public:
    YOLOv8();
    ~YOLOv8();

    // 初始化模型
    // option: NCNN配置选项
    // param: .param文件路径
    // model: .bin文件路径
    // modeltype: 模型类型（如"yolov8n", "yolov8s"等）
    int init(ncnn::Option option, const char *param, const char *model, const char *modeltype);

    // 执行推理
    // data: 输入图像数据（RGBA格式）
    // img_w: 图像宽度
    // img_h: 图像高度
    // modeltype: 模型类型
    // user_id: 用户ID（用于SNHA标签映射）
    // uuid: 唯一ID（透传）
    // time_sent: 时间戳（透传）
    std::vector<BoxInfo> run(ncnn::Mat &data, int img_w, int img_h, const char *modeltype,
                            const char *user_id = "", const char *uuid = "", const char *time_sent = "");

private:
    // 自动检测输出格式
    enum OutputFormat {
        FORMAT_UNKNOWN = 0,
        FORMAT_DIRECT_COORDS = 1,  // 直接坐标格式: [x, y, w, h, scores...]
        FORMAT_DFL = 2              // DFL格式: [distance_distribution, scores...]
    };

    // 检测输出格式
    OutputFormat detect_output_format();

    // 解码直接坐标格式
    std::vector<BoxInfo> decode_direct_coords(ncnn::Mat &output, int img_w, int img_h, float scale_x, float scale_y);

    // 解码DFL格式
    std::vector<BoxInfo> decode_dfl(ncnn::Mat &output, int img_w, int img_h, float scale_x, float scale_y);

    // NMS非极大值抑制
    static void nms(std::vector<BoxInfo> &boxes, float nms_threshold);

    // 快速sigmoid函数
    inline float sigmoid(float x);

    ncnn::Net net;
    int target_size;              // 目标输入尺寸（YOLOv8通常为640）
    float mean_vals[3];            // 均值
    float norm_vals[3];            // 归一化值
    int num_classes;               // 类别数量（默认80）
    OutputFormat output_format;    // 检测到的输出格式
    int reg_max;                   // DFL格式的reg_max值（通常为16）
    float conf_threshold;          // 置信度阈值
    float nms_threshold;           // NMS阈值
};

} // namespace yolo

#endif // YOLOV8_H


