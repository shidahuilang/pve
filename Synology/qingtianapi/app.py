# -*- coding: utf-8 -*-
# !/usr/bin/python3
# @Time     : 2024/9/05 20:32
# @Author   : 晴天
# @Email    : 1085281124@qq.com
# @File     : app.py
# @Project  : qingtianapi

from core.clear import *
from core.data_monitoring import *
from core.discover import discovers
from core.book_source import *
from core.key import *
from core.multi_detail import multi_details
from core.network_monitoring import *
from core.admin import *
from core.banned import *
from core.detail import *
from core.index import *
from core.online_reader import *
from core.search import *
from core.user_login import *
from core.bookshelf import *
from core.download_book import *


# 封禁模块
@app.before_request
def limit_remote_addr():
    check_memory_usage()
    return limit_remote_addrs()


# 打赏模块
@app.route('/coffee', methods=['GET'])
def coffee():
    qq = r.get("qqqun")
    if not qq:
        qq = "https://qm.qq.com/q/WQxJaskYc8"
    return render_template("coffee.html", qq=qq)


@app.route('/clear', methods=['GET'])
def clear():
    return clears()


@app.route('/get_clear_code', methods=['POST'])
def get_clear_code():
    return get_clear_codes()


@app.route('/clear_vip', methods=['POST'])
def clear_vip():
    return clear_vips()


# 用户登陆模块
@app.route('/user_login', methods=['GET', 'POST'])
def user_login():
    return user_logins()


@app.route('/verify', methods=['GET', 'POST'])
def verify():
    return verifys()


@app.route('/settings', methods=['GET'])
def setting():
    return settings()


@app.route('/billing', methods=['GET'])
def billing():
    return billings()


# 密钥模块
@app.route('/key', methods=['GET'])
def key():
    return keys()


@app.route('/query_key', methods=['POST'])
def query_key():
    return query_keys()


@app.route('/get_code', methods=['POST'])
def send_verification_code():
    return send_verification_codes()


@app.route('/get_key', methods=['POST'])
def get_secret_key():
    return get_secret_keys()


# 首页
@app.route('/', methods=['GET'])
def home():
    return index()


# 首页数据监控
@app.route('/status')
def system_statu():
    return system_status()


@app.route('/api/stats', methods=['GET'])
def get_stat():
    return get_stats()


@app.before_request
def track_request():
    return track_requests()


@app.after_request
def track_sent_data(response):
    return track_sent_datas(response)


# 管理员模块
@app.route('/admin')
def admin():
    return admins()


@app.route('/login', methods=['POST'])
def login_user():
    return login_users()


@app.route('/dashboard')
def dashboard():
    return dashboards()


@app.route('/logout')
def logout():
    return logouts()


@app.route('/api/users')
def get_users():
    return get_userss()


@app.route('/api/update_settings', methods=['POST'])
def update_settings():
    return update_settingss()


@app.route('/api/search_user', methods=['GET'])
def search_user():
    return search_users()


@app.route('/api/toggle_ban/<string:user>', methods=['POST'])
def toggle_ban(user):
    return toggle_bans(user)


@app.route('/api/vip/<string:user>', methods=['POST'])
def vip(user):
    return vips(user)


@app.route('/api/delete_user/<string:user>', methods=['DELETE'])
def delete_user(user):
    return delete_users(user)


@app.route('/detail', methods=['GET'])
def detail():
    return details()


# 搜索模块
@app.route('/search', methods=['GET'])
def search():
    return searchs()


@app.route('/searchNovel', methods=['GET'])
def search_novel():
    return search_novels()


@app.route('/searchCaricature', methods=['GET'])
def search_caricature():
    return search_caricatures()


@app.route('/searchAudio', methods=['GET'])
def search_audio():
    return search_audios()


# 发现页模块
@app.route('/discover', methods=['GET'])
def discover():
    return discovers()


# 详情页模块
@app.route('/multi_detail', methods=['GET'])
def multi_detail():
    return multi_details()


# 阅读模块
@app.route('/reader', methods=['GET'])
def reader():
    return readers()


# 上传书源模块
@app.route('/upload', methods=['POST'])
def upload_file():
    return upload_files()


# 下载模块
@app.route('/download/jijian')
def download_jijian():
    return download_jijians()


@app.route('/download/yuedu')
def download_yuedu():
    return download_yuedus()


@app.route('/download/yueducx')
def download_yueducx():
    return download_yueducxs()


@app.route('/download/xiangse')
def download_xiangse():
    return download_xiangses()


# 在线阅读模块
@app.route('/online_search', methods=['GET'])
def online_search():
    return online_searchs()


@app.route('/online_search_crawler', methods=['GET'])
def online_search_crawler():
    return online_search_crawlers()


@app.route('/online_catalogue', methods=['GET'])
def online_catalogue():
    return online_catalogues()


@app.route('/online_reader', methods=['GET'])
def online_reader():
    return online_readers()


# 书架模块
@app.route('/bookshelf', methods=['GET'])
def bookshelf():
    return bookshelfs()

# 终端模块
@app.route('/terminal', methods=['POST'])
def execute_command():
    return execute_commands()


@app.route('/cmd')
def cmd():
    return cmds()

# 数据同步模块
@app.route('/update_user', methods=['POST'])
def update_user():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No data provided"}), 400
        for key, value in data.items():
            r.set(key, value)
        return jsonify({"message": "Data updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5555)
