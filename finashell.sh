#!/bin/sh

# 添加阻止的主机条目
echo "127.0.0.1 www.youtusoft.com" >> /etc/hosts
echo "127.0.0.1 youtusoft.com" >> /etc/hosts
echo "127.0.0.1 hostbuf.com" >> /etc/hosts
echo "127.0.0.1 www.hostbuf.com" >> /etc/hosts
echo "127.0.0.1 dkys.org" >> /etc/hosts
echo "127.0.0.1 tcpspeed.com" >> /etc/hosts
echo "127.0.0.1 www.wn1998.com" >> /etc/hosts
echo "127.0.0.1 wn1998.com" >> /etc/hosts
echo "127.0.0.1 pwlt.wn1998.com" >> /etc/hosts
echo "127.0.0.1 backup.www.hostbuf.com" >> /etc/hosts

# 重启网络服务
/etc/init.d/network restart
