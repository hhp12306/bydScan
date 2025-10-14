import { MessageInfo, ObservedChatMessage } from '../../type/MessageType'
import { ChatMessage } from '../ChatMessage'
import { BaseDao } from '@ohos/dataorm'

// FeedbackComponent.ets
@Component
export struct FeedbackComponent {
  @ObjectLink item: ObservedChatMessage
  private content: MessageInfo = new MessageInfo()
  @State feedbackText: string = ''
  @State contactInfo: string = ''
  @State isSubmitting: boolean = false
  // 添加数据库操作的回调函数
  onUpdateDatabase?: (id: number, ifSubmit: boolean) => Promise<void>

  aboutToAppear(): void {
    this.content = JSON.parse(String(this.item.content)) as MessageInfo
    this.isSubmitting = this.content.ifSubmit ?? false
    console.log('content:', this.content.ifSubmit)
  }

  build() {
    Column({ space: 15 }) {
      Text('留言反馈')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 10 })

      Text(this.content?.content)
        .fontSize(16)
        .maxLines(5)

      Button(this.isSubmitting ? '提交中...' : '提交留言')
        // .enabled(!this.isSubmitting)
        .width('90%')
        .height(45)
        .borderRadius(8)
        .backgroundColor(this.isSubmitting ? '#cccccc' : '#007AFF')
        .fontColor(Color.White)
        .onClick(async () => {
          // 修改本地状态（用于UI显示）
          this.isSubmitting = !this.isSubmitting
          
          console.log('submit feedback')
          
          // 同步修改数据库
          // 注意：不需要修改 this.content，因为数据库更新会在 updateMessageInDatabase 中处理
          try {
            if (this.onUpdateDatabase && this.item.id) {
              console.log('update database')
              await this.onUpdateDatabase(this.item.id, this.isSubmitting)
            }
          } catch (error) {
            console.error('Failed to update database:', error)
            // 如果更新失败，恢复状态
            this.isSubmitting = !this.isSubmitting
          }
        })
    }
    .width('100%')
    .padding(20)
  }

}
