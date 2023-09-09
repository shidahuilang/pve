import os
import cv2

# 输入视频文件夹路径
input_folder = r'C:\Users\Administrator\Desktop\test\1'

# 输出视频文件夹路径
output_folder = r'C:\Users\Administrator\Desktop\test\2'

# 确保输出文件夹存在
os.makedirs(output_folder, exist_ok=True)

# 加载视频文件列表
video_files = [f for f in os.listdir(input_folder) if f.endswith('.mp4') or f.endswith('.avi')]

# 遍历视频文件
for video_file in video_files:
    # 构造输入视频文件路径
    input_file = os.path.join(input_folder, video_file)
    
    # 打开输入视频文件
    video_capture = cv2.VideoCapture(input_file)
    
    # 获取视频的基本信息
    fps = video_capture.get(cv2.CAP_PROP_FPS)
    width = int(video_capture.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
    
    # 获取音频编解码器
    audio_codec = cv2.VideoWriter_fourcc(*'mp4a')
    
    # 设置视频编码参数
    video_params = (cv2.VideoWriter_fourcc(*'mp4v'), fps, (width, height))
    
    # 设置场景变化阈值（可根据需要调整）
    scene_change_threshold = 50000000
    
    # 初始化场景变量
    prev_scene = None
    scene_frame_count = 0
    scene_count = 1
    video_writer = None
    
    while True:
        # 读取视频帧
        ret, frame = video_capture.read()
        
        if not ret:
            break
        
        # 将当前帧转换为灰度图像
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        if prev_scene is None:
            # 初始化第一个场景
            prev_scene = gray
            continue
        
        # 计算当前帧与前一帧的差异
        frame_diff = cv2.absdiff(prev_scene, gray)
        diff_sum = frame_diff.sum()
        
        if diff_sum > scene_change_threshold:
            if scene_frame_count > 0 and video_writer is not None:
                # 关闭上一个场景的视频写入器
                video_writer.release()
            
            # 场景变化超过阈值，创建新的视频写入器并保存当前场景的视频
            output_file = os.path.join(output_folder, f'{video_file}_scene{scene_count}.mp4')
            video_writer = cv2.VideoWriter(output_file, *video_params, isColor=True)
            scene_count += 1
            scene_frame_count = 0
        
        if video_writer is not None:
            # 保存当前帧到输出视频文件
            video_writer.write(frame)
        
        # 更新前一帧
        prev_scene = gray
        scene_frame_count += 1
    
    # 释放资源
    video_capture.release()
    
    if scene_frame_count > 0 and video_writer is not None:
        video_writer.release()
    
    print(f"视频文件 '{video_file}' 分割完成。")
