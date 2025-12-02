# OpenCV 应用样例开发指南

## 概述

本项目包含了一个完整的 OpenCV 图像处理应用样例，演示了如何在 HarmonyOS 应用中使用 OpenCV 进行图像处理。

## 项目结构

```
entry/src/main/
├── cpp/
│   ├── opencv_demo.cpp          # OpenCV C++ 实现文件
│   ├── CMakeLists.txt           # CMake 构建配置
│   └── types/
│       └── libopencv/
│           ├── index.d.ts       # TypeScript 类型定义
│           └── oh-package.json5 # 模块配置
└── ets/
    └── pages/
        └── OpenCVDemo.ets       # OpenCV 演示页面 UI
```

## 功能特性

当前实现的 OpenCV 功能包括：

1. **获取 OpenCV 版本信息** - `getOpenCVVersion()`
2. **图像灰度转换** - `convertToGrayscale(imagePath)`
3. **边缘检测（Canny算法）** - `detectEdges(imagePath, lowThreshold, highThreshold)`
4. **高斯模糊** - `blurImage(imagePath, blurRadius)`
5. **图像统计信息** - `getImageStats()`
6. **图像缩放** - `resizeImage(imagePath, width, height)`

## 使用方法

### 1. 在 ArkTS 中导入模块

```typescript
import libOpenCV from 'libopencv.so'
```

### 2. 调用 OpenCV 功能

```typescript
// 获取 OpenCV 版本
const version = libOpenCV.getOpenCVVersion()

// 转换为灰度图
const result = libOpenCV.convertToGrayscale('/path/to/image.jpg')

// 边缘检测
const edges = libOpenCV.detectEdges('/path/to/image.jpg', 50, 150)

// 图像模糊
const blurred = libOpenCV.blurImage('/path/to/image.jpg', 5)

// 获取图像统计信息
const stats = libOpenCV.getImageStats()
console.log(`宽度: ${stats.width}, 高度: ${stats.height}, 通道: ${stats.channels}`)

// 图像缩放
const resized = libOpenCV.resizeImage('/path/to/image.jpg', 640, 480)
```

## 配置 OpenCV 库

### 当前状态

当前代码是**示例实现**，不依赖实际的 OpenCV 库，可以直接编译运行。代码中包含了详细的注释，展示了如何使用 OpenCV API。

### 集成实际 OpenCV 库

如果需要使用实际的 OpenCV 库，需要执行以下步骤：

#### 1. 安装 OpenCV for HarmonyOS

- 下载 HarmonyOS 版本的 OpenCV SDK
- 将 OpenCV 库文件放置到项目的 `libs` 目录

#### 2. 更新 CMakeLists.txt

取消注释以下行并配置正确的路径：

```cmake
# 查找 OpenCV 包
find_package(OpenCV REQUIRED)

# 添加 OpenCV 头文件路径
target_include_directories(opencv PRIVATE ${OpenCV_INCLUDE_DIRS})

# 链接 OpenCV 库
target_link_libraries(opencv PUBLIC ${OpenCV_LIBS})
```

#### 3. 启用 OpenCV 代码

在 `opencv_demo.cpp` 中取消注释 OpenCV 相关的头文件：

```cpp
#include <opencv2/opencv.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
using namespace cv;
```

并取消注释实际的图像处理代码。

## 运行演示

1. 启动应用后，在主页面点击 **"OpenCV 图像处理演示"** 按钮
2. 进入 OpenCV 演示页面
3. 点击各个功能按钮测试不同的图像处理功能

## 注意事项

1. **图像路径**：当前示例使用模拟路径，实际使用时需要提供真实的图像文件路径
2. **OpenCV 版本**：确保使用的 OpenCV 版本与 HarmonyOS SDK 兼容
3. **权限**：访问设备上的图像文件可能需要相应的权限配置
4. **性能**：图像处理操作可能比较耗时，建议在后台线程中执行

## 扩展功能

可以基于此示例添加更多 OpenCV 功能：

- 图像旋转和翻转
- 颜色空间转换
- 图像滤波（中值滤波、双边滤波等）
- 形态学操作（腐蚀、膨胀等）
- 特征检测（角点检测、轮廓检测等）
- 图像分割
- 模板匹配

## 技术栈

- **HarmonyOS ArkTS** - UI 开发
- **C++** - 核心图像处理逻辑
- **NAPI** - JavaScript 与 C++ 的桥接
- **OpenCV** - 图像处理库（可选）

## 开发说明

代码中包含了详细的注释，说明了每个步骤的作用。遵循了 HarmonyOS 开发最佳实践，包括：

- 清晰的模块划分
- 完整的类型定义
- 错误处理
- 用户友好的 UI 设计

## 许可证

Copyright (c) 2022 Huawei Device Co., Ltd.
Licensed under the Apache License, Version 2.0

