#!/bin/bash

# 创建一个目录来存储iRedMail数据
mkdir /iredmail

# 进入目录并创建一个iRedMail配置文件
cd /iredmail
touch iredmail-docker.conf

# 向配置文件中添加必要的信息
echo HOSTNAME=mail.mydomain.com >> iredmail-docker.conf # 设置主机名
echo FIRST_MAIL_DOMAIN=mydomain.com >> iredmail-docker.conf # 设置首个邮件域名
echo FIRST_MAIL_DOMAIN_ADMIN_PASSWORD=dahuilang >> iredmail-docker.conf # 设置首个邮件域管理员密码
echo MLMMJADMIN_API_TOKEN= >> iredmail-docker.conf # 设置MLMMJ API Token（可选）

# 生成一个随机的Roundcube密钥并添加到配置文件中
echo ROUNDCUBE_DES_KEY=$(openssl rand -base64 24) >> iredmail-docker.conf

# 创建iRedMail数据目录结构
mkdir -p data/{backup-mysql,clamav,custom,imapsieve_copy,mailboxes,mlmmj,mlmmj-archive,mysql,sa_rules,ssl,postfix_queue}

# 运行iRedMail容器
docker run \
--rm \
--name iredmail \
--env-file iredmail-docker.conf \
--hostname mail.mydomain.com \
-p 80:80 \
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
