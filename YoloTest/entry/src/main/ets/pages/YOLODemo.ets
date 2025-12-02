/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import libYOLO from 'libyolo.so'

// 检测结果接口
interface DetectionResult {
  className: string;
  confidence: number;
  x: number;
  y: number;
  width: number;
  height: number;
}

@Entry
@Component
struct YOLODemo {
  // 页面标题和说明
  private title: string = 'YOLO 目标检测示例'
  private description: string = '使用 YOLO 模型进行实时目标检测'
  
  // 状态变量
  @State yoloVersion: string = '未知'
  @State modelLoaded: boolean = false
  @State detectionResults: DetectionResult[] = []
  @State detectionCount: number = 0
  @State processResult: string = '等待操作...'
  @State imagePath: string = '/data/storage/el2/base/haps/test.jpg'
  @State confidenceThreshold: number = 0.5
  
  // 图片显示相关
  @State originalImageSrc: ResourceStr = $r('app.media.background')
  @State showDetections: boolean = false
  
  // YOLO 类别列表
  @State yoloClasses: string[] = []

  // 组件构建
  build() {
    Column() {
      // 标题区域
      Row() {
        Text(this.title)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Blue)
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20, bottom: 10 })

      // 描述信息
      Row() {
        Text(this.description)
          .fontSize(18)
          .fontColor(Color.Gray)
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 20 })

      // 滚动容器
      Scroll() {
        Column({ space: 15 }) {
          // YOLO 版本信息
          this.buildInfoCard('YOLO 版本', this.yoloVersion, () => {
            try {
              this.yoloVersion = libYOLO.getYOLOVersion()
              this.processResult = `YOLO 版本: ${this.yoloVersion}`
            } catch (error) {
              const errorMsg = error instanceof Error ? error.message : String(error)
              this.processResult = `获取版本失败: ${errorMsg}`
            }
          })

          // 模型加载
          this.buildModelCard()

          // 图片显示区域（带检测框）
          this.buildImageDisplayCard()

          // 检测结果统计
          if (this.showDetections && this.detectionResults.length > 0) {
            this.buildDetectionResultsCard()
          }

          // 检测按钮
          this.buildActionButton('开始目标检测', () => {
            this.performDetection()
          })

          // 置信度阈值设置
          this.buildThresholdCard()

          // 结果显示区域
          this.buildResultCard()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 10, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 页面生命周期：页面显示时调用
  aboutToAppear() {
    // 页面加载时获取 YOLO 类别列表
    this.loadYOLOClasses()
  }

  // 加载 YOLO 类别列表
  loadYOLOClasses() {
    try {
      this.yoloClasses = libYOLO.getYOLOClasses()
      this.processResult = `已加载 ${this.yoloClasses.length} 个类别`
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error)
      this.processResult = `加载类别列表失败: ${errorMsg}`
    }
  }

  // 执行目标检测
  performDetection() {
    if (!this.modelLoaded) {
      this.processResult = '请先加载 YOLO 模型'
      return
    }

    try {
      const results = libYOLO.detectObjects(this.imagePath)
      this.detectionResults = results
      this.detectionCount = results.length
      this.showDetections = true
      
      // 过滤低置信度的检测结果
      const filteredResults = results.filter((det: DetectionResult) => 
        det.confidence >= this.confidenceThreshold
      )
      
      this.processResult = `检测完成！发现 ${filteredResults.length} 个目标`
      
      // 显示检测到的类别
      if (filteredResults.length > 0) {
        const classes = filteredResults.map((det: DetectionResult) => det.className).join(', ')
        this.processResult += `\n类别: ${classes}`
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error)
      this.processResult = `目标检测失败: ${errorMsg}`
      this.showDetections = false
    }
  }

  // 构建模型加载卡片
  @Builder
  buildModelCard() {
    Column() {
      Row() {
        Text('YOLO 模型状态')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 8 })

      Row() {
        Text(this.modelLoaded ? '✓ 模型已加载' : '✗ 模型未加载')
          .fontSize(16)
          .fontColor(this.modelLoaded ? Color.Green : Color.Red)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      Button(this.modelLoaded ? '重新加载模型' : '加载模型')
        .width('100%')
        .height(45)
        .fontSize(16)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .onClick(() => {
          try {
            const result = libYOLO.loadYOLOModel('/data/storage/el2/base/haps/yolo.onnx')
            this.modelLoaded = true
            this.processResult = result
          } catch (error) {
            const errorMsg = error instanceof Error ? error.message : String(error)
            this.processResult = `模型加载失败: ${errorMsg}`
            this.modelLoaded = false
          }
        })
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
  }

  // 构建图片显示卡片（带检测框）
  @Builder
  buildImageDisplayCard() {
    Column() {
      Row() {
        Text('检测结果预览')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 15 })

      // 原始图片
      Stack() {
        Image(this.originalImageSrc)
          .width('100%')
          .height(250)
          .objectFit(ImageFit.Contain)
          .borderRadius(8)
          .backgroundColor('#F0F0F0')

        // 检测框覆盖层（模拟）
        if (this.showDetections && this.detectionResults.length > 0) {
          Column() {
            ForEach(this.detectionResults, (detection: DetectionResult, index: number) => {
              if (detection.confidence >= this.confidenceThreshold) {
                // 这里应该绘制实际的检测框
                // 由于 ArkTS 的限制，这里用文本标签表示
                Text(`${detection.className} ${(detection.confidence * 100).toFixed(0)}%`)
                  .fontSize(12)
                  .fontColor(Color.White)
                  .backgroundColor('#FF0000')
                  .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                  .borderRadius(4)
                  .margin({ 
                    left: detection.x, 
                    top: detection.y 
                  })
              }
            }, (item: DetectionResult, index: number) => `${item.className}_${index}`)
          }
          .width('100%')
          .height(250)
        }
      }
      .width('100%')
      .height(250)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
  }

  // 构建检测结果卡片
  @Builder
  buildDetectionResultsCard() {
    Column() {
      Row() {
        Text(`检测结果 (${this.detectionCount} 个目标)`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      ForEach(this.detectionResults, (detection: DetectionResult, index: number) => {
        if (detection.confidence >= this.confidenceThreshold) {
          Column() {
            Row() {
              Text(`${index + 1}. ${detection.className}`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.Black)
              
              Blank()
              
              Text(`${(detection.confidence * 100).toFixed(1)}%`)
                .fontSize(14)
                .fontColor(Color.Blue)
            }
            .width('100%')
            .margin({ bottom: 5 })

            Row() {
              Text(`位置: (${detection.x.toFixed(0)}, ${detection.y.toFixed(0)})`)
                .fontSize(12)
                .fontColor(Color.Gray)
              
              Text(`大小: ${detection.width.toFixed(0)} × ${detection.height.toFixed(0)}`)
                .fontSize(12)
                .fontColor(Color.Gray)
                .margin({ left: 15 })
            }
            .width('100%')
          }
          .width('100%')
          .padding(10)
          .backgroundColor('#F8F8F8')
          .borderRadius(6)
          .margin({ bottom: 8 })
        }
      }, (item: DetectionResult, index: number) => `${item.className}_${index}`)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
  }

  // 构建置信度阈值卡片
  @Builder
  buildThresholdCard() {
    Column() {
      Row() {
        Text('置信度阈值')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 8 })

      Row() {
        Text(`当前阈值: ${(this.confidenceThreshold * 100).toFixed(0)}%`)
          .fontSize(16)
          .fontColor(Color.Gray)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      Row() {
        Slider({
          value: this.confidenceThreshold,
          min: 0.1,
          max: 0.9,
          step: 0.1
        })
        .width('80%')
        .onChange((value: number) => {
          this.confidenceThreshold = value
          try {
            libYOLO.setConfidenceThreshold(value)
            this.processResult = `置信度阈值已设置为 ${(value * 100).toFixed(0)}%`
          } catch (error) {
            const errorMsg = error instanceof Error ? error.message : String(error)
            this.processResult = `设置阈值失败: ${errorMsg}`
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
  }

  // 构建信息卡片
  @Builder
  buildInfoCard(title: string, value: string, onClick: () => void) {
    Column() {
      Row() {
        Text(title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 8 })

      Row() {
        Text(value)
          .fontSize(16)
          .fontColor(Color.Gray)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      Button('获取信息')
        .width('100%')
        .height(45)
        .fontSize(16)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .onClick(onClick)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
  }

  // 构建操作按钮
  @Builder
  buildActionButton(label: string, onClick: () => void) {
    Button(label)
      .width('100%')
      .height(50)
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .backgroundColor('#007DFF')
      .fontColor(Color.White)
      .borderRadius(8)
      .onClick(onClick)
  }

  // 构建结果显示卡片
  @Builder
  buildResultCard() {
    Column() {
      Row() {
        Text('操作结果')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      Row() {
        Text(this.processResult)
          .fontSize(16)
          .fontColor(Color.Black)
          .maxLines(5)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
    .margin({ top: 10 })
  }
}

