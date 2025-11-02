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

import { ChatMessageModel } from './ChatMessageModel'
import { ChatMessageRepository } from './ChatMessageRepository'

/**
 * 聊天消息服务类
 * 提供业务逻辑层的数据操作
 */
export class ChatMessageService {
  private repository: ChatMessageRepository

  constructor(repository: ChatMessageRepository) {
    this.repository = repository
  }

  /**
   * 发送消息
   */
  async sendMessage(
    sessionId: string,
    content: string,
    senderId: string,
    receiverId: string,
    messageType: string = 'text'
  ): Promise<ChatMessageModel> {
    const message = new ChatMessageModel(
      undefined, // id
      this.generateUUID(), // uuid
      sessionId,
      senderId,
      receiverId,
      content,
      Date.now(), // time
      messageType,
      1, // type
      1, // leftOrRight (发送方在右侧)
      1, // sendFrom
      'sending', // status
      '我', // nickname
      '', // headimgurl
      '', // custName
      0, // ifRead
      0, // ifSendSuccess
      0, // loadingProgress
      0, // messageInvalidation
      0, // evaluateMsg
      0, // evaluationWay
      '', // evaluation
      '', // evaluationResult
      0, // chatEvalResult
      '', // messageBoardResult
      '', // messageBoardParams
      '', // appid
      '', // robotAppid
      new Date().toISOString(), // createTime
      new Date().toISOString()  // updateTime
    )

    try {
      const id = await this.repository.save(message)
      message.setId(id)
      return message
    } catch (error) {
      console.error('发送消息失败:', error)
      throw error
    }
  }

  /**
   * 接收消息
   */
  async receiveMessage(
    sessionId: string,
    content: string,
    senderId: string,
    receiverId: string,
    messageType: string = 'text'
  ): Promise<ChatMessageModel> {
    const message = new ChatMessageModel(
      undefined, // id
      this.generateUUID(), // uuid
      sessionId,
      senderId,
      receiverId,
      content,
      Date.now(), // time
      messageType,
      1, // type
      0, // leftOrRight (接收方在左侧)
      0, // sendFrom
      'received', // status
      '对方', // nickname
      '', // headimgurl
      '', // custName
      0, // ifRead
      1, // ifSendSuccess
      0, // loadingProgress
      0, // messageInvalidation
      0, // evaluateMsg
      0, // evaluationWay
      '', // evaluation
      '', // evaluationResult
      0, // chatEvalResult
      '', // messageBoardResult
      '', // messageBoardParams
      '', // appid
      '', // robotAppid
      new Date().toISOString(), // createTime
      new Date().toISOString()  // updateTime
    )

    try {
      const id = await this.repository.save(message)
      message.setId(id)
      return message
    } catch (error) {
      console.error('接收消息失败:', error)
      throw error
    }
  }

  /**
   * 获取会话消息列表
   */
  async getSessionMessages(sessionId: string): Promise<ChatMessageModel[]> {
    try {
      return await this.repository.findBySessionId(sessionId)
    } catch (error) {
      console.error('获取会话消息失败:', error)
      throw error
    }
  }

  /**
   * 标记消息为已读
   */
  async markMessageAsRead(messageId: number): Promise<boolean> {
    try {
      return await this.repository.markAsRead(messageId)
    } catch (error) {
      console.error('标记消息已读失败:', error)
      throw error
    }
  }

  /**
   * 标记会话所有消息为已读
   */
  async markSessionAsRead(sessionId: string): Promise<boolean> {
    try {
      return await this.repository.markAllAsRead(sessionId)
    } catch (error) {
      console.error('标记会话已读失败:', error)
      throw error
    }
  }

  /**
   * 获取未读消息数量
   */
  async getUnreadCount(sessionId?: string): Promise<number> {
    try {
      return await this.repository.findUnreadCount(sessionId)
    } catch (error) {
      console.error('获取未读消息数量失败:', error)
      throw error
    }
  }

  /**
   * 删除消息
   */
  async deleteMessage(messageId: number): Promise<boolean> {
    try {
      return await this.repository.deleteById(messageId)
    } catch (error) {
      console.error('删除消息失败:', error)
      throw error
    }
  }

  /**
   * 删除会话所有消息
   */
  async deleteSessionMessages(sessionId: string): Promise<boolean> {
    try {
      return await this.repository.deleteBySessionId(sessionId)
    } catch (error) {
      console.error('删除会话消息失败:', error)
      throw error
    }
  }

  /**
   * 获取最新消息
   */
  async getLatestMessage(sessionId?: string): Promise<ChatMessageModel | null> {
    try {
      return await this.repository.findLatestMessage(sessionId)
    } catch (error) {
      console.error('获取最新消息失败:', error)
      throw error
    }
  }

  /**
   * 搜索消息
   */
  async searchMessages(keyword: string, sessionId?: string): Promise<ChatMessageModel[]> {
    try {
      // 这里可以实现更复杂的搜索逻辑
      const condition: any = {
        content: keyword
      }
      
      if (sessionId) {
        condition.session_id = sessionId
      }
      
      return await this.repository.findByCondition(condition)
    } catch (error) {
      console.error('搜索消息失败:', error)
      throw error
    }
  }

  /**
   * 生成UUID
   */
  private generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0
      const v = c === 'x' ? r : (r & 0x3 | 0x8)
      return v.toString(16)
    })
  }
}
