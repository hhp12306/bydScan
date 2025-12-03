# YOLOv8 升级指南

## 📋 目录
1. [模型准备](#1-模型准备)
2. [C++层实现](#2-c层实现)
3. [NAPI接口集成](#3-napi接口集成)
4. [ArkTS层更新](#4-arkts层更新)
5. [测试验证](#5-测试验证)

---

## 1. 模型准备

### 1.1 下载YOLOv8模型
从Ultralytics官方下载YOLOv8模型（.pt格式）：
- YOLOv8n (nano) - 最小最快
- YOLOv8s (small) - 平衡
- YOLOv8m (medium) - 中等
- YOLOv8l (large) - 较大
- YOLOv8x (xlarge) - 最大最准确

### 1.2 转换为NCNN格式

#### 方法1：使用pnnx（推荐）
```bash
# 1. 安装pnnx
pip install ncnn pnnx

# 2. 导出ONNX格式
python -c "from ultralytics import YOLO; model = YOLO('yolov8n.pt'); model.export(format='onnx')"

# 3. 使用pnnx转换为NCNN
pnnx yolov8n.onnx inputshape=[1,3,640,640]

# 得到文件：
# - yolov8n.ncnn.param
# - yolov8n.ncnn.bin
```

#### 方法2：使用onnx2ncnn
```bash
# 1. 导出ONNX
python -c "from ultralytics import YOLO; model = YOLO('yolov8n.pt'); model.export(format='onnx')"

# 2. 使用onnx2ncnn转换
onnx2ncnn yolov8n.onnx yolov8n.param yolov8n.bin

# 注意：可能需要手动修改param文件中的输出层名称
```

### 1.3 准备配置文件（可选）
创建 `yolov8n.yaml` 配置文件（用于类别名称）：
```yaml
names:
  0: person
  1: bicycle
  2: car
  # ... 其他类别
```

### 1.4 放置模型文件
将转换后的文件放到项目：
```
tncnn/src/main/resources/rawfile/models/
  - yolov8n.param
  - yolov8n.bin
  - yolov8n.yaml (可选)
```

---

## 2. C++层实现

### 2.1 创建 yolov8.h
✅ **已完成** - 文件已创建在 `tncnn/src/main/cpp/yolov8.h`

### 2.2 创建 yolov8.cpp
✅ **已完成** - 文件已创建在 `tncnn/src/main/cpp/yolov8.cpp`

实现的功能包括：
- ✅ 自动格式检测（DFL或直接坐标）
- ✅ 后处理（NMS）
- ✅ 坐标转换
- ✅ Letterbox预处理

### 2.3 关键实现点
- **输入尺寸**：YOLOv8通常使用640x640（已实现）
- **输出格式**：自动检测DFL格式或直接坐标（已实现）
- **输出层名称**：自动尝试 "output0", "output", "out"（已实现）

---

## 3. NAPI接口集成

✅ **已完成** - 已在 `napi_init.cpp` 中添加：
- ✅ `yolov8_init()` - 初始化函数
- ✅ `yolov8_run()` - 推理函数
- ✅ 在 `Init()` 函数中注册新接口
- ✅ 更新了benchmark模型尺寸映射

---

## 4. ArkTS层更新

### 4.1 更新 ModelList.ets
✅ **已完成** - 已添加YOLOv8n和YOLOv8s模型配置

### 4.2 更新 PhotoPage.ets 和 CameraPage.ets
✅ **已完成** - 已在模型选择和处理逻辑中添加YOLOv8支持

### 4.3 更新 TypeScript声明文件
✅ **已完成** - 已在 `Index.d.ts` 中添加YOLOv8接口声明

---

## 5. 测试验证

### 5.1 编译项目
```bash
# 在项目根目录执行
hvigorw assembleHap --mode module -p module=entry
```

### 5.2 准备模型文件
1. 将转换好的 `yolov8n.param` 和 `yolov8n.bin` 放到：
   ```
   tncnn/src/main/resources/rawfile/models/
   ```

2. 确保文件名与ModelList.ets中的配置一致

### 5.3 运行测试
1. **基准测试**：在应用中选择YOLOv8n模型，点击"基准测试"
2. **图片检测**：选择图片，使用YOLOv8n进行检测
3. **摄像头检测**：打开摄像头页面，切换到YOLOv8n模型

### 5.4 预期结果
- ✅ 模型成功加载
- ✅ 检测结果正确显示
- ✅ 性能指标合理（YOLOv8n在640x640输入下，单次推理约50-200ms，取决于设备）

---

## ⚠️ 注意事项

1. **输出格式差异**：YOLOv8可能使用DFL格式，需要特殊解码
2. **输入尺寸**：YOLOv8默认640x640，与YOLOv4-tiny的416不同
3. **性能考虑**：YOLOv8比YOLOv4-tiny更大，推理速度可能较慢
4. **内存占用**：确保设备有足够内存

---

## 🔧 故障排查

### 问题1：模型加载失败
- 检查param和bin文件路径
- 确认文件已正确复制到rawfile目录

### 问题2：检测结果异常
- 检查输出层名称是否正确
- 确认输出格式解码逻辑正确

### 问题3：性能问题
- 尝试使用更小的模型（YOLOv8n）
- 调整输入尺寸
- 优化NMS阈值

