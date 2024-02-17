
- ### pve虚拟机磁盘路径
```sh 
/var/lib/vz/
```
- ### 虚拟机路径
```sh
/etc/pve/qemu-serve
```
- ### LXC路径
```sh
/etc/pve/nodes/pve/lxc
```
- ### 无需借助任何软件直接转换openwrt的img文件为虚拟磁盘
```sh  
qm importdisk 104 /var/lib/vz/template/iso/1.img local-lvm
```
- ### PVE-LXC容器换源
```sh
sed -i 's|http://download.proxmox.com|https://mirrors.tuna.tsinghua.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
systemctl restart pvedaemon.service
```
- ### pve显示信息
```sh
wget -q -O /root/pve_source.tar.gz 'https://bbs.x86pi.cn/file/topic/2023-11-28/file/01ac88d7d2b840cb88c15cb5e19d4305b2.gz' && tar zxvf /root/pve_source.tar.gz && /root/./pve_source
```
