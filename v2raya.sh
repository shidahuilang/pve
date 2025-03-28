#!/bin/bash
# https://github.com/shidahuilang/
# v2rayA Module by dahuilang

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
if ! command -v wget &>/dev/null || ! command -v gpg &>/dev/null; then
  echo -e "${RED}❌ 需要安装 wget 和 gpg，请执行： sudo apt install -y wget gpg${RESET}"
  exit 1
fi

install_v2raya() {
  echo -e "\n${BLUE}正在安装 V2RayA 和 V2Ray...${RESET}"

  # 确保目录存在
  mkdir -p /etc/apt/keyrings

  # 删除旧的公钥文件，避免损坏
  rm -f /etc/apt/keyrings/v2raya.asc /etc/apt/keyrings/v2raya.gpg

  # 重新下载公钥
  wget -qO /etc/apt/keyrings/v2raya.asc https://apt.v2raya.org/key/public-key.asc

  # 确保公钥格式正确并转换为 gpg
  gpg --dearmor < /etc/apt/keyrings/v2raya.asc > /etc/apt/keyrings/v2raya.gpg

  # 重新添加软件源
  echo "deb [signed-by=/etc/apt/keyrings/v2raya.gpg] https://apt.v2raya.org/ v2raya main" > /etc/apt/sources.list.d/v2raya.list

  # 更新 APT 缓存并安装软件
  apt update
  apt install -y v2raya v2ray

  # 启动并设置开机自启
  systemctl enable --now v2raya.service

  echo -e "\n✅ ${GREEN}V2RayA 和 V2Ray 安装完成！${RESET}"
  echo -e "📢 你可以在浏览器中访问 V2RayA 控制面板: ${GREEN}http://localhost:2017${RESET}"
}

uninstall_v2raya() {
  echo -e "\n${YELLOW}你想卸载哪些组件？${RESET}"
  echo "1) 仅卸载 V2RayA"
  echo "2) 仅卸载 V2Ray"
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
      apt remove --purge -y v2raya
      echo -e "\n✅ ${GREEN}V2RayA 已卸载！${RESET}"
      ;;
    2)
      apt remove --purge -y v2ray
      echo -e "\n✅ ${GREEN}V2Ray 已卸载！${RESET}"
      ;;
    3)
      if systemctl list-units --full --all | grep -q "v2raya.service"; then
        systemctl stop v2raya.service
        systemctl disable v2raya.service
      fi
      apt remove --purge -y v2raya v2ray
      rm -rf /etc/apt/sources.list.d/v2raya.list /etc/apt/keyrings/v2raya.asc /etc/apt/keyrings/v2raya.gpg
      echo -e "\n✅ ${GREEN}V2RayA 和 V2Ray 已全部卸载！${RESET}"
      ;;
    4)
      if systemctl list-units --full --all | grep -q "v2raya.service"; then
        systemctl stop v2raya.service
        systemctl disable v2raya.service
      fi
      apt remove --purge -y v2raya v2ray
      rm -rf /etc/apt/sources.list.d/v2raya.list /etc/apt/keyrings/v2raya.asc /etc/apt/keyrings/v2raya.gpg
      rm -rf /etc/v2raya /usr/local/etc/v2ray /etc/v2ray /var/lib/v2raya ~/.config/v2raya ~/.local/share/v2raya
      echo -e "\n✅ ${GREEN}V2RayA 和 V2Ray 及其所有配置文件已彻底删除！${RESET}"
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
echo -e "\n${BLUE}====== V2RayA & V2Ray 管理脚本 ======${RESET}"
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
