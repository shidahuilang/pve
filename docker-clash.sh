#!/bin/bash

read -p "请输入 IP 或者域名：" IP

read -p "请选择操作：安装(A) / 卸载(U): " choice

if [[ $choice =~ ^[Aa]$ ]]; then
# 安装操作
rm -rf /root/sub-web-modify

# 下载 sub-web 源码
git clone https://github.com/youshandefeiyang/sub-web-modify.git sub-web-modify

#修改删除变量文件
rm -rf /root/sub-web-modify/.env
# 下载远程文件
curl -o /root/sub-web-modify/src/views/Subconverter.vue https://raw.githubusercontent.com/shidahuilang/SS-SSR-TG-iptables-bt/main/Subconverter.vue



# 修改 IP 地址
#sed -i "s/127.0.0.1/$IP/g" "/root/sub-web-modify/.env"
sed -i "s/0.0.0.0/$IP/g" "/root/sub-web-modify/src/views/Subconverter.vue"


# 进入构建目录
cd sub-web-modify/

# 开始构建
docker build -t sub-web-modify:latest .

# 运行容器
docker run -d -p 25510:80 --restart unless-stopped --name Sub-web-modify sub-web-modify:latest

#删除目录
cd /root
rm -rf /root/sub-web-modify/

# 处理订阅链接后端
docker pull tindy2013/subconverter:latest

# 新建subconverter目录下载二进制文件
mkdir -p /root/subconverter
cd /root/subconverter
wget https://github.com/MetaCubeX/subconverter/releases/latest/download/subconverter_linux64.tar.gz

# 解压二进制文件
tar -zxf subconverter_linux64.tar.gz

# 运行容器
docker run -d \
--name Subconverter \
--restart=unless-stopped \
-p 25500:25500 \
-v /root/subconverter/subconverter/subconverter:/usr/bin/subconverter \
tindy2013/subconverter:latest

echo "Sub-Web 已经启动，访问 http://$IP:25510 即可使用。"

elif [[ $choice =~ ^[Uu]$ ]]; then
# 卸载操作

read -p "确认要卸载 Sub-Web 应用吗？(Y/N): " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
# 停止并删除 Sub-Web 容器
docker stop sub-web-modify
docker rm sub-web-modify

# 停止并删除 Subconverter 容器
docker stop Subconverter
docker rm Subconverter

# 删除 Sub-Web相关的文件和目录
rm -rf /root/sub-web-modify/

# 删除 Sub-Web 镜像
docker image rmi -f sub-web-modify:latest

# 删除 Subconverter 镜像
docker image rmi -f tindy2013/subconverter:latest

        echo "Sub-Web 应用已成功卸载。"
    else
        echo "取消卸载操作。"
    fi

else
    echo "无效的选择。"
fi
