// 轻量封装 ECharts 为 ArkUI 组件，基于 Web 容器加载本地 HTML

@Component
export struct EChart {
  // 图表宽高
  @Prop width: string | number = '100%'
  @Prop height: string | number = 240

  // ECharts option 对象（传入 JS 对象更方便）
  @Prop option: any = {}

  // 是否使用暗色主题
  @Prop dark: boolean = false

  // Web 控制器
  private controller: WebController = new WebController()
  private inited: boolean = false

  aboutToAppear() {
  }

  aboutToDisappear() {
  }

  private applyOption() {
    if (!this.inited) {
      return
    }
    const json = JSON.stringify(this.option || {})
    const theme = this.dark ? 'dark' : 'light'
    // 调用内置的 bridge 更新图表
    this.controller.runJavaScript(`window.__byd_echarts__ && window.__byd_echarts__.setOption(${json}, '${theme}')`)
  }

  build() {
    Web({ src: $rawfile('echarts/index.html') })
      .javaScriptAccess(true)
      .onlineImageAccess(true)
      .domStorageAccess(true)
      .fileAccess(true)
      .enableZoom(false)
      .mixedMode(false)
      .onPageEnd(() => {
        this.inited = true
        // 初始化主题与尺寸
        const theme = this.dark ? 'dark' : 'light'
        const w = typeof this.width === 'number' ? `${this.width}px` : `${this.width}`
        const h = typeof this.height === 'number' ? `${this.height}px` : `${this.height}`
        this.controller.runJavaScript(`window.__byd_echarts__ && window.__byd_echarts__.init('${theme}', '${w}', '${h}')`)
        // 应用配置
        this.applyOption()
      })
      .controller(this.controller)
      .width(this.width)
      .height(this.height)
  }

  // 对外暴露的更新方法
  public setOption(option: any) {
    this.option = option
    this.applyOption()
  }
}


