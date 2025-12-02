# Copyright (c) 2022 Huawei Device Co., Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(MyApplication)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

# 添加 OpenCV 库
add_library(opencv SHARED opencv_demo.cpp)
target_link_libraries(opencv PUBLIC libace_napi.z.so)

# 如果系统已安装 OpenCV，取消下面的注释并配置正确的路径
# find_package(OpenCV REQUIRED)
# target_include_directories(opencv PRIVATE ${OpenCV_INCLUDE_DIRS})
# target_link_libraries(opencv PUBLIC ${OpenCV_LIBS})

# 添加 YOLO 库
add_library(yolo SHARED yolo_demo.cpp)
target_link_libraries(yolo PUBLIC libace_napi.z.so)

# 如果使用 OpenCV DNN 模块运行 YOLO，取消下面的注释
# target_link_libraries(yolo PUBLIC ${OpenCV_LIBS})

# 原有的 add 库
add_library(add SHARED add.cpp)
target_link_libraries(add PUBLIC libace_napi.z.so)