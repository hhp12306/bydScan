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

import { DaoMaster, DaoTraceSpace, Database, GlobalContext, Migration, Property } from '@byd/dataorm';
import { DaoSession } from '@byd/dataorm'
import { BaseDao } from '@byd/dataorm'
import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit';
import { Query } from '@byd/dataorm'
import { QueryBuilder } from '@byd/dataorm'
import { inquiry } from '@byd/dataorm'
import { TableAction } from '@byd/dataorm'
import { OnTableChangedListener } from '@byd/dataorm'
import { Toolbar } from './toolbar'
import { Note } from './Note'
import { NoteType } from './NoteType'
import dataRdb from '@ohos.data.relationalStore';
import { QueryTest, QueryClass } from './util'
import { ExampleOpenHelper } from './ExampleOpenHelper';
import { ChatMessage } from './ChatMessage';
import { RenderService } from './message/RenderService';
import { MessageInfo } from '../type/MessageType';
import { FeedbackComponent } from './message/FeedbackComponent';
import json from '@ohos.util.json';
import relationalStore from '@ohos.data.relationalStore';
import router from '@ohos.router';

@Entry
@Component
struct Index {
  scroller: Scroller = new Scroller()
  @State messageList: Array<ChatMessage> = new Array<ChatMessage>(); // 合并消息列表
  @State showMessageList: Array<MsgItem> = new Array<MsgItem>();
  @State editFlag: boolean = false
  // 在状态变量部分添加新变量
  @State currentPage: number = 0; // 当前页码
  @State pageSize: number = 10; // 每页条数
  @State messageText: string = '' // 聊天输入框内容
  private daoSession: DaoSession | null = null;
  private messageInfoDao: BaseDao<ChatMessage, number | string | Record<string, Object>> | null = null;
  private messageInfoQuery: Query<ChatMessage> | null = null;
  private context = getContext(this);
  private super_id = ''

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Button('跳转在线客服')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .width(80)
        .height(45)
        .onClick(() => {
          router.push({
            url: 'pages/component/page/onlineservice/OnlineService',
          })
        })
      Button('图表测试')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .width(80)
        .height(45)
        .margin({ left: 8 })
        .onClick(() => {
          router.push({
            url: 'pages/ChartsTestPage',
          })
        })
      Row() {
        Button('清空聊天数据')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .width(80)
          .height(45)
          .onClick(() => {
            this.showMessageList = []
            this.messageList = []
          })
        Button('初始化聊天数据库')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .width(80)
          .height(45)
          .onClick(() => {
            this.initDatabase()
          })

        Button('1修改用户id')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .width(80)
          .height(45)
          .onClick(() => {
            this.super_id = '12345667'
          })

        Button('2修改用户id')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .width(80)
          .height(45)
          .onClick(() => {
            this.super_id = '1234566711'
          })
      }

      // 顶部标题栏
      Column() {
        Toolbar({ title: '在线客服获取数据库实例', isBack: true })
          .onClick(() => {
            this.getAppData()
          })


        Button('加载更多')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .height(45)
          .onClick(() => {
            this.loadMoreMessages()
          })
      }.zIndex(200)
      .expandSafeArea([SafeAreaType.KEYBOARD])


      // 聊天记录显示区域
      Stack({ alignContent: Alignment.TopStart }) {
        Scroll(this.scroller) {
          List({ space: 10, initialIndex: 0 }) {
            // 显示所有消息
            ForEach(this.showMessageList, (item: MsgItem) => {
              ListItem() {
                // 根据发送者类型渲染不同样式的消息
                if (item.nickname === '用户') {
                  // RenderService({
                  //   item: item,
                  // })
                } else {
                  FeedbackComponent({
                    item: item,
                    onUpdateDatabase: (id: number, ifSubmit: boolean): Promise<void> => this.updateMessageInDatabase(id,
                      ifSubmit)
                  })
                }
              }
            })
          }
          .listDirection(Axis.Vertical)
          .edgeEffect(EdgeEffect.None)
          .width('95%')
          .margin({ left: 10, right: 10 })
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .scrollBarColor(Color.Gray)
        .scrollBarWidth(30)
      }
      .layoutWeight(1)
      .width('100%')

      // 底部输入区域
      Flex({ direction: FlexDirection.Row }) {
        TextInput({ placeholder: '请输入消息...' })
          .type(InputType.Normal)
          .placeholderColor(Color.Gray)
          .enterKeyType(EnterKeyType.Send)
          .caretColor(Color.Green)
          .layoutWeight(1)
          .height(45)
          .borderRadius(8)
          .backgroundColor('#f0f0f0')
          .onChange((value: string) => {
            this.messageText = value
          })
          .onSubmit(() => {
            this.sendUserMessage()
          })
        Button('留言')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .width(60)
          .height(45)
          .borderRadius(8)
          .margin({ left: 5 })
          .backgroundColor('#007AFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.storeSpecialMessage()
          })
        Button('发送')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .width(60)
          .height(45)
          .borderRadius(8)
          .margin({ left: 5 })
          .backgroundColor('#007AFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.sendUserMessage()
          })
      }
      .padding(10)
      .width('100%')
      .backgroundColor('#ffffff')
    }
    .width('100%')
    .height('100%')
  }

  // 发送用户消息
  async sendUserMessage() {
    if (!this.messageText.trim() || !this.messageInfoDao) {
      return;
    }

    let messageInfo = new ChatMessage();
    messageInfo.setId(Date.now()); // 使用时间戳作为ID
    messageInfo.setHeadimgurl('user');
    messageInfo.setCustName('用户');
    messageInfo.setContent(this.messageText);
    await this.messageInfoDao.insert(messageInfo);

    // 清空输入框
    this.messageText = '';

    // 更新消息列表
    await this.updateMessages();

    // 模拟客服自动回复
    setTimeout(async () => {
      await this.simulateServiceReply();
    }, 1000);
  }

  async storeSpecialMessage() {
    if (!this.messageInfoDao) {
      return;
    }
    let tempContent: MessageInfo = new MessageInfo()
    tempContent.content = '留言' + Date.now()
    tempContent.ifSubmit = false
    let messageInfo = new ChatMessage();
    messageInfo.setId(Date.now()); // 使用时间戳作为ID
    messageInfo.setHeadimgurl('user');
    messageInfo.setNickname('留言');
    messageInfo.setContent(JSON.stringify(tempContent));

    await this.messageInfoDao.insert(messageInfo);
  }

  // 更新数据库中的消息提交状态
  async updateMessageInDatabase(id: number, ifSubmit: boolean): Promise<void> {
    if (!this.messageInfoDao) {
      console.error('数据库未初始化');
      return;
    }

    try {
      // 1. 查询所有消息
      let entityClass = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS) as Record<string, Object>;
      let properties = entityClass.ChatMessage as Record<string, Property>;
      let query = this.messageInfoDao.queryBuilder()
        .orderAsc(properties.id)
        .buildCursor();
      let allMessages = await query.list();

      // 2. 在内存中查找匹配的消息
      let message: ChatMessage | null = null;
      for (let i = 0; i < allMessages.length; i++) {
        if (allMessages[i].getId() === id) {
          message = allMessages[i];
          break;
        }
      }

      if (message) {
        // 3. 解析并更新 content 字段中的 ifSubmit 属性
        try {
          let contentObj = JSON.parse(message.getContent() ?? '') as MessageInfo;
          contentObj.ifSubmit = ifSubmit;
          message.setContent(JSON.stringify(contentObj));
        } catch (e) {
          console.error('解析消息内容失败:', e);
          return;
        }

        // 4. 更新数据库
        await this.messageInfoDao.updateSync(message);
        console.info('数据库更新成功: ID=' + id + ', ifSubmit=' + ifSubmit);
      } else {
        console.error('未找到 ID 为 ' + id + ' 的消息');
      }
    } catch (error) {
      console.error('更新数据库失败:', error);
    }
  }

  // 模拟客服回复
  async simulateServiceReply() {
    if (!this.messageInfoDao) {
      return;
    }

    let messageInfo = new ChatMessage();
    messageInfo.setId(Date.now() + 1); // 使用时间戳作为ID
    messageInfo.setHeadimgurl('service');
    messageInfo.setCustName('客服');
    messageInfo.setContent('您好，我是客服，已收到您的消息："' + this.messageText + '"，我们将会尽快处理您的问题。');
    await this.messageInfoDao.insert(messageInfo);

    // 更新消息列表
    await this.updateMessages();
  }

  // 添加加载更多消息的方法
  async loadMoreMessages() {
    if (!this.messageInfoDao) {
      return;
    }

    let entityClass = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS) as Record<string, Object>;
    let properties = entityClass.ChatMessage as Record<string, Property>;

    // 构建分页查询
    // let query = this.messageInfoDao.queryBuilder()
    //   .orderDesc(properties.id) // 按ID倒序排列（最新的在前面）
    //   .offset(this.currentPage * this.pageSize) // 设置偏移量
    //   .limit(this.pageSize) // 限制返回条数
    //   .buildCursor();
    let query = this.messageInfoDao.queryBuilder()
      .orderDesc(properties.id) // 按ID倒序排列（最新的在前面）
      // .offset(this.currentPage * this.pageSize) // 设置偏移量
      // .limit(this.pageSize) // 限制返回条数
      .buildCursor();

    let moreMessages = await query.list();
    console.log('加载更多消息：', JSON.stringify(moreMessages))
    // this.showMessageList = moreMessages;

    if (moreMessages && moreMessages.length > 0) {
      // 将新加载的消息添加到现有消息列表的开头（因为是历史记录）
      this.messageList = [...moreMessages, ...this.messageList];
      // 遍历每条历史消息并逐个属性赋值
      for (let i = 0; i < moreMessages.length; i++) {
        let chatMessage = moreMessages[i];
        let msgItem = new MsgItem();
        // 逐个属性赋值

        // 复杂对象属性处理
        // msgItem.set_evaluation(chatMessage.getEvaluation());
        msgItem.set_evaluation(JSON.stringify(chatMessage.getEvaluation()) as EvaluationConfig);
        // msgItem.set_evaluationResult(chatMessage.getEvaluationResult());
        // msgItem.set_messageBoardResult(chatMessage.getMessageBoardResult());
        // msgItem.set_messageBoardParams(chatMessage.getMessageBoardParams());

        this.showMessageList.push(msgItem);
      }
      // this.showMessageList = this.messageList;
      this.currentPage++; // 增加页码
    } else {
      // 没有更多数据了
      console.info('没有更多历史消息了');
    }
  }

  async addMessageInfo() {
    if (!this.messageInfoDao) {
      return;
    }
    let messageInfo = new ChatMessage();
    messageInfo.setId(Date.now() + 2);
    messageInfo.setHeadimgurl('system');
    messageInfo.setNickname('系统');
    messageInfo.setContent('欢迎使用在线客服系统');
    await this.messageInfoDao.insert(messageInfo);
  }

  async updateMessages() {
    if (this.messageInfoQuery) {
      this.messageList = await this.messageInfoQuery.list();
    }
  }

  async queryMessage() {
    if (!this.messageInfoDao) {
      return;
    }
    let entityClass = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS) as Record<string, Object>;
    let properties = entityClass.ChatMessage as Record<string, Property>;
    let query = this.messageInfoDao.queryBuilder().orderAsc(properties.id).buildCursor();
    let a = await query.list();
    if (!a) {
      a = [];
    }
    this.messageList = a;
  }

  public aboutToAppear() {
    // this.getAppData();
  }

  async initDatabase() {
    let newVersion = 1;

    // 创建聊天数据库
    let helper: ExampleOpenHelper = new ExampleOpenHelper(this.context, this.super_id + "chat.db");

    // 设置数据库参数
    helper.setEncrypt(false);
    helper.setLogger(true);
    helper.setTrace({
      enabled: false,
      minLevel: DaoTraceSpace.TraceLevel.INFO,
      types: new Set([DaoTraceSpace.TraceType.CRUD])
    });

    // 设置数据库安全等级
    helper.setSecurityLevel(relationalStore.SecurityLevel.S1);

    // 设置数据库版本
    await helper.setVersion(newVersion);
    await helper.setAutoMigrate(true);

    // 注册聊天消息实体
    helper.setEntities(ChatMessage);
    console.info('EntryAbility setEntities ChatMessage =' + JSON.stringify(ChatMessage));

    // 数据库迁移配置（如果需要）
    let migration = new Migration(this.super_id + "chat.db", "CHAT_MESSAGE", newVersion)
      .addColumn("ATTACHMENT_URL", "TEXT");
    helper.setMigration(migration);

    // 获取数据库实例
    let db: Database = await helper.getWritableDb();
    db.name = this.super_id + "chat.db";

    // 设置全局DAO会话
    GlobalContext.getContext().setValue("daoSession", new DaoMaster(db).newSession());
    console.info('Chat database initialized successfully');
  }

  getAppData() {
    let globalContext = GlobalContext.getContext();
    if (!globalContext) {
      return;
    }

    this.daoSession = globalContext.getValue("daoSession") as DaoSession;
    if (!this.daoSession) {
      return;
    }

    this.messageInfoDao = this.daoSession.getBaseDao(ChatMessage);
    if (!this.messageInfoDao) {
      return;
    }

    this.messageInfoDao.addTableChangedListener(this.tabListener())
    let entityClass = globalContext.getValue(GlobalContext.KEY_CLS) as Record<string, Object>;
    if (!entityClass || !entityClass.ChatMessage) {
      return;
    }
    let properties = entityClass.ChatMessage as Record<string, Property>;
    this.messageInfoQuery = this.messageInfoDao.queryBuilder().orderAsc(properties.id).build();
  }

  onBackPress() {
    /**
     * 移除监听
     */
    if (this.messageInfoDao) {
      this.messageInfoDao.removeTableChangedListener();
    }
  }

  tabListener(): OnTableChangedListener<dataRdb.ResultSet> {
    let that = this;
    return {
      async onTableChanged(t: dataRdb.ResultSet, action: TableAction) {
        if (action === TableAction.INSERT) {
          console.info('--------insert--------')
          await that.updateMessages();
        } else if (action === TableAction.UPDATE) {
          console.info('--------edit--------')
          await that.updateMessages();
        } else if (action === TableAction.DELETE) {
          console.info('--------delete--------')
          await that.updateMessages();
        } else if (action === TableAction.QUERY) {
          console.info('--------query-------- any:' + JSON.stringify(t))
        }
      }
    }
  }
}












@Observed
export class MsgItem {
  loadingProgress?: boolean;
  ifSendSuccess?: boolean;
  messageInvalidation?: boolean;
  headimgurl?: string | Resource | PixelMap;
  session_id?: string;
  nickname?: string;
  content?: string | LocationMessage | Record<string, string> | HotQuestionItem[] | ImageTextMessageItem[] | OrderMessage | CartMessageInfo | ChatShop;
  time?: number;
  type?: number;
  leftOrRight?: number;
  messageType?: string;
  send_from?: number;
  ifRead?: boolean;
  cust_name?: string;
  evaluate_msg?: number;
  evaluation_way?: number;
  evaluation?: EvaluationConfig;
  evaluationResult?: EvaluationResult;
  messageBoardResult?: MessageBoardResult;
  messageBoardParams?: Record<string, string>;
  uuid?: string;
  chatEvalResult?: number;
  appid?: string;
  robot_appid?: string;

  constructor(
    loadingProgress?: boolean,
    ifSendSuccess?: boolean,
    messageInvalidation?: boolean,
    headimgurl?: string | Resource | PixelMap,
    session_id?: string,
    nickname?: string,
    content?: string | LocationMessage | Record<string, string> | HotQuestionItem[] | OrderMessage | CartMessageInfo | ChatShop,
    time?: number,
    type?: number,
    leftOrRight?: number,
    messageType?: string,
    send_from?: number,
    ifRead?: boolean,
    cust_name?: string,
    evaluate_msg?: number,
    evaluation_way?: number,
    evaluation?: EvaluationConfig,
    evaluationResult?: EvaluationResult,
    messageBoardResult?: MessageBoardResult,
    messageBoardParams?: Record<string, string>,
    uuid?: string,
    chatEvalResult?: number,
    appid?: string,
    robot_appid?: string
  ) {
    this.loadingProgress = loadingProgress;
    this.ifSendSuccess = ifSendSuccess;
    this.messageInvalidation = messageInvalidation;
    this.headimgurl = headimgurl;
    this.session_id = session_id;
    this.nickname = nickname;
    this.content = content;
    this.type = type;
    this.leftOrRight = leftOrRight;
    this.time = time;
    this.messageType = messageType;
    this.send_from = send_from;
    this.ifRead = ifRead;
    this.cust_name = cust_name;
    this.evaluate_msg = evaluate_msg;
    this.evaluation_way = evaluation_way;
    this.evaluation = evaluation;
    this.evaluationResult = evaluationResult;
    this.messageBoardResult = messageBoardResult;
    this.messageBoardParams = messageBoardParams;
    this.uuid = uuid;
    this.chatEvalResult = chatEvalResult;
    this.appid = appid;
    this.robot_appid = robot_appid;
  }

  get_loadingProgress(): boolean | undefined {
    return this.loadingProgress;
  }

  set_loadingProgress(value: boolean | undefined) {
    this.loadingProgress = value;
  }

  get_ifSendSuccess(): boolean | undefined {
    return this.ifSendSuccess;
  }

  set_ifSendSuccess(value: boolean | undefined) {
    this.ifSendSuccess = value;
  }

  get_messageInvalidation(): boolean | undefined {
    return this.messageInvalidation;
  }

  set_messageInvalidation(value: boolean | undefined) {
    this.messageInvalidation = value;
  }

  get_headimgurl(): string | Resource | PixelMap | undefined {
    return this.headimgurl;
  }

  set_headimgurl(value: string | Resource | PixelMap | undefined) {
    this.headimgurl = value;
  }

  get_session_id(): string | undefined {
    return this.session_id;
  }

  set_session_id(value: string | undefined) {
    this.session_id = value;
  }

  get_nickname(): string | undefined {
    return this.nickname;
  }

  set_nickname(value: string | undefined) {
    this.nickname = value;
  }

  get_content(): string | LocationMessage | Record<string, string> | HotQuestionItem[] | ImageTextMessageItem[] | OrderMessage | CartMessageInfo | ChatShop | undefined {
    return this.content;
  }

  set_content(value: string | LocationMessage | Record<string, string> | HotQuestionItem[] | ImageTextMessageItem[] | OrderMessage | CartMessageInfo | ChatShop | undefined) {
    this.content = value;
  }

  get_type(): number | undefined {
    return this.type;
  }

  set_type(value: number | undefined) {
    this.type = value;
  }

  get_leftOrRight(): number | undefined {
    return this.leftOrRight;
  }

  set_leftOrRight(value: number | undefined) {
    this.leftOrRight = value;
  }

  get_time(): number | undefined {
    return this.time;
  }

  set_time(value: number | undefined) {
    this.time = value;
  }

  get_messageType(): string | undefined {
    return this.messageType;
  }

  set_messageType(value: string | undefined) {
    this.messageType = value;
  }

  get_send_from(): number | undefined {
    return this.send_from;
  }

  set_send_from(value: number | undefined) {
    this.send_from = value;
  }

  get_ifRead(): boolean | undefined {
    return this.ifRead;
  }

  set_ifRead(value: boolean | undefined) {
    this.ifRead = value;
  }

  get_cust_name(): string | undefined {
    return this.cust_name;
  }

  set_cust_name(value: string | undefined) {
    this.cust_name = value;
  }

  get_evaluate_msg(): number | undefined {
    return this.evaluate_msg;
  }

  set_evaluate_msg(value: number | undefined) {
    this.evaluate_msg = value;
  }

  get_evaluation_way(): number | undefined {
    return this.evaluation_way;
  }

  set_evaluation_way(value: number | undefined) {
    this.evaluation_way = value;
  }

  get_evaluation(): EvaluationConfig | undefined {
    return this.evaluation;
  }

  set_evaluation(value: EvaluationConfig | undefined) {
    this.evaluation = value;
  }

  get_evaluationResult(): EvaluationResult | undefined {
    return this.evaluationResult;
  }

  set_evaluationResult(value: EvaluationResult | undefined) {
    this.evaluationResult = value;
  }

  get_messageBoardResult(): MessageBoardResult | undefined {
    return this.messageBoardResult;
  }

  set_messageBoardResult(value: MessageBoardResult | undefined) {
    this.messageBoardResult = value;
  }

  get_messageBoardParams(): Record<string, string> | undefined {
    return this.messageBoardParams;
  }

  set_messageBoardParams(value: Record<string, string> | undefined) {
    this.messageBoardParams = value;
  }

  get_uuid(): string | undefined {
    return this.uuid;
  }

  set_uuid(value: string | undefined) {
    this.uuid = value;
  }

  get_chatEvalResult(): number | undefined {
    return this.chatEvalResult;
  }

  set_chatEvalResult(value: number | undefined) {
    this.chatEvalResult = value;
  }

  get_appid(): string | undefined {
    return this.appid;
  }

  set_appid(value: string | undefined) {
    this.appid = value;
  }

  get_robot_appid(): string | undefined {
    return this.robot_appid;
  }

  set_robot_appid(value: string | undefined) {
    this.robot_appid = value;
  }
}

// 留言结果类
@Observed
export class MessageBoardResult {
  content?: string;
  phone?: string;
  files?: string[];
  ifSubmit?: boolean;
  messageTypeIndex: number = 0
  messageTypeText: string = '咨询'

  constructor(content?: string, phone?: string, files?: string[], ifSubmit?: boolean, messageTypeIndex: number = 0,
    messageTypeText: string = '咨询') {
    this.content = content;
    this.phone = phone;
    this.files = files;
    this.ifSubmit = ifSubmit;
    this.messageTypeIndex = messageTypeIndex;
    this.messageTypeText = messageTypeText;
  }

  get_content(): string | undefined {
    return this.content;
  }

  set_content(value: string | undefined) {
    this.content = value;
  }

  get_phone(): string | undefined {
    return this.phone;
  }

  set_phone(value: string | undefined) {
    this.phone = value;
  }

  get_files(): string[] | undefined {
    return this.files;
  }

  set_files(value: string[] | undefined) {
    this.files = value;
  }

  get_ifSubmit(): boolean | undefined {
    return this.ifSubmit;
  }

  set_ifSubmit(value: boolean | undefined) {
    this.ifSubmit = value;
  }

  get_messageTypeIndex(): number {
    return this.messageTypeIndex;
  }

  set_messageTypeIndex(value: number) {
    this.messageTypeIndex = value;
  }

  get_messageTypeText(): string {
    return this.messageTypeText;
  }

  set_messageTypeText(value: string) {
    this.messageTypeText = value;
  }
}


@Observed
export class EvaluationResult {
  ifSubmit?: boolean;
  currentId?: number;
  childCurrentId?: number;
  grade?: number;
  gradeDetail?: string;
  ifReverse?: boolean;

  constructor(ifSubmit?: boolean, currentId?: number, childCurrentId?: number, grade?: number, gradeDetail?: string,
    ifReverse?: boolean) {
    this.ifSubmit = ifSubmit;
    this.currentId = currentId;
    this.childCurrentId = childCurrentId;
    this.grade = grade;
    this.gradeDetail = gradeDetail;
    this.ifReverse = ifReverse;
  }

  get_ifSubmit(): boolean | undefined {
    return this.ifSubmit;
  }

  set_ifSubmit(value: boolean | undefined) {
    this.ifSubmit = value;
  }

  get_currentId(): number | undefined {
    return this.currentId;
  }

  set_currentId(value: number | undefined) {
    this.currentId = value;
  }

  get_childCurrentId(): number | undefined {
    return this.childCurrentId;
  }

  set_childCurrentId(value: number | undefined) {
    this.childCurrentId = value;
  }

  get_grade(): number | undefined {
    return this.grade;
  }

  set_grade(value: number | undefined) {
    this.grade = value;
  }

  get_gradeDetail(): string | undefined {
    return this.gradeDetail;
  }

  set_gradeDetail(value: string | undefined) {
    this.gradeDetail = value;
  }

  get_ifReverse(): boolean | undefined {
    return this.ifReverse;
  }

  set_ifReverse(value: boolean | undefined) {
    this.ifReverse = value;
  }
}

export interface IMessageResult {
  ret: number;
  data?: IMessageResultData;
  msg?: string;
  request_id?: string;
}

@Observed
export class CMessageResult implements IMessageResult {
  ret: number;
  data?: IMessageResultData;
  msg?: string;
  request_id?: string;

  constructor(data: IMessageResult) {
    this.ret = data.ret;
    this.data = data.data;
    this.msg = data.msg;
    this.request_id = data.request_id;
  }
}

@Observed
export class IMessageResultData {
  type: number;
  content?: Record<string, string>;
  child?: Record<string, string[]>;
  expire?: number;
  guide_words?: string;
  guide_type?: number;
  expire_words?: string;
  success_words?: string;
  comment_config?: IMessageResultCommentConfig[];
  grade?: number;
  expire_status?: number;
  sessionId?: number;
  click?: boolean;

  constructor(type: number, content?: Record<string, string>, child?: Record<string, string[]>,
    expire?: number, guide_words?: string, guide_type?: number, expire_words?: string, success_words?: string,
    comment_config?: IMessageResultCommentConfig[], grade?: number, expire_status?: number,
    sessionId?: number, click?: boolean) {
    this.type = type;
    this.content = content;
    this.child = child;
    this.expire = expire;
    this.guide_words = guide_words;
    this.guide_type = guide_type;
    this.expire_words = expire_words;
    this.success_words = success_words;
    this.comment_config = comment_config;
    this.grade = grade;
    this.expire_status = expire_status;
    this.sessionId = sessionId;
    this.click = click;
  }
}

@Observed
export class EvaluationConfig {
  type?: number;
  content?: Record<string, string | Record<string, string[]>>;
  child?: Record<string, string[]> | string[][];
  expire?: number;
  guide_words?: string;
  guide_type?: number;
  expire_words?: string;
  success_words?: string;
  comment_config?: CommentConfig[];
  grade?: number;
  expire_status?: number;
  sessionId?: number;
  click?: boolean;

  constructor(type?: number, content?: Record<string, string | Record<string, string[]>>,
    child?: Record<string, string[]> | string[][],
    expire?: number, guide_words?: string, guide_type?: number, expire_words?: string, success_words?: string,
    comment_config?: CommentConfig[], grade?: number, expire_status?: number,
    sessionId?: number, click?: boolean) {
    this.type = type;
    this.content = content;
    this.child = child;
    this.expire = expire;
    this.guide_words = guide_words;
    this.guide_type = guide_type;
    this.expire_words = expire_words;
    this.success_words = success_words;
    this.comment_config = comment_config;
    this.grade = grade;
    this.expire_status = expire_status;
    this.sessionId = sessionId;
    this.click = click;
  }
}

@Observed
export class MessageList {
  message: IMessageResultData;
  click: boolean;

  constructor(message: IMessageResultData, click: boolean) {
    this.message = message;
    this.click = click;
  }
}

@Observed
export class CommentConfig {
  content?: string;
  child?: string[];
  grade?: number;
  version?: number;
  selectImgUrl?: string;
  unselectImgUrl?: string;

  constructor(content?: string, child?: string[], grade?: number, version?: number,
    selectImgUrl?: string, unselectImgUrl?: string) {
    this.content = content;
    this.child = child;
    this.grade = grade;
    this.version = version;
    this.selectImgUrl = selectImgUrl;
    this.unselectImgUrl = unselectImgUrl;
  }
}

@Observed
export class IMessageResultCommentConfig {
  content?: string;
  child?: string[];
  grade?: number;
  version?: number;
  selectImgUrl?: string;
  unselectImgUrl?: string;

  constructor(content?: string, child?: string[], grade?: number, version?: number,
    selectImgUrl?: string, unselectImgUrl?: string) {
    this.content = content;
    this.child = child;
    this.grade = grade;
    this.version = version;
    this.selectImgUrl = selectImgUrl;
    this.unselectImgUrl = unselectImgUrl;
  }
}

@Observed
export class MessageFormData {
  grade?: number;
  grade_detail?: string;
  grade_type?: string;

  constructor(grade?: number, grade_detail?: string, grade_type?: string) {
    this.grade = grade;
    this.grade_detail = grade_detail;
    this.grade_type = grade_type;
  }
}


/**
 * 评价类型消息
 */

/**
 * 位置消息类型
 */
@Observed
export class LocationMessage {
  name?: string;
  address?: string;
  tel?: string;
  latitude?: number;
  longitude?: number;
  mapImage?: PixelMap | string;

  constructor(name?: string, address?: string, tel?: string, latitude?: number, longitude?: number,
    mapImage?: PixelMap | string) {
    this.name = name;
    this.address = address;
    this.tel = tel;
    this.latitude = latitude;
    this.longitude = longitude;
    this.mapImage = mapImage
  }

  get_name(): string | undefined {
    return this.name;
  }

  set_name(value: string | undefined) {
    this.name = value;
  }

  get_address(): string | undefined {
    return this.address;
  }

  set_address(value: string | undefined) {
    this.address = value;
  }

  get_tel(): string | undefined {
    return this.tel;
  }

  set_tel(value: string | undefined) {
    this.tel = value;
  }

  get_latitude(): number | undefined {
    return this.latitude;
  }

  set_latitude(value: number | undefined) {
    this.latitude = value;
  }

  get_longitude(): number | undefined {
    return this.longitude;
  }

  set_longitude(value: number | undefined) {
    this.longitude = value;
  }

  get_mapImage(): PixelMap | string | undefined {
    return this.mapImage;
  }

  set_mapImage(value: PixelMap | string | undefined) {
    this.mapImage = value;
  }
}

/**
 *  商品、订单消息体
 */
@Observed
export class ChatShop {
  ToUserName?: string;
  FromUserName?: string;
  CreateTime?: string;
  MsgType?: string;
  MsgId?: string;
  Title?: string;
  AppId?: string;
  PagePath?: string;
  ThumbUrl?: string;
  ThumbMediaId?: string;
  productName?: string; // 商品名称
  price?: string; // 订单为总价格，商品为单价
  RMB_price?: string; // 订单为总价格，商品为单价
  cardType?: number; // 0 订单；1 商品
  orderDate?: string; // 订单日期
  id?: string; // 订单id
  productType?: string; // 商品类型，0 积分商品/订单，1 货币商品/订单
  goodsType?: string;
  iso2o?: string;
  bannerBeanResp?: bannerBeanRespInfo; // 商品跳转对象，仅用于app内部跳转处理，目前只有商品类型才会有该字段
  orderProductDetail?: orderProductDetailItem[]; //订单商品信息，订单类型才会有该数组字段，商品类型该数组字段为空
  shop_name?: string;
  goods_id?: string;
  goods_no?: string;
  picture?: string;
  goods_name?: string;
  sales_price?: string;
  category?: string;
  page_path?: string;
  extra?: Extra; // Extra is a placeholder for any additional information that may be needed
  cardtype?: string;
  order_category?: string;
  order_sn?: string;
  order_type?: string;
  orderStatus?: string; //订单状态
  status?: string;
  payable_score?: string; //积分订单实际支付积分
  payable_money?: string; //积分订单实际支付金额
  spu_id?: string; //娱乐会员的商品id
  pay_score?: string;
  pay_money?: string;
  priceAndIntegral?: string;
  android_price?: string;
  is_virtual?: boolean;
  pay_way?: string;
  url?: string;
  params?: Record<string, string>;
  chatFromEnter?: string;

  constructor(
    ToUserName?: string,
    FromUserName?: string,
    CreateTime?: string,
    MsgType?: string,
    MsgId?: string,
    Title?: string,
    AppId?: string,
    PagePath?: string,
    ThumbUrl?: string,
    ThumbMediaId?: string,
    productName?: string,
    price?: string,
    RMB_price?: string,
    cardType?: number,
    orderDate?: string,
    id?: string,
    productType?: string,
    goodsType?: string,
    iso2o?: string,
    bannerBeanResp?: bannerBeanRespInfo,
    orderProductDetail?: orderProductDetailItem[],
    shop_name?: string,
    goods_id?: string,
    goods_no?: string,
    picture?: string,
    goods_name?: string,
    sales_price?: string,
    category?: string,
    page_path?: string,
    extra?: Extra,
    cardtype?: string,
    order_category?: string,
    order_sn?: string,
    order_type?: string,
    orderStatus?: string,
    status?: string,
    payable_score?: string,
    payable_money?: string,
    spu_id?: string,
    pay_score?: string,
    pay_money?: string,
    android_price?: string,
    is_virtual?: boolean,
    pay_way?: string,
    url?: string,
    params?: Record<string, string>,
    chatFromEnter?: string
  ) {
    this.ToUserName = ToUserName;
    this.FromUserName = FromUserName;
    this.CreateTime = CreateTime;
    this.MsgType = MsgType;
    this.MsgId = MsgId;
    this.Title = Title;
    this.AppId = AppId;
    this.PagePath = PagePath;
    this.ThumbUrl = ThumbUrl;
    this.ThumbMediaId = ThumbMediaId;
    this.productName = productName;
    this.price = price;
    this.RMB_price = RMB_price;
    this.cardType = cardType;
    this.orderDate = orderDate;
    this.id = id;
    this.productType = productType;
    this.goodsType = goodsType;
    this.iso2o = iso2o;
    this.bannerBeanResp = bannerBeanResp;
    this.orderProductDetail = orderProductDetail;
    this.shop_name = shop_name;
    this.goods_id = goods_id;
    this.goods_no = goods_no;
    this.picture = picture;
    this.goods_name = goods_name;
    this.sales_price = sales_price;
    this.category = category;
    this.page_path = page_path;
    this.extra = extra;
    this.cardtype = cardtype;
    this.order_category = order_category;
    this.order_sn = order_sn;
    this.order_type = order_type;
    this.orderStatus = orderStatus;
    this.status = status;
    this.payable_score = payable_score;
    this.payable_money = payable_money;
    this.spu_id = spu_id;
    this.pay_score = pay_score;
    this.pay_money = pay_money;
    this.android_price = android_price;
    this.is_virtual = is_virtual;
    this.pay_way = pay_way;
    this.url = url;
    this.params = params;
    this.chatFromEnter = chatFromEnter;
  }

  get_chatFromEnter(): string | undefined {
    return this.chatFromEnter;
  }

  set_chatFromEnter(value: string | undefined) {
    this.chatFromEnter = value;
  }

  get_params(): Record<string, string> | undefined {
    return this.params;
  }

  set_params(value: Record<string, string> | undefined) {
    this.params = value;
  }

  get_url(): string | undefined {
    return this.url;
  }

  set_url(value: string | undefined) {
    this.url = value;
  }

  get_pay_way(): string | undefined {
    return this.pay_way;
  }

  set_pay_way(value: string | undefined) {
    this.pay_way = value;
  }

  get_is_virtual(): boolean | undefined {
    return this.is_virtual;
  }

  set_is_virtual(value: boolean | undefined) {
    this.is_virtual = value;
  }

  get_ToUserName(): string | undefined {
    return this.ToUserName;
  }

  set_ToUserName(value: string | undefined) {
    this.ToUserName = value;
  }

  get_FromUserName(): string | undefined {
    return this.FromUserName;
  }

  set_FromUserName(value: string | undefined) {
    this.FromUserName = value;
  }

  get_CreateTime(): string | undefined {
    return this.CreateTime;
  }

  set_CreateTime(value: string | undefined) {
    this.CreateTime = value;
  }

  get_MsgType(): string | undefined {
    return this.MsgType;
  }

  set_MsgType(value: string | undefined) {
    this.MsgType = value;
  }

  get_MsgId(): string | undefined {
    return this.MsgId;
  }

  set_MsgId(value: string | undefined) {
    this.MsgId = value;
  }

  get_Title(): string | undefined {
    return this.Title;
  }

  set_Title(value: string | undefined) {
    this.Title = value;
  }

  get_AppId(): string | undefined {
    return this.AppId;
  }

  set_AppId(value: string | undefined) {
    this.AppId = value;
  }

  get_PagePath(): string | undefined {
    return this.PagePath;
  }

  set_PagePath(value: string | undefined) {
    this.PagePath = value;
  }

  get_ThumbUrl(): string | undefined {
    return this.ThumbUrl;
  }

  set_ThumbUrl(value: string | undefined) {
    this.ThumbUrl = value;
  }

  get_ThumbMediaId(): string | undefined {
    return this.ThumbMediaId;
  }

  set_ThumbMediaId(value: string | undefined) {
    this.ThumbMediaId = value;
  }

  get_productName(): string | undefined {
    return this.productName;
  }

  set_productName(value: string | undefined) {
    this.productName = value;
  }

  get_price(): string | undefined {
    return this.price;
  }

  set_price(value: string | undefined) {
    this.price = value;
  }

  get_RMB_price(): string | undefined {
    return this.RMB_price;
  }

  set_RMB_price(value: string | undefined) {
    this.RMB_price = value;
  }

  get_cardType(): number | undefined {
    return this.cardType;
  }

  set_cardType(value: number | undefined) {
    this.cardType = value;
  }

  get_orderDate(): string | undefined {
    return this.orderDate;
  }

  set_orderDate(value: string | undefined) {
    this.orderDate = value;
  }

  get_id(): string | undefined {
    return this.id;
  }

  set_id(value: string | undefined) {
    this.id = value;
  }

  get_productType(): string | undefined {
    return this.productType;
  }

  set_productType(value: string | undefined) {
    this.productType = value;
  }

  get_goodsType(): string | undefined {
    return this.goodsType;
  }

  set_goodsType(value: string | undefined) {
    this.goodsType = value;
  }

  get_iso2o(): string | undefined {
    return this.iso2o;
  }

  set_iso2o(value: string | undefined) {
    this.iso2o = value;
  }

  get_bannerBeanResp(): bannerBeanRespInfo | undefined {
    return this.bannerBeanResp;
  }

  set_bannerBeanResp(value: bannerBeanRespInfo | undefined) {
    this.bannerBeanResp = value;
  }

  get_orderProductDetail(): orderProductDetailItem[] | undefined {
    return this.orderProductDetail;
  }

  set_orderProductDetail(value: orderProductDetailItem[] | undefined) {
    this.orderProductDetail = value;
  }

  get_shop_name(): string | undefined {
    return this.shop_name;
  }

  set_shop_name(value: string | undefined) {
    this.shop_name = value;
  }

  get_goods_id(): string | undefined {
    return this.goods_id;
  }

  set_goods_id(value: string | undefined) {
    this.goods_id = value;
  }

  get_goods_no(): string | undefined {
    return this.goods_no;
  }

  set_goods_no(value: string | undefined) {
    this.goods_no = value;
  }

  get_picture(): string | undefined {
    return this.picture;
  }

  set_picture(value: string | undefined) {
    this.picture = value;
  }

  get_goods_name(): string | undefined {
    return this.goods_name;
  }

  set_goods_name(value: string | undefined) {
    this.goods_name = value;
  }

  get_sales_price(): string | undefined {
    return this.sales_price;
  }

  set_sales_price(value: string | undefined) {
    this.sales_price = value;
  }

  get_category(): string | undefined {
    return this.category;
  }

  set_category(value: string | undefined) {
    this.category = value;
  }

  get_page_path(): string | undefined {
    return this.page_path;
  }

  set_page_path(value: string | undefined) {
    this.page_path = value;
  }

  get_extra(): Extra | undefined {
    return this.extra;
  }

  set_extra(value: Extra | undefined) {
    this.extra = value;
  }

  get_cardtype(): string | undefined {
    return this.cardtype;
  }

  set_cardtype(value: string | undefined) {
    this.cardtype = value;
  }

  get_order_category(): string | undefined {
    return this.order_category;
  }

  set_order_category(value: string | undefined) {
    this.order_category = value;
  }

  get_order_sn(): string | undefined {
    return this.order_sn;
  }

  set_order_sn(value: string | undefined) {
    this.order_sn = value;
  }

  get_order_type(): string | undefined {
    return this.order_type;
  }

  set_order_type(value: string | undefined) {
    this.order_type = value;
  }

  get_orderStatus(): string | undefined {
    return this.orderStatus;
  }

  set_orderStatus(value: string | undefined) {
    this.orderStatus = value;
  }

  get_status(): string | undefined {
    return this.status;
  }

  set_status(value: string | undefined) {
    this.status = value;
  }

  get_payable_score(): string | undefined {
    return this.payable_score;
  }

  set_order_date(value: string | undefined) {
    this.payable_score = value;
  }

  get_payable_money(): string | undefined {
    return this.payable_money;
  }

  set_payable_money(value: string | undefined) {
    this.payable_money = value;
  }

  get_spu_id(): string | undefined {
    return this.payable_score;
  }

  set_spu_id(value: string | undefined) {
    this.spu_id = value;
  }

  get_pay_score(): string | undefined {
    return this.pay_score;
  }

  set_pay_score(value: string | undefined) {
    this.pay_score = value;
  }

  get_pay_money(): string | undefined {
    return this.pay_money;
  }

  set_pay_money(value: string | undefined) {
    this.pay_money = value;
  }

  get_android_price(): string | undefined {
    return this.android_price;
  }

  set_android_price(value: string | undefined) {
    this.android_price = value;
  }


  copyFrom(source: ChatShop): void {
    if (!source) {
      return;
    }

    // 复制基本属性
    this.ToUserName = source.ToUserName;
    this.FromUserName = source.FromUserName;
    this.CreateTime = source.CreateTime;
    this.MsgType = source.MsgType;
    this.MsgId = source.MsgId;
    this.Title = source.Title;
    this.AppId = source.AppId;
    this.PagePath = source.PagePath;
    this.ThumbUrl = source.ThumbUrl;
    this.ThumbMediaId = source.ThumbMediaId;
    this.productName = source.productName;
    this.price = source.price;
    this.RMB_price = source.RMB_price;
    this.cardType = source.cardType;
    this.orderDate = source.orderDate;
    this.id = source.id;
    this.productType = source.productType;
    this.goodsType = source.goodsType;
    this.iso2o = source.iso2o;
    this.shop_name = source.shop_name;
    this.goods_id = source.goods_id;
    this.goods_no = source.goods_no;
    this.picture = source.picture;
    this.goods_name = source.goods_name;
    this.sales_price = source.sales_price;
    this.category = source.category;
    this.page_path = source.page_path;
    this.cardtype = source.cardtype;
    this.order_category = source.order_category;
    this.order_sn = source.order_sn;
    this.order_type = source.order_type;
    this.orderStatus = source.orderStatus;
    this.status = source.status;
    this.payable_score = source.payable_score;
    this.payable_money = source.payable_money;
    this.spu_id = source.spu_id;
    this.pay_score = source.pay_score;
    this.pay_money = source.pay_money;
    this.android_price = source.android_price;

    // 复制嵌套对象 bannerBeanResp
    if (source.bannerBeanResp) {
      this.bannerBeanResp = new bannerBeanRespInfo();
      this.bannerBeanResp.copyFrom(source.bannerBeanResp);
    }

    // 复制嵌套数组 orderProductDetail
    if (source.orderProductDetail) {
      this.orderProductDetail = source.orderProductDetail.map((item: orderProductDetailItem) => {
        const newItem = new orderProductDetailItem();
        newItem.copyFrom(item);
        return newItem;
      });
    }
  }
}

@Observed
export class Extra {
  id?: string;
  productName?: string;
  ThumbUrl?: string;
  price?: string;
  RMB_price?: string;
  cardType?: string;
  productType?: string;
  goodsType?: string;
  iso2o?: string;

  constructor(id?: string, productName?: string, ThumbUrl?: string, price?: string, RMB_price?: string,
    cardType?: string, productType?: string, goodsType?: string, iso2o?: string) {
    this.id = id;
    this.productName = productName;
    this.ThumbUrl = ThumbUrl;
    this.price = price;
    this.RMB_price = RMB_price;
    this.cardType = cardType;
    this.productType = productType;
    this.goodsType = goodsType;
    this.iso2o = iso2o;
  }

  get_id(): string | undefined {
    return this.id;
  }

  set_id(value: string | undefined) {
    this.id
  }

  get_productName(): string | undefined {
    return this.productName;
  }

  set_productName(value: string | undefined) {
    this.productName = value;
  }

  get_ThumbUrl(): string | undefined {
    return this.ThumbUrl;
  }

  set_ThumbUrl(value: string | undefined) {
    this.ThumbUrl = value;
  }

  get_price(): string | undefined {
    return this.price;
  }

  set_price(value: string | undefined) {
    this.price = value;
  }

  get_RMB_price(): string | undefined {
    return this.RMB_price;
  }

  set_RMB_price(value: string | undefined) {
    this.RMB_price = value;
  }

  get_cardType(): string | undefined {
    return this.cardType;
  }

  set_cardType(value: string | undefined) {
    this.cardType = value;
  }

  get_productType(): string | undefined {
    return this.productType;
  }

  set_productType(value: string | undefined) {
    this.productType = value;
  }

  get_goodsType(): string | undefined {
    return this.goodsType;
  }

  set_goodsType(value: string | undefined) {
    this.goodsType = value;
  }

  get_iso2o(): string | undefined {
    return this.iso2o;
  }

  set_iso2o(value: string | undefined) {
    this.iso2o = value;
  }
}


// 订单消息类型
@Observed
export class OrderMessage {
  order_id?: string;
  id?: string; //订单实体传订单id，商品实体传商品id
  order_sn?: string;
  cartType?: string;
  productType?: string; // 商品类型，0 积分商品/订单，1 货币商品/订单
  order_type?: string;
  orderProductDetail?: orderProductDetailItem[]; //订单商品信息，订单类型才会有该数组字段，商品类型该数组字段为空
  bannerBeanResp?: bannerBeanRespInfo;
  orderDate?: string;
  Order_time?: string;
  isDirectShowCompletePrice?: string;
  brand?: string;
  payable_money?: string;
  payable_score?: string;
  MsgType?: string;
  price?: string; // 订单为订单总价，商品为商品价格
  cardType?: number; //0 订单；1 商品
  order_category?: string;
  is_o2o?: string; //纯正附件走精品传0，纯正附件走保养流程传1，其他情况不传
  status?: string;
  AppId?: string;
  productName?: string; //商品名称,订单没有该字段
  goodsType?: string; //"1":"4G","2":"iCall","3":"智能硬件","4":"售后保养套餐","5":"售后保养计划","6":"延保","7":"精品","8":"积分","9":"plus","10":"5G","11":"ecall","12":"爱车","13":"纯正附件"
  FromUserName?: string;

  constructor(
    order_id?: string,
    id?: string,
    order_sn?: string,
    cartType?: string,
    productType?: string,
    order_type?: string,
    orderProductDetail?: orderProductDetailItem[],
    bannerBeanResp?: bannerBeanRespInfo,
    orderDate?: string,
    Order_time?: string,
    isDirectShowCompletePrice?: string,
    brand?: string, payable_money?: string,
    payable_score?: string,
    MsgType?: string,
    price?: string,
    cardType?: number,
    order_category?: string,
    is_o2o?: string,
    status?: string,
    AppId?: string,
    productName?: string,
    goodsType?: string,
    FromUserName?: string
  ) {
    this.order_id = order_id;
    this.id = id;
    this.order_sn = order_sn;
    this.cartType = cartType;
    this.productType = productType;
    this.order_type = order_type;
    this.orderProductDetail = orderProductDetail;
    this.bannerBeanResp = bannerBeanResp;
    this.orderDate = orderDate;
    this.Order_time = Order_time;
    this.isDirectShowCompletePrice = isDirectShowCompletePrice;
    this.brand = brand;
    this.payable_money = payable_money;
    this.payable_score = payable_score;
    this.MsgType = MsgType;
    this.price = price;
    this.cardType = cardType;
    this.order_category = order_category;
    this.is_o2o = is_o2o;
    this.status = status;
    this.AppId = AppId;
    this.productName = productName;
    this.goodsType = goodsType;
    this.FromUserName = FromUserName;
  }

  get_order_id(): string | undefined {
    return this.order_id;
  }

  set_order_id(value: string | undefined) {
    this.order_id = value;
  }

  get_id(): string | undefined {
    return this.id;
  }

  set_id(value: string | undefined) {
    this.id = value;
  }

  get_order_sn(): string | undefined {
    return this.order_sn;
  }

  set_order_sn(value: string | undefined) {
    this.order_sn = value;
  }

  get_cartType(): string | undefined {
    return this.cartType;
  }

  set_cartType(value: string | undefined) {
    this.cartType = value;
  }

  get_productType(): string | undefined {
    return this.productType;
  }

  set_productType(value: string | undefined) {
    this.productType = value;
  }

  get_order_type(): string | undefined {
    return this.order_type;
  }

  set_order_type(value: string | undefined) {
    this.order_type = value;
  }

  get_orderProductDetail(): orderProductDetailItem[] | undefined {
    return this.orderProductDetail;
  }

  set_orderProductDetail(value: orderProductDetailItem[] | undefined) {
    this.orderProductDetail = value;
  }

  get_bannerBeanResp(): bannerBeanRespInfo | undefined {
    return this.bannerBeanResp;
  }

  set_bannerBeanResp(value: bannerBeanRespInfo | undefined) {
    this.bannerBeanResp = value;
  }

  get_orderDate(): string | undefined {
    return this.orderDate;
  }

  set_orderDate(value: string | undefined) {
    this.orderDate = value;
  }

  get_Order_time(): string | undefined {
    return this.Order_time;
  }

  set_Order_time(value: string | undefined) {
    this.Order_time = value;
  }

  get_isDirectShowCompletePrice(): string | undefined {
    return this.isDirectShowCompletePrice;
  }

  set_isDirectShowCompletePrice(value: string | undefined) {
    this.isDirectShowCompletePrice = value;
  }

  get_brand(): string | undefined {
    return this.brand;
  }

  set_brand(value: string | undefined) {
    this.brand = value;
  }

  get_payable_money(): string | undefined {
    return this.payable_money;
  }

  set_payable_money(value: string | undefined) {
    this.payable_money = value;
  }

  get_payable_score(): string | undefined {
    return this.payable_score;
  }

  set_payable_score(value: string | undefined) {
    this.payable_score = value;
  }

  get_MsgType(): string | undefined {
    return this.MsgType;
  }

  set_MsgType(value: string | undefined) {
    this.MsgType = value;
  }

  get_price(): string | undefined {
    return this.price;
  }

  set_price(value: string | undefined) {
    this.price = value;
  }

  get_cardType(): number | undefined {
    return this.cardType;
  }

  set_cardType(value: number | undefined) {
    this.cardType = value;
  }

  get_order_category(): string | undefined {
    return this.order_category;
  }

  set_order_category(value: string | undefined) {
    this.order_category = value;
  }

  get_is_o2o(): string | undefined {
    return this.is_o2o;
  }

  set_is_o2o(value: string | undefined) {
    this.is_o2o = value;
  }

  get_status(): string | undefined {
    return this.status;
  }

  set_status(value: string | undefined) {
    this.status = value;
  }

  get_AppId(): string | undefined {
    return this.AppId;
  }

  set_AppId(value: string | undefined) {
    this.AppId = value;
  }

  get_productName(): string | undefined {
    return this.productName;
  }

  set_productName(value: string | undefined) {
    this.productName = value;
  }

  get_goodsType(): string | undefined {
    return this.goodsType;
  }

  set_goodsType(value: string | undefined) {
    this.goodsType = value;
  }

  get_FromUserName(): string | undefined {
    return this.FromUserName;
  }

  set_FromUserName(value: string | undefined) {
    this.FromUserName = value;
  }
}

@Observed
export class orderProductDetailItem {
  imgUrl?: string;
  productCount?: number;
  id?: string;
  price?: string;
  pay_score?: string;
  pay_money?: string;
  name?: string;
  orderState?: string;
  score_price?: string;

  constructor(imgUrl?: string, productCount?: number, id?: string, price?: string, pay_score?: string,
    pay_money?: string, name?: string, orderState?: string, score_price?: string) {
    this.imgUrl = imgUrl;
    this.productCount = productCount;
    this.id = id;
    this.price = price;
    this.pay_score = pay_score;
    this.pay_money = pay_money;
    this.name = name;
    this.orderState = orderState;
    this.score_price = score_price;
  }

  get_imgUrl(): string | undefined {
    return this.imgUrl;
  }

  set_imgUrl(value: string | undefined) {
    this.imgUrl = value;
  }

  get_productCount(): number | undefined {
    return this.productCount;
  }

  set_productCount(value: number | undefined) {
    this.productCount = value;
  }

  get_id(): string | undefined {
    return this.id;
  }

  set_id(value: string | undefined) {
    this.id = value;
  }

  get_price(): string | undefined {
    return this.price;
  }

  set_price(value: string | undefined) {
    this.price = value;
  }

  get_pay_score(): string | undefined {
    return this.pay_score;
  }

  set_pay_score(value: string | undefined) {
    this.pay_score = value;
  }

  get_pay_money(): string | undefined {
    return this.pay_money;
  }

  set_pay_money(value: string | undefined) {
    this.pay_money = value;
  }

  get_name(): string | undefined {
    return this.name;
  }

  set_name(value: string | undefined) {
    this.name = value;
  }

  get_orderState(): string | undefined {
    return this.orderState;
  }

  set_orderState(value: string | undefined) {
    this.orderState = value;
  }

  get_score_price(): string | undefined {
    return this.score_price;
  }

  set_score_price(value: string | undefined) {
    this.score_price = value;
  }

  copyFrom(source: orderProductDetailItem): void {
    if (!source) {
      return;
    }

    this.imgUrl = source.imgUrl;
    this.productCount = source.productCount;
    this.id = source.id;
    this.price = source.price;
    this.pay_score = source.pay_score;
    this.pay_money = source.pay_money;
    this.name = source.name;
    this.orderState = source.orderState;
    this.score_price = source.score_price;
  }
}

@Observed
export class bannerBeanRespInfo {
  adId?: number;
  bannerVersion?: number;
  image?: string;
  isO2o?: string;
  name?: string;
  needRoundingRadius?: boolean;
  need_login?: number;
  orderType?: number;
  themeStyle?: number;
  type?: number;
  value?: string;

  constructor(adId?: number, bannerVersion?: number, image?: string, isO2o?: string, name?: string,
    needRoundingRadius?: boolean, need_login?: number, orderType?: number, themeStyle?: number, type?: number,
    value?: string) {
    this.adId = adId;
    this.bannerVersion = bannerVersion;
    this.image = image;
    this.isO2o = isO2o;
    this.name = name;
    this.needRoundingRadius = needRoundingRadius;
    this.need_login = need_login;
    this.orderType = orderType;
    this.themeStyle = themeStyle;
    this.type = type;
    this.value = value;
  }

  get_adId(): number | undefined {
    return this.adId;
  }

  set_adId(value: number | undefined) {
    this.adId = value;
  }

  get_bannerVersion(): number | undefined {
    return this.bannerVersion;
  }

  set_bannerVersion(value: number | undefined) {
    this.bannerVersion = value;
  }

  get_image(): string | undefined {
    return this.image;
  }

  set_image(value: string | undefined) {
    this.image = value;
  }

  get_isO2o(): string | undefined {
    return this.isO2o;
  }

  set_isO2o(value: string | undefined) {
    this.isO2o = value;
  }

  get_name(): string | undefined {
    return this.name;
  }

  set_name(value: string | undefined) {
    this.name = value;
  }

  get_needRoundingRadius(): boolean | undefined {
    return this.needRoundingRadius;
  }

  set_needRoundingRadius(value: boolean | undefined) {
    this.needRoundingRadius = value;
  }

  get_need_login(): number | undefined {
    return this.need_login;
  }

  set_need_login(value: number | undefined) {
    this.need_login = value;
  }

  get_orderType(): number | undefined {
    return this.orderType;
  }

  set_orderType(value: number | undefined) {
    this.orderType = value;
  }

  get_themeStyle(): number | undefined {
    return this.themeStyle;
  }

  set_themeStyle(value: number | undefined) {
    this.themeStyle = value;
  }

  get_type(): number | undefined {
    return this.type;
  }

  set_type(value: number | undefined) {
    this.type = value;
  }

  get_value(): string | undefined {
    return this.value;
  }

  set_value(value: string | undefined) {
    this.value = value;
  }

  copyFrom(source: bannerBeanRespInfo): void {
    if (!source) {
      return;
    }

    this.adId = source.adId;
    this.bannerVersion = source.bannerVersion;
    this.image = source.image;
    this.isO2o = source.isO2o;
    this.name = source.name;
    this.needRoundingRadius = source.needRoundingRadius;
    this.need_login = source.need_login;
    this.orderType = source.orderType;
    this.themeStyle = source.themeStyle;
    this.type = source.type;
    this.value = source.value;
  }
}


// 购物车消息类型
@Observed
export class CartMessageInfo {
  AppId?: string;
  CreateTime?: string;
  FromUserName?: string;
  MsgType?: string;
  RMB_price?: string;
  ThumbUrl?: string;
  ToUserName?: string;
  bannerBeanResp?: bannerBeanRespInfo;
  cardType?: number;
  category?: string;
  goodsType?: string;
  goods_no?: string;
  id?: string;
  iso2o?: string;
  order_type?: number;
  price?: string;
  productName?: string;
  productType?: string;

  constructor(AppId?: string, CreateTime?: string, FromUserName?: string, MsgType?: string, RMB_price?: string,
    ThumbUrl?: string, ToUserName?: string, bannerBeanResp?: bannerBeanRespInfo, cardType?: number, category?: string,
    goodsType?: string, goods_no?: string, id?: string, iso2o?: string, order_type?: number, price?: string,
    productName?: string, productType?: string) {
    this.AppId = AppId;
    this.CreateTime = CreateTime;
    this.FromUserName = FromUserName;
    this.MsgType = MsgType;
    this.RMB_price = RMB_price;
    this.ThumbUrl = ThumbUrl;
    this.ToUserName = ToUserName;
    this.bannerBeanResp = bannerBeanResp;
    this.cardType = cardType;
    this.category = category;
    this.goodsType = goodsType;
    this.goods_no = goods_no;
    this.id = id;
    this.iso2o = iso2o;
    this.order_type = order_type;
    this.price = price;
    this.productName = productName;
    this.productType = productType;
  }

  get_AppId(): string | undefined {
    return this.AppId;
  }

  set_AppId(value: string | undefined) {
    this.AppId = value;
  }

  get_CreateTime(): string | undefined {
    return this.CreateTime;
  }

  set_CreateTime(value: string | undefined) {
    this.CreateTime = value;
  }

  get_FromUserName(): string | undefined {
    return this.FromUserName;
  }

  set_FromUserName(value: string | undefined) {
    this.FromUserName = value;
  }

  get_MsgType(): string | undefined {
    return this.MsgType;
  }

  set_MsgType(value: string | undefined) {
    this.MsgType = value;
  }

  get_RMB_price(): string | undefined {
    return this.RMB_price;
  }

  set_RMB_price(value: string | undefined) {
    this.RMB_price = value;
  }

  get_ThumbUrl(): string | undefined {
    return this.ThumbUrl;
  }

  set_ThumbUrl(value: string | undefined) {
    this.ThumbUrl = value;
  }

  get_ToUserName(): string | undefined {
    return this.ToUserName;
  }

  set_ToUserName(value: string | undefined) {
    this.ToUserName = value;
  }

  get_bannerBeanResp(): bannerBeanRespInfo | undefined {
    return this.bannerBeanResp;
  }

  set_bannerBeanResp(value: bannerBeanRespInfo | undefined) {
    this.bannerBeanResp = value;
  }

  get_cardType(): number | undefined {
    return this.cardType;
  }

  set_cardType(value: number | undefined) {
    this.cardType = value;
  }

  get_category(): string | undefined {
    return this.category;
  }

  set_category(value: string | undefined) {
    this.category = value;
  }

  get_goodsType(): string | undefined {
    return this.goodsType;
  }

  set_goodsType(value: string | undefined) {
    this.goodsType = value;
  }

  get_goods_no(): string | undefined {
    return this.goods_no;
  }

  set_goods_no(value: string | undefined) {
    this.goods_no = value;
  }

  get_id(): string | undefined {
    return this.id;
  }

  set_id(value: string | undefined) {
    this.id = value;
  }

  get_iso2o(): string | undefined {
    return this.iso2o;
  }

  set_iso2o(value: string | undefined) {
    this.iso2o = value;
  }

  get_order_type(): number | undefined {
    return this.order_type;
  }

  set_order_type(value: number | undefined) {
    this.order_type = value;
  }

  get_price(): string | undefined {
    return this.price;
  }

  set_price(value: string | undefined) {
    this.price = value;
  }

  get_productName(): string | undefined {
    return this.productName;
  }

  set_productName(value: string | undefined) {
    this.productName = value;
  }

  get_productType(): string | undefined {
    return this.productType;
  }

  set_productType(value: string | undefined) {
    this.productType = value;
  }
}

/**
 * 热门问类型
 */
@Observed
export class HotQuestionItem {
  name?: string;
  topics?: string[];
  classification_id?: number

  constructor(name?: string, topics?: string[], classification_id?: number) {
    this.name = name;
    this.topics = topics;
    this.classification_id = classification_id;
  }

  get_name(): string | undefined {
    return this.name;
  }

  set_name(value: string | undefined) {
    this.name = value;
  }

  get_topics(): string[] | undefined {
    return this.topics;
  }

  set_topics(value: string[] | undefined) {
    this.topics = value;
  }

  get_classification_id(): number | undefined {
    return this.classification_id;
  }

  set_classification_id(value: number | undefined) {
    this.classification_id = value;
  }
}

@Observed
export class ImageTextMessageItem {
  type?: string
  value?: string
}

@Observed
export class RelatedQuestionMessageItem {
  type?: string
  label?: string
  value?: string
  linkValue?: string
}


export interface ClickEvent {
  displayX: number;
  displayY: number;
  windowX: number;
  windowY: number;
  screenX: number;
  screenY: number;
  x: number;
  y: number;
  timestamp: number;
  source: number;
  pressure: number;
  deviceId: number;
  tiltX: number;
  tiltY: number;
  sourceTool: number;
  axisVertical: number;
  axisHorizontal: number;
  target: Target;
}

interface Target {
  area: Area;
}

interface Position {
  x: number;
  y: number;
}

interface Area {
  position: Position;
  globalPosition: Position;
  width: number;
  height: number;
}

export interface RichTextData {
  text: string;
  link: string;
  clickEvent: ClickEvent;
}


@Observed
export class ProductInfo {
  goods_id?: number;
  imgUrl?: string;
  name?: string;
  price?: number;
  RMB_price?: string;
  pay_score?: string;
  pay_money?: string;
  productCount?: number;
  maintainGoodsType?: string;
  lovaCarEnterType?: string;
}

@Observed
export class OrderInfo {
  order_id?: string;
  name?: string;
  productType?: number;
  cash_price?: string;
  integral_price?: string;
  productInfoList?: ProductInfo[];
  orderDate?: string;
  status?: string;
}

@Observed
export class Param {
  orderNum?: string;
}

@Observed
export class OrderCardInfo {
  productInfo?: null;
  orderInfo?: OrderInfo;
  chatFromEnter?: string;
  url?: string;
  param?: Param;
}

@Observed
export class IMUserToken {
  token?: string;
  expire?: number;
}

@Observed
export class CustomerIdInfo {
  appid?: string;
  robot_appid?: string;
  enter?: number;
  user_id?: number;
  associate?: number;
  user_info_id?: number;
  organization_id?: number;
  title?: string;
  k?: string;
  userSig?: string;

  constructor(
    appid?: string,
    robot_appid?: string,
    enter?: number,
    user_id?: number,
    associate?: number,
    user_info_id?: number,
    organization_id?: number,
    title?: string,
    k?: string,
    userSig?: string
  ) {
    this.appid = appid;
    this.robot_appid = robot_appid;
    this.enter = enter;
    this.user_id = user_id;
    this.associate = associate;
    this.user_info_id = user_info_id;
    this.organization_id = organization_id;
    this.title = title;
    this.k = k;
    this.userSig = userSig;
  }
}






