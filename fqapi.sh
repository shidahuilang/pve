#!/bin/bash

# 项目配置
PROJECT_PORT=8000
MAX_CONNECTIONS=1024
NUM_WORKERS=4
NUM_THREADS=2
PYTHON_VERSION="3.11.2"
VENV_DIR="venv"
PID_FILE="project.pid"
LOG_FILE="project.log"

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 打印消息
print_message() {
    local type="$1"
    local message="$2"
    case "$type" in
        success) echo -e "${GREEN}[成功] $message${NC}" ;;
        error) echo -e "${RED}[错误] $message${NC}" ;;
        warning) echo -e "${YELLOW}[警告] $message${NC}" ;;
        *) echo "[信息] $message" ;;
    esac
    sleep 1
}


# 执行检查
check_gunicorn_status
check_redis_status


# 检测操作系统类型
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            OS="debian"
            print_message "success" "检测到操作系统为 Debian/Ubuntu 系列"
        elif command -v yum &> /dev/null; then
            OS="centos"
            print_message "success" "检测到操作系统为 CentOS/RedHat 系列"
        else
            OS="linux-unknown"
            print_message "error" "未知的 Linux 发行版"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="darwin"
        print_message "success" "检测到操作系统为 macOS"
    else
        OS="unknown"
        print_message "error" "无法检测操作系统类型"
        exit 1
    fi

    echo "操作系统类型：$OS"  # 调试输出操作系统类型
}




# 创建 requirements.txt 文件
create_requirements_file() {
    cat <<EOL > requirements.txt
requests
flask
bs4
lxml
cryptography
redis
resend
gunicorn
psutil
opencc-python-reimplemented
EOL
}

# 安装系统依赖
install_dependencies() {
    print_message "success" "安装系统依赖..."
    case "$OS" in
        debian)
            sudo apt update && sudo apt install -y build-essential libssl-dev libffi-dev python3-dev zlib1g-dev
            ;;
        centos)
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y openssl-devel bzip2-devel libffi-devel zlib-devel
            ;;
        darwin)
            brew install openssl readline sqlite3 zlib1g-dev zlib
            ;;
        *)
            print_message "error" "不支持的操作系统"
            exit 1
            ;;
    esac
}


# 安装 Python 3.11 和虚拟环境
install_python() {
    # 检查是否已安装 Python 3.11
    if ! python3.11 --version &> /dev/null; then
        print_message "warning" "未检测到 Python $PYTHON_VERSION，开始安装..."

        # 安装系统依赖
        install_dependencies

        # 下载并安装 Python 3.11
        wget "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
        tar -xf Python-$PYTHON_VERSION.tgz
        cd Python-$PYTHON_VERSION
        ./configure --enable-optimizations
        make -j$(nproc)
        sudo make altinstall
        cd .. && rm -rf Python-$PYTHON_VERSION Python-$PYTHON_VERSION.tgz
        print_message "success" "Python $PYTHON_VERSION 安装完成"
    else
        print_message "success" "Python $PYTHON_VERSION 已安装"
    fi

    # 强制安装 python3.11-venv 和相关模块
    if ! dpkg -l | grep -q python3.11-venv; then
        print_message "warning" "未找到 python3.11-venv，开始强制安装..."
        sudo apt update
        sudo apt install -y python3.11-venv python3.11-dev python3.11-distutils
    fi

    # 安装 pip（使用 apt 安装）
    if ! python3.11 -m pip --version &> /dev/null; then
        print_message "warning" "未找到 pip，开始使用 apt 安装..."
        sudo apt install -y python3-pip
        python3.11 -m pip install --upgrade pip setuptools
    fi
}

# 设置虚拟环境并安装依赖
setup_virtualenv() {
    print_message "success" "设置虚拟环境..."
    create_requirements_file

    # 检查 python3.11 是否支持 venv
    if ! python3.11 -m venv "$VENV_DIR" &> /dev/null; then
        print_message "error" "无法创建虚拟环境，可能缺少必要的 venv 模块"
        exit 1
    fi

    python3.11 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip
    pip install --no-cache-dir -r requirements.txt
    print_message "success" "依赖安装完成"
}


# 安装并启动 Redis
setup_redis() {
    if ! command -v redis-server &> /dev/null; then
        print_message "warning" "Redis 未安装，开始安装..."
        case "$OS" in
            debian)
                sudo apt update && sudo apt install -y redis-server
                ;;
            centos)
                sudo yum install -y epel-release
                sudo yum install -y redis
                ;;
            darwin)
                brew install redis
                ;;
            *)
                print_message "error" "不支持的操作系统"
                exit 1
                ;;
        esac
        print_message "success" "Redis 安装完成"
    else
        print_message "success" "Redis 已安装"
    fi

    print_message "success" "启动 Redis 服务..."
    case "$OS" in
        debian | centos)
            sudo systemctl start redis-server
            ;;
        darwin)
            redis-server --daemonize yes
            ;;
    esac

    # 检查 Redis 是否成功启动
    if [[ "$OS" == "darwin" ]]; then
        # macOS 通过检查进程是否存在来确认 Redis 是否启动
        if ! pgrep -x "redis-server" > /dev/null; then
            print_message "error" "Redis 启动失败，正在替换配置文件..."
            configure_redis
        else
            print_message "success" "Redis 服务已启动"
        fi
    else
        if ! systemctl is-active --quiet redis; then
            print_message "error" "Redis 启动失败，正在替换配置文件..."
            configure_redis
        else
            print_message "success" "Redis 服务已启动"
        fi
    fi
}

# 替换 Redis 配置文件
configure_redis() {
    # 获取 Redis 配置文件路径
    local redis_conf_path
    if [[ "$OS" == "debian" || "$OS" == "centos" ]]; then
        redis_conf_path="/etc/redis/redis.conf"
    elif [[ "$OS" == "darwin" ]]; then
        redis_conf_path="/usr/local/etc/redis.conf"
    else
        print_message "error" "无法找到 Redis 配置文件路径"
        exit 1
    fi

    # 替换配置文件内容
    echo -e "bind 127.0.0.1\nport 6379\nprotected-mode no" | sudo tee "$redis_conf_path" > /dev/null

    # 尝试重新启动 Redis 服务
    print_message "success" "配置文件已替换，尝试重新启动 Redis 服务..."
    case "$OS" in
        debian | centos)
            sudo systemctl start redis-server
            ;;
        darwin)
            redis-server --daemonize yes
            ;;
    esac

    if [[ "$OS" == "darwin" ]]; then
        if pgrep -x "redis-server" > /dev/null; then
            print_message "success" "Redis 服务已成功启动"
        else
            print_message "error" "Redis 启动仍然失败，请检查配置文件和日志"
        fi
    else
        if systemctl is-active --quiet redis; then
            print_message "success" "Redis 服务已成功启动"
        else
            print_message "error" "Redis 启动仍然失败，请检查配置文件和日志"
        fi
    fi
}



# 检查端口是否被占用并释放
check_and_release_port() {
    local port=$1
    local pids
    pids=$(lsof -t -i :"$port") # 获取占用端口的进程 ID
    if [[ -n "$pids" ]]; then
        print_message "warning" "端口 $port 已被以下进程占用："
        lsof -i :"$port"
        print_message "warning" "尝试终止占用进程..."
        echo "$pids" | xargs -r kill -9
        print_message "success" "端口 $port 已释放"
    else
        print_message "success" "端口 $port 未被占用"
    fi
}

# 启动项目（后台运行）
start_project() {
    check_and_release_port "$PROJECT_PORT"
    source "$VENV_DIR/bin/activate"
    print_message "success" "启动项目（后台运行）..."
    gunicorn -w "$NUM_WORKERS" -t "$NUM_THREADS" -b "0.0.0.0:$PROJECT_PORT" app:app \
        --pid "$PID_FILE" --daemon --access-logfile "$LOG_FILE" --error-logfile "$LOG_FILE"
    print_message "success" "项目已启动，日志文件: $LOG_FILE，监听端口: $PROJECT_PORT"
}

# 停止项目
stop_project() {
    print_message "info" "尝试停止项目..."
    
    if [ -f "$PID_FILE" ]; then
        print_message "info" "找到 PID 文件: $PID_FILE"
        PID=$(cat "$PID_FILE")
        
        if ps -p "$PID" > /dev/null; then
            print_message "success" "停止项目 (PID: $PID)..."
            sudo kill -9 "$PID" && rm -f "$PID_FILE"
            print_message "success" "项目已停止"
        else
            print_message "warning" "PID 文件存在，但进程已不存在，删除 PID 文件..."
            rm -f "$PID_FILE"
        fi
    else
        print_message "warning" "PID 文件不存在，尝试通过进程名停止 Gunicorn..."
        sudo pkill -f 'gunicorn.*app:app'

        PIDS=$(pgrep -f 'gunicorn.*app:app')
        if [ -z "$PIDS" ]; then
            print_message "success" "所有 Gunicorn 进程已停止"
        else
            print_message "error" "未能完全停止 Gunicorn 进程，仍有进程存在"
        fi
    fi
}

# 重启项目（后台运行）
restart_project() {
    stop_project
    start_project
}


run_data_cleanup() {
    print_message "success" "运行整理数据.py 脚本..."
    source "$VENV_DIR/bin/activate"
    python ./整理数据.py
    print_message "success" "整理数据完成"
}

run_import_user_data() {
    print_message "success" "运行 import_user_data.py 脚本..."
    source "$VENV_DIR/bin/activate"
    python ./import_user_data.py
    print_message "success" "用户数据导入完成"
}




# 卸载 Python 3.11
uninstall_python() {
    print_message "success" "卸载 Python 3.11..."

    stop_project  "success" "停止gunicorn所有进程"
    
    if command -v python3.11 &> /dev/null; then
        sudo rm -rf /usr/local/lib/python3.11
        sudo rm -rf /usr/local/bin/python3.11
        sudo rm -rf /usr/local/bin/pip3.11
        sudo rm -rf /usr/local/bin/venv
        print_message "success" "Python 3.11 卸载完成"
        
    else
        print_message "warning" "未找到 Python 3.11 安装"
    fi
}

# 卸载虚拟环境
uninstall_virtualenv() {
    print_message "success" "卸载虚拟环境..."
    if [ -d "$VENV_DIR" ]; then
        rm -rf "$VENV_DIR"
        print_message "success" "虚拟环境已卸载"
    fi
}


# 卸载 Redis
uninstall_redis() {
    print_message "success" "卸载 Redis..."
    echo "当前操作系统类型: $OS"
    case "$OS" in
        debian)
            print_message "info" "卸载 Redis 包..."
            sudo apt purge -y redis-server
            sudo apt autoremove -y
            sudo apt clean
            ;;

        centos)
            print_message "info" "卸载 Redis 包..."
            sudo yum remove -y redis
            sudo yum autoremove -y
            ;;

        darwin)
            print_message "info" "卸载 Redis 包..."
            brew uninstall redis
            ;;

        *)
            print_message "error" "不支持的操作系统: $OS"
            exit 1
            ;;
    esac

    # 清理 Redis 数据和配置文件
    print_message "info" "清理 Redis 数据和配置文件..."
    case "$OS" in
        debian | centos)
            sudo rm -rf /var/lib/redis
            sudo rm -rf /etc/redis
            ;;
        darwin)
            rm -rf /usr/local/var/db/redis
            rm -rf /usr/local/etc/redis.conf
            ;;
        *)
            print_message "error" "不支持的操作系统: $OS"
            exit 1
            ;;
    esac

    print_message "success" "Redis 卸载完成"
}



# 退出脚本
exit_script() {
    print_message "success" "退出脚本..."
    exit 0
}


# 检查Gunicorn是否正在运行
check_gunicorn_status() {
    if pgrep -f gunicorn &> /dev/null; then
        echo "${GREEN}Gunicorn:运行中${NC}"
    else
        echo "${RED}Gunicorn:已停止${NC}"
    fi
}

# 检查Redis是否正在运行
check_redis_status() {
    if systemctl is-active --quiet redis; then
        echo "${GREEN}Redis:运行中${NC}"
    else
        echo "${RED}Redis:已停止${NC}"
    fi
}

# 显示菜单并执行相应操作
show_menu() {
    clear
    echo -e "${CYAN}##################################################"
    echo -e "${CYAN}#           晴天书源项目脚本    by:大灰狼        #"
    echo -e "${CYAN}##################################################"
    echo -e "${BLUE}当前项目状态: $(check_redis_status) $(check_gunicorn_status)${NC}"
    echo -e "${BLUE}1) ${GREEN}安装项目"
    echo -e "${BLUE}2) ${GREEN}启动项目"
    echo -e "${BLUE}3) ${YELLOW}停止项目"
    echo -e "${BLUE}4) ${YELLOW}重启项目"
    echo -e "${BLUE}5) ${RED}卸载项目"
    echo -e "${BLUE}6) ${CYAN}整理数据"
    echo -e "${BLUE}7) ${CYAN}导入数据"
    echo -e "${BLUE}8) ${RED}退出脚本"
    echo -e "${CYAN}##################################################"
    read -p "请输入操作: " choice
    case "$choice" in
        1)
            detect_os
            install_python
            setup_virtualenv
            setup_redis
            start_project
            exit_script
            ;;
        2)
            start_project
            exit_script
            ;;
        3)
            stop_project
            exit_script
            ;;
        4)
            restart_project
            exit_script
            ;;
        5)
            detect_os
            uninstall_python
            uninstall_virtualenv
            uninstall_redis
            exit_script
            ;;
        6)
            run_data_cleanup
            exit_script
            ;;
        7)
            run_import_user_data
            exit_script
            ;;
        8)
            exit_script
            ;;
        *)
            print_message "error" "无效选项"
            exit_script
            ;;
    esac
}

# 调用菜单
show_menu
