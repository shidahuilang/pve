# pve


- 为防止系统没安装curl，使用不了一键命令，使用下面的一键命令之前先执行一次安装curl命令
```sh
apt -y update && apt -y install curl wget || yum install -y curl wget || apk add curl bash
```

- 使用root用户登录alpine系统，后执行以下命令安装curl
```sh
apk add curl bash
```

集合脚本自用
```sh
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/pve/main/set.sh)"
```
- ### clsh订阅转换docker版
```sh
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/pve/main/docker-clash.sh)"
```
- ### PVE开启直通+CPU硬盘温度显示,风扇转速+一键开启换源，去订阅+CPU睿频模式选择
```sh
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/pve/main/pve.sh)"
```
- ### PVE一键升级PVE，lxc换源，去掉无效订阅
```sh
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/pve/main/pvehy.sh)"
```
- ### 开启ssh+BBR+root登录+密码设置(默认密码：dahuilang)
```
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/pve/main/lang.sh)"
```
- ### (centos、ubuntu、debian、alpine)一键开启SSH
```sh
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/pve/main/ssh.sh)"
```
- 黑群晖cpu正确识别
```
wget -qO ch_cpuinfo_cn.sh https://raw.githubusercontent.com/shidahuilang/pve/main/ch_cpuinfo_cn.sh && sudo bash ch_cpuinfo_cn.sh
```
- 黑群晖自动挂载洗白(挂载目录/tmp/boot)
```
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/pve/main/arpl.sh)"
```
- 一键设置交换虚拟分区
```
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/pve/main/swap.sh)"
```
- ### PVE升级系统
```sh
apt update && apt dist-upgrade -y
```
[![Stargazers over time](https://starchart.cc/shidahuilang/pve.svg)](https://starchart.cc/shidahuilang/pve)
