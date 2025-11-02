import { EChartOptions,ClickParams } from "./EChartOption"

type onClickEvent = (e: ClickParams) => void;

export declare class ChartType {
  constructor(context: CanvasRenderingContext2D);

  setOption(options: EChartOptions | null): void;

  onClick(cb: onClickEvent): void

  onTouchEvent(options:TouchEvent|ClickEvent): void;

  dispose(): void;

  registerMap(key:string,value:string): void;
}