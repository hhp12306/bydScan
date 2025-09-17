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

import { beforeAll, describe, expect, it } from '@ohos/hypium';
import {
  BaseDao,
  ColumnType,
  DaoMaster,
  DaoSession,
  Database,
  GlobalContext,
  Migration,
  Property
} from '@ohos/dataorm';
import { Note } from '../../../main/ets/pages/Note';
import { CTXInstance } from './CTXInstance';
import { ExampleOpenHelper } from './ExampleOpenHelper';

export default function notePageTest() {

  describe('notePageTest', () => {
    let daoSession: DaoSession;
    let noteDao: BaseDao<Note, number>;
    let ctt: Context = CTXInstance.getInstance().getContext();

    beforeAll(async () => {
      let newVersion = 2;
      let helper: ExampleOpenHelper = new ExampleOpenHelper(ctt, "notes.db");
      helper.setEncrypt(true);
      await helper.setVersion(newVersion)
      helper.setEntities(Note);
      let migration: Migration = new Migration("notes.db", "NOTE", newVersion).addColumn("MONEYS", ColumnType.realValue);
      helper.setMigration(migration);
      let db: Database = await helper.getWritableDb();
      db.name = "notes.db";
      daoSession = new DaoMaster(db).newSession();
      noteDao = daoSession.getBaseDao(Note);
      await noteDao.deleteAllAsync();
    })

    /**
     * note继承属性createTime，添加和查询
     */
    it('noteExtendsTest_001', 0, async () => {
      await noteDao.deleteAllAsync();
      let note = new Note();
      let noteText = 'aaa';
      note.setText(noteText);
      let dateString = new Date().toLocaleString();
      note.setCreateTime(dateString);
      await noteDao.insert(note);

      let entityClass = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS) as Record<string, Object>;
      let properties = entityClass.Note as Record<string, Property>;
      let query = noteDao.queryBuilder().where(properties.text.eq(noteText)).build();
      let queryList = await query.list();
      expect(queryList.length).assertLarger(0);

      let queryNote = queryList[0];
      expect(queryNote.getCreateTime()).assertEqual(dateString);
    })

    /**
     * note继承属性createTime，修改
     */
    it('noteExtendsTest_002', 0, async () => {
      await noteDao.deleteAllAsync();
      let noteText = 'aaa';
      let dateString = new Date().toLocaleString();

      let note = new Note();
      note.setText(noteText);
      note.setCreateTime(dateString);
      await noteDao.insert(note);

      let entityClass = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS) as Record<string, Object>;
      let properties = entityClass.Note as Record<string, Property>;
      let query = noteDao.queryBuilder().where(properties.text.eq(noteText)).build();
      let queryList = await query.list();
      expect(queryList.length).assertLarger(0);

      let queryNote = queryList[0];
      let dateString1 = '3/1/2024, 12:00:00 AM';
      queryNote.setCreateTime(dateString1);
      await noteDao.updateAsync(queryNote);
      query = noteDao.queryBuilder().where(properties.createTime.eq(dateString1)).build();
      let queryList1 = await query.list();
      expect(queryList1.length).assertLarger(0);
    })

    /**
     * note继承属性createTime，删除
     */
    it('noteExtendsTest_003', 0, async () => {
      await noteDao.deleteAllAsync();
      let noteText = 'aaa';
      let dateString = new Date().toLocaleString();

      let note = new Note();
      note.setText(noteText);
      note.setCreateTime(dateString);
      await noteDao.insert(note);

      let entityClass = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS) as Record<string, Object>;
      let properties = entityClass.Note as Record<string, Property>;
      let query = noteDao.queryBuilder().where(properties.text.eq(noteText)).build();
      let queryList = await query.list();
      expect(queryList.length).assertLarger(0);

      let deleteQuery = noteDao.queryBuilder().where(properties.createTime.eq(dateString)).buildDelete();
      await deleteQuery.executeDeleteWithoutDetachingEntities();
      let queryList1 = await query.list();
      expect(queryList1.length).assertEqual(0);
    })

  })
}