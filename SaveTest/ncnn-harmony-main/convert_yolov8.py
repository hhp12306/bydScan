#!/usr/bin/env python3
"""
快速转换YOLOv8模型为NCNN格式
使用方法：
    python convert_yolov8.py yolov8n
    python convert_yolov8.py yolov8s
"""
import sys
import os
from pathlib import Path

def convert_yolov8(model_name='yolov8n'):
    """转换YOLOv8模型为NCNN格式"""
    try:
        from ultralytics import YOLO
    except ImportError:
        print("❌ 错误：请先安装 ultralytics")
        print("   运行: pip install ultralytics")
        return False
    
    print(f"📥 正在下载/加载 {model_name}...")
    try:
        model = YOLO(f'{model_name}.pt')
    except Exception as e:
        print(f"❌ 加载模型失败: {e}")
        return False
    
    print(f"📤 正在导出ONNX格式...")
    try:
        onnx_file = f'{model_name}.onnx'
        model.export(format='onnx', imgsz=640, simplify=True)
        print(f"✅ ONNX文件已生成: {onnx_file}")
    except Exception as e:
        print(f"❌ 导出ONNX失败: {e}")
        return False
    
    print(f"🔄 正在使用pnnx转换为NCNN...")
    try:
        import subprocess
        # 检查pnnx是否可用
        result = subprocess.run(['pnnx', '--version'], 
                              capture_output=True, text=True)
        if result.returncode != 0:
            print("❌ pnnx未安装或不在PATH中")
            print("   请安装pnnx: pip install pnnx")
            print("   或者手动运行: pnnx yolov8n.onnx inputshape=[1,3,640,640]")
            return False
        
        # 转换
        subprocess.run(['pnnx', onnx_file, 'inputshape=[1,3,640,640]'], check=True)
        print(f"✅ NCNN转换完成")
    except subprocess.CalledProcessError as e:
        print(f"❌ pnnx转换失败: {e}")
        print("   请手动运行: pnnx yolov8n.onnx inputshape=[1,3,640,640]")
        return False
    except FileNotFoundError:
        print("❌ pnnx未找到")
        print("   请安装pnnx: pip install pnnx")
        return False
    
    # 重命名文件
    ncnn_param = f'{model_name}.ncnn.param'
    ncnn_bin = f'{model_name}.ncnn.bin'
    final_param = f'{model_name}.param'
    final_bin = f'{model_name}.bin'
    
    if os.path.exists(ncnn_param):
        os.rename(ncnn_param, final_param)
        print(f"✅ 生成 {final_param}")
    else:
        print(f"⚠️  未找到 {ncnn_param}")
    
    if os.path.exists(ncnn_bin):
        os.rename(ncnn_bin, final_bin)
        file_size = os.path.getsize(final_bin) / (1024 * 1024)
        print(f"✅ 生成 {final_bin} ({file_size:.2f} MB)")
    else:
        print(f"⚠️  未找到 {ncnn_bin}")
    
    # 复制到目标目录
    project_root = Path(__file__).parent
    target_dir = project_root / 'tncnn' / 'src' / 'main' / 'resources' / 'rawfile' / 'models'
    
    if target_dir.exists():
        if os.path.exists(final_param):
            import shutil
            shutil.copy(final_param, target_dir)
            print(f"✅ 已复制 {final_param} 到 {target_dir}")
        
        if os.path.exists(final_bin):
            import shutil
            shutil.copy(final_bin, target_dir)
            print(f"✅ 已复制 {final_bin} 到 {target_dir}")
        
        print(f"\n🎉 完成！模型文件已准备好")
        print(f"   现在可以在ModelList.ets中取消YOLOv8的注释了")
    else:
        print(f"⚠️  目标目录不存在: {target_dir}")
        print(f"   请手动复制文件到: tncnn/src/main/resources/rawfile/models/")
    
    return True

if __name__ == '__main__':
    model_name = sys.argv[1] if len(sys.argv) > 1 else 'yolov8n'
    print(f"🚀 开始转换 {model_name} 模型\n")
    success = convert_yolov8(model_name)
    sys.exit(0 if success else 1)


