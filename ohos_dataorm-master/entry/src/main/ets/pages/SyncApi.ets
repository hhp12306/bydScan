/*
  * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import {
  GlobalContext,
  DaoMaster,
  TableAction,
  Property,
  BaseDao,
  DaoSession,
  Query,
  OnTableChangedListener
} from '@ohos/dataorm';
import { Note } from './Note'
import { NoteType } from './NoteType'
import dataRdb from '@ohos.data.relationalStore';


@Entry
@Component
struct Index {
  private daoSession: DaoSession | null = null;
  private noteDao: BaseDao<Note, number> | null = null;
  private notesQuery: Query<Note> | null = null;
  @State noteList: Note[] = [];
  note1?: Note;
  note2?: Note;
  note3?: Note;
  note4?: Note;
  noteInsertOne?: Note;
  @State selectedNote: Note | null = null;

  async aboutToAppear() {
    this.daoSession = GlobalContext.getContext().getValue("daoSession") as DaoSession;
    this.noteDao = this.daoSession?.getBaseDao(Note) ?? null;
    if (!this.noteDao) {
      return;
    }
    // 添加监听
    this.noteDao.addTableChangedListener(this.tabListener());
    let entityClass = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS) as Record<string, Object>;
    let properties = entityClass.Note as Record<string, Property>;
    this.notesQuery = this.noteDao.queryBuilder().orderAsc(properties.text).build();
  }

  tabListener(): OnTableChangedListener<dataRdb.ResultSet> {
    let that = this;
    return {
      async onTableChanged(t: dataRdb.ResultSet, action: TableAction) {
        if (action === TableAction.INSERT) {
          that.refreshList();
        } else if (action === TableAction.UPDATE) {
          that.refreshList();
        } else if (action === TableAction.DELETE) {
          that.refreshList();
        } else if (action === TableAction.QUERY) {
        }
      }
    }
  }

  refreshList() {
    if (this.notesQuery) {
      // 查询所有数据并刷新界面
      this.noteList = this.notesQuery.listSync() ?? [];
    }
  }

  insertOneSync() {
    if (!this.noteDao) {
      return;
    }
    if (this.noteInsertOne) {
      this.noteInsertOne = new Note();
      this.noteInsertOne.setText('Add One Item');
      this.noteInsertOne.setComment('comment');
      this.noteInsertOne.setType(NoteType[NoteType.TEXT]);
      this.noteDao.insertOrReplaceSync(this.noteInsertOne);
    } else {
      let note = new Note();
      note.setText('Add One Item');
      note.setComment('comment');
      note.setType(NoteType[NoteType.TEXT]);
      this.noteDao.insertOrReplaceSync(note);
    }

  }

  insertBatchSync() {
    if (!this.noteDao) {
      return;
    }
    let noteArr: Note[] = [];
    for (let i = 1; i <= 6; i++) {
      noteArr.push(new Note(undefined, `batch ${i}`, `insertBatchSync ${i}`, '', NoteType[NoteType.TEXT]));
    }
    this.noteDao.insertOrReplaceInTxSync(noteArr);
  }

  list() {
    this.refreshList();
  }

  // 删除首条
  deleteFirstOne() {
    if (!this.noteDao) {
      return;
    }
    // 直接查数据库获取最新数据
    let notes = this.notesQuery?.listSync() ?? [];
    if (!notes || notes.length === 0) {
      return;
    }
    let firstNote = notes[0];
    this.noteDao.deleteSync(firstNote);
  }

  // 批量删除
  deleteBatch() {
    if (!this.noteDao) {
      return;
    }
    let notes = this.notesQuery?.listSync() ?? [];
    if (!notes || notes.length === 0) {
      return;
    }
    this.noteDao.deleteInTxArrSync(...notes);
  }

  // 按Key删除首条
  deleteByKey() {
    if (!this.noteDao) {
      return;
    }
    let notes = this.notesQuery?.listSync() ?? []
    if (!notes || notes.length === 0) {
      return;
    }
    let firstNote = notes[0];
    this.noteDao.deleteByKeySync(firstNote.getId());
  }

  // 按Keys批量删除
  deleteByKeys() {
    if (!this.noteDao) {
      return;
    }
    let notes = this.notesQuery?.listSync() ?? []
    if (!notes || notes.length === 0) {
      return;
    }
    let ids = notes.map(note => note.getId());
    this.noteDao.deleteByKeyInTxArrSync(...ids);
  }

  // 更新首条
  updateFirstOne() {
    if (!this.noteDao) {
      return;
    }
    let notes = this.notesQuery?.listSync() ?? []
    if (!notes || notes.length === 0) {
      return;
    }
    let firstNote = notes[0];
    firstNote.setText(`已更新-${firstNote.text}`);
    firstNote.setComment(`已更新-${firstNote.comment}`);
    this.noteDao.updateSync(firstNote);
  }

  // 加载首条
  load() {
    if (!this.noteDao) {
      return;
    }
    let notes = this.notesQuery?.listSync() ?? []
    if (!notes || notes.length === 0) {
      return;
    }
    let firstId = notes[0].getId();
    let note = this.noteDao.loadSync(firstId);
    this.selectedNote = note;
  }

  loadAll() {
    if (!this.noteDao) {
      return;
    }
    let notes = this.noteDao.loadAllSync();
    this.noteList = notes ?? [];
  }

  saveInTxSync() {
    if (!this.noteDao) {
      return;
    }
    let currentNotes = this.notesQuery?.listSync() ?? []

    // add
    let noteOne = new Note()
    noteOne.setText('abc1')
    noteOne.setComment('saveInTxSync comment')
    noteOne.setType(NoteType[NoteType.TEXT])

    //update
    let noteTwo = new Note()
    noteTwo.setId(currentNotes[0]?.id)
    noteTwo.setText('abc2')
    noteTwo.setComment('saveInTxSync comment')
    noteTwo.setType(NoteType[NoteType.TEXT])


    let entities: Set<Note> = new Set<Note>()
    entities.add(noteOne).add(noteTwo)
    this.noteDao.saveInTxASync(noteOne, noteTwo)
    // this.noteDao.saveInTxSync(entities)
  }

  @Builder
  buildBtn(content: string, callback: () => void) {
    Button(content)
      .size({ width: 88, height: 40 })
      .onClick(callback)
      .padding(0)
      .margin({ right: 2, bottom: 2 })
  }

  build() {
    Column() {
      Text('同步接口demo')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
        .height(50)
      Row() {
        this.buildBtn('插入一条', (): void => this.insertOneSync())
        this.buildBtn('批量插入', (): void => this.insertBatchSync())
        this.buildBtn('刷新', (): void => this.list())
        this.buildBtn('更新首条', (): void => this.updateFirstOne())
      }
      Row() {
        this.buildBtn('删除首条', (): void => this.deleteFirstOne())
        this.buildBtn('批量删除', (): void => this.deleteBatch())
        this.buildBtn('按Key删首条', (): void => this.deleteByKey())
        this.buildBtn('按Keys批量删', (): void => this.deleteByKeys())
      }
      Row() {
        this.buildBtn('加载首条', (): void => this.load())
        this.buildBtn('加载全部', (): void => this.loadAll())
        this.buildBtn('新增或更新第一条', (): void => this.saveInTxSync())
      }
      List({ space: 8 }) {
        ForEach(this.noteList, (item: Note, index: number) => {
          ListItem() {
            Column() {
              Text(`ID: ${item.getId()}  内容: ${item.getText()} 备注: ${item.getComment()}`)
                .fontSize(14)
            }
            .padding(8)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
          }
        })
      }
      .width("100%")
      .height(380)
      if (this.selectedNote) {
        Column() {
          Text('load 首条数据：')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 4 })
          Text(`ID: ${this.selectedNote.getId()}  内容: ${this.selectedNote.getText()} 备注: ${this.selectedNote.getComment()}`)
            .fontSize(14)
        }
        .margin({top: 16})
        .padding(8)
        .backgroundColor('#e0f7fa')
        .borderRadius(8)
      }
    }
    .height('100%')
    .width('100%')
    .padding(16)
  }
}