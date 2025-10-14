import { ObservedChatMessage } from "../../type/MessageType"

@Component
export struct RenderService {
  @ObjectLink item: ObservedChatMessage

  aboutToAppear(): void {

  }
  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start }) {
      Flex({ direction: FlexDirection.Column }) {
        Text(String(this.item.content ?? ''))
          .fontSize(14)
          .fontColor(Color.Black)
          .padding({
            top: 10,
            bottom: 10,
            left: 15,
            right: 15
          })
      }
      .backgroundColor('#e0e0e0')
      .borderRadius(20)
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
  }
}