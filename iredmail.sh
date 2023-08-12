#!/bin/bash 

# 提示用户输入主机名
read -p "请输入主机名如：mail.mydomain.com: " hostname

# 提示用户输入首个邮件域名
read -p "请输入首个邮件域名如：mydomain.com: " maildomain

# 提示用户输入首个邮件域管理员密码
read -s -p "请输入首个邮件域管理员密码: " adminpassword
echo

# 提示用户输入MLMMJ API Token（可选）
read -p "请输入MLMMJ API Token（可选）: " mlmmjtoken

# 提示用户输入要映射的主机端口
read -p "请输入要映射的主机端口 (默认为80): " hostport
hostport=${hostport:-80}  # 如果用户未输入，则使用默认值80

# 创建一个目录来存储iRedMail数据
mkdir /root/iredmail

# 进入目录并创建一个iRedMail配置文件
cd /root/iredmail
touch iredmail-docker.conf

# 向配置文件中添加必要的信息
echo "HOSTNAME=$hostname" >> iredmail-docker.conf
echo "FIRST_MAIL_DOMAIN=$maildomain" >> iredmail-docker.conf
echo "FIRST_MAIL_DOMAIN_ADMIN_PASSWORD=$adminpassword" >> iredmail-docker.conf
echo "MLMMJADMIN_API_TOKEN=$mlmmjtoken" >> iredmail-docker.conf

# 生成一个随机的Roundcube密钥并添加到配置文件中
echo "ROUNDCUBE_DES_KEY=$(openssl rand -base64 24)" >> iredmail-docker.conf

# 创建iRedMail数据目录结构
mkdir -p data/{backup-mysql,clamav,custom,imapsieve_copy,mailboxes,mlmmj,mlmmj-archive,mysql,sa_rules,ssl,postfix_queue}

# 运行iRedMail容器
docker run \
--rm \
--name iredmail \
--env-file iredmail-docker.conf \
--hostname $hostname \
-p $hostport:80 \
-p 443:443 \
-p 110:110 \
-p 995:995 \
-p 143:143 \
-p 993:993 \
-p 25:25 \
-p 465:465 \
-p 587:587 \
-v /iredmail/data/backup-mysql:/var/vmail/backup/mysql \
-v /iredmail/data/mailboxes:/var/vmail/vmail1 \
-v /iredmail/data/mlmmj:/var/vmail/mlmmj \
-v /iredmail/data/mlmmj-archive:/var/vmail/mlmmj-archive \
-v /iredmail/data/imapsieve_copy:/var/vmail/imapsieve_copy \
-v /iredmail/data/custom:/opt/iredmail/custom \
-v /iredmail/data/ssl:/opt/iredmail/ssl \
-v /iredmail/data/mysql:/var/lib/mysql \
-v /iredmail/data/clamav:/var/lib/clamav \
-v /iredmail/data/sa_rules:/var/lib/spamassassin \
-v /iredmail/data/postfix_queue:/var/spool/postfix \
iredmail/mariadb:stable
