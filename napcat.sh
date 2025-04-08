#!/bin/sh

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CURRENT_DIR=$(
    cd "$(dirname "$0")" || exit
    pwd
)

echo -e '\033[35m'

cat << EOF
██       █████  ███    ██  ██████  
██      ██   ██ ████   ██ ██       
██      ███████ ██ ██  ██ ██   ███ 
██      ██   ██ ██  ██ ██ ██    ██ 
███████ ██   ██ ██   ████  ██████  
                                   
                                     
EOF

echo -e '\033[0m'

function log() {
    message="[Napcat Log]: $1 "

    case "$1" in
        *"失败"*|*"错误"*|*"请使用 root 或 sudo 权限运行此脚本"*|*"请参阅官方文档，选择受支持的系统。"*)
            echo -e "${RED}${message}${NC}" 2>&1 | tee -a "${CURRENT_DIR}"/install.log
            ;;
        *"成功"*)
            echo -e "${GREEN}${message}${NC}" 2>&1 | tee -a "${CURRENT_DIR}"/install.log
            ;;
        *"忽略"*|*"跳过"*)
            echo -e "${YELLOW}${message}${NC}" 2>&1 | tee -a "${CURRENT_DIR}"/install.log
            ;;
        *)
            echo -e "${BLUE}${message}${NC}" 2>&1 | tee -a "${CURRENT_DIR}"/install.log
            ;;
    esac
}

function check_system() {
    os=$(uname -m)

    if [[ ${os} == "x86_64" || ${os} == "amd64" ]]; then
        os="x86_64"
    elif [[  ${os} == "aarch64" || ${os} == "arm64" ]]; then
        os="aarch64"
    else
        log "暂不支持的系统架构，请参阅官方文档，选择受支持的系统。"
        exit 1
    fi

    if ! command -v apt &> /dev/null; then
        log "未检测到 apt 包管理器，请参阅官方文档，选择受支持的系统。"
        exit 1
    fi
}

function check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "请使用 root 或 sudo 权限运行此脚本"
        exit 1
    fi
}

function docker_network_test() {
    docker_target_proxy=""
    docker_proxy_arr=("docker.1panel.dev" "dockerpull.com" "docker.rainbond.cc" "dockerproxy.cn" "docker.agsvpt.work" "docker.agsv.top" "docker.registry.cyou")

    for docker_proxy in "${docker_proxy_arr[@]}"; do
        docker_status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 10 "${docker_proxy}/")

        if [ ${docker_status} -eq 200 ] || [ ${docker_status} -eq 301 ]; then
            docker_target_proxy="${docker_proxy}"
            log "将使用 docker 代理: ${docker_proxy}"
            break
        else
            log "无可用代理, 将直接连接 docker..."
        fi

    done
}

function github_network_test() {
    github_target_proxy=""
    github_proxy_arr=( "https://ghp.ci" "https://github.moeyy.xyz" "https://mirror.ghproxy.com" "https://gh-proxy.com" "https://x.haod.me")

    for github_proxy in "${github_proxy_arr[@]}"; do
        github_status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 10 "${github_proxy}/")

        if [ $github_status -eq 200 ]; then
            github_target_proxy="${github_proxy}"
            log "将使用 github 代理: ${github_proxy}"
            break
        else
            log "无可用代理, 将直接连接 github..."
        fi

    done
}

function change_repo() {

    change_repo_url="https://linuxmirrors.cn/main.sh"

    if curl -s --head "${change_repo_url}" | grep "200 OK" > /dev/null; then
        change_repo_url=${change_repo_url}
    else
        github_network_test
        change_repo_url=${github_target_proxy:+${github_target_proxy}/}https://raw.githubusercontent.com/SuperManito/LinuxMirrors/main/ChangeMirrors.sh
    fi

    curl -sSL ${change_repo_url} -o ChangeMirrors.sh
    chmod +x ChangeMirrors.sh
    log "(1)手动换源"
    log "(2)一键换源(清华源)"
    while true; do
        read -p "请输入数字选择您需要进行的操作:" choice

        case "${choice}" in
            1)
                bash ChangeMirrors.sh
                break
                ;;
            2)
                bash ChangeMirrors.sh --source mirrors.tuna.tsinghua.edu.cn --protocol http --use-intranet-source false --install-epel false --close-firewall true --backup true --upgrade-software true --clean-cache true --ignore-backup-tips
                break
                ;;
            *)
                log "错误的选项，请重新输入。"
                continue
                ;;
        esac
    done

}

function install_fonts() {
    log "apt install fonts-wqy-zenhei fonts-wqy-microhei -y > /dev/null 2>&1"
    apt install fonts-wqy-zenhei fonts-wqy-microhei -y > /dev/null 2>&1
    log "fc-cache -fv > /dev/null 2>&1"
    fc-cache -fv > /dev/null 2>&1
    log "中文字体安装完成，若不生效请重启服务器"
}

function check_docker() {
    while true; do

        if command -v docker >/dev/null 2>&1; then
            docker_version=$(docker --version | awk '{print $3}' | sed 's/,//g')
            log "检测到 docker 已安装，当前版本为 ${docker_version}"

            read -p "是否强制重新安装(回车默认跳过) (Y/n): " reinstalldocker
            if [[ "${reinstalldocker}" == "N" || "${reinstalldocker}" == "n" ]]; then
                log "正在强制重新安装 docker..."
                install_docker
                break
            fi

            if systemctl is-active --quiet docker; then
                log "docker 已在运行, 不需要重启"
                break
            else
                log "启动 docker"
                systemctl start docker 2>&1 | tee -a "${CURRENT_DIR}"/install.log
                break
            fi

        else
            log "未检测到 docker, 正在安装"
            install_docker
            break
        fi

    done
}

function install_docker() {
    while true; do

        log "请选择 docker 安装方式："
        log "1. 在线安装"
        log "2. 离线安装"
        read -p "请输入选择 (回车默认在线安装): " choice
        choice=${choice:-1}
        
        if [ "${choice}" = "1" ]; then
            log "... 在线安装 docker"
            docker_install_url="https://linuxmirrors.cn/docker.sh"

            if curl -s --head "${docker_install_url}" | grep "200 OK" > /dev/null; then
                docker_install_url=${docker_install_url}
            else
                github_network_test
                docker_install_url=${github_target_proxy:+${github_target_proxy}/}https://raw.githubusercontent.com/SuperManito/LinuxMirrors/main/DockerInstallation.sh
            fi

            curl -sSL ${docker_install_url} -o DockerInstallation.sh
            chmod +x DockerInstallation.sh
            log "(1)手动安装"
            log "(2)一键安装(清华源)"
            while true; do
                read -p "请输入数字选择您需要进行的操作:" choice

                case "${choice}" in
                    1)
                        bash DockerInstallation.sh
                        break
                        ;;
                    2)
                        bash DockerInstallation.sh --source mirrors.tuna.tsinghua.edu.cn/docker-ce --source-registry registry.hub.docker.com --install-latested true --ignore-backup-tips
                        break
                        ;;
                    *)
                        log "错误的选项，请重新输入。"
                        continue
                        ;;
                esac
            done
        elif [ "${choice}" = "2" ]; then
            log "... 离线安装 docker"
            github_network_test
            curl -O ${github_target_proxy:+${github_target_proxy}/}https://github.com/Fahaxikiii/napcat-scripts/releases/download/docker/docker.tar.gz
            tar zxvf docker.tar.gz
            rm -rf docker.tar.gz
            chmod +x docker/bin/*
            cp docker/bin/* /usr/bin/
            cp docker/service/docker.service /etc/systemd/system/
            chmod 754 /etc/systemd/system/docker.service
            mkdir -p /etc/docker/
            cp docker/conf/daemon.json /etc/docker/daemon.json
            rm -rf docker
            log "... 启动 docker"
            systemctl enable docker; systemctl daemon-reload; systemctl start docker 2>&1 | tee -a "${CURRENT_DIR}"/install.log
        else
            log "无效的选择，请重新输入"
            continue
        fi

        if command -v docker >/dev/null 2>&1; then
            docker_new_version=$(docker --version | awk '{print $3}' | sed 's/,//g')
            log "docker 已安装，版本为 ${docker_new_version}"
            break
        else
            log "docker 安装更新失败"
            read -p "是否重试安装 docker? 请尝试另一种方法(Y/n): " retry

            if [ "${retry}" = "Y" ] || [ "${retry}" = "y" ] || [ -z "${retry}" ]; then
                log "重试安装 docker..."
                continue
            else
                log "退出安装"
                exit 1
            fi

        fi

    done
}

function check_docker_compose() {
    check_system
    github_network_test
    required_docker_compose_version="2.26.1"
    docker_compose_url=${github_target_proxy:+${github_target_proxy}/}https://github.com/Fahaxikiii/napcat-scripts/releases/download/docker-compose/docker-compose-linux-$os
    if command -v docker-compose >/dev/null 2>&1; then
        installed_docker_compose_version=$(docker-compose --version | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^v//')

        if [ "$(printf '%s\n' "${required_docker_compose_version}" "${installed_docker_compose_version}" | sort -V | head -n1)" = "${required_docker_compose_version}" ]; then
            log "检测到 docker-compose 已安装, 跳过安装步骤"
        else
            log " docker-compose 版本过低, 开始升级"
            apt autoremove docker-compose -y > /dev/null 2>&1
            rm -rf $(which docker-compose) > /dev/null 2>&1
            curl -L "${docker_compose_url}" -o /usr/bin/docker-compose

            if [ -f /usr/bin/docker-compose ]; then
                chmod +x /usr/bin/docker-compose
                log "docker-compose 成功安装。"
            else
                log "文件下载失败，请检查网络连接。"
                exit 1
            fi
        fi

    else
        log "检测到 docker-compose 没有安装, 开始安装"
        curl -L "${docker_compose_url}" -o /usr/bin/docker-compose
        
        if [ -f "/usr/bin/docker-compose" ]; then
            chmod +x /usr/bin/docker-compose
            log "docker-compose 成功安装。"
        else
            log "文件下载失败，请检查网络连接。"
            exit 1
        fi
    fi
}

function set_container_name() {
    default_container_name="napcat"

    while true; do
        read -p "设置容器名称(默认为${default_container_name}): " container_name

        if [[ "${container_name}" == "" ]];then
            container_name=${default_container_name}
        fi

        log "您设置的容器名称为: ${container_name}"
        break
    done
}

function set_qq_account() {
    default_qq_account="123456789"

    while true; do
        read -p "设置 机器人 qq 号(默认为${default_qq_account}): " qq_account

        if [[ "${qq_account}" == "" ]];then
            qq_account=${default_qq_account}
        fi
        
        if [[ ! "${qq_account}" =~ ^[0-9]{1,30}$ ]]; then
            log "错误: qq 号仅支持数字,长度 1-30 位"
            continue
        fi

        log "您设置的机器人 qq 号为: ${qq_account}"
        break
    done
}

function mkdir_config_path() {
    mkdir -p "${config_path}/QQ"
    mkdir -p "${config_path}/config"
    mkdir -p "${config_path}/logs"
    create_napcat
    log "您设置的安装路径为: ${config_path}"
    log "您设置的 qq 持久化数据路径为: ${config_path}/QQ"
    log "您设置的 napcat 配置文件路径为: ${config_path}/config"
    log "您设置的 napcat 日志输出路径为: ${config_path}/logs"
}
function set_config_path() {
    log "当前目录为 $CURRENT_DIR"
    default_config_path="/opt/napcat"
    while true; do
        read -p "设置 napcat 安装目录(默认为${default_config_path}): " config_path

        if [[ "${config_path}" != "" ]]; then

            if [[ "${config_path}" != /* ]]; then
                log "请输入目录的完整路径"
                continue
            elif [[ ! -d ${config_path} ]]; then
                mkdir -p "${config_path}"
                mkdir_config_path
                break
            else
                mkdir_config_path
                break
            fi

        else
            config_path=${default_config_path}
            mkdir -p "${config_path}"
            mkdir_config_path
            break
        fi
    done
}

function set_bot_path() {
    local counter=1
    while true; do
        read -p "是否添加机器人目录(方便 ffmpeg 转码及发送本地文件) (Y/n): " addbot

        if [ "${addbot}" = "Y" ] || [ "${addbot}" = "y" ] || [ -z "${addbot}" ]; then
            add_bot_path ${counter}
            break
        else
            log "跳过添加，继续下一步"
            break
        fi

    done
}

function add_bot_path() {
    total_bot_paths=0
    local bot_path_counter=$((total_bot_paths + 1))
    while true; do
        log "回车也可跳过添加，继续下一步"
        read -p "请输入机器人安装目录(如/root/zhenxun_bot): " bot_path

        if [[ "${bot_path}" == "" ]]; then
            log "目录为空，跳过添加，继续下一步。"
            break
        elif [[ "${bot_path}" != /* ]]; then
            log "请输入目录的完整路径"
            continue
        elif [[ ! -d ${bot_path} ]]; then
            log "目录不存在，请重新添加"
            continue
        fi

        eval "bot_path${bot_path_counter}='${bot_path}'"
        log "已添加 bot_path${bot_path_counter}: ${bot_path}"
        bot_path_counter=$((bot_path_counter + 1))
        total_bot_paths=$((total_bot_paths + 1))

        read -p "是否继续添加另一个目录? (Y/n): " add_more
        if [ "${add_more}" != "Y" ] && [ "${add_more}" != "y" ] && [ ! -z "${add_more}" ]; then
            break
        fi
    done
}


function set_webui_host() {
    default_webui_host="0.0.0.0"

    while true; do
        read -p "设置 webui 主机(默认为${default_webui_host}): " webui_host

        if [[ "${webui_host}" == "" ]];then
            webui_host=${default_webui_host}
        fi

        if [[ "${webui_host}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
            webui_host=${webui_host}
            log "您设置的 webui 主机为: ${webui_host}"
            break
        elif [[ "${webui_host}" =~ ^\[?([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\]?$ || "${webui_host}" == "::" ]]; then
            webui_host=[${webui_host}]
            log "您设置的 webui 主机为: ${webui_host}"
            break
        else
            log "错误: 输入的主机必须是 ipv4 或 ipv6 地址"
            continue
        fi

        log "您设置的 webui 主机为: ${webui_host}"
        break
    done
}

function set_webui_port() {
    default_webui_port="6099"

    while true; do
        read -p "设置 webui 端口(默认为${default_webui_port}): " webui_port

        if [[ "${webui_port}" == "" ]];then
            webui_port=${default_webui_port}
        fi

        if ! [[ "${webui_port}" =~ ^[1-9][0-9]{0,4}$ && "${webui_port}" -le 65535 ]]; then
            log "错误: 输入的端口号必须在 1 到 65535 之间"
            continue
        fi

        if command -v ss >/dev/null 2>&1; then

            if ss -tlun | grep -q ":${webui_port} " >/dev/null 2>&1; then
                log "端口 ${webui_port} 被占用, 请重新输入..."
                continue
            fi

        elif command -v netstat >/dev/null 2>&1; then

            if netstat -tlun | grep -q ":${webui_port} " >/dev/null 2>&1; then
                log "端口 ${webui_port} 被占用, 请重新输入..."
                continue
            fi

        fi

        log "您设置的 webui 端口为: ${webui_port}"
        break
    done
}

function set_webui_token() {
    default_webui_token="napcat"

    while true; do
        read -p "设置 webui 密钥(默认为${default_webui_token}): " webui_token

        if [[ "${webui_token}" == "" ]];then
            webui_token=${default_webui_token}
        fi

        log "您设置的 webui 密钥为: ${webui_token}"
        break
    done
}

function set_webui_login_rate() {
    default_webui_login_rate="3"

    while true; do
        read -p "设置 webui 登录次数(默认为${default_webui_login_rate}): " webui_login_rate

        if [[ "${webui_login_rate}" == "" ]];then
            webui_login_rate=${default_webui_login_rate}
        fi

        if [[ ! "${webui_login_rate}" =~ ^[0-9]{1,30}$ ]]; then
            log "错误: webui 登录次数仅支持数字,长度 1-30 位"
            continue
        fi

        log "您设置的 webui 登录次数为: ${webui_login_rate}"
        break
    done
}

function create_webui_config() {
    webui_path="$config_path/config/webui.json"

cat <<EOF > "${webui_path}"
{
    "host": "${webui_host}",
    "port": ${webui_port},
    "prefix": "",
    "token": "${webui_token}",
    "loginRate": ${webui_login_rate}
}
EOF
}

function set_mac_address() {
    default_mac_address=$(ip addr show $(ip route | awk '/default/ {print $5}') | grep link/ether | awk '{print $2}')

    while true; do
        read -p "设置 mac_address (默认为${default_mac_address}): " mac_address

        if [[ "${mac_address}" == "" ]];then
            mac_address=${default_mac_address}
        fi

        if [[ ! "${mac_address}" =~ ^([0-9a-fA-F]{2}(:|-)){5}[0-9a-fA-F]{2}$ ]]; then
            log "错误: mac_address 格式错误"
            continue
        fi

        log "您设置的 mac_address 为: ${mac_address}"
        break
    done
}

function set_napcat_uid() {
    default_napcat_uid="0"

    while true; do
        read -p "设置 napcat uid (默认为${default_napcat_uid}): " napcat_uid

        if [[ "${napcat_uid}" == "" ]];then
            napcat_uid=${default_napcat_uid}
        fi

        if [[ ! "${napcat_uid}" =~ ^[0-9]{1,30}$ ]]; then
            log "错误: napcat uid 仅支持数字,长度 1-30 位"
            continue
        fi

        log "您设置的 napcat uid 为: ${napcat_uid}"
        break
    done
}

function set_napcat_gid() {
    default_napcat_gid="0"

    while true; do
        read -p "设置 napcat gid (默认为${default_napcat_gid}): " napcat_gid

        if [[ "${napcat_gid}" == "" ]];then
            napcat_gid=${default_napcat_gid}
        fi

        if [[ ! "${napcat_gid}" =~ ^[0-9]{1,30}$ ]]; then
            log "错误: napcat gid 仅支持数字,长度 1-30 位"
            continue
        fi

        log "您设置的 napcat gid 为: ${napcat_gid}"
        break
    done
}

function get_ip() {
    active_interface=$(ip route | awk '/default/ {print $5}')
    public_ipv4=$(curl -s 4.ipw.cn)
    public_ipv6=$(curl -s 6.ipw.cn)

    if [[ -z ${active_interface} ]]; then
        local_ip="127.0.0.1"
    else
        local_ip=$(ip -4 addr show dev "${active_interface}" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    fi

    if [[ -z "${public_ipv4}" ]]; then
        {public_ipv4}="N/A"
    fi

    if echo "${public_ipv4}" | grep -q ":"; then
        public_ipv4=${public_ipv4}
    fi

    if [[ -z "${public_ipv6}" ]]; then
        public_ipv6="N/A"
    fi

    if echo "${public_ipv6}" | grep -q ":"; then
        public_ipv6=[${public_ipv6}]
    fi
}

function confirm_napcat_env() {
    clear
    log "(1)您设置的容器名称为: ${container_name}"
    log "(2)您设置的机器人QQ号为: ${qq_account}"
    log "(3)您设置的QQ持久化数据路径为: ${config_path}/QQ"
    log "(3)您设置的NapCat配置文件路径为: ${config_path}/config"
    log "(3)您设置的NapCat日志输出路径为: ${config_path}/logs"
    log "(4)您设置的WEBUI主机为: ${webui_host}"
    log "(5)您设置的WEBUI端口为: ${webui_port}"
    log "(6)您设置的WEBUI密钥为: ${webui_token}"
    log "(7)您设置的WEBUI登录次数为: ${webui_login_rate}"
    log "(8)您设置的MAC_ADDRESS为: ${mac_address}"
    log "(9)您设置的Napcat UID为: ${napcat_uid}"
    log "(10)您设置的Napcat GID为: ${napcat_gid}"

    for i in $(seq 1 ${total_bot_paths}); do
        eval current_bot_path="\$bot_path${i}"

        if [[ "${current_bot_path}" != "" ]]; then
            log "(11) 您设置的机器人目录为: ${current_bot_path}"
        else
            log "(11) 您设置的机器人目录为空"
        fi
    done
    log "您想要继续修改数据还是继续下一步？直接回车进行安装"
}

function confirm_napcat() { 
    confirm_napcat_env
    while true; do
        read -p "请输入数字选择您需要修改的数据:" choice

        case "${choice}" in
            1)
                set_container_name
                confirm_napcat_env
                continue
                ;;
            2)
                set_qq_account
                confirm_napcat_env
                continue
                ;;
            3)
                set_config_path
                confirm_napcat_env
                continue
                ;;
            4)
                set_webui_host
                confirm_napcat_env
                continue
                ;;
            5)
                set_webui_port
                confirm_napcat_env
                continue
                ;;
            6)
                set_webui_token
                confirm_napcat_env
                continue
                ;;
            7)
                set_webui_login_rate
                confirm_napcat_env
                continue
                ;;
            8)
                set_mac_address
                confirm_napcat_env
                continue
                ;;
            9)
                set_napcat_uid
                confirm_napcat_env
                continue
                ;;
            10)
                set_napcat_gid
                confirm_napcat_env
                continue
                ;;
            11)
                set_bot_path
                confirm_napcat_env
                continue
                ;;
            "")
                break
                ;;
            *)
                log "错误的选项，请重新输入。"
                continue
                ;;
        esac

    done
    log "开始安装，请您耐心等待。"
    create_napcat_env
    create_napcat_cmd
    install_napcat
}

function create_napcat_env() {
    docker_network_test

cat <<EOF > "${config_path}/.env"
CONTAINER_NAME=${container_name}
MAC_ADDRESS=${mac_address}
NAPCAT_UID=${napcat_uid}
NAPCAT_GID=${napcat_gid}
QQ_ACCOUNT=${qq_account}
CONFIG_PATH=${config_path}
WEBUI_HOST=${webui_host}
WEBUI_PORT=${webui_port}
WEBUI_TOKEN=${webui_token}
WEBUI_LOGIN_RATE=${webui_login_rate}
PUBLIC_IPV4=${public_ipv4}
PUBLIC_IPV6=${public_ipv6}
LOCAL_IP=${local_ip}
DOCKER_TARGET_PROXY=${docker_target_proxy}
EOF

    for i in $(seq 1 ${total_bot_paths}); do
        eval current_bot_path="\$bot_path${i}"

        if [[ "${current_bot_path}" != "" ]]; then
            echo "BOT_PATH${i}=${current_bot_path}" >> "${config_path}/.env"
            echo "            - \"\${BOT_PATH${i}}/\${BOT_PATH${i}}\"" >> "${config_path}/docker-compose.yml"
        fi
    done

}

function create_napcat() {

cat <<EOF > "${config_path}/docker-compose.yml"
services:
    napcat:
        container_name: \${CONTAINER_NAME}
        image: \${DOCKER_TARGET_PROXY:+\${DOCKER_TARGET_PROXY}/}mlikiowa/napcat-docker:latest
        restart: always
        network_mode: "host"
        mac_address: "\${MAC_ADDRESS}"
        environment:
            - "TZ=Asia/Shanghai"
            - "NAPCAT_UID=\${NAPCAT_UID}"
            - "NAPCAT_GID=\${NAPCAT_GID}"
            - "ACCOUNT=\${QQ_ACCOUNT}"
        volumes:
            - "\${CONFIG_PATH}/QQ:/app/.config/QQ"
            - "\${CONFIG_PATH}/config:/app/napcat/config"
            - "\${CONFIG_PATH}/logs:/app/napcat/logs" 
EOF

}

function install_napcat() {
    docker-compose -f "${config_path}/docker-compose.yml" --env-file "${config_path}/.env" up -d
    show_result
}

function create_napcat_cmd() {
    mkdir -vp /usr/local/bin
cat <<EOF > "/usr/local/bin/napcat"
#!/bin/bash
action=\$1
. ${config_path}/.env
function usage() {
    echo "napcat 控制脚本"
    echo
    echo "Usage: "
    echo "  napcat [COMMAND] "
    echo "  napcat help"
    echo
    echo "Usage: napcat {status|start|stop|restart|update|rebuild|uninstall|info|log|help}"
    echo "  status              查看 \${CONTAINER_NAME} 容器运行状态"
    echo "  start               启动 \${CONTAINER_NAME} 容器"
    echo "  stop                停止 \${CONTAINER_NAME} 容器"
    echo "  restart             重启 \${CONTAINER_NAME} 容器"
    echo "  update              更新 \${CONTAINER_NAME} 容器"
    echo "  rebuild             重建 \${CONTAINER_NAME} 容器"
    echo "  uninstall           卸载 \${CONTAINER_NAME} 容器"
    echo "  info                获取 \${CONTAINER_NAME} 容器信息"
    echo "  log 行数            查看 \${CONTAINER_NAME} 容器最后多少条(默认100)日志"
}

function status() {
    docker ps -a | grep "\${CONTAINER_NAME}"
}

function start() {
    docker-compose -f "\${CONFIG_PATH}/docker-compose.yml" --env-file "\${CONFIG_PATH}/.env" up -d
}

function stop() {
    docker-compose -f "\${CONFIG_PATH}/docker-compose.yml" stop
}

function restart() {
    docker-compose -f "\${CONFIG_PATH}/docker-compose.yml" restart
}

function update() {
    docker-compose -f "\${CONFIG_PATH}/docker-compose.yml" stop
    docker-compose -f "\${CONFIG_PATH}/docker-compose.yml" pull
    docker-compose -f "\${CONFIG_PATH}/docker-compose.yml" up -d
}

function rebuild() {
    echo "咕咕咕"
}

function uninstall() {
    docker-compose -f "\${CONFIG_PATH}/docker-compose.yml" down
}

function info() {
    echo "容器名称: \${CONTAINER_NAME}"
    echo "QQ 账号: \${QQ_ACCOUNT}"
    echo "MAC地址: \${MAC_ADDRESS}"
    echo "NAPCAT_UID: \${NAPCAT_UID}"
    echo "NAPCAT_GID: \${NAPCAT_GID}"
    echo "数据目录: \${CONFIG_PATH}"
    echo "Docker代理: \${DOCKER_TARGET_PROXY}"
    echo
    echo "WEBUI主机: \${WEBUI_HOST}"
    echo "外网地址: http://\${PUBLIC_IPV4}:\${WEBUI_PORT}/webui"
    echo "外网地址: http://\${PUBLIC_IPV6}:\${WEBUI_PORT}/webui"
    echo "内网地址: http://127.0.0.1:\${WEBUI_PORT}/webui"
    echo "内网地址: http://\${LOCAL_IP}:\${WEBUI_PORT}/webui"
    echo "访问密钥: \${WEBUI_TOKEN}"
    echo "WEBUI限制登录次数为: \${WEBUI_LOGIN_RATE}"
}

function log() {
    docker logs -t -fn"\${2:-100}" "\${CONTAINER_NAME}"
}

function main() {
    case "\${action}" in
        status)
            status
            ;;
        start)
            start
            ;;
        stop)
            stop
            ;;
        restart)
            restart
            ;;
        update)
            update
            ;;
        rebuild)
            rebuild
            ;;
        uninstall)
            uninstall
            ;;
        info)
            info
            ;;
        log)
            log
            ;;
        help)
            usage
            ;;
        "")
            usage
            ;;
        *)
        echo "不支持的参数，请使用 help 或 --help 参数获取帮助"
    esac
}
main
EOF
    cp -f "/usr/local/bin/${container_name}" "${config_path}/${container_name}"
    chmod 755 "/usr/local/bin/${container_name}"

}

function show_result() {
    log ""
    log "=================感谢您的耐心等待，安装已经完成=================="
    log ""
    log "napcat 容器已启动，容器名称: ${container_name}"
    log ""
    log "请用浏览器访问webui:"
    log "外网地址: http://${public_ipv4}:${webui_port}/webui"
    log "外网地址: http://${public_ipv6}:${webui_port}/webui"
    log "内网地址: http://127.0.0.1:${webui_port}/webui"
    log "内网地址: http://${local_ip}:${webui_port}/webui"
    log "访问密钥: ${webui_token}"
    log "如果使用的是云服务器，请至安全组开放 ${webui_port} 端口"
    log ""
    log "已安装 napcat 控制脚本"
    log "请使用 ${container_name} help 获取帮助"
    log ""
    log "================================================================"
}

function main() {
    check_system
    check_root
    log "(1)安装 napcat"
    log "(2)更换系统软件源"
    log "(3)安装升级 docker"
    log "(4)安装中文字体"
    log "(5)退出脚本"
    while true; do
        read -p "请输入数字选择您需要进行的操作:" choice

        case "$choice" in
            1)
                check_docker
                check_docker_compose
                set_container_name
                set_qq_account
                set_config_path
                set_bot_path
                set_webui_host
                set_webui_port
                set_webui_token
                set_webui_login_rate
                create_webui_config
                set_mac_address
                set_napcat_uid
                set_napcat_gid
                get_ip
                confirm_napcat
                break
                ;;
            2)
                change_repo
                continue
                ;;
            3)
                check_docker
                continue
                ;;
            4)
                install_fonts
                continue
                ;;
            5)
                log "欢迎您的使用"
                break
                ;;
            *)
                log "错误的选项，请重新输入。"
                continue
                ;;
        esac

    done
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --install)
            check_docker
            check_docker_compose
            set_container_name
            set_qq_account
            set_config_path
            set_bot_path
            set_webui_host
            set_webui_port
            set_webui_token
            set_webui_login_rate
            create_webui_config
            set_mac_address
            set_napcat_uid
            set_napcat_gid
            get_ip
            confirm_napcat
            exit 0
            ;;
        *)
            echo "错误，请使用--install"
            exit 1
            ;;
    esac
done

main
