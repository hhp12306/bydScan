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

// 图像统计信息接口
export interface ImageStats {
  width: number;
  height: number;
  channels: number;
}

// OpenCV 模块导出（与 libadd 格式一致）
export const getOpenCVVersion: () => string;
export const convertToGrayscale: (imagePath: string) => string;
export const detectEdges: (imagePath: string, lowThreshold: number, highThreshold: number) => string;
export const blurImage: (imagePath: string, blurRadius: number) => string;
export const getImageStats: () => ImageStats;
export const resizeImage: (imagePath: string, width: number, height: number) => string;

