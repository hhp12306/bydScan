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
import { ChatMessage } from '../ChatMessage'

/**
 * 聊天消息前端模型
 * 使用 @Observed 装饰器，支持响应式更新
 */
@Observed
export class ChatMessageModel extends BaseObservedModel {
  // 消息唯一标识
  uuid?: string
  
  // 会话ID
  sessionId?: string
  
  // 发送者ID
  senderId?: string
  
  // 接收者ID
  receiverId?: string
  
  // 消息内容
  content?: string
  
  // 消息时间戳
  time?: number
  
  // 消息类型
  messageType?: string
  
  // 消息分类
  type?: number
  
  // 消息位置（左/右）
  leftOrRight?: number
  
  // 发送来源
  sendFrom?: number
  
  // 消息状态
  status?: string
  
  // 昵称
  nickname?: string
  
  // 头像URL
  headimgurl?: string
  
  // 客户名称
  custName?: string
  
  // 是否已读
  ifRead?: number
  
  // 是否发送成功
  ifSendSuccess?: number
  
  // 加载进度
  loadingProgress?: number
  
  // 消息是否失效
  messageInvalidation?: number
  
  // 评价消息
  evaluateMsg?: number
  
  // 评价方式
  evaluationWay?: number
  
  // 评价配置
  evaluation?: string
  
  // 评价结果
  evaluationResult?: string
  
  // 聊天评价结果
  chatEvalResult?: number
  
  // 留言板结果
  messageBoardResult?: string
  
  // 留言板参数
  messageBoardParams?: string
  
  // 应用ID
  appid?: string
  
  // 机器人应用ID
  robotAppid?: string

  constructor(
    id?: number,
    uuid?: string,
    sessionId?: string,
    senderId?: string,
    receiverId?: string,
    content?: string,
    time?: number,
    messageType?: string,
    type?: number,
    leftOrRight?: number,
    sendFrom?: number,
    status?: string,
    nickname?: string,
    headimgurl?: string,
    custName?: string,
    ifRead?: number,
    ifSendSuccess?: number,
    loadingProgress?: number,
    messageInvalidation?: number,
    evaluateMsg?: number,
    evaluationWay?: number,
    evaluation?: string,
    evaluationResult?: string,
    chatEvalResult?: number,
    messageBoardResult?: string,
    messageBoardParams?: string,
    appid?: string,
    robotAppid?: string,
    createTime?: string,
    updateTime?: string
  ) {
    super(id, createTime, updateTime)
    this.uuid = uuid
    this.sessionId = sessionId
    this.senderId = senderId
    this.receiverId = receiverId
    this.content = content
    this.time = time
    this.messageType = messageType
    this.type = type
    this.leftOrRight = leftOrRight
    this.sendFrom = sendFrom
    this.status = status
    this.nickname = nickname
    this.headimgurl = headimgurl
    this.custName = custName
    this.ifRead = ifRead
    this.ifSendSuccess = ifSendSuccess
    this.loadingProgress = loadingProgress
    this.messageInvalidation = messageInvalidation
    this.evaluateMsg = evaluateMsg
    this.evaluationWay = evaluationWay
    this.evaluation = evaluation
    this.evaluationResult = evaluationResult
    this.chatEvalResult = chatEvalResult
    this.messageBoardResult = messageBoardResult
    this.messageBoardParams = messageBoardParams
    this.appid = appid
    this.robotAppid = robotAppid
  }

  // Getter 和 Setter 方法
  getUuid(): string | undefined {
    return this.uuid
  }

  setUuid(uuid: string | undefined) {
    this.uuid = uuid
  }

  getSessionId(): string | undefined {
    return this.sessionId
  }

  setSessionId(sessionId: string | undefined) {
    this.sessionId = sessionId
  }

  getSenderId(): string | undefined {
    return this.senderId
  }

  setSenderId(senderId: string | undefined) {
    this.senderId = senderId
  }

  getReceiverId(): string | undefined {
    return this.receiverId
  }

  setReceiverId(receiverId: string | undefined) {
    this.receiverId = receiverId
  }

  getContent(): string | undefined {
    return this.content
  }

  setContent(content: string | undefined) {
    this.content = content
  }

  getTime(): number | undefined {
    return this.time
  }

  setTime(time: number | undefined) {
    this.time = time
  }

  getMessageType(): string | undefined {
    return this.messageType
  }

  setMessageType(messageType: string | undefined) {
    this.messageType = messageType
  }

  getType(): number | undefined {
    return this.type
  }

  setType(type: number | undefined) {
    this.type = type
  }

  getLeftOrRight(): number | undefined {
    return this.leftOrRight
  }

  setLeftOrRight(leftOrRight: number | undefined) {
    this.leftOrRight = leftOrRight
  }

  getSendFrom(): number | undefined {
    return this.sendFrom
  }

  setSendFrom(sendFrom: number | undefined) {
    this.sendFrom = sendFrom
  }

  getStatus(): string | undefined {
    return this.status
  }

  setStatus(status: string | undefined) {
    this.status = status
  }

  getNickname(): string | undefined {
    return this.nickname
  }

  setNickname(nickname: string | undefined) {
    this.nickname = nickname
  }

  getHeadimgurl(): string | undefined {
    return this.headimgurl
  }

  setHeadimgurl(headimgurl: string | undefined) {
    this.headimgurl = headimgurl
  }

  getCustName(): string | undefined {
    return this.custName
  }

  setCustName(custName: string | undefined) {
    this.custName = custName
  }

  getIfRead(): number | undefined {
    return this.ifRead
  }

  setIfRead(ifRead: number | undefined) {
    this.ifRead = ifRead
  }

  getIfSendSuccess(): number | undefined {
    return this.ifSendSuccess
  }

  setIfSendSuccess(ifSendSuccess: number | undefined) {
    this.ifSendSuccess = ifSendSuccess
  }

  getLoadingProgress(): number | undefined {
    return this.loadingProgress
  }

  setLoadingProgress(loadingProgress: number | undefined) {
    this.loadingProgress = loadingProgress
  }

  getMessageInvalidation(): number | undefined {
    return this.messageInvalidation
  }

  setMessageInvalidation(messageInvalidation: number | undefined) {
    this.messageInvalidation = messageInvalidation
  }

  getEvaluateMsg(): number | undefined {
    return this.evaluateMsg
  }

  setEvaluateMsg(evaluateMsg: number | undefined) {
    this.evaluateMsg = evaluateMsg
  }

  getEvaluationWay(): number | undefined {
    return this.evaluationWay
  }

  setEvaluationWay(evaluationWay: number | undefined) {
    this.evaluationWay = evaluationWay
  }

  getEvaluation(): string | undefined {
    return this.evaluation
  }

  setEvaluation(evaluation: string | undefined) {
    this.evaluation = evaluation
  }

  getEvaluationResult(): string | undefined {
    return this.evaluationResult
  }

  setEvaluationResult(evaluationResult: string | undefined) {
    this.evaluationResult = evaluationResult
  }

  getChatEvalResult(): number | undefined {
    return this.chatEvalResult
  }

  setChatEvalResult(chatEvalResult: number | undefined) {
    this.chatEvalResult = chatEvalResult
  }

  getMessageBoardResult(): string | undefined {
    return this.messageBoardResult
  }

  setMessageBoardResult(messageBoardResult: string | undefined) {
    this.messageBoardResult = messageBoardResult
  }

  getMessageBoardParams(): string | undefined {
    return this.messageBoardParams
  }

  setMessageBoardParams(messageBoardParams: string | undefined) {
    this.messageBoardParams = messageBoardParams
  }

  getAppid(): string | undefined {
    return this.appid
  }

  setAppid(appid: string | undefined) {
    this.appid = appid
  }

  getRobotAppid(): string | undefined {
    return this.robotAppid
  }

  setRobotAppid(robotAppid: string | undefined) {
    this.robotAppid = robotAppid
  }

  /**
   * 将当前模型转换为数据库实体
   */
  toEntity(): ChatMessage {
    const entity = new ChatMessage()
    
    // 映射基础字段
    entity.id = this.id
    entity.uuid = this.uuid
    entity.session_id = this.sessionId
    entity.senderId = this.senderId
    entity.receiverId = this.receiverId
    entity.content = this.content
    entity.time = this.time
    entity.messageType = this.messageType
    entity.type = this.type
    entity.leftOrRight = this.leftOrRight
    entity.send_from = this.sendFrom
    entity.status = this.status
    entity.nickname = this.nickname
    entity.headimgurl = this.headimgurl
    entity.cust_name = this.custName
    entity.ifRead = this.ifRead
    entity.ifSendSuccess = this.ifSendSuccess
    entity.loadingProgress = this.loadingProgress
    entity.messageInvalidation = this.messageInvalidation
    entity.evaluate_msg = this.evaluateMsg
    entity.evaluation_way = this.evaluationWay
    entity.evaluation = this.evaluation
    entity.evaluationResult = this.evaluationResult
    entity.chatEvalResult = this.chatEvalResult
    entity.messageBoardResult = this.messageBoardResult
    entity.messageBoardParams = this.messageBoardParams
    entity.appid = this.appid
    entity.robot_appid = this.robotAppid
    
    return entity
  }

  /**
   * 从数据库实体创建模型
   */
  fromEntity(entity: ChatMessage): void {
    // 映射基础字段
    this.id = entity.id
    this.uuid = entity.uuid
    this.sessionId = entity.session_id
    this.senderId = entity.senderId
    this.receiverId = entity.receiverId
    this.content = entity.content
    this.time = entity.time
    this.messageType = entity.messageType
    this.type = entity.type
    this.leftOrRight = entity.leftOrRight
    this.sendFrom = entity.send_from
    this.status = entity.status
    this.nickname = entity.nickname
    this.headimgurl = entity.headimgurl
    this.custName = entity.cust_name
    this.ifRead = entity.ifRead
    this.ifSendSuccess = entity.ifSendSuccess
    this.loadingProgress = entity.loadingProgress
    this.messageInvalidation = entity.messageInvalidation
    this.evaluateMsg = entity.evaluate_msg
    this.evaluationWay = entity.evaluation_way
    this.evaluation = entity.evaluation
    this.evaluationResult = entity.evaluationResult
    this.chatEvalResult = entity.chatEvalResult
    this.messageBoardResult = entity.messageBoardResult
    this.messageBoardParams = entity.messageBoardParams
    this.appid = entity.appid
    this.robotAppid = entity.robot_appid
  }

  /**
   * 复制对象属性
   */
  copyFrom(source: ChatMessageModel): void {
    super.copyFrom(source)
    this.uuid = source.uuid
    this.sessionId = source.sessionId
    this.senderId = source.senderId
    this.receiverId = source.receiverId
    this.content = source.content
    this.time = source.time
    this.messageType = source.messageType
    this.type = source.type
    this.leftOrRight = source.leftOrRight
    this.sendFrom = source.sendFrom
    this.status = source.status
    this.nickname = source.nickname
    this.headimgurl = source.headimgurl
    this.custName = source.custName
    this.ifRead = source.ifRead
    this.ifSendSuccess = source.ifSendSuccess
    this.loadingProgress = source.loadingProgress
    this.messageInvalidation = source.messageInvalidation
    this.evaluateMsg = source.evaluateMsg
    this.evaluationWay = source.evaluationWay
    this.evaluation = source.evaluation
    this.evaluationResult = source.evaluationResult
    this.chatEvalResult = source.chatEvalResult
    this.messageBoardResult = source.messageBoardResult
    this.messageBoardParams = source.messageBoardParams
    this.appid = source.appid
    this.robotAppid = source.robotAppid
  }
}
