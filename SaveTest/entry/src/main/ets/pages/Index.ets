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

import { GlobalContext, Property } from '@ohos/dataorm';
import { DaoSession } from '@ohos/dataorm'
import { BaseDao } from '@ohos/dataorm'
import { Query } from '@ohos/dataorm'
import { QueryBuilder } from '@ohos/dataorm'
import { inquiry } from '@ohos/dataorm'
import { TableAction } from '@ohos/dataorm'
import { OnTableChangedListener } from '@ohos/dataorm'
import { Toolbar } from './toolbar'
import { Note } from './Note'
import { NoteType } from './NoteType'
import dataRdb from '@ohos.data.relationalStore';
import { QueryTest, QueryClass } from './util'
import { ExampleOpenHelper } from './ExampleOpenHelper';
import { ChatMessage } from './ChatMessage';
import { RenderService } from './message/RenderService';
import { MessageInfo, ObservedChatMessage } from '../type/MessageType';
import { FeedbackComponent } from './message/FeedbackComponent';
import json from '@ohos.util.json';

@Entry
@Component
struct Index {
  scroller: Scroller = new Scroller()
  @State messageList: Array<ChatMessage> = new Array<ChatMessage>(); // 合并消息列表
  @State showMessageList: Array<ObservedChatMessage> = new Array<ObservedChatMessage>();
  @State editFlag: boolean = false
  // 在状态变量部分添加新变量
  @State currentPage: number = 0; // 当前页码
  @State pageSize: number = 10;   // 每页条数
  @State messageText: string = '' // 聊天输入框内容
  private daoSession: DaoSession | null = null;
  private messageInfoDao: BaseDao<ChatMessage, number | string | Record<string, Object>> | null = null;
  private messageInfoQuery: Query<ChatMessage> | null = null;

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      // 顶部标题栏
      Column(){
        Toolbar({ title: '在线客服初始数据', isBack: true })
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
            ForEach(this.showMessageList, (item: ObservedChatMessage) => {
              ListItem() {
                // 根据发送者类型渲染不同样式的消息
                if (item.nickname === '用户') {
                  RenderService({
                    item: item,
                  })
                } else {
                  FeedbackComponent({
                    item: item,
                    onUpdateDatabase: (id: number, ifSubmit: boolean): Promise<void> => this.updateMessageInDatabase(id, ifSubmit)
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
    messageInfo.setNickname('用户');
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

  async storeSpecialMessage(){
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
          let contentObj = JSON.parse(message.getContent()) as MessageInfo;
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
    messageInfo.setNickname('客服');
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
      this.showMessageList = this.messageList;
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