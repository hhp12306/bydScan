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

// YOLO 检测结果接口
export interface DetectionResult {
  className: string;    // 检测到的类别名称
  confidence: number;   // 置信度 (0.0 - 1.0)
  x: number;           // 边界框左上角 x 坐标
  y: number;           // 边界框左上角 y 坐标
  width: number;        // 边界框宽度
  height: number;       // 边界框高度
}

// YOLO 模块导出
export const loadYOLOModel: (modelPath: string) => string;
export const detectObjects: (imagePath: string) => DetectionResult[];
export const getYOLOClasses: () => string[];
export const getYOLOVersion: () => string;
export const setConfidenceThreshold: (threshold: number) => string;

