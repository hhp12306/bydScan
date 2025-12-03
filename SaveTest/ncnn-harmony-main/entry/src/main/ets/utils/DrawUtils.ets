import { image } from '@kit.ImageKit';
import { display } from '@kit.ArkUI';
import { stringToColor } from './ColorUtil';

const labels = [
  "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat", "traffic light",
  "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat", "dog", "horse", "sheep", "cow",
  "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella", "handbag", "tie", "suitcase", "frisbee",
  "skis", "snowboard", "sports ball", "kite", "baseball bat", "baseball glove", "skateboard", "surfboard",
  "tennis racket", "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple",
  "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair", "couch",
  "potted plant", "bed", "dining table", "toilet", "tv", "laptop", "mouse", "remote", "keyboard", "cell phone",
  "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase", "scissors", "teddy bear",
  "hair drier", "toothbrush"
]

// 增强的检测结果接口
export interface IBoxInfo {
  // 边界框坐标
  x1: number
  y1: number
  x2: number
  y2: number
  x_center: number      // 中心点X坐标
  y_center: number      // 中心点Y坐标
  
  // 检测结果信息
  label: number         // 类别ID
  labelName: string     // 类别名称（如"person"或SNHA物料编码）
  score: number         // 置信度
  
  // 透传数据
  uuid?: string         // 唯一ID
  timeSent?: string     // 时间戳
  imglabel?: string     // 图像级标签
}

/**
 * 画框
 */
export function drawBox(boxInfos: IBoxInfo[], imagePixelMap: image.PixelMap, width: number, height: number) {
  const offScreenCanvas = new OffscreenCanvas(width, height)
  const offScreenContext = offScreenCanvas.getContext('2d')
  offScreenContext.drawImage(imagePixelMap, 0, 0, width, height)
  const imageScale = width / px2vp(display.getDefaultDisplaySync().width)
  offScreenContext.textAlign = 'left'
  offScreenContext.font = 16 * imageScale + 'vp'
  offScreenContext.lineWidth = 3 * imageScale

  for (let i = 0; i < boxInfos.length; i++) {
    const boxInfo: IBoxInfo = boxInfos[i]
    // 使用labelName（优先）或labels数组
    const labelText = boxInfo.labelName || labels[boxInfo.label] || 'unknown'
    const color = stringToColor(labelText)
    
    offScreenContext.strokeStyle = color
    offScreenContext.strokeRect(boxInfo.x1, boxInfo.y1, boxInfo.x2 - boxInfo.x1, boxInfo.y2 - boxInfo.y1)

    const displayText = labelText + ' ' + boxInfo.score.toFixed(2)
    offScreenContext.fillStyle = '#222222' // 文字阴影
    offScreenContext.fillText(displayText, boxInfo.x1 + 2, Math.max(boxInfo.y1 - 5 + 2, 20))
    offScreenContext.fillStyle = color
    offScreenContext.fillText(displayText, boxInfo.x1, Math.max(boxInfo.y1 - 5, 20))
  }
  return offScreenContext.getPixelMap(0, 0, width, height)
}
