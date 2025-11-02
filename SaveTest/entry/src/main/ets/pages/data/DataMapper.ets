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

import { BaseObservedModel } from './BaseObservedModel'

/**
 * 数据映射器接口
 * 定义 Observed 模型和 Entity 之间的转换规则
 */
export interface IDataMapper<T extends BaseObservedModel, E> {
  /**
   * 将 Observed 模型转换为 Entity
   */
  toEntity(model: T): E

  /**
   * 将 Entity 转换为 Observed 模型
   */
  toModel(entity: E): T

  /**
   * 批量转换 Entity 列表为 Observed 模型列表
   */
  toModelList(entities: E[]): T[]
}

/**
 * 通用数据映射器基类
 * 提供通用的映射逻辑
 */
export abstract class BaseDataMapper<T extends BaseObservedModel, E> implements IDataMapper<T, E> {
  /**
   * 抽象方法：创建新的模型实例
   */
  protected abstract createModel(): T

  /**
   * 抽象方法：创建新的实体实例
   */
  protected abstract createEntity(): E

  /**
   * 抽象方法：将模型属性映射到实体
   */
  protected abstract mapModelToEntity(model: T, entity: E): void

  /**
   * 抽象方法：将实体属性映射到模型
   */
  protected abstract mapEntityToModel(entity: E, model: T): void

  /**
   * 将 Observed 模型转换为 Entity
   */
  toEntity(model: T): E {
    const entity = this.createEntity()
    this.mapModelToEntity(model, entity)
    return entity
  }

  /**
   * 将 Entity 转换为 Observed 模型
   */
  toModel(entity: E): T {
    const model = this.createModel()
    this.mapEntityToModel(entity, model)
    return model
  }

  /**
   * 批量转换 Entity 列表为 Observed 模型列表
   */
  toModelList(entities: E[]): T[] {
    return entities.map(entity => this.toModel(entity))
  }
}

/**
 * 反射式数据映射器
 * 通过反射自动映射同名字段
 */
export class ReflectionDataMapper<T extends BaseObservedModel, E> extends BaseDataMapper<T, E> {
  private modelConstructor: new () => T
  private entityConstructor: new () => E

  constructor(modelConstructor: new () => T, entityConstructor: new () => E) {
    super()
    this.modelConstructor = modelConstructor
    this.entityConstructor = entityConstructor
  }

  protected createModel(): T {
    return new this.modelConstructor()
  }

  protected createEntity(): E {
    return new this.entityConstructor()
  }

  protected mapModelToEntity(model: T, entity: E): void {
    // 通过反射复制同名字段
    const modelKeys = Object.keys(model)
    const entityKeys = Object.keys(entity)
    
    for (const key of modelKeys) {
      if (entityKeys.includes(key) && model[key] !== undefined) {
        entity[key] = model[key]
      }
    }
  }

  protected mapEntityToModel(entity: E, model: T): void {
    // 通过反射复制同名字段
    const entityKeys = Object.keys(entity)
    const modelKeys = Object.keys(model)
    
    for (const key of entityKeys) {
      if (modelKeys.includes(key) && entity[key] !== undefined) {
        model[key] = entity[key]
      }
    }
  }
}
