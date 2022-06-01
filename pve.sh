#!/bin/bash
# PVE语言设置
pvelocale(){
	sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen && TIME g "PVE语言包设置完成!"
}
if [ `export|grep 'LC_ALL'|wc -l` = 0 ];then
	pvelocale
	if [ `grep "LC_ALL" /etc/profile|wc -l` = 0 ];then
		echo "export LC_ALL='en_US.UTF-8'" >> /etc/profile
		echo "export LANG='en_US.UTF-8'" >> /etc/profile
	fi
fi
if [ `grep "alias ll" /etc/profile|wc -l` = 0 ];then
	echo "alias ll='ls -alh'" >> /etc/profile
	echo "alias sn='snapraid'" >> /etc/profile
fi
source /etc/profile
# pause
pause(){
    read -n 1 -p " Press any key to continue... " input
    if [[ -n ${input} ]]; then
        echo -e "\b\n"
    fi
}
# 字体颜色设置
TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
	 case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
	  esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
	  }
}


#--------------pve_optimization-start----------------
# apt国内源
aptsources() {
	sver=`cat /etc/debian_version |awk -F"." '{print $1}'`
	case "$sver" in
	11 )
		sver="bullseye"
	;;
	10 )
		sver="buster"
	;;
	9 )
		sver="stretch"
	;;
	8 )
		sver="jessie"
	;;
	7 )
		sver="wheezy"
	;;
	6 )
		sver="squeeze"
	;;
	* )
		sver=""
	;;
	esac
	if [ ! $sver ];then
		TIME r "您的版本不支持！"
		exit 1
	fi
	cp -rf /etc/apt/sources.list /etc/apt/backup/sources.list.bak
	echo " 请选择您需要的apt国内源"
	echo " 1. 清华大学镜像站"
	echo " 2. 中科大镜像站"
	echo " 3. 上海交大镜像站"
	echo " 4. 阿里云镜像站"
	echo " 5. 腾讯云镜像站"
	echo " 6. 网易镜像站"
	echo " 7. 华为镜像站"
	input="请输入选择[默认1]"
	while :; do
	read -t 30 -p " ${input}： " aptsource || echo
	aptsource=${aptsource:-1}
	case $aptsource in
	1)
	cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${sver} main contrib non-free
		deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${sver} main contrib non-free
		deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${sver}-updates main contrib non-free
		deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${sver}-updates main contrib non-free
		deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${sver}-backports main contrib non-free
		deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${sver}-backports main contrib non-free
		deb https://mirrors.tuna.tsinghua.edu.cn/debian-security ${sver}-security main contrib non-free
		deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security ${sver}-security main contrib non-free
	EOF
	break
	;;
	2)
	cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.ustc.edu.cn/debian/ ${sver} main contrib non-free
		deb-src https://mirrors.ustc.edu.cn/debian/ ${sver} main contrib non-free
		deb https://mirrors.ustc.edu.cn/debian/ ${sver}-updates main contrib non-free
		deb-src https://mirrors.ustc.edu.cn/debian/ ${sver}-updates main contrib non-free
		deb https://mirrors.ustc.edu.cn/debian/ ${sver}-backports main contrib non-free
		deb-src https://mirrors.ustc.edu.cn/debian/ ${sver}-backports main contrib non-free
		deb https://mirrors.ustc.edu.cn/debian-security/ ${sver}-security main contrib non-free
		deb-src https://mirrors.ustc.edu.cn/debian-security/ ${sver}-security main contrib non-free
	EOF
	break
	;;  
	3)
	cat > /etc/apt/sources.list <<-EOF
		deb https://mirror.sjtu.edu.cn/debian/ ${sver} main non-free contrib
		deb-src https://mirror.sjtu.edu.cn/debian/ ${sver} main non-free contrib
		deb https://mirror.sjtu.edu.cn/debian/ ${sver}-security main
		deb-src https://mirror.sjtu.edu.cn/debian/ ${sver}-security main
		deb https://mirror.sjtu.edu.cn/debian/ ${sver}-updates main non-free contrib
		deb-src https://mirror.sjtu.edu.cn/debian/ ${sver}-updates main non-free contrib
		deb https://mirror.sjtu.edu.cn/debian/ ${sver}-backports main non-free contrib
		deb-src https://mirror.sjtu.edu.cn/debian/ ${sver}-backports main non-free contrib
	EOF
	break
	;;
	4)
	cat > /etc/apt/sources.list <<-EOF
		deb http://mirrors.aliyun.com/debian/ ${sver} main non-free contrib
		deb-src http://mirrors.aliyun.com/debian/ ${sver} main non-free contrib
		deb http://mirrors.aliyun.com/debian-security/ ${sver}-security main
		deb-src http://mirrors.aliyun.com/debian-security/ ${sver}-security main
		deb http://mirrors.aliyun.com/debian/ ${sver}-updates main non-free contrib
		deb-src http://mirrors.aliyun.com/debian/ ${sver}-updates main non-free contrib
		deb http://mirrors.aliyun.com/debian/ ${sver}-backports main non-free contrib
		deb-src http://mirrors.aliyun.com/debian/ ${sver}-backports main non-free contrib
	EOF
	break
	;;
	5)
	cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.tencent.com/debian/ ${sver} main non-free contrib
		deb-src https://mirrors.tencent.com/debian/ ${sver} main non-free contrib
		deb https://mirrors.tencent.com/debian-security/ ${sver}-security main
		deb-src https://mirrors.tencent.com/debian-security/ ${sver}-security main
		deb https://mirrors.tencent.com/debian/ ${sver}-updates main non-free contrib
		deb-src https://mirrors.tencent.com/debian/ ${sver}-updates main non-free contrib
		deb https://mirrors.tencent.com/debian/ ${sver}-backports main non-free contrib
		deb-src https://mirrors.tencent.com/debian/ ${sver}-backports main non-free contrib
	EOF
	break
	;;
	6)
	cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.163.com/debian/ ${sver} main non-free contrib
		deb-src https://mirrors.163.com/debian/ ${sver} main non-free contrib
		deb https://mirrors.163.com/debian-security/ ${sver}-security main
		deb-src https://mirrors.163.com/debian-security/ ${sver}-security main
		deb https://mirrors.163.com/debian/ ${sver}-updates main non-free contrib
		deb-src https://mirrors.163.com/debian/ ${sver}-updates main non-free contrib
		deb https://mirrors.163.com/debian/ ${sver}-backports main non-free contrib
		deb-src https://mirrors.163.com/debian/ ${sver}-backports main non-free contrib
	EOF
	break
	;;
	7)
	cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.huaweicloud.com/debian/ ${sver} main non-free contrib
		deb-src https://mirrors.huaweicloud.com/debian/ ${sver} main non-free contrib
		deb https://mirrors.huaweicloud.com/debian-security/ ${sver}-security main
		deb-src https://mirrors.huaweicloud.com/debian-security/ ${sver}-security main
		deb https://mirrors.huaweicloud.com/debian/ ${sver}-updates main non-free contrib
		deb-src https://mirrors.huaweicloud.com/debian/ ${sver}-updates main non-free contrib
		deb https://mirrors.huaweicloud.com/debian/ ${sver}-backports main non-free contrib
		deb-src https://mirrors.huaweicloud.com/debian/ ${sver}-backports main non-free contrib
	EOF
	break
	;;
	*)
	TIME r "请输入正确编码！"
	;;
	esac
	done
	TIME g "apt源，更换完成!"
}
# CT模板国内源
ctsources() {
	cp -rf /usr/share/perl5/PVE/APLInfo.pm /usr/share/perl5/PVE/APLInfo.pm.bak
	echo " 请选择您需要的CT模板国内源"
	echo " 1. 清华大学镜像站"
	echo " 2. 中科大镜像站"
	input="请输入选择[默认1]"
	while :; do
	read -t 30 -p " ${input}： " ctsource || echo
	ctsource=${ctsource:-1}
	case $ctsource in
	1)
	sed -i 's|http://download.proxmox.com|https://mirrors.tuna.tsinghua.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
	sed -i 's|http://mirrors.ustc.edu.cn/proxmox|https://mirrors.tuna.tsinghua.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
	break
	;;
	2)
	sed -i 's|http://download.proxmox.com|http://mirrors.ustc.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
	sed -i 's|https://mirrors.tuna.tsinghua.edu.cn/proxmox|http://mirrors.ustc.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
	break
	;;
	*)
	TIME r "请输入正确编码！"
	;;
	esac
	done
	TIME g "CT模板源，更换完成!"
}
# 更换使用帮助源
pvehelp(){
	cp -rf /etc/apt/sources.list.d/pve-no-subscription.list /etc/apt/backup/pve-no-subscription.list.bak
	cat > /etc/apt/sources.list.d/pve-no-subscription.list <<-EOF
deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian ${sver} pve-no-subscription
EOF
	TIME g "使用帮助源，更换完成!"
}
# 关闭企业源
pveenterprise(){
	if [[ -f /etc/apt/sources.list.d/pve-enterprise.list ]];then
		cp -rf /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/backup/pve-enterprise.list.bak
		rm -rf /etc/apt/sources.list.d/pve-enterprise.list
		TIME g "CT模板源，更换完成!"
	else
		TIME g "pve-enterprise.list不存在，忽略!"
	fi
}
# 移除无效订阅
novalidsub(){
	# 移除 Proxmox VE 无有效订阅提示 (6.4-5、6、8、9 、13；7.0-9、10、11已测试通过)
	cp -rf /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak
	sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
	# sed -i 's#if (res === null || res === undefined || !res || res#if (false) {#g' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
	# sed -i '/data.status.toLowerCase/d' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
	TIME g "已移除订阅提示!"
}
pvegpg(){
	cp -rf /etc/apt/trusted.gpg.d/proxmox-release-${sver}.gpg /etc/apt/backup/proxmox-release-${sver}.gpg.bak
	rm -rf /etc/apt/trusted.gpg.d/proxmox-release-${sver}.gpg
	wget -q --timeout=5 --tries=1 --show-progres http://mirrors.ustc.edu.cn/proxmox/debian/proxmox-release-${sver}.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-${sver}.gpg
	if [[ $? -ne 0 ]];then
		TIME r "尝试重新下载..."
		wget -q --timeout=5 --tries=1 --show-progres http://mirrors.ustc.edu.cn/proxmox/debian/proxmox-release-${sver}.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-${sver}.gpg
			if [[ $? -ne 0 ]];then
				TIME r "下载秘钥失败，请检查网络再尝试!"
				sleep 2
				exit 1
		else
			TIME g "密匙下载完成!"
			fi
	else
		TIME g "密匙下载完成!"	
	fi
}
pve_optimization(){
	echo
	clear
	TIME y "提示：PVE原配置文件放入/etc/apt/backup文件夹"
	[[ ! -d /etc/apt/backup ]] && mkdir -p /etc/apt/backup
	echo
	TIME y "※※※※※ 更换apt源... ※※※※※"
	aptsources
	echo
	TIME y "※※※※※ 更换CT模板源... ※※※※※"
	ctsources
	echo
	TIME y "※※※※※ 更换使用帮助源... ※※※※※"
	pvehelp
	echo
	TIME y "※※※※※ 关闭企业源... ※※※※※"
	pveenterprise
	echo
	TIME y "※※※※※ 移除 Proxmox VE 无有效订阅提示... ※※※※※"
	novalidsub
	echo
	TIME y "※※※※※ 下载PVE7.0源的密匙... ※※※※※"
	pvegpg
	echo
	TIME y "※※※※※ 重新加载服务配置文件、重启web控制台... ※※※※※"
	systemctl daemon-reload && systemctl restart pveproxy.service && TIME g "服务重启完成!"
	sleep 3
	echo
	TIME y "※※※※※ 更新源、安装常用软件和升级... ※※※※※"
	# apt-get update && apt-get install -y net-tools curl git
	# apt-get dist-upgrade -y
	TIME y "如需对PVE进行升级，请使用apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y"
	echo
	TIME g "修改完毕！"
}
#--------------pve_optimization-end----------------


#--------------hw_passth-start----------------
# 开启硬件直通
enable_pass(){
	echo
	TIME y "开启硬件直通..."
	if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
		TIME r "您的硬件不支持直通！"
	fi
	if [ `cat /proc/cpuinfo|grep Intel|wc -l` = 0 ];then
		iommu="amd_iommu=on"
	else
		iommu="intel_iommu=on"
	fi
	if [ `grep $iommu /etc/default/grub|wc -l` = 0 ];then
		sed -i 's|quiet|quiet '$iommu'|' /etc/default/grub
		update-grub
		if [ `grep "vfio" /etc/modules|wc -l` = 0 ];then
			cat <<-EOF >> /etc/modules
				vfio
				vfio_iommu_type1
				vfio_pci
				vfio_virqfd
			EOF
		fi
		TIME g "开启设置后需要重启系统，请稍后重启。"
	else
		TIME r "您已经配置过!"
	fi

}
# 关闭硬件直通
disable_pass(){
	echo
	TIME y "关闭硬件直通..."
	if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
		TIME r "您的硬件不支持直通！"
	fi
	if [ `cat /proc/cpuinfo|grep Intel|wc -l` = 0 ];then
		iommu="amd_iommu=on"
	else
		iommu="intel_iommu=on"
	fi
	if [ `grep $iommu /etc/default/grub|wc -l` = 0 ];then
		TIME r "您还没有配置过该项"
	else
		{
			sed -i 's/ '$iommu'//g' /etc/default/grub
			sed -i '/vfio/d' /etc/modules
			sleep 1
		}|TIME g "关闭设置后需要重启系统，请稍后重启。"
		sleep 1
		update-grub
	fi
}
# 硬件直通菜单
hw_passth(){
	while :; do
		clear
		cat <<-EOF
`TIME y "	      配置硬件直通"`
┌──────────────────────────────────────────┐
    1. 开启硬件直通
    2. 关闭硬件直通
├──────────────────────────────────────────┤
    0. 返回
└──────────────────────────────────────────┘
EOF
		echo -ne " 请选择: [ ]\b\b"
		read -t 60 hwmenuid
		hwmenuid=${hwmenuid:-0}
		case "${hwmenuid}" in
		1)
			enable_pass
			pause
			hw_passth
			break
		;;
		2)
			disable_pass
			pause
			hw_passth
			break
		;;
		0)
			menu
			break
		;;
		*)
		;;
		esac
	done
}
#--------------hw_passth-end----------------


#--------------cpu_freq-start----------------
# CPU模式
cpu_governor(){
	governors=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`
	while :; do
		clear
		cat <<EOF
`TIME y "	      设置CPU模式"`
┌──────────────────────────────────────────┐
    1. ondemand		[默认]
    2. conservative
    3. userspace
    4. powersave
    5. performance
    6. schedutil
└──────────────────────────────────────────┘
EOF
		echo -ne " 请选择: [ ]\b\b"
		read -t 10 governorid
		governorid=${governorid:-1}
		case "${governorid}" in
		1)
			governor="ondemand"
		;;
		2)
			governor="conservative"
		;;
		3)
			governor="userspace"
		;;	
		4)
			governor="powersave"
		;;
		5)
			governor="performance"
		;;
		6)
			governor="schedutil"
		;;
		*)
			governor=""
		;;
		esac
		if [[ ${governor} != "" ]]; then
			if [[ -n `echo "${governors}" | grep -o "${governor}"` ]]; then
				TIME g "您选择的CPU模式：${governor}"
				break
			else
				echo "您的CPU不支持该模式！"
				sleep 2
			fi
		fi
	done
}
# CPU最大频率
cpu_maxfreq(){
	echo
	info=`cpufreq-info | grep "hardware limits" | uniq | awk -F: '{print $2}' | sed 's/ //g'`
	echo " 当前CPU默认频率范围：${info}"
	echo " 示例：以J4125为例，最大频率2.7GHz，输入2700000"
	while :; do
		read -t 30 -p " 请输入CPU最大频率[HZ]：" maxfreq || echo
		maxfreq=${maxfreq:-2700000}
		nmax=`echo ${maxfreq} | sed 's/[0-9]//g'`
		if [[ ! -z $nmax ]]; then
			TIME r "输入错误，请重新输入！"
		elif [[ ${maxfreq} -lt 100000 ]] || [[ ${maxfreq} -gt 9000000 ]] || [[ ${maxfreq} == "" ]]; then
			TIME r "貌似输入值的范围不正确，请重新输入！"
		else
			TIME g "CPU最大频率设置为：${maxfreq}"
			break
		fi
	done
}
# CPU最小频率
cpu_minfreq(){
	echo
	info=`cpufreq-info | grep "hardware limits" | uniq | awk -F: '{print $2}' | sed 's/ //g'`
	echo " 当前CPU默认频率范围：${info}"
	echo " 示例：以J4125为例，最小频率800MHz，输入800000"
	while :; do
		read -t 30 -p " 请输入CPU最小频率[HZ]：" minfreq || echo
		minfreq=${minfreq:-800000}
		nmin=`echo ${minfreq} | sed 's/[0-9]//g'`
		if [[ ! -z $nmin ]]; then
			TIME r "输入错误，请重新输入！"
		elif [[ ${minfreq} -lt 100000 ]] || [[ ${minfreq} -gt ${maxfreq} ]] || [[ ${minfreq} == "" ]]; then
			TIME r "貌似输入值的范围不正确，请重新输入！"
		else
			TIME g "CPU最小频率设置为：${minfreq}"
			break
		fi
	done
}
# 设置CPU频率
do_cpufreq(){
	echo
	TIME y "配置CPU模式"
	sleep 1
	install_tools
	if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
		sed -i 's|quiet|quiet intel_pstate=disable|' /etc/default/grub
		update-grub
	fi
	cpu_governor
	cpu_maxfreq
	cpu_minfreq
	cat <<-EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="${governor}"
MAX_SPEED="${maxfreq}"
MIN_SPEED="${minfreq}"
EOF
	echo
	TIME g "已安装好，请稍后重启。"
}
# 还原CPU模式
undo_cpufreq(){
	clear
	TIME y "还原CPU模式"
	cat <<-EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="ondemand"
EOF
	systemctl restart cpufrequtils
	while :; do
		read -t 30 -p " 是否继续？[y/Y或n/N，默认y]：" rmgoon || echo
		rmgoon=${rmgoon:-y}
		case ${rmgoon} in
		y|Y)
			apt -y remove cpufrequtils && \
			sed -i 's/ intel_pstate=disable//g' /etc/default/grub && \
			rm -rf /etc/default/cpufrequtils && TIME g "配置完成!"
			break
		;;
		n|N)
			menu
			break
		;;
		*)
		;;
		esac
	done
}
# CPU模式菜单
cpu_freq(){
	clear
	cat <<-EOF
`TIME y "	      cpufrequtils工具"`
┌──────────────────────────────────────────┐
    1. 安装配置
    2. 还原配置
├──────────────────────────────────────────┤
    0. 返回
└──────────────────────────────────────────┘
EOF
	echo -ne " 请选择: [ ]\b\b"
	read -t 60 cpumenuid
	cpumenuid=${cpumenuid:-0}
	case "${cpumenuid}" in
	1)
		if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
			do_cpufreq
		else
			TIME y "查询到/etc/default/grub存在intel_pstate=disable配置，似乎已经配置过。"
			while :; do
				read -t 10 -p " 是否继续？[y/Y或n/N，默认y]：" chgoon || echo
				chgoon=${chgoon:-y}
				case ${chgoon} in
				y|Y)
					do_cpufreq
					break
				;;
				n|N)
					menu
					break
				;;
				*)
				;;
				esac
			done
		fi
		echo
		pause
		menu
	;;
	2)
		undo_cpufreq
		echo
		pause
		menu
	;;
	0)
		menu
	;;
	*)
		cpu_freq		
	esac
}
#--------------cpu_freq-end----------------


# 安装工具
install_tools(){
	pve_pkgs="cpufrequtils"
	for i in ${pve_pkgs}; do
		if [[ $(apt list --installed | grep -o "^${i}\/" | wc -l) -ge 1 ]]; then
			TIME g "${i} 已安装"
			sleep 3
		else
			clear
			TIME r "${i} 未安装"
			TIME g "开始安装${i} ..."
			apt install -y ${i}
		fi
	done
}


# 主菜单
menu(){
	clear
	cat <<-EOF
`TIME y "	      PVE优化脚本22.03"`
┌──────────────────────────────────────────┐
    1. 一键优化PVE(换源、去订阅等)
    2. 配置PCI硬件直通
    3. CPU睿频模式
    4. CPU、主板、硬盘温度显示
├──────────────────────────────────────────┤
    0. 退出
└──────────────────────────────────────────┘
EOF
	echo -ne " 请选择: [ ]\b\b"
	read -t 60 menuid
	menuid=${menuid:-0}
	case ${menuid} in
	1)
		pve_optimization
		echo
		pause
		menu
	;;
	2)
		hw_passth
		echo
		pause
		menu
	;;
	3)
		cpu_freq
		echo
		pause
		menu
	;;
	4)
		echo
		echo " 敬请期待！"
		echo
		pause
		menu
	;;
	0)
		clear
		exit 0
	;;
	*)
		menu
	;;
	esac
}
menu
