#!/bin/bash

# --- 自动安装并配置 postfix 和 mailutils ---
if ! dpkg -l | grep -q "^ii\s*postfix\s"; then
  echo "检测到 postfix 未安装，开始安装..."

  HOSTNAME=$(hostname)
  echo "postfix postfix/mailname string $HOSTNAME" | sudo debconf-set-selections
  echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections

  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postfix mailutils

  sudo systemctl enable postfix
  sudo systemctl start postfix

  echo "postfix 安装完成并启动"
else
  echo "postfix 已安装"
fi

# --- 服务器分组 ---
SERVERS_DAHUILANG=(
  "http://vip.123:45800"
  "https://20.456.tk"

)

SERVERS_QINGTIAN=(
  "https://api.123.com"
  "https://v1.456.com"

)

# --- Telegram 配置 ---
declare -A TELEGRAMS=(
  ["16225853:AAGeQmivyLJjVCdQkqix45tZbWyY_LGY"]="12090858"
#  ["1625953:AAGeQmiLJjVC5iydQk5tZbWyY_LGY"]="1209658"  
)

# --- 邮箱列表 ---
EMAILS=(
  "2794341@qq.com"
  "1085124@qq.com"
)

# --- 邮件推送开关 ---
PUSH_EMAIL=false   # true开启邮件推送，false关闭

# --- QQ 群推送配置 ---
PUSH_ALL=true  # true 推送全部状态，false 只推异常

DAHUILANG=true
declare -A QQ_GROUPS_DAHUILANG=(
  ["1077141"]="大灰狼vip群"
#  ["106611"]="大灰狼1群"
#  ["837023"]="大灰狼2群"
#  ["1040466"]="大灰狼3群"   
)

PUSH_QQ_QINGTIAN=true
declare -A QQ_GROUPS_QINGTIAN=(
  ["415943"]="晴天vip1群"
  ["1041031"]="晴天vip2群"
)

QQ_PUSH_URL="http://xx.xx.xxx.xxx:3001/send_group_msg"

LOGFILE="./server.log"

# --- 检测函数（同步） ---
check_servers() {
  local -n servers=$1
  local group_name=$2
  local body_var=$3

  local body="$group_name 服务器检测 - $(date '+%Y-%m-%d %H:%M:%S')"$'\n'
  for server in "${servers[@]}"; do
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" "$server")
    local status
    if [ "$code" == "200" ]; then
      status="✔️ 正常"
    elif [ "$code" == "405" ]; then
      status="❌ 关闭 (405 Method Not Allowed)"
    else
      status="❌ 关闭 (HTTP $code)"
    fi
    body+="$server $status"$'\n'
  done

  printf -v "$body_var" "%s" "$body"
}

# --- 发送 Telegram ---
send_telegram() {
  local message=$1
  for BOT_TOKEN in "${!TELEGRAMS[@]}"; do
    local CHAT_ID=${TELEGRAMS[$BOT_TOKEN]}
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
      -d "chat_id=$CHAT_ID" \
      -d "text=$message" \
      -d "parse_mode=Markdown" > /dev/null
  done
}

# --- 发送邮件 ---
send_email() {
  local message=$1
  local subject=$2
  for EMAIL in "${EMAILS[@]}"; do
    echo -e "$message" | mail -s "$subject" "$EMAIL"
  done
}

# --- 发送QQ群消息 ---
send_qq() {
  local -n groups=$1
  local message=$2
  for group_id in "${!groups[@]}"; do
    curl -s -X POST "$QQ_PUSH_URL" \
      -H "Content-Type: application/json" \
      -d "{\"group_id\":\"$group_id\",\"message\":\"$(echo "$message" | sed ':a;N;$!ba;s/\n/\\n/g')\"}" > /dev/null
  done
}

# --- 主体执行 ---
BODY_DAHUILANG=""
BODY_QINGTIAN=""

check_servers SERVERS_DAHUILANG "大灰狼" BODY_DAHUILANG
check_servers SERVERS_QINGTIAN "晴天" BODY_QINGTIAN

# 过滤内容（如果只推异常）
if [ "$PUSH_ALL" != true ]; then
  BODY_DAHUILANG=$(echo "$BODY_DAHUILANG" | grep -E '❌' || echo "")
  [ -n "$BODY_DAHUILANG" ] && BODY_DAHUILANG="大灰狼 服务器异常 - $(date '+%Y-%m-%d %H:%M:%S')"$'\n'"$BODY_DAHUILANG"

  BODY_QINGTIAN=$(echo "$BODY_QINGTIAN" | grep -E '❌' || echo "")
  [ -n "$BODY_QINGTIAN" ] && BODY_QINGTIAN="晴天 服务器异常 - $(date '+%Y-%m-%d %H:%M:%S')"$'\n'"$BODY_QINGTIAN"
fi


# 统一日志
echo -e "$BODY_DAHUILANG\n\n$BODY_QINGTIAN" > "$LOGFILE"
cat "$LOGFILE"

# 发送 Telegram
if [ -n "$BODY_DAHUILANG" ]; then
  send_telegram "$BODY_DAHUILANG"
fi
if [ -n "$BODY_QINGTIAN" ]; then
  send_telegram "$BODY_QINGTIAN"
fi

# 发送邮件
if $PUSH_EMAIL; then
  combined_body="$BODY_DAHUILANG"$'\n\n'"$BODY_QINGTIAN"
  if [ -n "$combined_body" ]; then
    send_email "$combined_body" "服务器检测通知 - $(date '+%Y-%m-%d %H:%M:%S')"
  fi
fi

# 发送 QQ 群
if $DAHUILANG && [ -n "$BODY_DAHUILANG" ]; then
  send_qq QQ_GROUPS_DAHUILANG "$BODY_DAHUILANG"
fi

if $PUSH_QQ_QINGTIAN && [ -n "$BODY_QINGTIAN" ]; then
  send_qq QQ_GROUPS_QINGTIAN "$BODY_QINGTIAN"
fi
