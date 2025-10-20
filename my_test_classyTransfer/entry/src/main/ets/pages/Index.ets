// 导入 classy_transfer HAR 包
import { plainToInstance, instanceToPlain, Expose, Type } from 'classy_transfer';

// 示例用户类
class User {
  @Expose()
  id: number = 0;

  @Expose()
  name: string = '';

  @Expose()
  email: string = '';

  constructor(id?: number, name?: string, email?: string) {
    if (id !== undefined) this.id = id;
    if (name !== undefined) this.name = name;
    if (email !== undefined) this.email = email;
  }
}

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State userInfo: string = '';

  // 演示 class-transformer 功能
  private demonstrateClassTransformer() {
    // 创建用户实例
    const user = new User(1, '张三', 'zhangsan@example.com');
    
    // 将类实例转换为普通对象
    const plainUser = instanceToPlain(user);
    console.log('转换为普通对象:', JSON.stringify(plainUser));
    
    // 将普通对象转换为类实例
    const plainData = { id: 2, name: '李四', email: 'lisi@example.com' };
    const userFromPlain = plainToInstance(User, plainData);
    console.log('从普通对象创建用户:', userFromPlain);
    
    this.userInfo = `用户: ${userFromPlain.name} (${userFromPlain.email})`;
  }

  build() {
    RelativeContainer() {
      Column() {
        Text(this.message)
          .id('HelloWorld')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            this.message = 'Welcome';
            this.demonstrateClassTransformer();
          })
        
        if (this.userInfo) {
          Text(this.userInfo)
            .fontSize(16)
            .margin({ top: 20 })
            .textAlign(TextAlign.Center)
        }
      }
    }
    .height('100%')
    .width('100%')
  }
}