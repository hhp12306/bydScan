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

import { BaseRepository } from './BaseRepository'
import { ChatMessageModel } from './ChatMessageModel'
import { ChatMessage } from '../ChatMessage'
import { IDataMapper } from './DataMapper'

/**
 * 聊天消息数据映射器
 */
export class ChatMessageMapper implements IDataMapper<ChatMessageModel, ChatMessage> {
  toEntity(model: ChatMessageModel): ChatMessage {
    return model.toEntity()
  }

  toModel(entity: ChatMessage): ChatMessageModel {
    const model = new ChatMessageModel()
    model.fromEntity(entity)
    return model
  }

  toModelList(entities: ChatMessage[]): ChatMessageModel[] {
    return entities.map(entity => this.toModel(entity))
  }
}

/**
 * 聊天消息数据访问仓库
 */
export class ChatMessageRepository extends BaseRepository<ChatMessageModel, ChatMessage> {
  constructor(entityManager: any) {
    super(new ChatMessageMapper(), entityManager)
  }

  /**
   * 根据会话ID查找消息列表
   */
  async findBySessionId(sessionId: string): Promise<ChatMessageModel[]> {
    try {
      const entities = await this.entityManager.queryBuilder()
        .where('session_id', '=', sessionId)
        .orderBy('time', 'ASC')
        .queryList()
      
      return this.mapper.toModelList(entities)
    } catch (error) {
      console.error('根据会话ID查找消息失败:', error)
      throw error
    }
  }

  /**
   * 根据发送者ID查找消息列表
   */
  async findBySenderId(senderId: string): Promise<ChatMessageModel[]> {
    try {
      const entities = await this.entityManager.queryBuilder()
        .where('senderId', '=', senderId)
        .orderBy('time', 'DESC')
        .queryList()
      
      return this.mapper.toModelList(entities)
    } catch (error) {
      console.error('根据发送者ID查找消息失败:', error)
      throw error
    }
  }

  /**
   * 根据消息类型查找消息列表
   */
  async findByMessageType(messageType: string): Promise<ChatMessageModel[]> {
    try {
      const entities = await this.entityManager.queryBuilder()
        .where('messageType', '=', messageType)
        .orderBy('time', 'DESC')
        .queryList()
      
      return this.mapper.toModelList(entities)
    } catch (error) {
      console.error('根据消息类型查找消息失败:', error)
      throw error
    }
  }

  /**
   * 查找未读消息数量
   */
  async findUnreadCount(sessionId?: string): Promise<number> {
    try {
      let queryBuilder = this.entityManager.queryBuilder()
        .where('ifRead', '=', 0)
      
      if (sessionId) {
        queryBuilder = queryBuilder.where('session_id', '=', sessionId)
      }
      
      const result = await queryBuilder.count().queryObject()
      return result.count || 0
    } catch (error) {
      console.error('查找未读消息数量失败:', error)
      throw error
    }
  }

  /**
   * 标记消息为已读
   */
  async markAsRead(messageId: number): Promise<boolean> {
    try {
      const result = await this.entityManager.updateBuilder()
        .where('id', '=', messageId)
        .set('ifRead', 1)
        .execute()
      
      return result.changes > 0
    } catch (error) {
      console.error('标记消息为已读失败:', error)
      throw error
    }
  }

  /**
   * 批量标记消息为已读
   */
  async markAllAsRead(sessionId: string): Promise<boolean> {
    try {
      const result = await this.entityManager.updateBuilder()
        .where('session_id', '=', sessionId)
        .where('ifRead', '=', 0)
        .set('ifRead', 1)
        .execute()
      
      return result.changes > 0
    } catch (error) {
      console.error('批量标记消息为已读失败:', error)
      throw error
    }
  }

  /**
   * 根据时间范围查找消息
   */
  async findByTimeRange(startTime: number, endTime: number, sessionId?: string): Promise<ChatMessageModel[]> {
    try {
      let queryBuilder = this.entityManager.queryBuilder()
        .where('time', '>=', startTime)
        .where('time', '<=', endTime)
      
      if (sessionId) {
        queryBuilder = queryBuilder.where('session_id', '=', sessionId)
      }
      
      const entities = await queryBuilder
        .orderBy('time', 'ASC')
        .queryList()
      
      return this.mapper.toModelList(entities)
    } catch (error) {
      console.error('根据时间范围查找消息失败:', error)
      throw error
    }
  }

  /**
   * 删除会话的所有消息
   */
  async deleteBySessionId(sessionId: string): Promise<boolean> {
    try {
      const result = await this.entityManager.deleteBuilder()
        .where('session_id', '=', sessionId)
        .execute()
      
      return result.changes > 0
    } catch (error) {
      console.error('删除会话消息失败:', error)
      throw error
    }
  }

  /**
   * 查找最新的消息
   */
  async findLatestMessage(sessionId?: string): Promise<ChatMessageModel | null> {
    try {
      let queryBuilder = this.entityManager.queryBuilder()
      
      if (sessionId) {
        queryBuilder = queryBuilder.where('session_id', '=', sessionId)
      }
      
      const entity = await queryBuilder
        .orderBy('time', 'DESC')
        .limit(1)
        .queryObject()
      
      if (!entity) {
        return null
      }
      
      return this.mapper.toModel(entity)
    } catch (error) {
      console.error('查找最新消息失败:', error)
      throw error
    }
  }
}
