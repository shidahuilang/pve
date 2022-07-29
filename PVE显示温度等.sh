#!/usr/bin/env bash



function add(){

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
[ ! -e $nodes.$pvever.bak ] && cp $nodes $nodes.$pvever.bak || { echo 已经修改过，请务重复执行; exit 1;}
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
	// 风扇转速
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

	/* 检测不到相关参数的可以注释掉---需要的注释本行即可
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
	检测不到相关参数的可以注释掉---需要的注释本行即可  */

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

function del(){

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


echo ==========================================================
echo
echo      ============ 为PVE添加硬件温度显示 ============
echo
echo ==========================================================
echo 
echo 1.添加硬件温度显示
echo 2.删除硬件温度显示
echo 3.退出


read -p "请输入你的选择：" num1
    case $num1 in
        1)
            add
            ;;
        2)
            del
            ;;
        3)
            exit 0
            ;;
        *)
            echo "你的输入无效 ,请重新输入 !!!"
            exit 1
            ;;
esac
