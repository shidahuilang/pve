import os

import redis
import json

current_file_path = os.path.abspath(__file__)

# 获取当前文件所在文件夹的路径
current_folder = os.path.dirname(current_file_path)

print("当前文件夹路径:", current_folder)
r = redis.Redis(host='localhost', port=6379, db=0)

# 导入所有永久数据
with open(f'{current_folder}/permanent_data.json', 'r', encoding='utf-8') as f:
    redis_data = json.load(f)

for key, value in redis_data.items():
    r.set(key, value)

print("Redis 数据已成功导入。")
