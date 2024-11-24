# -*- coding: utf-8 -*-
# @Project  : qingtianapi
# @File     : /重启项目自动授权.py
# @Time     : 2024/11/1 18:21
# @Author   : 晴天
# @Email    : wangjie_w123@163.com.com

'''
注： 如果重启项目，请在重启后运行此脚本进行自动授权，自行添加定时任务
'''
import requests

data = {"authCode": "bf4f6b7ef900dc66"}
requests.post("http://doubi.tk//adt", json=data)
