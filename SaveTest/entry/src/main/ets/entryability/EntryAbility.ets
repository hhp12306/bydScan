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

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  async onCreate(want:Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    let newVersion = 1;
    // console.info('EntryAbility onCreate newVersion =' + newVersion);
    // console.info('EntryAbility onCreate oldVersion = 11111111')
    // regular SQLite database
    let helper: ExampleOpenHelper = new ExampleOpenHelper(this.context, "notes.db");
    // console.info('EntryAbility ExampleOpenHelper helper =' + JSON.stringify(helper))
    // 设定数据加密密钥，加密后不可变更，加密和非加密库暂不能切换（普通数据库不能在设定为加密库，加密库不能变更为普通库，一经生成不可变更）
    helper.setEncrypt(false);
    console.info('EntryAbility setEncrypt helper =' + helper)
    helper.setLogger(true)
    // console.info('EntryAbility setLogger helper =' + helper)
    helper.setTrace({
      enabled:false,
      minLevel:DaoTraceSpace.TraceLevel.INFO,
      types:new Set([DaoTraceSpace.TraceType.CRUD])
    })
    // console.info('EntryAbility setTrace helper =' + helper)
    // 设置数据库安全等级，不设置则默认为S1
    helper.setSecurityLevel(relationalStore.SecurityLevel.S1);
    // console.info('EntryAbility getSecurityLevel helper =' + helper.getSecurityLevel())
    // 设置新的数据库版本,如果新版本中包含表更新实例将在这调用onUpgradeDatabase进行表更新
    await helper.setVersion(newVersion)
    // console.info('EntryAbility getVersion setVersion =' + newVersion)
    await helper.setAutoMigrate(true)
    // console.info('EntryAbility setAutoMigrate setVersion =' + helper.getAutoMigrate())
    // 将所有的表(新增,修改,已存在)加到全局
    helper.setEntities(Note, Student);
    console.info('EntryAbility setEntities setEntities =' + JSON.stringify(Note), JSON.stringify(Student))

    // Migration为表更新实例,也可调用Migration.backupDB对当前数据库进行备份
    let migration = new Migration("notes.db", "NOTE", newVersion).addColumn("MONEYS", "REAL");
    console.info('EntryAbility onCreate migration =' + migration)
    // 将所有表更新实例放到ExampleOpenHelper的父级中
    helper.setMigration(migration);
    let db: Database = await helper.getWritableDb();
    db.name = "notes.db";
    console.info('EntryAbility onCreate db =' + db)
    GlobalContext.getContext().setValue("daoSession", new DaoMaster(db).newSession());
    console.info('EntryAbility onCreate GlobalContext.getContext().getValue("daoSession") =' + GlobalContext.getContext().getValue("daoSession"))
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