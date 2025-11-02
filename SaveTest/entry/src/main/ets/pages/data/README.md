# 数据访问中间层使用指南

## 概述

这个数据访问中间层提供了一个优雅的方式来使用 `@Observed` 装饰器进行数据操作，而不需要直接使用数据库的 `@Entity` 和 `@Columns` 装饰器。它通过映射器模式将前端模型和数据库实体分离，让开发者可以专注于业务逻辑。

## 架构设计

```
前端UI层 (使用@Observed模型)
    ↓
业务服务层 (ChatMessageService)
    ↓
数据访问层 (Repository)
    ↓
数据映射层 (Mapper)
    ↓
数据库实体层 (Entity)
```

## 核心组件

### 1. BaseObservedModel
所有前端数据模型的基类，提供：
- `@Observed` 装饰器支持
- 基础字段管理（id, createTime, updateTime）
- 对象转换方法（toEntity, fromEntity）
- 对象复制和克隆功能

### 2. DataMapper
数据映射器，负责：
- 将 `@Observed` 模型转换为数据库实体
- 将数据库实体转换为 `@Observed` 模型
- 批量转换操作

### 3. BaseRepository
数据访问仓库基类，提供：
- 通用的CRUD操作
- 条件查询
- 批量操作
- 统计功能

### 4. ChatMessageService
业务服务层，提供：
- 业务逻辑封装
- 数据验证
- 错误处理

## 使用步骤

### 1. 创建前端数据模型

```typescript
@Observed
export class ChatMessageModel extends BaseObservedModel {
  content?: string
  time?: number
  messageType?: string
  // ... 其他字段

  constructor(...) {
    super()
    // 初始化字段
  }

  // 实现抽象方法
  toEntity(): ChatMessage {
    const entity = new ChatMessage()
    // 映射字段
    entity.content = this.content
    entity.time = this.time
    // ...
    return entity
  }

  fromEntity(entity: ChatMessage): void {
    this.content = entity.content
    this.time = entity.time
    // ...
  }
}
```

### 2. 创建数据映射器

```typescript
export class ChatMessageMapper implements IDataMapper<ChatMessageModel, ChatMessage> {
  toEntity(model: ChatMessageModel): ChatMessage {
    return model.toEntity()
  }

  toModel(entity: ChatMessage): ChatMessageModel {
    const model = new ChatMessageModel()
    model.fromEntity(entity)
    return model
  }

  toModelList(entities: ChatMessage[]): ChatMessageModel[] {
    return entities.map(entity => this.toModel(entity))
  }
}
```

### 3. 创建数据访问仓库

```typescript
export class ChatMessageRepository extends BaseRepository<ChatMessageModel, ChatMessage> {
  constructor(entityManager: any) {
    super(new ChatMessageMapper(), entityManager)
  }

  // 自定义查询方法
  async findBySessionId(sessionId: string): Promise<ChatMessageModel[]> {
    // 实现特定业务查询
  }
}
```

### 4. 创建业务服务

```typescript
export class ChatMessageService {
  private repository: ChatMessageRepository

  constructor(repository: ChatMessageRepository) {
    this.repository = repository
  }

  async sendMessage(sessionId: string, content: string): Promise<ChatMessageModel> {
    // 业务逻辑处理
    const message = new ChatMessageModel(...)
    const id = await this.repository.save(message)
    message.setId(id)
    return message
  }
}
```

### 5. 在前端页面中使用

```typescript
@Entry
@Component
struct ChatPage {
  @State messageList: ChatMessageModel[] = []
  private chatService: ChatMessageService

  aboutToAppear() {
    this.initDataLayer()
    this.loadMessages()
  }

  private initDataLayer() {
    const entityManager = getEntityManager() // 获取数据库管理器
    const repository = new ChatMessageRepository(entityManager)
    this.chatService = new ChatMessageService(repository)
  }

  private async loadMessages() {
    this.messageList = await this.chatService.getSessionMessages('session_001')
  }

  private async sendMessage(content: string) {
    const message = await this.chatService.sendMessage('session_001', content)
    this.messageList.push(message) // 自动触发UI更新
  }
}
```

## 优势

1. **响应式更新**: 使用 `@Observed` 装饰器，数据变化自动触发UI更新
2. **类型安全**: 完整的TypeScript类型支持
3. **业务分离**: 前端模型和数据库实体分离，便于维护
4. **可扩展性**: 易于添加新的数据模型和业务逻辑
5. **可测试性**: 各层职责清晰，便于单元测试
6. **复用性**: 基础组件可复用于不同的数据模型

## 扩展指南

### 添加新的数据模型

1. 继承 `BaseObservedModel`
2. 实现 `toEntity()` 和 `fromEntity()` 方法
3. 创建对应的映射器和仓库
4. 创建业务服务类

### 自定义查询方法

在Repository中添加自定义查询方法：

```typescript
async findByCustomCondition(condition: any): Promise<ChatMessageModel[]> {
  // 实现自定义查询逻辑
}
```

### 添加数据验证

在Service层添加数据验证：

```typescript
async saveMessage(message: ChatMessageModel): Promise<ChatMessageModel> {
  // 数据验证
  if (!message.getContent()) {
    throw new Error('消息内容不能为空')
  }
  
  // 保存数据
  return await this.repository.save(message)
}
```

## 注意事项

1. 确保所有 `@Observed` 模型都继承自 `BaseObservedModel`
2. 在 `toEntity()` 和 `fromEntity()` 方法中正确映射所有字段
3. 使用 `@State` 装饰器来管理UI状态
4. 在异步操作中正确处理错误
5. 合理使用批量操作来提高性能

## 示例项目

参考 `ChatPageExample.ets` 文件查看完整的使用示例。
