#!/usr/bin/env bash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
# 
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# CREATE TABLE if not exists task (
#                         task_name                       TEXT PRIMARY KEY NOT NULL,
#                         description                     TEXT,
#                         event                           TEXT NOT NULL,
#                         depend_on_task          TEXT,
#                         enable                          INTEGER DEFAULT 1,
#                         owner                           INTEGER NOT NULL,
#                         run_the_same_time       INTEGER DEFAULT 1,
#                         notify_enable           INTEGER DEFAULT 0,
#                         notify_mail                     TEXT,
#                         notify_if_error         INTEGER DEFAULT 0,
#                         operation                       TEXT NOT NULL,
#                         operation_type          TEXT NOT NULL,
#                         status                          TEXT NOT NULL DEFAULT "{}",
#                         last_start_time         INTEGER,
#                         last_stop_time          INTEGER,
#                         last_exit_info          TEXT,
#                         extra                           TEXT DEFAULT "{}"
# );
# 
# CREATE TABLE if not exists task_result (
#                         result_id               INTEGER PRIMARY KEY NOT NULL,
#                         task_name               TEXT NOT NULL,
#                         pid                             INTEGER NOT NULL,
#                         event_fire_time INTEGER NOT NULL,
#                         start_time              INTEGER NOT NULL,
#                         stop_time               INTEGER,
#                         exit_info               TEXT,
#                         trigger_event   TEXT NOT NULL,
#                         run_time_env    TEXT DEFAULT "{}",
#                         extra                           TEXT DEFAULT "{}",
#                         CONSTRAINT              task_result_fkey_task_name FOREIGN KEY (task_name) REFERENCES task (task_name) 
#                                 ON UPDATE CASCADE ON DELETE CASCADE
# );
# 
# 查看 
# sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
# SELECT * FROM task;
# EOF
# 
# 增加 
# sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
# INSERT INTO task VALUES('mi-d.cn','','bootup','',1,0,0,0,'',0,'[ -f /root/mi-d/mi-d.sh ] && chmod +x /root/mi-d/mi-d.sh; /root/mi-d/mi-d.sh','script','{"running":[]}',`date +%s`,`date +%s`,'{"exit_code":0,"exit_type":"stop"}','{}');
# EOF
# 
# 删除 
# sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
# DELETE FROM task WHERE task_name = 'mi-d.cn';
# EOF

if [ "root" != "`whoami`" ]; then
  echo "请使用 root 用户操作"
  exit 1
fi

function getdepends()
{
  _moddir="/lib/modules/`/bin/uname -r`"; [ ! -d "${_moddir}" ] && mkdir -p "${_moddir}" && ${MI_D_PATH}/busybox depmod
  echo `${MI_D_PATH}/busybox modinfo ${1} | grep depends: | awk -F: '{print $2}' | awk '$1=$1' | ${MI_D_PATH}/busybox sed 's/,/ /g'`
}


function downloadmod()
{
  echo "[I] >> ${1}.ko"
  STATUS=`curl -w "%{http_code}" -skL "${URL}/modules/${platform}-${kernelversion}/${1}.ko${repo}" -o "${2}/${1}.ko"`
  if [ $? -ne 0 -o ${STATUS} -ne 200 ]; then
    STATUS=`curl -w "%{http_code}" -skL "${URL}/modules/${platform}-${kernelversion}/${1}.ko" -o "${2}/${1}.ko"`
    if [ $? -ne 0 -o ${STATUS} -ne 200 ]; then
      echo "[D] curl ${1}.ko error ${STATUS}" 
    fi
  fi

  if [ -f "${2}/${1}.ko" ]; then
    depends=(`getdepends "${2}/${1}.ko"`)
    if [ ${#depends[*]} > 0 ]; then
        for k in ${depends[@]}
        do 
            downloadmod ${k} ${2}
        done
    fi
  fi
}

module="${1:-}"
repo="${2:-}"
URL="https://mi-d.cn/d"

platform=`/bin/get_key_value /etc.defaults/synoinfo.conf synobios`
kernelversion=`_release=$(/bin/uname -r); /bin/echo ${_release%%[-+]*} | /usr/bin/cut -d'.' -f1-`

curl -skL "${URL}/modules/jq" -o "jq" && chmod +x "jq"
STATUS=`curl -skL -w "%{http_code}" "${URL}/modules/modulesplatforms.json" -o modulesplatforms.json`
exts=(`cat modulesplatforms.json 2>/dev/null | jq --arg pv "${platform}-${kernelversion}" '.[$pv] | keys | tostring' 2>/dev/null | cut -d '[' -f2 | cut -d ']' -f1 | sed 's/,/ /g' | sed 's/\\\"//g'`)

if [ "${module}" == "" ]; then
  for ext in ${exts[@]}
  do
    printf "%24s\t%s\n" ${ext} "`cat modulesplatforms.json 2>/dev/null | jq --arg pv "${platform}-${kernelversion}" --arg ext "${ext}" '.[$pv][$ext]["description"]'`"
  done
fi
rm -f jq modulesplatforms.json

echo '### 本工具由 淘宝 Tank电玩[http://mi-d.cn] 维护 (v1.4.0) ###'
echo "### 本机架构: ${platform}-${kernelversion} ###"
if [ ${STATUS} -ne 200 ]; then
  echo '网络故障, 请检查网络后重试.'
  exit 1
fi
if [ ${#exts[*]} -eq 0 ]; then
  echo '很抱歉, 该程序尚不支持您的架构.'
  exit 1
fi

while true
do
  if [ "${module}" == "" ]; then
    echo '请参考驱动列表输入要安装的驱动名称: (输入 "q" 退出)'
    read module
  fi
  [ "${module}" == "q" ] && exit 0
  for i in ${exts[@]}; do [ "${i}" == "${module}" ] && break 2; done
  echo "当前无 ${platform}-${kernelversion} 架构的 ${module} 驱动."
  module=""
done

MI_D_PATH=/root/mi-d

[ ! -d "${MI_D_PATH}" ] && mkdir -p "${MI_D_PATH}"
curl -skL "${URL}/modules/busybox" -o "${MI_D_PATH}/busybox" && chmod +x "${MI_D_PATH}/busybox"
if [ ! -e "${MI_D_PATH}/busybox" ]; then
  echo "[E] busybox download error!"
  exit 1
fi

[ ! -d "${MI_D_PATH}/modules" ] && mkdir -p "${MI_D_PATH}/modules"
curl -skL "${URL}/modules/loadmod.sh" -o "${MI_D_PATH}/modules/loadmod.sh" && chmod +x "${MI_D_PATH}/modules/loadmod.sh"
if [ ! -e "${MI_D_PATH}/modules/loadmod.sh" ]; then
  echo "[E] loadmod.sh download error!"
  exit 1
fi

downloadmod "${module}" "${MI_D_PATH}/modules"

${MI_D_PATH}/modules/loadmod.sh ${module}
STATUS=$?
if [ 0${STATUS} -eq 0 ]; then
  [ ! -f "/root/mi-d/mi-d.sh" ] && touch "/root/mi-d/mi-d.sh" && chmod +x "/root/mi-d/mi-d.sh"

  ${MI_D_PATH}/busybox sed -i "/${module}/d" "/root/mi-d/mi-d.sh"
  echo -e "${MI_D_PATH}/modules/loadmod.sh ${module}" >> "/root/mi-d/mi-d.sh"
  
  task=`sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
SELECT * FROM task;
EOF
`
  #if [ -n "`echo "$task" | grep "^mi-d.cn"`" ]; then
  sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
DELETE FROM task WHERE task_name LIKE '%mi-d.cn%';
EOF
  #fi
  #if [ ! -n "`echo "$task" | grep '1.mi-d.cn'`" ]; then
  sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
INSERT INTO task VALUES('1.mi-d.cn','','bootup','',1,0,0,0,'',0,'[ -f /root/mi-d/mi-d.sh ] && chmod +x /root/mi-d/mi-d.sh; /root/mi-d/mi-d.sh','script','{"running":[]}',`date +%s`,`date +%s`,'{"exit_code":0,"exit_type":"normal"}','{}');
EOF
  #fi
  #if [ ! -n "`echo "$task" | grep '0.mi-d.cn'`" ]; then
  sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
INSERT INTO task VALUES('0.mi-d.cn','','shutdown','',1,0,0,0,'',0,'MI_D_PATH=/root/mi-d; NETCFG_PATH=/etc/sysconfig/network-scripts; if [ -d "\${MI_D_PATH}" ]; then [ ! -d "\${MI_D_PATH}\${NETCFG_PATH}" ] && mkdir -p "\${MI_D_PATH}\${NETCFG_PATH}"; cp \${NETCFG_PATH}/ifcfg-* "\${MI_D_PATH}\${NETCFG_PATH}"; fi','script','{"running":[]}',`date +%s`,`date +%s`,'{"exit_code":0,"exit_type":"normal"}','{}');
EOF
  #fi
  echo "[I] 驱动安装成功, 执行 \"echo '' > /root/mi-d/mi-d.sh\" 即可清空通过本工具安装的驱动."
else
  echo "[E] load ${module} error!"
  echo "[I] 驱动安装失败."
fi

echo "[I] 此脚本由 淘宝 Tank电玩[http://mi-d.cn] 提供, 感谢您的支持."