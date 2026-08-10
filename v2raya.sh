#!/bin/bash
# https://github.com/shidahuilang/
# v2rayA Module by dahuilang
# 修复版：绕过过期 APT 签名密钥，自动配置局域网代理访问

# 颜色代码
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ 请使用 root 权限运行此脚本！${RESET}"
  exit 1
fi

# 检查是否为 Debian/Ubuntu 系统
if ! grep -qi "debian\|ubuntu" /etc/os-release; then
  echo -e "${RED}❌ 此脚本仅适用于 Debian/Ubuntu 系统！${RESET}"
  exit 1
fi

# 检查必要的软件是否安装
if ! command -v wget &>/dev/null || ! command -v curl &>/dev/null; then
  echo -e "${YELLOW}⚠️  正在安装必要依赖...${RESET}"
  apt update && apt install -y wget curl jq
fi

if ! command -v jq &>/dev/null; then
  echo -e "${YELLOW}⚠️  正在安装 jq...${RESET}"
  apt install -y jq
fi

# 检测系统架构
get_arch() {
  local arch=$(dpkg --print-architecture)
  case "$arch" in
    amd64)  echo "x64" ;;
    arm64)  echo "arm64" ;;
    armhf)  echo "armv7" ;;
    *)      echo "$arch" ;;
  esac
}

# 错误退出函数
die() {
  echo -e "${RED}❌ $1${RESET}"
  exit 1
}

install_v2raya() {
  echo -e "\n${BLUE}正在安装 V2RayA 和 V2Ray...${RESET}"

  # ===== 1. 清理旧的过期 APT 源配置 =====
  echo -e "${YELLOW}🧹 清理旧的 APT 源配置...${RESET}"
  rm -f /etc/apt/sources.list.d/v2raya.list
  rm -f /etc/apt/keyrings/v2raya.asc
  rm -f /etc/apt/keyrings/v2raya.gpg
  rm -f /usr/share/keyrings/v2raya.asc
  rm -f /usr/share/keyrings/v2raya.gpg

  # ===== 2. 安装必要依赖 =====
  echo -e "${YELLOW}📦 安装必要依赖...${RESET}"
  apt update || die "apt update 失败"
  apt install -y wget curl jq gnupg || die "依赖安装失败"

  # ===== 3. 获取最新版本号 =====
  echo -e "${YELLOW}🔍 获取 v2rayA 最新版本...${RESET}"
  LATEST_V=$(curl -sL --retry 3 --connect-timeout 10 \
    "https://api.github.com/repos/v2rayA/v2rayA/releases/latest" | jq -r '.tag_name')

  if [ -z "$LATEST_V" ] || [ "$LATEST_V" = "null" ]; then
    die "无法获取 v2rayA 最新版本号，请检查网络连接"
  fi
  echo -e "${GREEN}✓ 最新版本: $LATEST_V${RESET}"

  # ===== 4. 下载 v2rayA deb 包 =====
  ARCH=$(get_arch)
  DEB_NAME="installer_debian_${ARCH}_${LATEST_V#v}.deb"
  DEB_URL="https://github.com/v2rayA/v2rayA/releases/download/${LATEST_V}/${DEB_NAME}"
  DEB_PATH="/tmp/${DEB_NAME}"

  echo -e "${YELLOW}⬇️  下载 v2rayA deb 包 (${ARCH})...${RESET}"
  echo -e "${BLUE}   URL: $DEB_URL${RESET}"

  if ! wget --show-progress --timeout=60 -O "$DEB_PATH" "$DEB_URL"; then
    die "下载 v2rayA deb 包失败"
  fi

  # ===== 5. 安装 v2rayA =====
  echo -e "${YELLOW}📦 安装 v2rayA...${RESET}"
  if ! apt install -y "$DEB_PATH"; then
    die "安装 v2rayA 失败"
  fi

  # 清理下载的 deb 包
  rm -f "$DEB_PATH"

  # ===== 6. 【关键修复】配置代理端口监听 0.0.0.0 =====
  echo -e "${YELLOW}🔧 配置代理端口允许局域网访问...${RESET}"
  mkdir -p /etc/systemd/system/v2raya.service.d/
  tee /etc/systemd/system/v2raya.service.d/inbound-ip.conf > /dev/null << 'EOF'
[Service]
Environment="V2RAYA_INBOUND_IP=0.0.0.0"
EOF
  systemctl daemon-reload

  # ===== 7. 安装 V2Ray 核心 =====
  echo -e "${YELLOW}📦 安装 V2Ray 核心...${RESET}"
  if ! bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh); then
    die "安装 V2Ray 核心失败"
  fi

  # ===== 8. 启动并设置开机自启 =====
  echo -e "${YELLOW}🚀 启动 V2RayA 服务...${RESET}"
  if ! systemctl enable --now v2raya.service; then
    die "启动 v2raya.service 失败"
  fi

  # ===== 9. 验证安装 =====
  echo -e "${YELLOW}🔍 验证安装...${RESET}"
  sleep 2
  if systemctl is-active --quiet v2raya.service; then
    echo -e "${GREEN}✓ v2raya.service 运行正常${RESET}"
  else
    echo -e "${RED}⚠️  v2raya.service 未运行，请检查日志: journalctl -u v2raya${RESET}"
  fi

  if command -v v2ray &>/dev/null; then
    V2RAY_VER=$(v2ray version 2>/dev/null | head -n1 || echo "未知")
    echo -e "${GREEN}✓ V2Ray 核心已安装: $V2RAY_VER${RESET}"
  else
    echo -e "${RED}⚠️  V2Ray 核心可能未正确安装${RESET}"
  fi

  # 验证代理端口监听
  echo -e "${YELLOW}🔍 验证代理端口监听...${RESET}"
  if ss -tlnp | grep -q '0.0.0.0:20171'; then
    echo -e "${GREEN}✓ HTTP 代理端口 20171 已监听 0.0.0.0${RESET}"
  else
    echo -e "${YELLOW}⚠️  HTTP 代理端口可能未监听 0.0.0.0，请在面板连接节点后再次检查${RESET}"
  fi

  echo -e "\n${GREEN}✅ V2RayA 和 V2Ray 安装完成！${RESET}"
  echo -e "📢 控制面板: ${GREEN}http://$(hostname -I | awk '{print $1}'):2017${RESET}"
  echo -e "📢 HTTP 代理: ${GREEN}http://$(hostname -I | awk '{print $1}'):20171${RESET}"
  echo -e "📢 SOCKS5 代理: ${GREEN}$(hostname -I | awk '{print $1}'):20170${RESET}"
  echo -e "${YELLOW}💡 其他服务器使用代理: export http_proxy=http://$(hostname -I | awk '{print $1}'):20171${RESET}"
}

uninstall_v2raya() {
  echo -e "\n${YELLOW}你想卸载哪些组件？${RESET}"
  echo "1) 仅卸载 V2RayA"
  echo "2) 仅卸载 V2Ray 核心"
  echo "3) 卸载所有 (V2RayA + V2Ray)"
  echo "4) 卸载所有并删除所有配置文件"
  echo "5) 退出"
  read -p "请输入选项 (1-5): " choice

  case $choice in
    1)
      if systemctl list-units --full --all | grep -q "v2raya.service"; then
        systemctl stop v2raya.service
        systemctl disable v2raya.service
      fi
      apt remove --purge -y v2raya 2>/dev/null || true
      rm -rf /etc/systemd/system/v2raya.service.d/
      echo -e "\n${GREEN}✅ V2RayA 已卸载！${RESET}"
      ;;
    2)
      echo -e "${YELLOW}正在卸载 V2Ray 核心...${RESET}"
      bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove || true
      echo -e "\n${GREEN}✅ V2Ray 核心已卸载！${RESET}"
      ;;
    3)
      if systemctl list-units --full --all | grep -q "v2raya.service"; then
        systemctl stop v2raya.service
        systemctl disable v2raya.service
      fi
      apt remove --purge -y v2raya 2>/dev/null || true
      bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove || true
      rm -f /etc/apt/sources.list.d/v2raya.list
      rm -f /etc/apt/keyrings/v2raya.asc /etc/apt/keyrings/v2raya.gpg
      rm -f /usr/share/keyrings/v2raya.asc /usr/share/keyrings/v2raya.gpg
      rm -rf /etc/systemd/system/v2raya.service.d/
      echo -e "\n${GREEN}✅ V2RayA 和 V2Ray 已全部卸载！${RESET}"
      ;;
    4)
      if systemctl list-units --full --all | grep -q "v2raya.service"; then
        systemctl stop v2raya.service
        systemctl disable v2raya.service
      fi
      apt remove --purge -y v2raya 2>/dev/null || true
      bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove || true
      rm -f /etc/apt/sources.list.d/v2raya.list
      rm -f /etc/apt/keyrings/v2raya.asc /etc/apt/keyrings/v2raya.gpg
      rm -f /usr/share/keyrings/v2raya.asc /usr/share/keyrings/v2raya.gpg
      rm -rf /etc/systemd/system/v2raya.service.d/
      rm -rf /etc/v2raya /usr/local/etc/v2ray /etc/v2ray /var/lib/v2raya ~/.config/v2raya ~/.local/share/v2raya
      rm -rf /usr/local/bin/v2ray /usr/local/bin/v2ctl /usr/local/share/v2ray /usr/local/etc/v2ray
      rm -f /etc/systemd/system/v2ray.service /etc/systemd/system/v2ray@.service
      rm -rf /etc/systemd/system/v2ray.service.d /etc/systemd/system/v2ray@.service.d
      echo -e "\n${GREEN}✅ V2RayA 和 V2Ray 及其所有配置文件已彻底删除！${RESET}"
      ;;
    5)
      echo -e "${BLUE}操作已取消。${RESET}"
      exit 0
      ;;
    *)
      echo -e "${RED}❌ 无效选项，请重新运行脚本。${RESET}"
      exit 1
      ;;
  esac
}

# 主菜单
echo -e "\n${BLUE}====== V2RayA & V2Ray 管理脚本 (修复版 v2) ======${RESET}"
echo "1) 安装 V2RayA & V2Ray"
echo "2) 卸载 V2RayA & V2Ray"
echo "3) 退出"
read -p "请输入选项 (1-3): " option

case $option in
  1) install_v2raya ;;
  2) uninstall_v2raya ;;
  3) echo -e "${BLUE}退出脚本。${RESET}" ; exit 0 ;;
  *) echo -e "${RED}❌ 无效选项，退出。${RESET}" ; exit 1 ;;
esac
