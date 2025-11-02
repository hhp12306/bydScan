/*
 * 图表组件测试页面
 */

import { EChartOptions, Echarts, TooltipComponentOption } from '@byd/echarts';
import webview from '@ohos.web.webview';
@Entry
@Component
struct ChartsTestPage {
  private controller: webview.WebviewController = new webview.WebviewController();
  // 定义柱状图配置，展示一周数据
  @State option: EChartOptions = {
    title: {
      text: '销售额示例柱状图',
      left: 'center',
      textStyle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#333'
      }
    },
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(50,50,50,0.8)',
      borderColor: '#555',
      borderWidth: 1,
      textStyle: {
        color: '#fff',
        fontSize: 14
      },
      // formatter: function(params: any) {
      //   const data = params[0];
      //   return `${data.name}<br/>
      //         <span style="display:inline-block;margin-right:5px;border-radius:10px;width:9px;height:9px;background-color:${data.color}"></span>
      //         ${data.seriesName}: <strong>${data.value} 万元</strong>`;
      // }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '10%',
      top: '15%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: ['一月', '二月', '三月', '四月', '五月', '六月'],
      axisLine: {
        lineStyle: {
          color: '#999'
        }
      },
      axisTick: {
        alignWithLabel: true,
        lineStyle: {
          color: '#999'
        }
      },
      axisLabel: {
        color: '#666',
        fontSize: 12
      }
    },
    yAxis: {
      type: 'value',
      name: '销售额 (万元)',
      nameTextStyle: {
        color: '#666',
        fontSize: 12,
        padding: [0, 0, 0, 10]
      },
      axisLine: {
        show: true,
        lineStyle: {
          color: '#999'
        }
      },
      axisTick: {
        show: true,
        lineStyle: {
          color: '#999'
        }
      },
      splitLine: {
        lineStyle: {
          color: '#eee',
          type: 'dashed'
        }
      },
      axisLabel: {
        color: '#666',
        fontSize: 12,
        formatter: '{value}'
      }
    },
    series: [
      {
        name: '销售额',
        type: 'bar',
        data: [12, 20, 15, 8, 25, 18],
        barWidth: '60%',
        itemStyle: {
          color: '#5470C6',
          borderRadius: [4, 4, 0, 0],
          shadowColor: 'rgba(0, 0, 0, 0.1)',
          shadowBlur: 4,
          shadowOffsetX: 2,
          shadowOffsetY: 2
        },
        // emphasis: {
        //   itemStyle: {
        //     color: '#2c4ba0',
        //     shadowColor: 'rgba(0, 0, 0, 0.3)',
        //     shadowBlur: 8
        //   }
        // },
        label: {
          show: true,
          position: 'top',
          color: '#5470C6',
          fontWeight: 'bold',
          fontSize: 12,
          formatter: '{c} 万元'
        }
      }
    ],
    animation: true,
    animationDuration: 1000,
    animationEasing: 'cubicOut'
  };
  // 定义雷达图配置，展示多维度对比
  @State radarOption: EChartOptions = {
    tooltip: ({
      trigger: 'item'
    } as TooltipComponentOption),
    radar: {
      radius: '30%',
      indicator: [
        { name: '销量', max: 6500 },
        { name: '利润', max: 16000 },
        { name: '市场', max: 30000 },
        { name: '用户', max: 38000 },
        { name: '口碑', max: 52000 },
        { name: '潜力', max: 25000 }
      ]
    },
    series: [
      {
        name: '业务对比',
        type: 'radar',
        data: [
          {
            value: [4300, 10000, 28000, 35000, 50000, 19000],
            name: '本部门'
          },
          {
            value: [5000, 14000, 28000, 31000, 42000, 21000],
            name: '目标值'
          }
        ]
      }
    ]
  };

  build() {
    Column() {
      Row() {
        Text('图表组件测试')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12, top: 12, bottom: 12 })
      }

      // 第一步：渲染柱状图
      Echarts({ options: this.option })
        .width('100%')
        .height(250)

      // 第二步：渲染雷达图
      Echarts({ options: this.radarOption })
        .width('100%')
        .height(300)

      // 通过 Web 载入 rawfile 中的 echarts 演示页面
      // Web({ src: 'resource://rawfile/echarts/index.html', controller: this.controller })
      //   .width('100%')
      //   .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}


