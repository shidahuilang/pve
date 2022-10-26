#!/usr/bin/env bash
#替换黑群晖序列号进行半洗白
#by 隔壁老英Blichus  1175933588@qq.com

# 颜色
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 使用root运行
[[ $EUID -ne 0 ]] && echo -e "[${red}Error${plain}] 请用root权限运行脚本!" && exit 1

echo -e "$yellow作者 老英 博客 https://blog.dadiopi.top/$plain"
echo -e "$yellow此脚本为替换黑群晖NAS序列号，不适用于二合一引导！$plain"
echo -e "$yellow请使用群晖vm套件新建VirtualDSM进入查看正版序列号！$plain"
echo -e "$yellow博客图文教程https://blog.dadiopi.top/index.php/archives/212/$plain"

#检查是否是优盘引导
echo -e "\n $yello正在检查系统...$plain"
sleep 2s

if [ -b /dev/synoboot1 ]; then
    echo -e "$green检测脚本适用于此系统!$plain"
else
    echo -e "$red没有检测到所需文件，可能为二合一引导不适用于此脚本。$plain" && exit 1
fi

#挂载synoboot1分区
echo -e "$green正在挂载分区..$plain"
sleep 1s
mkdir -p /tmp/boot
cd /dev/ && mount -t vfat synoboot1 /tmp/boot/
if [ $? == 0 ]; then
    echo -e "$green分区挂载成功！$plain"
else
    echo -e "$red分区挂载失败！$plain" && exit 1
fi

#检查grub文件
if [ -f /tmp/boot/grub/grub.cfg ]; then
    echo -e "$green检测到grub文件，正在读取当前序列号..$plain"
    sleep 1s
    SN=$(grep "set sn" /tmp/boot/grub/grub.cfg |cut -c 8-)
    echo -e "$green检测到当前序列号为$SN..$plain"
else 
    echo -e "$red没有检测到grub文件！$plain" && exit 1
fi

#替换序列号
read -p "请输入新的序列号(按回车键确定)    " NEWSN
echo -e "$green新序列号为$NEWSN..$plain"
echo -e "$green正在替换序列号..$plain"
sleep 1
sed -i "s/$SN/$NEWSN/g" /tmp/boot/grub/grub.cfg
if [ $? == 0 ]; then
    echo -e "$green恭喜您，序列号替换成功！请重启系统使配置生效！在控制面板-信息中心查看是否成功。$plain"
else
    echo -e "$red序列号替换失败！$plain" && exit 1
fi









