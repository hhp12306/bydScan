/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Observed } from '@kit.ArkUI'

/**
 * 基础可观察数据模型
 * 所有前端数据模型都应该继承此类
 */
@Observed
export abstract class BaseObservedModel {
  // 主键ID，用于数据库操作
  id?: number
  
  // 创建时间
  createTime?: string
  
  // 更新时间
  updateTime?: string

  constructor(id?: number, createTime?: string, updateTime?: string) {
    this.id = id
    this.createTime = createTime
    this.updateTime = updateTime
  }

  /**
   * 获取主键ID
   */
  getId(): number | undefined {
    return this.id
  }

  /**
   * 设置主键ID
   */
  setId(id: number | undefined) {
    this.id = id
  }

  /**
   * 获取创建时间
   */
  getCreateTime(): string | undefined {
    return this.createTime
  }

  /**
   * 设置创建时间
   */
  setCreateTime(createTime: string | undefined) {
    this.createTime = createTime
  }

  /**
   * 获取更新时间
   */
  getUpdateTime(): string | undefined {
    return this.updateTime
  }

  /**
   * 设置更新时间
   */
  setUpdateTime(updateTime: string | undefined) {
    this.updateTime = updateTime
  }

  /**
   * 抽象方法：将当前对象转换为数据库实体对象
   * 子类需要实现此方法来定义如何转换为对应的Entity
   */
  abstract toEntity(): any

  /**
   * 抽象方法：从数据库实体对象创建当前对象
   * 子类需要实现此方法来定义如何从Entity创建对象
   */
  abstract fromEntity(entity: any): void

  /**
   * 复制对象属性
   */
  copyFrom(source: BaseObservedModel): void {
    this.id = source.id
    this.createTime = source.createTime
    this.updateTime = source.updateTime
  }

  /**
   * 克隆对象
   */
  clone(): BaseObservedModel {
    const cloned = Object.create(Object.getPrototypeOf(this))
    cloned.copyFrom(this)
    return cloned
  }
}
