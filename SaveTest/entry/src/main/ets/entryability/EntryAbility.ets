import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { ExampleOpenHelper } from '../pages/ExampleOpenHelper';
import { GlobalContext, DaoTraceUtil, DaoTraceSpace } from '@ohos/dataorm'
import { relationalStore } from '@kit.ArkData';
import { Note } from '../pages/Note';
import { Migration } from '@ohos/dataorm';
import { DaoMaster } from '@ohos/dataorm';
import { Database } from '@ohos/dataorm';
import json from '@ohos.util.json';
import { Student } from '../pages/Student';
import { ChatMessage } from '../pages/ChatMessage';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  async onCreate(want:Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    let newVersion = 1;

    // 创建聊天数据库
    let helper: ExampleOpenHelper = new ExampleOpenHelper(this.context, "chat.db");

    // 设置数据库参数
    helper.setEncrypt(false);
    helper.setLogger(true);
    helper.setTrace({
      enabled:false,
      minLevel:DaoTraceSpace.TraceLevel.INFO,
      types:new Set([DaoTraceSpace.TraceType.CRUD])
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
    let migration = new Migration("chat.db", "CHAT_MESSAGE", newVersion)
      .addColumn("ATTACHMENT_URL", "TEXT");
    helper.setMigration(migration);

    // 获取数据库实例
    let db: Database = await helper.getWritableDb();
    db.name = "chat.db";

    // 设置全局DAO会话
    GlobalContext.getContext().setValue("daoSession", new DaoMaster(db).newSession());
    console.info('Chat database initialized successfully');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}