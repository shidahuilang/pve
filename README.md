# pve

- 进入服务器后,切换到root用户,下面命令一般都切进入root用户,如果不行请自行百度
```sh
sudo -i || su - root
```

- 如果您服务器本身是没密码的,比如谷歌云，甲骨云这些，请设置密码
```sh
echo root:你想要设置的密码 |chpasswd root

比如：
echo root:adminadmin |chpasswd root
```

- 为防止系统没安装curl，使用不了一键命令，使用下面的一键命令之前先执行一次安装curl命令
```sh
apt -y update && apt -y install curl || yum install -y curl || apk add curl bash
```

- 使用root用户登录alpine系统，后执行以下命令安装curl
```sh
apk add curl bash
```

- ### PVE温度硬盘显示
```sh
bash -c  "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/PVE%E6%98%BE%E7%A4%BA%E6%B8%A9%E5%BA%A6%E7%AD%89.sh)"
```
- ###开启ssh
```
sed -i "s/.*PermitRootLogin.*/PermitRootLogin yes/g"   /etc/ssh/sshd_config && systemctl restart sshd.service && service sshd restart
```
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
