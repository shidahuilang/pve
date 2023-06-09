#!/usr/bin/env bash

# 一键在/etc/profile最下面添加 source /root/system-info.sh
# sed -i '/system-info/d' /etc/profile && echo "source /root/system-info.sh" >> /etc/profile

# 任何更改都将在支持包更新中丢失
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


SHOW_IP_PATTERN="^[ewr].*|^br.*|^lt.*|^umts.*"


# 不要在下面编辑
function display()
{
    # $1=name $2=value $3=red_limit $4=minimal_show_limit $6=after $7=acs/desc{
    # battery red color is opposite, lower number
    if [[ "$1" == "Battery" ]]; then
        local great="<";
    else
        local great=">";
    fi
    if [[ -n "$2" && (( "${2%.*}" -ge "$4" )) ]]; then
        printf "%-14s%s" "$1:"
        if awk "BEGIN{exit ! ($2 $great $3)}"; then
            echo -ne "\e[0;91m $2";
        else
            echo -ne "\e[0;92m $2";
        fi
        printf "%-1s%s\x1B[0m" "$6"
        printf "%-11s%s\t" ""
        return 1
    fi
} # display


function get_ip_addresses()
{
    local ips=()
    for f in /sys/class/net/*; do
        local intf=$(basename $f)
        # match only interface names starting with e (Ethernet), br (bridge), w (wireless), r (some Ralink drivers use ra<number> format)
        if [[ $intf =~ $SHOW_IP_PATTERN ]]; then
            local tmp=$(ifconfig $intf | awk '/inet / {print $2}')
            # add IP only
            [[ -n $tmp ]] && ips+=("$tmp")
        fi
    done
    echo "${ips[@]}"
} # get_ip_addresses


function storage_info()
{
    # storage info
    RootInfo=$(df -h /)
    root_usage=$(awk '/\// {print $(NF-1)}' <<<${RootInfo} | sed 's/%//g')
    root_total=$(awk '/\// {print $(NF-4)}' <<<${RootInfo})

    # storage info
    BootInfo=$(df -h /boot/efi)
    boot_usage=$(awk '/\// {print $(NF-1)}' <<<${BootInfo} | sed 's/%//g')
    boot_total=$(awk '/\// {print $(NF-4)}' <<<${BootInfo})

} # storage_info


# 查询各种系统并将一些内容发送到后台，以便总体上更快地执行.
# 仅适用于环境温度和电池信息，因为A20足够慢 :)
ip_address=$(get_ip_addresses &)
storage_info
critical_load=$(( 1 + $(grep -c processor /proc/cpuinfo) / 2 ))

# 获取正常运行时间、登录用户和一次性加载
UptimeString=$(uptime | tr -d ',')
time=$(awk -F" " '{print $3" "$4}' <<<"${UptimeString}")
load="$(awk -F"average: " '{print $2}'<<<"${UptimeString}")"
case ${time} in
    1:*) # 1-2 hours
        time=$(awk -F" " '{print $3" 小时"}' <<<"${UptimeString}")
        ;;
    *:*) # 2-24 hours
        time=$(awk -F" " '{print $3" 小时"}' <<<"${UptimeString}")
        ;;
    *day) # days
        days=$(awk -F" " '{print $3"天"}' <<<"${UptimeString}")
        time=$(awk -F" " '{print $5}' <<<"${UptimeString}")
        time="$days "$(awk -F":" '{print $1"小时 "$2"分钟"}' <<<"${time}")
        ;;
esac


# 内存和交换区信息
mem_info=$(free -w 2>/dev/null | grep "^Mem" || free | grep "^Mem")
memory_usage=$(awk '{printf("%.0f",(($2-($4+$6))/$2) * 100)}' <<<${mem_info})
memory_total=$(awk '{printf("%d",$2/1024)}' <<<${mem_info})
memory_used=$(awk '{printf("%d",($3+$5)/1024)}' <<<${mem_info})
memory_useds=$(awk '{printf("%.0f",(($3+$5)/$2) * 100)}' <<<${mem_info})
memory_cache=$(awk '{printf("%d",$7/1024)}' <<<${mem_info})
memory_caches=$(awk '{printf("%.0f",($7/$2) * 100)}' <<<${mem_info})


swap_info=$(free -m | grep "^Swap")
swap_usage=$( (awk '/Swap/ { printf("%3.0f", $3/$2*100) }' <<<${swap_info} 2>/dev/null || echo 0) | tr -c -d '[:digit:]')
swap_total=$(awk '{print $(2)}' <<<${swap_info})

# 处理器信息
cpuinfox=$(cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c)
cpuinfo=`echo $cpuinfox | sed 's/.*G*./& 核心x/g' | sed -r 's/^(..)(.*)/\2\1/'`

# 主板和操作系统信息
chassis_vendor=`cat /sys/class/dmi/id/chassis_vendor`
product_version=`cat /sys/class/dmi/id/product_version`
arch=`arch`
operating_system=`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`

# display info
echo ""
echo ""
#在线生成：http://patorjk.com/software/
#字体：Roman


echo "   oooooooooo.              .o8        o8o                         "
echo "   '888'   'Y8b            '888        '''                         "
echo "    888      888  .ooooo.   888oooo.  oooo   .oooo.   ooo. .oo.    "
echo "    888      888 d88' '88b  d88' '88b '888  'P  188b  '888P'Y88b   "
echo "    888      888 888ooo888  888   888  888   .oP'888   888   888   "
echo "    888     d88' 888    .o  888   888  888  d8(  888   888   888   "
echo "   o888bood8P'   'Y8bod8P'  'Y8bod8P' o888o 'Y888''8o o888o o888o  "



echo ""
echo -e "-------------------------------系统信息----------------------------"
echo ""

printf "制 造 商:  \x1B[92m%s\x1B[0m" "$chassis_vendor $product_version"
echo ""

printf "处 理 器:  \x1B[92m%s\x1B[0m" "$cpuinfo $arch"
echo ""

printf "操作系统:  \x1B[92m%s\x1B[0m" "$operating_system"
echo ""

printf "IP  地址:  \x1B[92m%s\x1B[0m" "$ip_address"
echo ""

display "系统负载" "${load%% *}" "${critical_load}" "0" "" "${load#* }"
printf "运行时间:  \x1B[92m%s\x1B[0m\t\t" "$time"
echo ""

display "内存已用" "$memory_usage" "70" "0" "%" " of ${memory_total}MB"
display "交换内存" "$swap_usage" "10" "0" "%" " of $swap_total""Mb"
echo ""

display "真实内存" "$memory_useds" "50" "0" "%" " 值：$memory_used""Mb"
display "缓存内存" "$memory_caches" "40" "0" "%" " 值：$memory_cache""Mb"
echo ""

display "启动存储" "$boot_usage" "90" "1" "%" " of $boot_total"
display "系统存储" "$root_usage" "90" "1" "%" " of $root_total"
echo ""

echo ""
echo -e "------------------------------硬盘使用率---------------------------"
#显示指定路径
# df -hT / /boot/efi /docker/caddy/srv /docker/download
#显示指定分区格式
# df -Th -t vfat -t xfs -t ext4 -t nfs
#排除指定分区格式
df -Th -x tmpfs -x overlay -x devtmpfs

echo ""


SSHTG="警报-'$USER'用户在'$HOSTNAME'主机上登录，登录时间：`date`，来源IP：`who`"
SSHTG=`echo $SSHTG | sed 's/ /%20/g'`
curl "http://43.154.188.00:20086/push?token=dahuilang&message=$SSHTG" >/dev/null 2>&1
curl "https://api.workers.dev/bot16953:AAGeQmivyLJjVC5iydQkqix45tZbWyY_LGY/sendMessage" -d "chat_id=12090658&text=$xinxi" >/dev/null 2>&1
