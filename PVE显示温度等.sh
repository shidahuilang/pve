#!/usr/bin/env bash
nodes="/usr/share/perl5/PVE/API2/Nodes.pm"
pvemanagerlib="/usr/share/pve-manager/js/pvemanagerlib.js"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

if ! sensors;then
  echo 安装lm-sensors
  apt update && apt-get install lm-sensors && apt-get install nvme-cli && apt-get install hddtemp && chmod +s /usr/sbin/nvme && chmod +s /usr/sbin/hddtemp && chmod +s /usr/sbin/smartctl && systemctl restart pveproxy

fi

pvever=$(pveversion | awk -F"/" '{print $2}')
echo pve版本$pvever
echo 备份源文件
[ ! -e $nodes.$pvever.bak ] && cp $nodes $nodes.$pvever.bak || { echo 已经修改过，请务重复执行; exit 1;}
[ ! -e $pvemanagerlib.$pvever.bak ] && cp $pvemanagerlib $pvemanagerlib.$pvever.bak
[ ! -e $proxmoxlib.$pvever.bak ] && cp $proxmoxlib $proxmoxlib.$pvever.bak

therm='$res->{thermalstate} = `sensors`;';
cpure='$res->{cpusensors} = `lscpu | grep MHz`;';
m2temp='$res->{nvme_ssd_temperatures} = `smartctl -a /dev/nvme?|grep -E "Model Number|Total NVM Capacity|Temperature:|Percentage|Data Unit|Power On Hours"`;';
hddtempe='$res->{hdd_temperatures} = `smartctl -a /dev/sd?|grep -E "Model|Capacity|Power_On_Hours|Temperature"`;';

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
              // CPU包温度
              // const p0 = value.match(/Package id 0.*?\+([\d\.]+)Â/)[1];
              const c0 = value.match(/Core 0.*?\+([\d\.]+)Â/)[1];
              const c1 = value.match(/Core 1.*?\+([\d\.]+)Â/)[1];
              const c2 = value.match(/Core 2.*?\+([\d\.]+)Â/)[1];
              const c3 = value.match(/Core 3.*?\+([\d\.]+)Â/)[1];
              // 主板温度
              // const b0 = value.match(/temp1.*?\+([\d\.]+)?/)[1];
              // 主板温度2
              // const b1 = value.match(/temp2.*?\+([\d\.]+)?/)[1];
              // 不带主板温度
              return ` 核心1: ${c0} ℃ | 核心2: ${c1} ℃ | 核心3: ${c2} ℃ | 核心4: ${c3} ℃ `
              // 带主板温度
              // return `Package: ${p0} ℃ || 核心1: ${c0} ℃ | 核心2: ${c1} ℃ | 核心3: ${c2} ℃ | 核心4: ${c3} ℃ || 主板: ${b0} ℃ | ${b1} ℃ `
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

#找到关键字pveversion的行号
echo 修改pvemanagerlib.js
# 显示匹配的行
ln=$(sed -n '/pveversion/,+10{/},/{=;q}}' $pvemanagerlib)
echo "匹配的行号pveversion：" $ln

echo 修改结果：
sed -i "${ln}r $tmpf" $pvemanagerlib
# 显示修改结果
sed -n '/pveversion/,+30p' $pvemanagerlib

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
