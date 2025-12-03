export interface IModelType {
  name: string
  param: string
  bin: string
}

export const modelList: IModelType[] = [
  // YOLOv8模型（支持自动格式检测和SNHA标签映射）
  // 需要单独准备模型文件，详细步骤请参考：如何获取YOLOv8模型.md
  // 准备好模型文件后，取消下面的注释即可使用
  // {
  //   name: 'yolov8n',
  //   param: 'yolov8n.param',
  //   bin: 'yolov8n.bin'
  // },
  // {
  //   name: 'yolov8s',
  //   param: 'yolov8s.param',
  //   bin: 'yolov8s.bin'
  // },
  
  // NanoDet模型（备用）
  {
    name: 'nanodet-m',
    param: 'nanodet-m.param',
    bin: 'nanodet-m.bin'
  }

]
