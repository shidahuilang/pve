#!/bin/bash
# Docker容器状态检测

#----------------------------
# 计划任务，每天20点运行脚本
# 0 20 * * * /bash/docker.sh #Docker容器状态检测
# 手动运行脚本
# /bash/docker.sh
# 添加运行权限
# chmod +x /bash/docker.sh
#----------------------------

docker=$(docker ps -a | grep Exited) && dockerstop=$(awk '{print $(2)}' <<<${docker}) && echo "$dockerstop" >> /var/tmp/dockerlist.md

#排除项目
cat >> /var/tmp/docker.md <<EOF
rubyangxg/jd-qinglong
adguard/adguardhome:latest
oldiy/dosgame-web-docker:latest
johngong/qbittorrent:latest
hectorqin/reader
EOF

# 对比容器停止列表
docker=`grep -Fxvf /var/tmp/docker.md /var/tmp/dockerlist.md`
dockers=`echo $docker | sed 's/ /、/g'`;echo $dockers

# 如果变量有效就发送通知

if [ -n "$docker" ]; then  curl "http://xxxx:xx/push?token=dahuilang&message=🚫容器意外停止，停止列表：$dockers......"; else curl "http://xxxx:xx/push?token=dahuilang&message=🎉所有容器运行正常......"; fi

# 容器出问题才发消息
# if [ -n "$docker" ]; then  curl "http://xxxx:xx/push?token=dahuilang&message=🚫容器意外停止，停止列表：$dockers";fi
# if [ -n "$docker" ]; then  curl "https://api-telegram.workers.dev/bot1622585953:AAxxccff/sendMessage" -d "chat_id=12345678&text=🚫容器意外停止，停止列表:$dockers......"; else curl "https://api-telegram.workers.dev/bot12345:AAGeQmivyLJjVC5xxcc/sendMessage" -d "chat_id=12345678&text=🎉所有容器运行正常......"; fi

# 删除对比更新目录列表
rm -rf /var/tmp/docker.md
rm -rf /var/tmp/dockerlist.md



