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

/**
 * Entity mapped to table "CHAT_MESSAGE".
 */
import { Columns, ColumnType, Entity, Id, NotNull } from '@ohos/dataorm'
import { TableBasic } from './test/TableBasic'
import { observer } from '@kit.TelephonyKit'


@Entity("CHAT_MESSAGE")
export class ChatMessage extends TableBasic {
  @Id()
  @Columns({ columnName: "ID", types: ColumnType.num })
  id: number

  @Columns({ columnName: "UUID", types: ColumnType.str })
  uuid: string

  @Columns({ columnName: "SESSION_ID", types: ColumnType.str })
  session_id: string

  @Columns({ columnName: "SENDER_ID", types: ColumnType.str })
  senderId: string

  @Columns({ columnName: "RECEIVER_ID", types: ColumnType.str })
  receiverId: string

  @Columns({ columnName: "CONTENT", types: ColumnType.str })
  content: string

  @Columns({ columnName: "TIME", types: ColumnType.num })
  time: number

  @Columns({ columnName: "MESSAGE_TYPE", types: ColumnType.str })
  messageType: string

  @Columns({ columnName: "TYPE", types: ColumnType.num })
  type: number

  @Columns({ columnName: "LEFT_OR_RIGHT", types: ColumnType.num })
  leftOrRight: number

  @Columns({ columnName: "SEND_FROM", types: ColumnType.num })
  send_from: number

  @Columns({ columnName: "STATUS", types: ColumnType.str })
  status: string

  @Columns({ columnName: "NICKNAME", types: ColumnType.str })
  nickname: string

  @Columns({ columnName: "HEADIMGURL", types: ColumnType.str })
  headimgurl: string

  @Columns({ columnName: "CUST_NAME", types: ColumnType.str })
  cust_name: string

  @Columns({ columnName: "IF_READ", types: ColumnType.num })
  ifRead: number

  @Columns({ columnName: "IF_SEND_SUCCESS", types: ColumnType.num })
  ifSendSuccess: number

  @Columns({ columnName: "LOADING_PROGRESS", types: ColumnType.num })
  loadingProgress: number

  @Columns({ columnName: "MESSAGE_INVALIDATION", types: ColumnType.num })
  messageInvalidation: number

  @Columns({ columnName: "EVALUATE_MSG", types: ColumnType.num })
  evaluate_msg: number

  @Columns({ columnName: "EVALUATION_WAY", types: ColumnType.num })
  evaluation_way: number

  @Columns({ columnName: "EVALUATION", types: ColumnType.str })
  evaluation: string

  @Columns({ columnName: "EVALUATION_RESULT", types: ColumnType.str })
  evaluationResult: string

  @Columns({ columnName: "CHAT_EVAL_RESULT", types: ColumnType.num })
  chatEvalResult: number

  @Columns({ columnName: "MESSAGE_BOARD_RESULT", types: ColumnType.str })
  messageBoardResult: string

  @Columns({ columnName: "MESSAGE_BOARD_PARAMS", types: ColumnType.str })
  messageBoardParams: string

  @Columns({ columnName: "APPID", types: ColumnType.str })
  appid: string

  @Columns({ columnName: "ROBOT_APPID", types: ColumnType.str })
  robot_appid: string

  constructor(
    id?: number,
    uuid?: string,
    session_id?: string,
    senderId?: string,
    receiverId?: string,
    content?: string,
    time?: number,
    messageType?: string,
    type?: number,
    leftOrRight?: number,
    send_from?: number,
    status?: string,
    nickname?: string,
    headimgurl?: string,
    cust_name?: string,
    ifRead?: number,
    ifSendSuccess?: number,
    loadingProgress?: number,
    messageInvalidation?: number,
    evaluate_msg?: number,
    evaluation_way?: number,
    evaluation?: string,
    evaluationResult?: string,
    chatEvalResult?: number,
    messageBoardResult?: string,
    messageBoardParams?: string,
    appid?: string,
    robot_appid?: string,
    createTime?: string,
  ) {
    super(createTime)
    this.id = id
    this.uuid = uuid
    this.session_id = session_id
    this.senderId = senderId
    this.receiverId = receiverId
    this.content = content
    this.time = time
    this.messageType = messageType
    this.type = type
    this.leftOrRight = leftOrRight
    this.send_from = send_from
    this.status = status
    this.nickname = nickname
    this.headimgurl = headimgurl
    this.cust_name = cust_name
    this.ifRead = ifRead
    this.ifSendSuccess = ifSendSuccess
    this.loadingProgress = loadingProgress
    this.messageInvalidation = messageInvalidation
    this.evaluate_msg = evaluate_msg
    this.evaluation_way = evaluation_way
    this.evaluation = evaluation
    this.evaluationResult = evaluationResult
    this.chatEvalResult = chatEvalResult
    this.messageBoardResult = messageBoardResult
    this.messageBoardParams = messageBoardParams
    this.appid = appid
    this.robot_appid = robot_appid
  }

  getId(): number {
    return this.id
  }

  setId(id: number) {
    this.id = id
  }

  getUuid(): string {
    return this.uuid
  }

  setUuid(uuid: string) {
    this.uuid = uuid
  }

  getSessionId(): string {
    return this.session_id
  }

  setSessionId(session_id: string) {
    this.session_id = session_id
  }

  getSenderId(): string {
    return this.senderId
  }

  setSenderId(senderId: string) {
    this.senderId = senderId
  }

  getReceiverId(): string {
    return this.receiverId
  }

  setReceiverId(receiverId: string) {
    this.receiverId = receiverId
  }

  getContent(): string {
    return this.content
  }

  setContent(content: string) {
    this.content = content
  }

  getTime(): number {
    return this.time
  }

  setTime(time: number) {
    this.time = time
  }

  getMessageType(): string {
    return this.messageType
  }

  setMessageType(messageType: string) {
    this.messageType = messageType
  }

  getType(): number {
    return this.type
  }

  setType(type: number) {
    this.type = type
  }

  getLeftOrRight(): number {
    return this.leftOrRight
  }

  setLeftOrRight(leftOrRight: number) {
    this.leftOrRight = leftOrRight
  }

  getSendFrom(): number {
    return this.send_from
  }

  setSendFrom(send_from: number) {
    this.send_from = send_from
  }

  getStatus(): string {
    return this.status
  }

  setStatus(status: string) {
    this.status = status
  }

  getNickname(): string {
    return this.nickname
  }

  setNickname(nickname: string) {
    this.nickname = nickname
  }

  getHeadimgurl(): string {
    return this.headimgurl
  }

  setHeadimgurl(headimgurl: string) {
    this.headimgurl = headimgurl
  }

  getCustName(): string {
    return this.cust_name
  }

  setCustName(cust_name: string) {
    this.cust_name = cust_name
  }

  getIfRead(): number {
    return this.ifRead
  }

  setIfRead(ifRead: number) {
    this.ifRead = ifRead
  }

  getIfSendSuccess(): number {
    return this.ifSendSuccess
  }

  setIfSendSuccess(ifSendSuccess: number) {
    this.ifSendSuccess = ifSendSuccess
  }

  getLoadingProgress(): number {
    return this.loadingProgress
  }

  setLoadingProgress(loadingProgress: number) {
    this.loadingProgress = loadingProgress
  }

  getMessageInvalidation(): number {
    return this.messageInvalidation
  }

  setMessageInvalidation(messageInvalidation: number) {
    this.messageInvalidation = messageInvalidation
  }

  getEvaluateMsg(): number {
    return this.evaluate_msg
  }

  setEvaluateMsg(evaluate_msg: number) {
    this.evaluate_msg = evaluate_msg
  }

  getEvaluationWay(): number {
    return this.evaluation_way
  }

  setEvaluationWay(evaluation_way: number) {
    this.evaluation_way = evaluation_way
  }

  getEvaluation(): string {
    return this.evaluation
  }

  setEvaluation(evaluation: string) {
    this.evaluation = evaluation
  }

  getEvaluationResult(): string {
    return this.evaluationResult
  }

  setEvaluationResult(evaluationResult: string) {
    this.evaluationResult = evaluationResult
  }

  getChatEvalResult(): number {
    return this.chatEvalResult
  }

  setChatEvalResult(chatEvalResult: number) {
    this.chatEvalResult = chatEvalResult
  }

  getMessageBoardResult(): string {
    return this.messageBoardResult
  }

  setMessageBoardResult(messageBoardResult: string) {
    this.messageBoardResult = messageBoardResult
  }

  getMessageBoardParams(): string {
    return this.messageBoardParams
  }

  setMessageBoardParams(messageBoardParams: string) {
    this.messageBoardParams = messageBoardParams
  }

  getAppid(): string {
    return this.appid
  }

  setAppid(appid: string) {
    this.appid = appid
  }

  getRobotAppid(): string {
    return this.robot_appid
  }

  setRobotAppid(robot_appid: string) {
    this.robot_appid = robot_appid
  }
}


