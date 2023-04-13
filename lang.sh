!/bin/bash
#这个脚本启用了SSH的root登录和密码验证，安装了必要的软件包，并开启了BBR以提高网络性能。
GREEN='\033[0;32m'

YELLOW='\033[1;33m'

NC='\033[0m'

echo "修改ssh配置"
sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

sed -i "s/PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

systemctl restart ssh

echo "开启BBR"
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf

echo "net.ipv4.tcpcongestioncontrol=bbr" >> /etc/sysctl.conf

sysctl -p

echo "修改root密码"
echo root:dahuilang | sudo chpasswd root

echo "允许root登录"
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

echo "允许密码登录"
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config

sudo service sshd restart

echo "卸载man-db"
apt remove man-db

echo "更新并安装curl和wget"
apt -y update && apt -y install curl wget

echo -e "${GREEN}已启用SSH的root登录和密码验证。${NC}"
echo -e "${GREEN}已设置root用户的新密码。${NC}"
echo -e "${GREEN}已安装必要的软件包。${NC}"
echo -e "${GREEN}已开启BBR以提高网络性能。${NC}"

echo "脚本执行完毕！"
