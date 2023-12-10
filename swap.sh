#!/bin/bash

# 提示用户输入交换文件大小
read -p "Enter the swap file size (e.g., 2G, 4G): " swap_size

# 创建交换文件
sudo fallocate -l $swap_size /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久化交换文件
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 更新 swappiness 值
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 验证交换内存是否正常
sudo swapon -s
free -m
