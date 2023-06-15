#!/bin/bash 

创建交换文件
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

永久化交换文件
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

更新 swappiness 值，使系统更倾向于使用物理内存而非交换内存
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

验证交换内存是否正常
sudo swapon -s
free -m
