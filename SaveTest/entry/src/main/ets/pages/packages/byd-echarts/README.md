# @byd/echarts 使用说明（本地包示例）

## 简介
将 ECharts 封装为 ArkUI 组件 `EChart`，以包形式导出，便于后续发布为 HAR 并在 `entry` 中像 `@byd/dataorm` 一样引用。

## 目录结构
```
packages/byd-echarts/
  ├─ index.ets         // 导出入口
  └─ src/
     └─ EChart.ets     // ArkUI 组件实现
resources/rawfile/echarts/index.html  // Web 容器页面，加载 ECharts 并提供 Bridge
```

## 使用
1) 引入组件
```ts
import { EChart } from '../../packages/byd-echarts'
// 未来发布为 HAR 后：
// import { EChart } from '@byd/echarts'
```

2) 在页面中使用
```ts
@Component
struct Demo {
  @State option: any = {
    tooltip: {},
    xAxis: { data: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'] },
    yAxis: {},
    series: [{ type: 'bar', data: [120, 200, 150, 80, 70, 110, 130] }]
  }

  build() {
    Column() {
      EChart({ width: '100%', height: 300, option: this.option, dark: false })
    }
    .width('100%')
    .height('100%')
  }
}
```

3) 动态更新
```ts
// 直接更新 @State option 即可触发 setOption（也可拿到 ref 调用 setOption）
this.option = { ...this.option, darkMode: true }
```

## 发布为 HAR（示意）
- 在独立工程中整理 `byd-echarts` 源码，配置 `oh-package.json5`、`build-profile.json5`
- 执行 `ohpm pack` 生成 `.har`
- 在 App `oh-package.json5` 的 dependencies 中加入：
```json
{
  "@byd/echarts": "^1.0.0"
}
```
- 代码中直接：`import { EChart } from '@byd/echarts'`

## 说明
- 当前示例通过 `Web` 组件 + 本地 `rawfile` HTML 加载 ECharts，并通过 `runJavaScript` 调用页面中暴露的 `window.__byd_echarts__` 接口完成初始化和更新。
- 默认使用 CDN 引入 ECharts，如需离线可将 `echarts.min.js` 放入 `rawfile` 并修改 HTML 引用。
