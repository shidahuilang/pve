#!/usr/bin/env bash

# 颜色
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 使用root运行
[[ $EUID -ne 0 ]] && echo -e "[${red}Error${plain}] 请用root权限运行脚本!" && exit 1

# 选择操作
echo -e "${green}请选择您要执行的操作：${plain}"
echo -e "${green}1. PVE开启直通+CPU硬盘温度显示,风扇转速+一键开启换源，去订阅+CPU睿频模式选择${plain}"
echo -e "${green}2. PVE一键升级PVE，lxc换源，去掉无效订阅${plain}"
echo -e "${green}3. 开启ssh+BBR+root登录+密码设置(默认密码：dahuilang)${plain}"
echo -e "${green}4. (centos、ubuntu、debian、alpine)一键开启SSH${plain}"
echo -e "${green}5. 黑群晖cpu正确识别${plain}"
echo -e "${green}6. 黑群晖自动挂载洗白(挂载目录/tmp/boot)${plain}"
echo -e "${green}7. 一键设置交换虚拟分区${plain}"
read -p "请输入要执行的操作编号：" operation

case $operation in
    1)
        bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/pve.sh)"
        ;;
    2)
        bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/pvehy.sh)"
        ;;
    3)
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/shidahuilang/pve/main/lang.sh)"
        ;;
    4)
        bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/ssh.sh)"
        ;;
    5)
        wget -qO ch_cpuinfo_cn.sh https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/ch_cpuinfo_cn.sh && sudo bash ch_cpuinfo_cn.sh
        ;;
    6)
        bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/arpl.sh)"
        ;;
    7)
        bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/shidahuilang/pve/main/swap.sh)"
        ;;
    *)
        echo -e "${red}输入的操作编号无效，请重新运行脚本并输入正确的编号。${plain}"
        ;;
esac
