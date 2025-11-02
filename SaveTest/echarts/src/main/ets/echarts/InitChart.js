import * as chart from './echarts.esm.js';

export class HmInitChart {
    constructor(ctx) {
        this.myCharts = chart.init(ctx)
    }

    setOption(option) {
        this.myCharts.setOption({ animation: false, ...option })
    }

    dispose(){
        this.myCharts.dispose()
    }

    registerMap(key,value){
        chart.registerMap(key,JSON.parse(value))
    }

    onClick(cb) {
        this.myCharts.on('click', function (params) {
            cb({
                borderColor: params.borderColor,
                color: params.color,
                componentIndex: params.componentIndex,
                componentSubType: params.componentSubType,
                componentType: params.componentType,
                data: params.data,
                dataIndex: params.dataIndex,
                dataType: params.dataType,
                name: params.name,
                seriesId: params.seriesId,
                seriesIndex: params.seriesIndex,
                seriesName: params.seriesName,
                seriesType: params.seriesType,
                type: params.type,
                value: params.value,
            })
        })
    }

    onTouchEvent(event){
        //0 按下 1 释放 2 移动
        this._initEvent(event)
    }
    // 处理事件机制
    _initEvent(event) {
        const eventNames = [{
            type: '0',
            ecName: 'mousedown'
        }, {
            type: '2',
            ecName: 'mousemove'
        }, {
            type: '1',
            ecName: 'mouseup'
        }, {
            type: '1',
            ecName: 'click'
        }];
        eventNames.forEach(name => {
            if(event.type==name.type){
                const touch = event.touches[0];
                this.myCharts.getZr().handler.dispatch(name.ecName, {
                    zrX: name.type === 'tap' ? touch.screenX : touch.x,
                    zrY: name.type === 'tap' ? touch.screenY : touch.y,
                    preventDefault: () => {},
                    stopImmediatePropagation: () => {},
                    stopPropagation: () => {}
                });
            }

        });
    }
}
