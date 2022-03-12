# pve

#
- 为防止系统没安装curl，使用不了一键命令，使用下面的一键命令之前先执行一次安装curl命令
#

- 使用root用户登录ubuntu或者debian系统，后执行以下命令安装curl
```sh
apt -y update && apt -y install curl
```

- 使用root用户登录centos系统，后执行以下命令安装curl
```sh
yum install -y curl
```

- 使用root用户登录alpine系统，后执行以下命令安装curl
```sh
apk add curl bash
```
#

- ### (centos、ubuntu、debian、alpine)一键开启SSH
```sh
bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/ssh.sh)"
```
---
- ### PVE一键开启换源，去掉订阅
```sh
bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/pvehy.sh)"
```
- ### PVE一键可视化脚本
```sh
bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/PVEauto.sh)"
```

- ### PVE升级系统
```sh
apt update && apt dist-upgrade -y
```
