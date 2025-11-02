import { HmInitChart } from './InitChart'
import { ChartType } from './ChartModel'
import { EChartOptions ,ClickParams} from './EChartOption'

@Component
export struct Echarts {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private myChart: ChartType | null = null;

  @Prop @Watch('changeEchartsOption')
  options: EChartOptions;
  onReady = (e:ChartType) => {
  }

  // 子组件的方法
  changeEchartsOption() {
    if (this.myChart) {
      this.myChart.setOption(this.options);
    }
  }

  build() {
    Canvas(this.context)
      .onReady(() => {
        this.myChart = new HmInitChart(this.context) as ChartType;
        this.onReady(this.myChart)
        if (this.options) {
          this.myChart.setOption(this.options);
        }
      })
      .onTouch((event:TouchEvent) => {
        if(this.myChart){
          this.myChart.onTouchEvent(event);
        }
      })
      .width('100%')
      .height('100%')
  }
}
