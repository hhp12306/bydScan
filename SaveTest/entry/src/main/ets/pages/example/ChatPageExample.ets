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

import { ChatMessageModel } from '../data/ChatMessageModel'
import { ChatMessageRepository } from '../data/ChatMessageRepository'
import { ChatMessageService } from '../data/ChatMessageService'

/**
 * 聊天页面示例
 * 展示如何使用 @Observed 模型进行数据操作
 */
@Entry
@Component
struct ChatPageExample {
  // 使用 @State 装饰器，支持响应式更新
  @State messageList: ChatMessageModel[] = []
  @State inputText: string = ''
  @State sessionId: string = 'session_001'
  @State unreadCount: number = 0

  // 服务层实例
  private chatService: ChatMessageService
  private repository: ChatMessageRepository

  aboutToAppear() {
    // 初始化数据访问层
    this.initDataLayer()
    // 加载消息列表
    this.loadMessages()
  }

  /**
   * 初始化数据访问层
   */
  private initDataLayer() {
    // 这里需要传入实际的数据库实体管理器
    // const entityManager = getEntityManager() // 您需要实现这个方法
    // this.repository = new ChatMessageRepository(entityManager)
    // this.chatService = new ChatMessageService(this.repository)
    
    // 示例：使用模拟数据
    this.loadMockData()
  }

  /**
   * 加载模拟数据（用于演示）
   */
  private loadMockData() {
    const mockMessages = [
      new ChatMessageModel(
        1,
        'uuid_001',
        this.sessionId,
        'user_001',
        'user_002',
        '你好，这是一条测试消息',
        Date.now() - 10000,
        'text',
        1,
        0, // 左侧消息
        0,
        'received',
        '对方',
        '',
        '',
        0,
        1,
        0,
        0,
        0,
        0,
        '',
        '',
        0,
        '',
        '',
        '',
        '',
        new Date().toISOString(),
        new Date().toISOString()
      ),
      new ChatMessageModel(
        2,
        'uuid_002',
        this.sessionId,
        'user_002',
        'user_001',
        '你好，我收到了你的消息',
        Date.now() - 5000,
        'text',
        1,
        1, // 右侧消息
        1,
        'sent',
        '我',
        '',
        '',
        1,
        1,
        0,
        0,
        0,
        0,
        '',
        '',
        0,
        '',
        '',
        '',
        '',
        new Date().toISOString(),
        new Date().toISOString()
      )
    ]
    
    this.messageList = mockMessages
    this.unreadCount = 1
  }

  /**
   * 加载消息列表
   */
  private async loadMessages() {
    try {
      // 实际使用时的代码：
      // this.messageList = await this.chatService.getSessionMessages(this.sessionId)
      // this.unreadCount = await this.chatService.getUnreadCount(this.sessionId)
      
      console.log('消息列表加载完成，共', this.messageList.length, '条消息')
    } catch (error) {
      console.error('加载消息失败:', error)
    }
  }

  /**
   * 发送消息
   */
  private async sendMessage() {
    if (!this.inputText.trim()) {
      return
    }

    const messageText = this.inputText.trim()
    this.inputText = ''

    try {
      // 创建新消息对象
      const newMessage = new ChatMessageModel(
        undefined,
        this.generateUUID(),
        this.sessionId,
        'user_002', // 当前用户ID
        'user_001', // 对方用户ID
        messageText,
        Date.now(),
        'text',
        1,
        1, // 右侧消息
        1,
        'sending',
        '我',
        '',
        '',
        0,
        0,
        0,
        0,
        0,
        0,
        '',
        '',
        0,
        '',
        '',
        '',
        '',
        new Date().toISOString(),
        new Date().toISOString()
      )

      // 添加到消息列表（立即显示）
      this.messageList.push(newMessage)

      // 实际使用时的代码：
      // const savedMessage = await this.chatService.sendMessage(
      //   this.sessionId,
      //   messageText,
      //   'user_002',
      //   'user_001'
      // )
      // 
      // // 更新消息列表中的消息（替换临时消息）
      // const index = this.messageList.findIndex(msg => msg.getUuid() === newMessage.getUuid())
      // if (index !== -1) {
      //   this.messageList[index] = savedMessage
      // }

      console.log('消息发送成功:', messageText)
    } catch (error) {
      console.error('发送消息失败:', error)
      // 发送失败，从列表中移除消息
      this.messageList = this.messageList.filter(msg => msg.getContent() !== messageText)
    }
  }

  /**
   * 标记消息为已读
   */
  private async markMessageAsRead(messageId: number) {
    try {
      // 实际使用时的代码：
      // await this.chatService.markMessageAsRead(messageId)
      
      // 更新本地消息状态
      const message = this.messageList.find(msg => msg.getId() === messageId)
      if (message) {
        message.setIfRead(1)
      }
      
      console.log('消息已标记为已读:', messageId)
    } catch (error) {
      console.error('标记消息已读失败:', error)
    }
  }

  /**
   * 删除消息
   */
  private async deleteMessage(messageId: number) {
    try {
      // 实际使用时的代码：
      // await this.chatService.deleteMessage(messageId)
      
      // 从列表中移除消息
      this.messageList = this.messageList.filter(msg => msg.getId() !== messageId)
      
      console.log('消息删除成功:', messageId)
    } catch (error) {
      console.error('删除消息失败:', error)
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

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('聊天')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Spacer()
        
        if (this.unreadCount > 0) {
          Text(`${this.unreadCount}`)
            .fontSize(12)
            .fontColor(Color.White)
            .backgroundColor(Color.Red)
            .borderRadius(10)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        }
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#f5f5f5')

      // 消息列表
      List() {
        ForEach(this.messageList, (message: ChatMessageModel, index: number) => {
          ListItem() {
            this.MessageItem({ message: message, index: index })
          }
        })
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })

      // 输入框
      Row() {
        TextInput({ placeholder: '请输入消息...' })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.inputText = value
          })
          .onSubmit(() => {
            this.sendMessage()
          })

        Button('发送')
          .margin({ left: 8 })
          .onClick(() => {
            this.sendMessage()
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#f5f5f5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  MessageItem({ message, index }: { message: ChatMessageModel, index: number }) {
    Row() {
      if (message.getLeftOrRight() === 0) {
        // 左侧消息（对方）
        Column() {
          Text(message.getContent() || '')
            .fontSize(14)
            .fontColor(Color.Black)
            .backgroundColor('#e0e0e0')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(8)
          
          Text(this.formatTime(message.getTime() || 0))
            .fontSize(10)
            .fontColor('#999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        
        Spacer()
      } else {
        // 右侧消息（自己）
        Spacer()
        
        Column() {
          Text(message.getContent() || '')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#007AFF')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(8)
          
          Row() {
            Text(this.formatTime(message.getTime() || 0))
              .fontSize(10)
              .fontColor('#999')
            
            if (message.getIfSendSuccess() === 1) {
              Text('✓')
                .fontSize(10)
                .fontColor('#999')
                .margin({ left: 4 })
            }
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.End)
      }
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
    .onClick(() => {
      // 点击消息时标记为已读
      if (message.getId() && message.getIfRead() === 0) {
        this.markMessageAsRead(message.getId()!)
      }
    })
    .onLongPress(() => {
      // 长按消息时显示删除选项
      if (message.getId()) {
        this.deleteMessage(message.getId()!)
      }
    })
  }

  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp)
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    
    if (diff < 60000) { // 1分钟内
      return '刚刚'
    } else if (diff < 3600000) { // 1小时内
      return `${Math.floor(diff / 60000)}分钟前`
    } else if (diff < 86400000) { // 24小时内
      return `${Math.floor(diff / 3600000)}小时前`
    } else {
      return date.toLocaleDateString()
    }
  }
}
