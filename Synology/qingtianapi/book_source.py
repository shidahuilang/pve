# -*- coding: utf-8 -*-
# @Time     : 2024/10/11 22:47
# @Author   : 晴天
# @Email    : 1085281124@qq.com
# @File     : core/download.py
# @Project  : qingtian

from flask import send_file, request, jsonify
import os

current_directory = os.getcwd()


def download_jijians():
    return send_file(f'{current_directory}/file/jjyd.mrs', as_attachment=True)


def download_yuedus():
    return send_file(f'{current_directory}/file/azyd.json', as_attachment=True)


def download_yueducxs():
    return send_file(f'{current_directory}/file/cxyd.json', as_attachment=True)


def download_xiangses():
    return send_file(f'{current_directory}/file/xsgg.xbs', as_attachment=True)


# 上传目录
UPLOAD_FOLDER = f'{current_directory}/file/'


def upload_files():
    # 保存各文件
    files = request.files
    messages = []

    # 安卓阅读书源 (JSON)
    if 'androidSource' in files:
        android_file = files['androidSource']
        if android_file.filename.endswith('.json'):
            android_file.save(os.path.join(UPLOAD_FOLDER, "azyd.json"))
            messages.append(f"\n{android_file.filename} (安卓书源) 上传成功\n")
        else:
            messages.append(f"\n{android_file.filename} (安卓书源) 格式错误\n")

    # 纯享阅读书源 (JSON)
    if 'pureReadSource' in files:
        pure_read_file = files['pureReadSource']
        if pure_read_file.filename.endswith('.json'):
            pure_read_file.save(os.path.join(UPLOAD_FOLDER, "cxyd.json"))
            messages.append(f"\n{pure_read_file.filename} (纯享书源) 上传成功\n")
        else:
            messages.append(f"\n{pure_read_file.filename} (纯享书源) 格式错误\n")

    # 极简阅读书源 (MRS)
    if 'minimalSource' in files:
        minimal_file = files['minimalSource']
        if minimal_file.filename.endswith('.mrs'):
            minimal_file.save(os.path.join(UPLOAD_FOLDER, "jjyd.mrs"))
            messages.append(f"\n{minimal_file.filename} (极简书源) 上传成功\n")
        else:
            messages.append(f"\n{minimal_file.filename} (极简书源) 格式错误\n")

    # 香色闺阁书源 (XBS)
    if 'xiangseSource' in files:
        xiangse_file = files['xiangseSource']
        if xiangse_file.filename.endswith('.xbs'):
            xiangse_file.save(os.path.join(UPLOAD_FOLDER, 'xsgg.xbs'))
            messages.append(f"\n{xiangse_file.filename} (香色书源) 上传成功\n")
        else:
            messages.append(f"\n{xiangse_file.filename} (香色书源) 格式错误\n")

    return jsonify({'message': ''.join(messages)})
