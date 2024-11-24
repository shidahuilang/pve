import json
import time
import redis
from email.utils import parseaddr

# 判断邮箱地址格式是否有效
def is_valid_email_format(email):
    name, addr = parseaddr(email)
    return '@' in addr and '.' in addr.split('@')[-1]

try:
    r = redis.StrictRedis(host='localhost', port=6379, db=0, decode_responses=True)
    if not r.get("RATE_LIMIT"):
        r.set("RATE_LIMIT", 10)  # 每秒允许访问次数
    if not r.get("TIME_WINDOW"):
        r.set("TIME_WINDOW", 2)  # 时间窗口,单位为秒
    if not r.get("BLOCK_DURATION"):
        r.set("BLOCK_DURATION", 120)  # 封禁时长为120秒
    if not r.get("Tip_at_end_of_chapter"):
        r.set("Tip_at_end_of_chapter", "书源更新地址：http://api.2280.eu.org（Telegram群：https://t.me/dahuilang888）")  # 章尾提醒
    if not r.get("Key_error_user_alert"):
        r.set("Key_error_user_alert", "大灰狼提醒您：")  # 通知
    if not r.get("online_max_requests"):
        r.set("online_max_requests", 100)

    while True:
        admin = input("请输入管理员账号(邮箱)：")
        if not is_valid_email_format(admin):
            print("请输入正确的邮箱账号")
        else:
            break

    r.set("admin", admin)  # 管理员账号
    r.set("password", input("请输入管理员密码："))  # 管理员密码
    net_name = input("请为自己的网站命名：")
    r.set("net_name", net_name)
    qqqun = input("请填写自己的qq群，如不需要，默认管理员qq群（注意：此为qq群分享链接，非群号）：")
    if qqqun:
        r.set("qqqun", qqqun)
    else:
        r.set("qqqun", "https://qm.qq.com/q/WQxJaskYc8")

    while True:
        send_email = input("请输入验证码发送邮箱（重新注册一个163邮箱）：")
        if not is_valid_email_format(admin):
            print("请输入正确的邮箱账号")
        else:
            break
    email_password = input("请输入验证码发送邮箱密码（登录邮箱获取邮箱的授权码）：")
    r.set("send_email",send_email)
    r.set("email_password",email_password)

    print("初始化完成，重启项目请不要再次执行")
except:
    print("请先开启redis数据库")