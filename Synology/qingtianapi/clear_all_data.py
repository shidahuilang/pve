import json

import redis

r = redis.StrictRedis(host='localhost', port=6379, db=0, decode_responses=True)

# 清空所有数据
r.flushall()
print("所有数据库的数据已被清空")


