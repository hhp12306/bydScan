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

import libAdd from 'libadd.so'
import router from '@ohos.router'

@Entry
@Component
struct Index {
  private textInputController1: TextInputController = new TextInputController()
  private textInputController2: TextInputController = new TextInputController()
  private tittle: string = '调用C标准库示例(NAPI)'
  private message: string = '计算两个给定数和x+y'
  private tipsNum1: string = '请输入第一个数：'
  private tipsNum2: string = '请输入第二个数：'
  private tipsResult: string = '结果：'
  private buttonSubmit: string = '计算'
  @State result: number = 0.0
  @State num1: number = 0.0
  @State num2: number = 0.0

  build() {
    Row() {
      Column() {
        Row(){
          Text(this.tittle).height('100%').align(Alignment.Center).fontSize(40).fontWeight(800)
        }.height('10%').width('100%').justifyContent(FlexAlign.Center)
        Row(){
          Text(this.message).height('100%').align(Alignment.Center).fontSize(35).fontWeight(500)
        }.height('15%').width('100%').justifyContent(FlexAlign.Center)
        Row(){
          Text(this.tipsNum1).fontColor(Color.Black).fontSize('25px').width('30%').height('100%').margin({left:30})
          TextInput({ placeholder: '请输入第一个数字：', controller:this.textInputController1}).type(InputType.Number)
            .height('100%').width('60%').margin({left:10,right:30}).fontSize('25px')
            .onChange(value =>{this.num1 = parseFloat(value)})
        }.height('6%').width('100%').justifyContent(FlexAlign.Start)
        Row(){
          Text(this.tipsNum2).fontColor(Color.Black).fontSize('25px').width('30%').height('100%').margin({left:30})
          TextInput({ placeholder: '请输入第二个数字：', controller:this.textInputController2}).type(InputType.Number)
            .height('100%').width('60%').margin({left:10,right:30}).fontSize('25px')
            .onChange(value =>{this.num2 = parseFloat(value)})
        }.height('6%').width('100%').margin({top:20})
        Row(){
          Text(this.tipsResult).fontColor(Color.Black).fontSize(35).width('40%').height('100%').margin({left:30})
          Text(''+this.result).fontColor(Color.Black).fontSize(35).width('60%').height('100%')
        }.height('10%').width('100%')
        Row(){
          Button(this.buttonSubmit)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .margin({top:5})
            .height(80)
            .width(200)
            .onClick(() => {
              this.result = libAdd.add(this.num1,this.num2)
            })
        }.height('20%').width('100%').justifyContent(FlexAlign.Center)
        Row(){
          Button('OpenCV 图像处理演示')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .margin({top:10})
            .height(70)
            .width(280)
            .backgroundColor('#007DFF')
            .fontColor(Color.White)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/OpenCVDemo'
              }).then(() => {
                // 跳转成功
              }).catch(() => {
                // 跳转失败处理
              })
            })
        }.height('10%').width('100%').justifyContent(FlexAlign.Center)
        Row(){
          Button('YOLO 目标检测演示')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .margin({top:10})
            .height(70)
            .width(280)
            .backgroundColor('#28A745')
            .fontColor(Color.White)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/YOLODemo'
              }).then(() => {
                // 跳转成功
              }).catch(() => {
                // 跳转失败处理
              })
            })
        }.height('10%').width('100%').justifyContent(FlexAlign.Center)
      }
      .width('100%')
    }
    .height('100%')
  }
}

