#!/usr/bin/env bash
#====================================================
#!/bin/bash
# https://github.com/shidahuilang/openwrt
# common Module by 大灰狼
# matrix.target=${Modelfile}
#====================================================

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"

function ECHOY() {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOR() {
  echo -e "${Red} $1 ${Font}"
}
function ECHOB() {
  echo
  echo -e "${Blue} $1 ${Font}"
  echo
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOG() {
  echo -e "${Green} $1 ${Font}"
}
function print_ok() {
  echo
  echo -e " ${OK} ${Blue} $1 ${Font}"
  echo
}
function print_error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}
judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 完成,等待重启openwrt"
  else
    print_error "$1 失败"
  fi
}

function ip_install() {
  echo
  echo
  export YUMING="请输入您的IP"
  ECHOYY "${YUMING}[比如:192.168.2.2]"
  while :; do
  domainy=""
  read -p " ${YUMING}：" domain
  if [[ -n "${domain}" ]] && [[ "$(echo ${domain} |egrep -c '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')" == '1' ]]; then
    domainy="Y"
  fi
  case $domainy in
  Y)
    export domain="${domain}"
    uci set network.lan.ipaddr="${domain}"
    uci set network.lan.dns=
    uci set network.lan.gateway=
    uci set network.lan.broadcast=
    uci commit network
    judge "IP 修改"
    ECHOG "您的IP为：${domain}"
  break
  ;;
  *)
    export YUMING="敬告：请输入正确格式的IP"
  ;;
  esac
  done
  
  echo
  echo
  read -p " 是否清空密码?直接回车跳过，按[Y/y]回车确认清空密码：" YN
  case ${YN} in
    [Yy]) 
      passwd -d root
      judge "清空密码"
    ;;
    *)
      ECHOR "您已跳过清空密码"
    ;;
  esac
}

function dns_install() {
  export YUMING="请输入您的DNS"
  ECHOYY "${YUMING}[比如:114.114.114.114]"
  ECHOYY "多个DNS之间要用空格分开[比如:114.114.114.114 223.5.5.5 8.8.8.8]"
  while :; do
  domaind=""
  read -p " ${YUMING}：" domaindns
  if [[ -n "${domaindns}" ]] && [[ "$(echo ${domaindns} |egrep -c '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')" == '1' ]]; then
    domaind="Y"
  fi
  case $domaind in
  Y)
    export domaindns="${domaindns}"
    uci set network.lan.dns="${domaindns}"
    uci commit network
    judge "DNS 修改"
    ECHOG "您的DNS为：${domaindns}"
  break
  ;;
  *)
    export YUMING="敬告：请输入正确格式的DNS"
  ;;
  esac
  done
}

function wg_install() {
  export YUMING="请输入您的主路由IP（网关）"
  ECHOYY "${YUMING}[比如:192.168.2.1]"
  while :; do
  domainw=""
  read -p " ${YUMING}：" domainwg
  if [[ -n "${domainwg}" ]] && [[ "$(echo ${domainwg} |egrep -c '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')" == '1' ]]; then
    domainw="Y"
  fi
  case $domainw in
  Y)
    export domainwg="${domainwg}"
    uci set network.lan.gateway="${domainwg}"
    uci commit network
    judge "DNS 修改"
    ECHOG "您的DNS为：${domainwg}"
  break
  ;;
  *)
    export YUMING="敬告：请输入正确格式的网关IP"
  ;;
  esac
  done
}

function install_ws() {
  clear
  ip_install
  echo
  echo
  read -p " 是否设置DNS?主路由一般无需设置DSN,直接回车跳过，旁路由按[Y/y]设置：" YN
  case ${YN} in
    [Yy]) 
      dns_install
    ;;
    *)
      ECHOR "您已跳过DNS设置"
    ;;
  esac
  echo
  echo
  read -p " 是否设置网关?主路由无需设置网关,直接回车跳过，旁路由按[Y/y]设置：" YN
  case ${YN} in
    [Yy]) 
      wg_install
    ;;
    *)
      ECHOR "您已跳过网关设置"
    ;;
  esac
  echo
  echo
  ECHOG "正在为您重启openwrt中，预计需要1~2分钟，请稍后..."
  echo
  reboot -f
}

function first_boot() {
  echo
  echo
  ECHOR "是否恢复出厂设置?按[Y/y]执行,按[N/n]退出,如果执行的话,请耐心等待openwrt重启完成"
  firstboot && reboot -f
}

function install_bootstrap() {
  echo
  ECHOY "正在安装官方主题，请耐心等候..."
  echo
  opkg update
  opkg remove luci-theme-bootstrap
  sed -i '/bootstrap/d' /etc/config/luci
  rm -rf /tmp/luci-*cache*
  opkg install luci-theme-bootstrap
  if [[ $? -ne 0 ]]; then
    print_error "固件自带源安装主题失败，正在尝试外部源，请稍后..."
    export Anzhuang_shibai="1"
    sleep 2
  else
    export Anzhuang_shibai="0"
    uci set luci.main.mediaurlbase='/luci-static/bootstrap'
    uci commit luci
    print_ok "正在重启openwrt，请稍等一会进入后台..."
    sleep 2
    reboot -f
  fi
  
  if [[ ${Anzhuang_shibai} == "1" ]]; then
    rm -rf /tmp/luci-theme-bootstrap.ipk
    wget --tries=4 -q -P /tmp https://ghproxy.com/https://github.com/shidahuilang/openwrt-package/blob/usb/zhuti/luci-theme-bootstrap_18.06.ipk -O /tmp/luci-theme-bootstrap.ipk
    if [[ $? -ne 0 ]]; then
      wget --tries=4 -q -P /tmp https://archive.openwrt.org/releases/packages-18.06/aarch64_cortex-a72/luci/luci-theme-bootstrap_git-18.235.62437-6503756-1_all.ipk -O /tmp/luci-theme-bootstrap.ipk
      if [[ $? -ne 0 ]]; then
        print_error "下载主题插件失败，请检查网络"
        exit 1
      fi
    fi
    opkg remove luci-theme-bootstrap
    opkg install /tmp/luci-theme-bootstrap.ipk
    if [[ $? -ne 0 ]]; then
      print_error "主题安装失败"
      exit 1
    else
      print_ok "主题安装成功，正在重启openwrt，请稍后登录..."
      uci set luci.main.mediaurlbase='/luci-static/bootstrap'
      uci commit luci
      reboot -f
    fi
  fi
}

function install_material() {
  echo
  ECHOY "正在安装官方主题，请耐心等候..."
  echo
  opkg update
  opkg remove luci-theme-material
  sed -i '/material/d' /etc/config/luci
  rm -rf /tmp/luci-*cache
  opkg install luci-theme-material
  if [[ $? -ne 0 ]]; then
    print_error "固件自带源安装主题失败，正在尝试外部源，请稍后..."
    export Anzhuang_shibai="1"
    sleep 2
  else
    export Anzhuang_shibai="0"
    uci set luci.main.mediaurlbase='/luci-static/material'
    uci commit luci
    print_ok "正在重启openwrt，请稍等一会进入后台..."
    sleep 2
    reboot -f
  fi
  
  if [[ ${Anzhuang_shibai} == "1" ]]; then
    rm -rf /tmp/luci-theme-material.ipk
    wget --tries=4 -q -P /tmp https://ghproxy.com/https://github.com/shidahuilang/openwrt-package/blob/usb/zhuti/luci-theme-material_21.02.ipk -O /tmp/luci-theme-material.ipk
    if [[ $? -ne 0 ]]; then
      wget --tries=4 -q -P /tmp https://archive.openwrt.org/releases/packages-21.02/aarch64_cortex-a72/luci/luci-theme-material_git-21.295.66888-fc702bc_all.ipk -O /tmp/luci-theme-material.ipk
        if [[ $? -ne 0 ]]; then
          print_error "下载主题插件失败，请检查网络"
          exit 1
        fi
    fi
    opkg remove luci-theme-material
    opkg install /tmp/luci-theme-material.ipk
    if [[ $? -ne 0 ]]; then
      print_error "主题安装失败"
      exit 1
    else
      print_ok "主题安装成功，正在重启openwrt，请稍后登录..."
      uci set luci.main.mediaurlbase='/luci-static/material'
      uci commit luci
      reboot -f
    fi
  fi
}

function install_zhuti() {
  if [[ "$(. /etc/openwrt_release && echo "$DISTRIB_RECOGNIZE")" == "18" ]]; then
    install_bootstrap
  elif [[ "$(. /etc/openwrt_release && echo "$DISTRIB_RECOGNIZE")" == "20" ]]; then
    install_material
  else
    print_error "不清楚您固件的LUCI版本，无法运行程序!"
    exit 1
  fi
}
  

menu() {
  clear
  echo  
  ECHOB "  请选择执行命令编码"
  ECHOY " 1. 检查更新(保留配置)"
  ECHOYY " 2. 检查更新(不保留配置)"
  ECHOY " 3. 测试模式,观看运行步骤(不安装固件)"
  ECHOYY " 4. 转换成其他源码作者固件(不保留配置)"
  ECHOY " 5. 查看状态信息"
  ECHOYY " 6. 更换检测固件的gihub地址"
  ECHOY " 7. 修改IP/DSN/网关(会进行重启操作)"
  ECHOYY " 8. 清空密码(会进行重启操作)"
  ECHOY " 9. 尝试修复因主题错误进了不LUCI(强制重新安装官方主题,会进行重启操作)"
  ECHOYY " 10. 恢复出厂设置(会进行重启操作)"
  ECHOY " Q. 退出菜单"
  echo
  XUANZHEOP="请输入数字,或按[Q/q]退出菜单"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      bash /bin/AutoUpdate.sh
    break
    ;;
    2)
      bash /bin/AutoUpdate.sh -n
    break
    ;;
    3)
      bash /bin/AutoUpdate.sh -t
    break
    ;;
    4)
      bash /bin/replace.sh
    break
    ;;
    5)
      bash /bin/AutoUpdate.sh -h
    break
    ;;
    6)
      bash /bin/AutoUpdate.sh -c
    break
    ;;
    7)
      install_ws
    break
    ;;
    8)
      passwd -d root
      echo
      ECHOG "密码已清空，正在为您重启openwrt中，请稍后从新登录..."
      echo
      reboot
    break
    ;;
    9)
      install_zhuti
    break
    ;;
    10)
      first_boot
    break
    ;;
    [Qq])
      ECHOR "您选择了退出程序"
      exit 0
    break
    ;;
    *)
      XUANZHEOP="请输入正确的数字编号,或按[Q/q]退出菜单!"
    ;;
    esac
    done
}

menuws() {
  clear
  echo  
  ECHOB "  请选择执行命令编码"
  ECHOY " 1. 修改IP/DSN/网关(会进行重启操作)"
  ECHOYY " 2. 清空密码(会进行重启操作)"
  ECHOY " 3. 尝试修复因主题错误进了不LUCI(强制重新安装官方主题,会进行重启操作)"
  ECHOYY " 4. 恢复出厂设置(会进行重启操作)"
  ECHOY " 5. 退出菜单"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      install_ws
    break
    ;;
    2)
      passwd -d root
      echo
      ECHOG "密码已清空，正在为您重启openwrt中，请稍后从新登录..."
      echo
      reboot
    break
    ;;
    3)
      install_zhuti
    break
    ;;
    4)
      first_boot
    break
    ;;
    5)
      ECHOR "您选择了退出程序"
      exit 0
    break
    ;;
    *)
      XUANZHEOP="请输入正确的数字编号!"
    ;;
    esac
    done
}

if [[ -f /bin/openwrt_info ]] && [[ -f /bin/AutoUpdate.sh ]];then
  menu "$@"
else
  menuws "$@"
fi

exit 0
