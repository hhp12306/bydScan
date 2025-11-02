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
import { IDataMapper } from './DataMapper'

/**
 * 数据访问仓库接口
 * 定义通用的数据访问操作
 */
export interface IRepository<T extends BaseObservedModel> {
  /**
   * 保存模型（插入或更新）
   */
  save(model: T): Promise<number>

  /**
   * 根据ID查找模型
   */
  findById(id: number): Promise<T | null>

  /**
   * 查找所有模型
   */
  findAll(): Promise<T[]>

  /**
   * 根据条件查找模型
   */
  findByCondition(condition: any): Promise<T[]>

  /**
   * 根据ID删除模型
   */
  deleteById(id: number): Promise<boolean>

  /**
   * 删除模型
   */
  delete(model: T): Promise<boolean>

  /**
   * 批量保存模型
   */
  saveAll(models: T[]): Promise<number[]>

  /**
   * 批量删除模型
   */
  deleteAll(models: T[]): Promise<boolean>

  /**
   * 统计记录数
   */
  count(): Promise<number>

  /**
   * 根据条件统计记录数
   */
  countByCondition(condition: any): Promise<number>
}

/**
 * 基础数据访问仓库
 * 提供通用的数据访问实现
 */
export abstract class BaseRepository<T extends BaseObservedModel, E> implements IRepository<T> {
  protected mapper: IDataMapper<T, E>
  protected entityManager: any // 数据库实体管理器

  constructor(mapper: IDataMapper<T, E>, entityManager: any) {
    this.mapper = mapper
    this.entityManager = entityManager
  }

  /**
   * 保存模型（插入或更新）
   */
  async save(model: T): Promise<number> {
    try {
      const entity = this.mapper.toEntity(model)
      const result = await this.entityManager.insertOrReplace(entity)
      return result.insertId || result.lastInsertRowid || 0
    } catch (error) {
      console.error('保存数据失败:', error)
      throw error
    }
  }

  /**
   * 根据ID查找模型
   */
  async findById(id: number): Promise<T | null> {
    try {
      const entity = await this.entityManager.queryBuilder()
        .where('id', '=', id)
        .queryObject()
      
      if (!entity) {
        return null
      }
      
      return this.mapper.toModel(entity)
    } catch (error) {
      console.error('根据ID查找数据失败:', error)
      throw error
    }
  }

  /**
   * 查找所有模型
   */
  async findAll(): Promise<T[]> {
    try {
      const entities = await this.entityManager.queryBuilder()
        .queryList()
      
      return this.mapper.toModelList(entities)
    } catch (error) {
      console.error('查找所有数据失败:', error)
      throw error
    }
  }

  /**
   * 根据条件查找模型
   */
  async findByCondition(condition: any): Promise<T[]> {
    try {
      let queryBuilder = this.entityManager.queryBuilder()
      
      // 构建查询条件
      for (const [key, value] of Object.entries(condition)) {
        if (value !== undefined && value !== null) {
          queryBuilder = queryBuilder.where(key, '=', value)
        }
      }
      
      const entities = await queryBuilder.queryList()
      return this.mapper.toModelList(entities)
    } catch (error) {
      console.error('根据条件查找数据失败:', error)
      throw error
    }
  }

  /**
   * 根据ID删除模型
   */
  async deleteById(id: number): Promise<boolean> {
    try {
      const result = await this.entityManager.deleteBuilder()
        .where('id', '=', id)
        .execute()
      
      return result.changes > 0
    } catch (error) {
      console.error('根据ID删除数据失败:', error)
      throw error
    }
  }

  /**
   * 删除模型
   */
  async delete(model: T): Promise<boolean> {
    if (!model.getId()) {
      throw new Error('模型ID不能为空')
    }
    
    return await this.deleteById(model.getId()!)
  }

  /**
   * 批量保存模型
   */
  async saveAll(models: T[]): Promise<number[]> {
    const results: number[] = []
    
    for (const model of models) {
      const id = await this.save(model)
      results.push(id)
    }
    
    return results
  }

  /**
   * 批量删除模型
   */
  async deleteAll(models: T[]): Promise<boolean> {
    let allSuccess = true
    
    for (const model of models) {
      const success = await this.delete(model)
      if (!success) {
        allSuccess = false
      }
    }
    
    return allSuccess
  }

  /**
   * 统计记录数
   */
  async count(): Promise<number> {
    try {
      const result = await this.entityManager.queryBuilder()
        .count()
        .queryObject()
      
      return result.count || 0
    } catch (error) {
      console.error('统计记录数失败:', error)
      throw error
    }
  }

  /**
   * 根据条件统计记录数
   */
  async countByCondition(condition: any): Promise<number> {
    try {
      let queryBuilder = this.entityManager.queryBuilder()
      
      // 构建查询条件
      for (const [key, value] of Object.entries(condition)) {
        if (value !== undefined && value !== null) {
          queryBuilder = queryBuilder.where(key, '=', value)
        }
      }
      
      const result = await queryBuilder.count().queryObject()
      return result.count || 0
    } catch (error) {
      console.error('根据条件统计记录数失败:', error)
      throw error
    }
  }
}
