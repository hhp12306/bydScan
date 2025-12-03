import resourceManager from '@ohos.resourceManager';

/**
 * ncnn 版本号
 */
export const ncnn_version: () => string;

// --------------------------------------------[ yolo start ]--------------------------------------------
// YOLOv4已移除，只使用YOLOv8
// 如需使用YOLOv4，请参考git历史记录

// --------------------------------------------[ yolo end ]--------------------------------------------

// --------------------------------------------[ nanodet start ]--------------------------------------------
// ---------------------------------- 早期版本的 nanodet，新版本的模型有变化
export const nanodet_init: (
  resMgr: resourceManager.ResourceManager,
  sanboxPath: string,
  option: any,
  config: any
) => string;

export const nanodet_run: (
  imgData: ArrayBuffer,
  imgWidth: number,
  imgHeight: number
) => any[];

// --------------------------------------------[ nanodet end ]--------------------------------------------

// --------------------------------------------[ yolov8 start ]--------------------------------------------
export const yolov8_init: (
  resMgr: resourceManager.ResourceManager,
  sanboxPath: string,
  modelType: string,
  option: any,
  config: any
) => string;

// 增强版运行函数，支持透传数据和SNHA标签映射
export const yolov8_run: (
  imgData: ArrayBuffer,
  imgWidth: number,
  imgHeight: number,
  modelType?: string,
  userId?: string,      // 用户ID（"SNHA"时启用特殊标签映射）
  uuid?: string,        // 唯一ID（透传）
  timeSent?: string     // 时间戳（透传）
) => any[];

// --------------------------------------------[ yolov8 end ]--------------------------------------------

// --------------------------------------------[ benchmark start ]--------------------------------------------
export const benchmark_ncnn: (
  sanboxPath: string,
  model_name: string,
  param_name: string,
  option: any,
  config: any,
  loop: number
) => any;

// --------------------------------------------[ benchmark end ]--------------------------------------------

