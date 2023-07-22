- ### pve虚拟机磁盘路径
```sh 
/var/lib/vz/
```sh
- ### 虚拟机路径
```sh
/etc/pve/qemu-serve
```sh
- ### 无需借助任何软件直接转换openwrt的img文件为虚拟磁盘
```sh  
qm importdisk 104 /var/lib/vz/template/iso/1.img local-lvm
```sh
