import redis
import json

import os

# 获取当前执行的 Python 文件的绝对路径
current_file_path = os.path.abspath(__file__)

# 获取当前文件所在文件夹的路径
current_folder = os.path.dirname(current_file_path)

print("当前文件夹路径:", current_folder)


r = redis.Redis(host='localhost', port=6379, db=0)

# 导出所有永久数据
all_keys = r.keys()
permanent_data = {}
for key in all_keys:
    if r.ttl(key) == -1:
        key_str = key.decode('utf-8')
        value = r.get(key).decode('utf-8')
        permanent_data[key_str] = value
with open(f'{current_folder}/permanent_data.json', 'w', encoding='utf-8') as f:
    json.dump(permanent_data, f, ensure_ascii=False, indent=4)
# 清空所有数据
r.flushall()
# 导入所有永久数据
with open(f'{current_folder}/permanent_data.json', 'r', encoding='utf-8') as f:
    redis_data = json.load(f)

for key, value in redis_data.items():
    r.set(key, value)
