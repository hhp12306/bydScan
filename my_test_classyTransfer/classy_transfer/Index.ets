// 导出 class-transformer 的主要功能
export { ClassTransformer } from './src/ClassTransformer';
export * from './src/decorators';
export * from './src/interfaces';
export * from './src/enums';

// 导出主要的转换函数
export {
  classToPlain,
  instanceToPlain,
  classToPlainFromExist,
  plainToClass,
  plainToInstance,
  plainToClassFromExist,
  instanceToInstance,
  classToClassFromExist,
  serialize,
  deserialize,
  deserializeArray
} from './src/index';
