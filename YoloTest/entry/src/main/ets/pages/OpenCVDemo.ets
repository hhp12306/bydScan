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

import libOpenCV from 'libopencv.so'

@Entry
@Component
struct OpenCVDemo {
  // 页面标题和说明
  private title: string = 'OpenCV 图像处理示例'
  private description: string = '演示 OpenCV 基础图像处理功能'
  
  // 状态变量
  @State openCVVersion: string = '未知'
  @State imageStats: string = '未获取'
  @State processResult: string = '等待操作...'
  @State imagePath: string = '/data/storage/el2/base/haps/test.jpg'
  
  // 图片显示相关
  @State originalImageSrc: ResourceStr = $r('app.media.background')
  @State processedImageSrc: ResourceStr | string = ''
  @State showProcessedImage: boolean = false
  
  // 边缘检测参数
  @State lowThreshold: number = 50
  @State highThreshold: number = 150
  @State blurRadius: number = 5
  
  // 图像缩放参数
  @State resizeWidth: number = 640
  @State resizeHeight: number = 480

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

      // 滚动容器，包含所有功能按钮
      Scroll() {
        Column({ space: 15 }) {
          // 图片显示区域
          this.buildImageDisplayCard()
          
          // OpenCV 版本信息
          this.buildInfoCard('OpenCV 版本', this.openCVVersion, () => {
            try {
              this.openCVVersion = libOpenCV.getOpenCVVersion()
              this.processResult = `OpenCV 版本: ${this.openCVVersion}`
            } catch (error) {
              const errorMsg = error instanceof Error ? error.message : String(error)
              this.processResult = `获取版本失败: ${errorMsg}`
            }
          })

          // 图像统计信息
          this.buildInfoCard('图像统计信息', this.imageStats, () => {
            try {
              const stats = libOpenCV.getImageStats()
              this.imageStats = `宽: ${stats.width}, 高: ${stats.height}, 通道: ${stats.channels}`
              this.processResult = `统计信息: ${this.imageStats}`
            } catch (error) {
              const errorMsg = error instanceof Error ? error.message : String(error)
              this.processResult = `获取统计信息失败: ${errorMsg}`
            }
          })

          // 灰度转换
          this.buildActionButton('转换为灰度图', () => {
            try {
              const result = libOpenCV.convertToGrayscale(this.imagePath)
              this.processResult = result
              // 模拟显示处理后的图片（实际应用中需要从 OpenCV 返回处理后的图片路径）
              this.showProcessedImage = true
              this.processedImageSrc = this.originalImageSrc // 实际应该是处理后的图片
            } catch (error) {
              const errorMsg = error instanceof Error ? error.message : String(error)
              this.processResult = `灰度转换失败: ${errorMsg}`
              this.showProcessedImage = false
            }
          })

          // 边缘检测
          this.buildActionButton('边缘检测 (Canny)', () => {
            try {
              const result = libOpenCV.detectEdges(this.imagePath, this.lowThreshold, this.highThreshold)
              this.processResult = result
              this.showProcessedImage = true
              this.processedImageSrc = this.originalImageSrc // 实际应该是处理后的图片
            } catch (error) {
              const errorMsg = error instanceof Error ? error.message : String(error)
              this.processResult = `边缘检测失败: ${errorMsg}`
              this.showProcessedImage = false
            }
          })

          // 图像模糊
          this.buildActionButton('高斯模糊', () => {
            try {
              const result = libOpenCV.blurImage(this.imagePath, this.blurRadius)
              this.processResult = result
              this.showProcessedImage = true
              this.processedImageSrc = this.originalImageSrc // 实际应该是处理后的图片
            } catch (error) {
              const errorMsg = error instanceof Error ? error.message : String(error)
              this.processResult = `图像模糊失败: ${errorMsg}`
              this.showProcessedImage = false
            }
          })

          // 图像缩放
          this.buildActionButton('图像缩放', () => {
            try {
              const result = libOpenCV.resizeImage(this.imagePath, this.resizeWidth, this.resizeHeight)
              this.processResult = result
              this.showProcessedImage = true
              this.processedImageSrc = this.originalImageSrc // 实际应该是处理后的图片
            } catch (error) {
              const errorMsg = error instanceof Error ? error.message : String(error)
              this.processResult = `图像缩放失败: ${errorMsg}`
              this.showProcessedImage = false
            }
          })

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

  // 构建图片显示卡片
  @Builder
  buildImageDisplayCard() {
    Column() {
      // 标题
      Row() {
        Text('图像预览')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 15 })

      // 原始图片
      Column() {
        Text('原始图片')
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ bottom: 8 })
        
        Image(this.originalImageSrc)
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Contain)
          .borderRadius(8)
          .backgroundColor('#F0F0F0')
      }
      .width('100%')
      .margin({ bottom: 15 })

      // 处理后的图片（条件显示）
      if (this.showProcessedImage) {
        Column() {
          Text('处理后图片')
            .fontSize(16)
            .fontColor(Color.Gray)
            .margin({ bottom: 8 })
          
          Image(this.processedImageSrc)
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Contain)
            .borderRadius(8)
            .backgroundColor('#F0F0F0')
        }
        .width('100%')
        .margin({ bottom: 15 })
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
  }

  // 构建结果显示卡片
  @Builder
  buildResultCard() {
    Column() {
      Row() {
        Text('处理结果')
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

