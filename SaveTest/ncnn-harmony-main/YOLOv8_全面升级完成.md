# YOLOv8 全面升级完成报告

## ✅ 已完成的功能

### 1. 增强的数据结构

#### C++ 层 (BoxInfo)
```cpp
typedef struct BoxInfo {
    // 边界框坐标
    float x1, y1, x2, y2;
    float x_center;           // 中心点X坐标 ✅
    float y_center;           // 中心点Y坐标 ✅
    
    // 检测结果信息
    float score;              // 置信度
    int label;                // 类别ID
    std::string label_name;   // 类别名称（支持SNHA物料编码）✅
    
    // 透传数据
    std::string uuid;         // 唯一ID ✅
    std::string time_sent;    // 时间戳 ✅
    std::string imglabel;     // 图像级标签 ✅
} BoxInfo;
```

#### ArkTS 层 (IBoxInfo)
```typescript
export interface IBoxInfo {
  // 边界框坐标
  x1: number
  y1: number
  x2: number
  y2: number
  x_center: number      // 中心点X坐标 ✅
  y_center: number      // 中心点Y坐标 ✅
  
  // 检测结果信息
  label: number         // 类别ID
  labelName: string     // 类别名称 ✅
  score: number         // 置信度
  
  // 透传数据
  uuid?: string         // 唯一ID ✅
  timeSent?: string     // 时间戳 ✅
  imglabel?: string     // 图像级标签 ✅
}
```

### 2. SNHA标签映射

#### 标签映射表
```cpp
// SNHA标签映射表（类别ID -> 物料编码）
static const std::map<int, std::string> SNHA_LABEL_DICT = {
    {0, "DTUM2437761"},  // person
    {1, "DTUM2437762"},  // bicycle
    {2, "DTUM2437763"},  // car
    // 可根据业务需求添加更多映射
};

// SNHA图像级标签映射
static const std::map<int, std::string> SNHA_IMAGE_LABEL = {
    {0, "IMG_PERSON"},
    {1, "IMG_VEHICLE"},
    {2, "IMG_VEHICLE"},
    // 可根据业务需求添加更多映射
};
```

#### 使用方式
```typescript
// 普通模式（使用COCO标准类别名称）
const boxInfos = tncnn.yolov8_run(
  imgData, imgWidth, imgHeight, 
  'yolov8n', 
  '',  // userId为空或非"SNHA"
  uuid, timeSent
)
// 结果：labelName = "person", "car" 等

// SNHA模式（使用物料编码）
const boxInfos = tncnn.yolov8_run(
  imgData, imgWidth, imgHeight, 
  'yolov8n', 
  'SNHA',  // userId设置为"SNHA"
  uuid, timeSent
)
// 结果：labelName = "DTUM2437761", imglabel = "IMG_PERSON"
```

### 3. 自动格式检测

YOLOv8实现会自动检测模型输出格式：

- **直接坐标格式**: `[x_center, y_center, width, height, class_scores...]`
- **DFL格式**: `[distance_distribution(reg_max*4), class_scores...]`

无需手动配置，代码会在初始化时自动识别。

### 4. 透传数据支持

#### NAPI接口
```cpp
std::vector<BoxInfo> YOLOv8::run(
    ncnn::Mat &data, int img_w, int img_h, 
    const char *modeltype,
    const char *user_id = "",      // 用户ID ✅
    const char *uuid = "",          // 唯一ID ✅
    const char *time_sent = ""     // 时间戳 ✅
)
```

#### ArkTS调用
```typescript
const uuid = Date.now().toString() + Math.random().toString(36).substring(7)
const timeSent = new Date().toISOString()
const userId = "SNHA"  // 或 ""

const boxInfos = tncnn.yolov8_run(
  imgData, imgWidth, imgHeight, 
  'yolov8n', 
  userId, uuid, timeSent  // 透传数据
)

// 结果中包含透传数据
console.log(boxInfos[0].uuid)      // 与输入相同
console.log(boxInfos[0].timeSent)  // 与输入相同
```

### 5. COCO类别名称支持

内置80个COCO类别名称：
```cpp
static const std::map<int, std::string> COCO_LABELS = {
    {0, "person"}, {1, "bicycle"}, {2, "car"}, ...
};
```

检测结果中的`labelName`字段会自动填充正确的类别名称。

## 📝 使用示例

### PhotoPage 使用示例
```typescript
runModel(imgData: ArrayBuffer, imgWidth: number, imgHeight: number) {
  // YOLOv8增强版
  const uuid = Date.now().toString() + Math.random().toString(36).substring(7)
  const timeSent = new Date().toISOString()
  const userId = ""  // 设置为"SNHA"可启用特殊标签映射
  
  const boxInfos: IBoxInfo[] = tncnn.yolov8_run(
    imgData, imgWidth, imgHeight, 
    this.currentModel.name,  // 'yolov8n' 或 'yolov8s'
    userId, uuid, timeSent
  )
  
  // 打印增强信息
  for (let box of boxInfos) {
    console.log(`${box.labelName}: ${box.score.toFixed(2)}`)
    console.log(`  中心点: (${box.x_center}, ${box.y_center})`)
    console.log(`  UUID: ${box.uuid}`)
  }
  
  // 绘制结果（会使用labelName显示）
  this.pixelMap = drawBox(boxInfos, this.pixelMap, imgWidth, imgHeight)
}
```

### CameraPage 使用示例
```typescript
// 在runModelFun函数中
const uuid = Date.now().toString() + Math.random().toString(36).substring(7)
const timeSent = new Date().toISOString()
const userId = ""  // 或 "SNHA"

const boxInfos: IBoxInfo[] = tncnn.yolov8_run(
  imgData, imgWidth, imgHeight, 
  modelName, 
  userId, uuid, timeSent
)
```

## 📊 对比：升级前 vs 升级后

| 功能 | 升级前 | 升级后 |
|------|-------|-------|
| **模型** | YOLOv4-tiny | YOLOv8n/s/m/l/x |
| **输出格式检测** | ❌ 手动指定 | ✅ 自动检测 |
| **类别名称** | ❌ 只有ID | ✅ labelName字段 |
| **中心点坐标** | ❌ 需要计算 | ✅ x_center, y_center |
| **SNHA标签映射** | ❌ 不支持 | ✅ 完整支持 |
| **透传数据** | ❌ 不支持 | ✅ uuid, timeSent, imglabel |
| **图像级标签** | ❌ 不支持 | ✅ imglabel字段 |

## 🔧 如何使用

### 1. 准备YOLOv8模型（必须）

```bash
# 使用转换脚本
python convert_yolov8.py yolov8n

# 或手动转换
pip install ultralytics ncnn pnnx
python -c "from ultralytics import YOLO; model = YOLO('yolov8n.pt'); model.export(format='onnx')"
pnnx yolov8n.onnx inputshape=[1,3,640,640]
```

### 2. 放置模型文件
```
tncnn/src/main/resources/rawfile/models/
  - yolov8n.param
  - yolov8n.bin
```

### 3. 启用YOLOv8

在 `ModelList.ets` 中取消YOLOv8的注释：
```typescript
export const modelList: IModelType[] = [
  {
    name: 'yolov8n',  // 取消注释
    param: 'yolov8n.param',
    bin: 'yolov8n.bin'
  },
  // ...
]
```

### 4. 编译运行
```bash
hvigorw assembleHap --mode module -p module=entry
```

## ⚙️ 配置选项

### SNHA模式配置
```typescript
// 在PhotoPage或CameraPage中
const userId = "SNHA"  // 启用SNHA标签映射
```

### 添加更多SNHA映射
在 `yolov8.cpp` 中：
```cpp
static const std::map<int, std::string> SNHA_LABEL_DICT = {
    {0, "DTUM2437761"},  // person
    {1, "DTUM2437762"},  // bicycle
    {2, "DTUM2437763"},  // car
    {3, "YOUR_CODE_HERE"},  // 添加更多映射
    // ...
};
```

## 📂 修改的文件列表

### C++ 层
- ✅ `tncnn/src/main/cpp/yolov8.h` - 增强的数据结构
- ✅ `tncnn/src/main/cpp/yolov8.cpp` - SNHA映射、透传数据
- ✅ `tncnn/src/main/cpp/napi_init.cpp` - 更新NAPI接口

### ArkTS 层
- ✅ `entry/src/main/ets/utils/DrawUtils.ets` - 增强的IBoxInfo接口
- ✅ `entry/src/main/ets/pages/PhotoPage.ets` - 支持透传数据
- ✅ `entry/src/main/ets/pages/CameraPage.ets` - 支持透传数据
- ✅ `entry/src/main/ets/model/ModelList.ets` - 模型列表调整
- ✅ `tncnn/src/main/cpp/types/libtncnn/Index.d.ts` - TypeScript声明

## 🎯 下一步

1. **准备模型文件** - 使用 `convert_yolov8.py` 转换模型
2. **启用YOLOv8** - 在ModelList.ets中取消注释
3. **测试功能** - 编译并测试所有增强功能
4. **自定义SNHA映射** - 根据业务需求修改映射表

## 📚 相关文档

- `YOLOv8_升级指南.md` - 详细升级步骤
- `如何获取YOLOv8模型.md` - 模型获取方法
- `convert_yolov8.py` - 自动转换脚本

---

所有增强功能已全部实现！🎉

