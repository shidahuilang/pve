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
    read -n 1 -p " 按任意键继续... " input
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


#--------------PVE更换软件源----------------
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
#--------------PVE更换软件源----------------


#--------------开启硬件直通----------------
# 开启硬件直通
enable_pass(){
	echo
	TIME y "开启硬件直通..."
	if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
		TIME r "您的硬件不支持直通！"
		pause
		menu
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
				kvmgt
			EOF
		fi
		
	if [ ! -f "/etc/modprobe.d/blacklist.conf" ];then
       echo "blacklist snd_hda_intel" >> /etc/modprobe.d/blacklist.conf 
       echo "blacklist snd_hda_codec_hdmi" >> /etc/modprobe.d/blacklist.conf 
       echo "blacklist i915" >> /etc/modprobe.d/blacklist.conf 
       fi


    if [ ! -f "/etc/modprobe.d/vfio.conf" ];then
      echo "options vfio-pci ids=8086:3185" >> /etc/modprobe.d/vfio.conf
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
		pause
		menu
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
			rm -rf /etc/modprobe.d/blacklist.conf
			rm -rf /etc/modprobe.d/vfio.conf
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
#--------------开启硬件直通----------------


#--------------CPU、主板、硬盘温度显示----------------

# 安装工具
cpu_add(){

nodes="/usr/share/perl5/PVE/API2/Nodes.pm"
pvemanagerlib="/usr/share/pve-manager/js/pvemanagerlib.js"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

echo 安装lm-sensors
if ! sensors;then
  apt update && apt-get install lm-sensors && apt-get install nvme-cli && apt-get install hddtemp && chmod +s /usr/sbin/nvme && chmod +s /usr/sbin/hddtemp && chmod +s /usr/sbin/smartctl
fi

echo 检测硬件信息
sensors-detect --auto > /tmp/sensors
drivers=`sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`
if [ `echo $drivers|wc -w` = 0 ];then
    echo 没有找到任何驱动，似乎你的系统不支持。
else
    for i in $drivers
    do
        modprobe $i
        if [ `grep $i /etc/modules|wc -l` = 0 ];then
            echo $i >> /etc/modules
        fi
    done
    sensors
    sleep 3
    echo 驱动信息配置成功。
fi
/etc/init.d/kmod start
rm /tmp/sensors

echo 备份源文件
pvever=$(pveversion | awk -F"/" '{print $2}')
echo pve版本$pvever
[ ! -e $nodes.$pvever.bak ] && cp $nodes $nodes.$pvever.bak || { echo 已经执行过修改，请勿重复执行; exit 1;}
[ ! -e $pvemanagerlib.$pvever.bak ] && cp $pvemanagerlib $pvemanagerlib.$pvever.bak
[ ! -e $proxmoxlib.$pvever.bak ] && cp $proxmoxlib $proxmoxlib.$pvever.bak

# 生成系统变量
therm='$res->{thermalstate} = `sensors`;';
cpure='$res->{cpusensors} = `lscpu | grep MHz`;';
m2temp='$res->{nvme_ssd_temperatures} = `smartctl -a /dev/nvme?|grep -E "Model Number|Total NVM Capacity|Temperature:|Percentage|Data Unit|Power On Hours"`;';
hddtempe='$res->{hdd_temperatures} = `smartctl -a /dev/sd?|grep -E "Device Model|Capacity|Power_On_Hours|Temperature"`;';


###################  修改node.pm   ##########################
echo 修改node.pm：
sed -i "/PVE::pvecfg::version_text()/a $cpure\n$therm\n$m2temp\n$hddtempe" $nodes
# 显示修改结果
sed -n "/PVE::pvecfg::version_text()/,+5p"  $nodes


###################  修改pvemanagerlib.js   ##########################
tmpf=tmpfile.temp
touch $tmpf
cat > $tmpf << 'EOF'
	{
          itemId: 'thermal',
          colspan: 2,
          printBar: false,
          title: gettext('CPU温度'),
          textField: 'thermalstate',
          renderer:function(value){
              // const p0 = value.match(/Package id 0.*?\+([\d\.]+)Â/)[1];  // CPU包温度
              const c0 = value.match(/Core 0.*?\+([\d\.]+)Â/)[1];  // CPU核心1温度
              const c1 = value.match(/Core 1.*?\+([\d\.]+)Â/)[1];  // CPU核心2温度
              const c2 = value.match(/Core 2.*?\+([\d\.]+)Â/)[1];  // CPU核心3温度
              const c3 = value.match(/Core 3.*?\+([\d\.]+)Â/)[1];  // CPU核心4温度
              // const b0 = value.match(/temp1.*?\+([\d\.]+)?/)[1];  // 主板温度
              // const b1 = value.match(/temp2.*?\+([\d\.]+)?/)[1];  // 主板温度2
              return ` 核心1: ${c0} ℃ | 核心2: ${c1} ℃ | 核心3: ${c2} ℃ | 核心4: ${c3} ℃ `  // 不带主板温度
              // return `Package: ${p0} ℃ || 核心1: ${c0} ℃ | 核心2: ${c1} ℃ | 核心3: ${c2} ℃ | 核心4: ${c3} ℃ || 主板: ${b0} ℃ | ${b1} ℃ `  // 带主板温度
            }
    },
	{
          itemId: 'MHz',
          colspan: 2,
          printBar: false,
          title: gettext('CPU频率'),
          textField: 'cpusensors',
          renderer:function(value){
			  const f0 = value.match(/CPU MHz.*?([\d]+)/)[1];
			  const f1 = value.match(/CPU min MHz.*?([\d]+)/)[1];
			  const f2 = value.match(/CPU max MHz.*?([\d]+)/)[1];
			  return `CPU实时: ${f0} MHz | 最小: ${f1} MHz | 最大: ${f2} MHz `
            }
	},
	// /* 检测不到相关参数的可以注释掉---需要的注释本行即可
	/* 风扇转速
	{
          itemId: 'RPM',
          colspan: 2,
          printBar: false,
          title: gettext('CPU风扇'),
          textField: 'thermalstate',
          renderer:function(value){
			  const fan1 = value.match(/fan1:.*?\ ([\d.]+) R/)[1];
			  const fan2 = value.match(/fan2:.*?\ ([\d.]+) R/)[1];
			  return `CPU风扇: ${fan1} RPM | 系统风扇: ${fan2} RPM `
            }
	},
	// 检测不到相关参数的可以注释掉---需要的注释本行即可  */
	// /* 检测不到相关参数的可以注释掉---需要的注释本行即可
	// NVME硬盘温度
	{
          itemId: 'nvme_ssd-temperatures',
          colspan: 2,
          printBar: false,
          title: gettext('NVME硬盘'),
          textField: 'nvme_ssd_temperatures',
          renderer:function(value){
          if (value.length > 0) {
          let nvmedevices = value.matchAll(/^Model.*:\s*([\s\S]*?)(\n^Total.*\[[\s\S]*?\]$|\s{0}$)\n^Temperature:\s*([\d]+)\s*Celsius\n^Percentage.*([\d]+\%)\n^Data Units.*\[([\s\S]*?)\]\n^Data Units.*\[([\s\S]*?)\]\n^Power.*:\s*([\s\S]*?)\n/gm);
          for (const nvmedevice of nvmedevices) {
          for (var i=5; i<8; i++) {
          nvmedevice[i] = nvmedevice[i].replace(/ |,/gm, '');
          }
          if (nvmedevice[2].length > 0) {
          let nvmecapacity = nvmedevice[2].match(/.*\[([\s\S]*?)\]/);
          nvmecapacity = nvmecapacity[1].replace(/ /, '');
          value = `${nvmedevice[1]} | 已使用寿命: ${nvmedevice[4]} (累计读取: ${nvmedevice[5]}, 累计写入: ${nvmedevice[6]}) | 容量: ${nvmecapacity} | 已通电: ${nvmedevice[7]}小时 | 温度: ${nvmedevice[3]}°C\n`;
          } else {
          value = `${nvmedevice[1]} | 已使用寿命: ${nvmedevice[4]} (累计读取: ${nvmedevice[5]}, 累计写入: ${nvmedevice[6]}) | 已通电: ${nvmedevice[7]}小时 | 温度: ${nvmedevice[3]}°C\n`;
          }
          }
          return value.replace(/\n/g, '<br>');
          } else { 
          return `提示: 未安装硬盘或已直通硬盘控制器`;
          }
          }
          },
	// /* 检测不到相关参数的可以注释掉---需要的注释本行即可  */
          // SATA硬盘温度
          {
          itemId: 'hdd-temperatures',
          colspan: 2,
          printBar: false,
          title: gettext('SATA硬盘'),
          textField: 'hdd_temperatures',
          renderer:function(value){
          if (value.length > 0) {
          let devices = value.matchAll(/(\s*Model.*:\s*[\s\S]*?\n){1,2}^User.*\[([\s\S]*?)\]\n^\s*9[\s\S]*?\-\s*([\d]+)[\s\S]*?(\n(^19[0,4][\s\S]*?$){1,2}|\s{0}$)/gm);
          for (const device of devices) {
          if(device[1].indexOf("Family") !== -1){
          devicemodel = device[1].replace(/.*Model Family:\s*([\s\S]*?)\n^Device Model:\s*([\s\S]*?)\n/m, '$1 - $2');
          } else {
          devicemodel = device[1].replace(/.*Model:\s*([\s\S]*?)\n/m, '$1');
          }
          device[2] = device[2].replace(/ |,/gm, '');
          if(value.indexOf("Min/Max") !== -1){
          let devicetemps = device[5].matchAll(/19[0,4][\s\S]*?\-\s*(\d+)(\s\(Min\/Max\s(\d+)\/(\d+)\)$|\s{0}$)/gm);
          for (const devicetemp of devicetemps) {
          value = `${devicemodel} | 容量: ${device[2]} | 已通电: ${device[3]}小时 | 温度: ${devicetemp[1]}°C\n`;
          }
          } else if (value.indexOf("Temperature") !== -1){
          let devicetemps = device[5].matchAll(/19[0,4][\s\S]*?\-\s*(\d+)/gm);
          for (const devicetemp of devicetemps) {
          value = `${devicemodel} | 容量: ${device[2]} | 已通电: ${device[3]}小时 | 温度: ${devicetemp[1]}°C\n`;
          }
          } else {
          value = `${devicemodel} | 容量: ${device[2]} | 已通电: ${device[3]}小时 | 提示: 未检测到温度传感器\n`;
          }
          }
          return value.replace(/\n/g, '<br>');
          } else { 
          return `提示: 未安装硬盘或已直通硬盘控制器`;
          }
          }
          },
EOF

echo 找到关键字pveversion的行号
# 显示匹配的行
ln=$(sed -n '/pveversion/,+10{/},/{=;q}}' $pvemanagerlib)
echo "匹配的行号pveversion：" $ln

echo 修改结果：
sed -i "${ln}r $tmpf" $pvemanagerlib
# 显示修改结果
# sed -n '/pveversion/,+30p' $pvemanagerlib
rm $tmpf


echo 修改页面高度
# 修改并显示修改结果,位置10288行,原始值400
# sed -i -r '/\[logView\]/,+5{/heigh/{s#[0-9]+#700#;}}' $pvemanagerlib
# sed -n '/\[logView\]/,+5{/heigh/{p}}' $pvemanagerlib
# 修改并显示修改结果,位置36495行,原始值300
sed -i -r '/widget\.pveNodeStatus/,+5{/height/{s#[0-9]+#380#}}' $pvemanagerlib
sed -n '/widget\.pveNodeStatus/,+5{/height/{p}}' $pvemanagerlib
## 两处 height 的值需按情况修改，每多一行数据增加 20
###################  修改proxmoxlib.js   ##########################


echo 修改去除订阅弹窗
sed -r -i '/\/nodes\/localhost\/subscription/,+10{/^\s+if \(res === null /{N;s#.+#\t\t  if(false){#}}' $proxmoxlib
# 显示修改结果
sed -n '/\/nodes\/localhost\/subscription/,+10p' $proxmoxlib

systemctl restart pveproxy

echo "请刷新浏览器缓存shift+f5"


}

# 删除工具
cpu_del(){

nodes="/usr/share/perl5/PVE/API2/Nodes.pm"
pvemanagerlib="/usr/share/pve-manager/js/pvemanagerlib.js"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

pvever=$(pveversion | awk -F"/" '{print $2}')
echo pve版本$pvever
if [ -f "$nodes.$pvever.bak" ];then
rm -f $nodes $pvemanagerlib $proxmoxlib
mv $nodes.$pvever.bak $nodes
mv $pvemanagerlib.$pvever.bak $pvemanagerlib
mv $proxmoxlib.$pvever.bak $proxmoxlib

echo "已删除温度显示，请重新刷新浏览器缓存."
else
echo "你没有添加过温度显示，退出脚本."
fi


}

#--------------CPU、主板、硬盘温度显示----------------


# 主菜单
menu(){
	clear
	cat <<-EOF
`TIME y "	      PVE优化脚本"`
┌──────────────────────────────────────────┐
    1. 一键优化PVE(换源、去订阅等)
    2. 配置PCI硬件直通
    3. 添加CPU、主板、硬盘温度显示
    4. 删除CPU、主板、硬盘温度显示
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
		cpu_add
		echo
		pause
		menu
	;;
	4)
		cpu_del
		echo
		pause
		menu
	;;
	0)
		clear
		exit 0
	;;
	*)
		echo "你的输入无效 ,请重新输入 !!!"
		menu
	;;
	esac
}
menu
