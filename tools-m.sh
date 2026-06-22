#!/bin/bash
#=============================================================
# Linux 系统管理工具箱 — tools-m.sh
# 使用方法: source tools-m.sh 或直接执行 bash tools-m.sh
# 输入 "m" 即可调用（需先 source 或 alias）
#=============================================================

# ---- 颜色变量（由 load_theme 设置） ----
RED=''
GREEN=''
YELLOW=''
BLUE=''
CYAN=''
WHITE=''
PURPLE=''
NC='\033[0m'

# ---- 系统信息 ----
SCRIPT_VERSION="1.2.0"
OS_NAME=$(grep -oP '^NAME="?\K[^"]+' /etc/os-release 2>/dev/null || echo "Unknown")
OS_VERSION=$(grep -oP '^VERSION_ID="?\K[^"]+' /etc/os-release 2>/dev/null || echo "Unknown")
ARCH=$(uname -m)
CURRENT_USER=$(whoami)

# ---- 主题系统 ----
THEME_DIR="${HOME}/.config/tools-m"
THEME_FILE="${THEME_DIR}/theme.conf"
CURRENT_THEME="default"

load_theme() {
    local theme="default"
    if [[ -f "$THEME_FILE" ]]; then
        theme=$(cat "$THEME_FILE" 2>/dev/null)
    fi
    CURRENT_THEME="$theme"
    case "$theme" in
        sunset)
            # 🌅 落日暖阳 — 暖色调，橙/金/棕
            RED='\033[38;5;196m'
            GREEN='\033[38;5;142m'
            YELLOW='\033[38;5;214m'
            BLUE='\033[38;5;173m'
            CYAN='\033[38;5;180m'
            WHITE='\033[38;5;230m'
            PURPLE='\033[38;5;176m'
            BORDER='\033[38;5;208m'
            TITLE='\033[1;38;5;214m'
            NC='\033[0m'
            ;;
        neon)
            # 🌃 暗夜霓虹 — 暗底高对比，荧光绿/紫/蓝
            RED='\033[38;5;197m'
            GREEN='\033[38;5;83m'
            YELLOW='\033[38;5;227m'
            BLUE='\033[38;5;75m'
            CYAN='\033[38;5;51m'
            WHITE='\033[38;5;255m'
            PURPLE='\033[38;5;201m'
            BORDER='\033[1;38;5;99m'
            TITLE='\033[1;38;5;83m'
            NC='\033[0m'
            ;;
        *)
            # 🌊 海洋蓝（默认）— 清爽蓝色系
            RED='\033[0;31m'
            GREEN='\033[0;32m'
            YELLOW='\033[1;33m'
            BLUE='\033[0;34m'
            CYAN='\033[0;36m'
            WHITE='\033[1;37m'
            PURPLE='\033[0;35m'
            BORDER='\033[0;36m'
            TITLE='\033[1;37m'
            NC='\033[0m'
            ;;
    esac
}

apply_theme() {
    local theme="$1"
    mkdir -p "$THEME_DIR" 2>/dev/null
    echo "$theme" > "$THEME_FILE"
    load_theme
}

# 加载主题
load_theme

# ---- 辅助函数 ----
pause() {
    echo
    read -r -p "$(echo -e "${YELLOW}按回车键返回...${NC}")"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[错误] 此操作需要 root 权限，请使用 sudo 或切换 root 用户${NC}"
        return 1
    fi
    return 0
}

# 检查命令是否存在
check_cmd() {
    command -v "$1" &>/dev/null
}

# 安装系统包
install_pkg() {
    local pkg=$1
    if check_cmd apt-get; then
        apt-get install -y "$pkg" &>/dev/null
    elif check_cmd yum; then
        yum install -y "$pkg" &>/dev/null
    elif check_cmd dnf; then
        dnf install -y "$pkg" &>/dev/null
    elif check_cmd pacman; then
        pacman -S --noconfirm "$pkg" &>/dev/null
    elif check_cmd zypper; then
        zypper install -y "$pkg" &>/dev/null
    else
        return 1
    fi
}

# 确保必要工具
ensure_tool() {
    local tool=$1
    local pkg=${2:-$1}
    if ! check_cmd "$tool"; then
        echo -e "${YELLOW}正在安装 $pkg...${NC}"
        if install_pkg "$pkg"; then
            echo -e "${GREEN}$pkg 安装完成${NC}"
        else
            echo -e "${RED}无法自动安装 $pkg，请手动安装${NC}"
            return 1
        fi
    fi
    return 0
}

print_header() {
    clear
    echo -e "${BORDER}==============================================${NC}"
    echo -e "${TITLE}         Linux 系统管理工具箱 v${SCRIPT_VERSION}${NC}"
    echo -e "${BORDER}==============================================${NC}"
    echo -e "${GREEN}  系统:${NC} $OS_NAME $OS_VERSION"
    echo -e "${GREEN}  架构:${NC} $ARCH"
    echo -e "${GREEN}  用户:${NC} $CURRENT_USER"
    echo -e "${BORDER}==============================================${NC}"
    echo
}

# ============================================================
# 1. 系统管理
# ============================================================
system_management() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 系统管理 ━━━${NC}"
        echo
        echo -e "  ${GREEN}1.${NC}  系统信息"
        echo -e "  ${GREEN}2.${NC}  系统更新"
        echo -e "  ${GREEN}3.${NC}  系统清理"
        echo -e "  ${GREEN}4.${NC}  系统服务管理"
        echo -e "  ${GREEN}5.${NC}  系统用户管理"
        echo -e "  ${GREEN}6.${NC}  时区设置"
        echo -e "  ${GREEN}7.${NC}  修改主机名"
        echo -e "  ${GREEN}8.${NC}  SWAP 管理"
        echo -e "  ${GREEN}9.${NC}  系统防火墙管理"
        echo -e "  ${GREEN}10.${NC} SSH 安全配置"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回主菜单"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-10/b]:${NC} ")" choice

        case $choice in
            1) show_system_info ;;
            2) system_update ;;
            3) system_cleanup ;;
            4) service_management ;;
            5) user_management ;;
            6) timezone_setting ;;
            7) change_hostname ;;
            8) swap_management ;;
            9) firewall_management ;;
            10) ssh_security_config ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 1.1 系统信息
show_system_info() {
    print_header
    echo -e "${WHITE}━━━ 系统信息 ━━━${NC}\n"

    ensure_tool "lscpu" "util-linux"

    echo -e "${CYAN}▶ 系统基本信息${NC}"
    echo -e "  主机名:     $(hostname)"
    echo -e "  操作系统:   $OS_NAME $OS_VERSION"
    echo -e "  内核版本:   $(uname -r)"
    echo -e "  架构:       $ARCH"
    echo -e "  运行时间:   $(uptime -p 2>/dev/null || uptime)"
    echo -e "  当前用户:   $CURRENT_USER"
    echo

    echo -e "${CYAN}▶ CPU 信息${NC}"
    if check_cmd lscpu; then
        echo -e "  型号:       $(lscpu | grep 'Model name' | head -1 | awk -F': ' '{print $2}')"
        echo -e "  核心数:     $(nproc)"
        echo -e "  架构:       $(lscpu | grep 'Architecture' | awk -F': ' '{print $2}')"
    else
        echo -e "  核心数:     $(nproc)"
    fi
    echo

    echo -e "${CYAN}▶ 内存信息${NC}"
    if check_cmd free; then
        free -h | awk 'NR==1 || NR==2'
    fi
    echo

    echo -e "${CYAN}▶ 磁盘信息${NC}"
    if check_cmd df; then
        df -h --total | grep -v "tmpfs\|loop" | head -10
    fi
    echo

    echo -e "${CYAN}▶ 网络信息${NC}"
    ip addr show 2>/dev/null | grep -E 'inet ' | awk '{print "  " $NF ": " $2}' || \
    ifconfig 2>/dev/null | grep -E 'inet ' | awk '{print "  " $1 ": " $2}'
    echo -e "  公网 IP:   $(curl -s --max-time 3 ip.sb 2>/dev/null || echo '获取失败')"
    echo

    echo -e "${CYAN}▶ 负载信息${NC}"
    uptime
    echo

    pause
}

# 1.2 系统更新
system_update() {
    print_header
    echo -e "${WHITE}━━━ 系统更新 ━━━${NC}\n"

    if ! check_root; then
        pause
        return
    fi

    echo -e "${YELLOW}即将开始系统更新操作...${NC}"
    read -r -p "$(echo -e "${BLUE}确认更新？(y/n):${NC} ")" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}已取消${NC}"
        pause
        return
    fi

    if check_cmd apt-get; then
        echo -e "${GREEN}▶ 更新软件源...${NC}"
        apt-get update
        echo
        echo -e "${GREEN}▶ 升级软件包...${NC}"
        apt-get upgrade -y
        echo
        echo -e "${GREEN}▶ 升级发行版...${NC}"
        apt-get dist-upgrade -y
    elif check_cmd yum; then
        echo -e "${GREEN}▶ 更新软件包...${NC}"
        yum update -y
    elif check_cmd dnf; then
        echo -e "${GREEN}▶ 更新软件包...${NC}"
        dnf upgrade --refresh -y
    elif check_cmd pacman; then
        echo -e "${GREEN}▶ 更新软件包...${NC}"
        pacman -Syu --noconfirm
    else
        echo -e "${RED}不支持此系统的包管理器${NC}"
    fi

    echo -e "\n${GREEN}更新完成！${NC}"
    pause
}

# 1.3 系统清理
system_cleanup() {
    print_header
    echo -e "${WHITE}━━━ 系统清理 ━━━${NC}\n"

    if ! check_root; then
        pause
        return
    fi

    echo -e "${YELLOW}即将清理系统缓存、临时文件和无用包${NC}"
    read -r -p "$(echo -e "${BLUE}确认清理？(y/n):${NC} ")" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}已取消${NC}"
        pause
        return
    fi

    echo -e "${GREEN}▶ 清理 apt/yum 缓存...${NC}"
    if check_cmd apt-get; then
        apt-get autoremove -y
        apt-get autoclean -y
        apt-get clean -y
    elif check_cmd yum; then
        yum autoremove -y
        yum clean all
    elif check_cmd dnf; then
        dnf autoremove -y
        dnf clean all
    elif check_cmd pacman; then
        pacman -Sc --noconfirm
        paccache -r 2>/dev/null
    fi

    echo
    echo -e "${GREEN}▶ 清理临时文件...${NC}"
    rm -rf /tmp/* 2>/dev/null
    rm -rf /var/tmp/* 2>/dev/null
    echo -e "${GREEN}  /tmp 和 /var/tmp 已清理${NC}"

    echo
    echo -e "${GREEN}▶ 清理 journal 日志（保留最近 3 天）...${NC}"
    if check_cmd journalctl; then
        journalctl --vacuum-time=3d 2>/dev/null
    fi

    echo
    echo -e "${GREEN}▶ 清理已卸载的 snap 残留...${NC}"
    if check_cmd snap; then
        snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' | while read -r name rev; do
            snap remove "$name" --revision="$rev" 2>/dev/null
        done
        echo -e "${GREEN}  snap 残留已清理${NC}"
    fi

    echo -e "\n${GREEN}系统清理完成！${NC}"
    pause
}

# 1.4 系统服务管理
service_management() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 系统服务管理 ━━━${NC}\n"

        echo -e "${YELLOW}当前运行的服务（部分）:${NC}"
        if check_cmd systemctl; then
            systemctl list-units --type=service --state=running --no-legend 2>/dev/null | head -10 | awk '{printf "  %s [运行中]\n", $1}'
        fi
        echo

        echo -e "  ${GREEN}1.${NC}  查看所有服务"
        echo -e "  ${GREEN}2.${NC}  启动服务"
        echo -e "  ${GREEN}3.${NC}  停止服务"
        echo -e "  ${GREEN}4.${NC}  重启服务"
        echo -e "  ${GREEN}5.${NC}  查看服务状态"
        echo -e "  ${GREEN}6.${NC}  设置服务开机自启"
        echo -e "  ${GREEN}7.${NC}  取消服务开机自启"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-7/b]:${NC} ")" choice

        case $choice in
            1)
                echo -e "${CYAN}▶ 所有服务列表:${NC}"
                systemctl list-units --type=service --no-legend 2>/dev/null | awk '{printf "  %s [%s]\n", $1, $3}'
                pause
                ;;
            2|3|4|5|6|7)
                local action_name
                local action_cmd
                case $choice in
                    2) action_name="启动"; action_cmd="start" ;;
                    3) action_name="停止"; action_cmd="stop" ;;
                    4) action_name="重启"; action_cmd="restart" ;;
                    5) action_name="查看状态"; action_cmd="status" ;;
                    6) action_name="设置开机自启"; action_cmd="enable" ;;
                    7) action_name="取消开机自启"; action_cmd="disable" ;;
                esac
                read -r -p "$(echo -e "${BLUE}请输入服务名称:${NC} ")" svc
                if [[ -n "$svc" ]]; then
                    if check_root; then
                        if [[ "$action_cmd" == "status" ]]; then
                            systemctl status "$svc" 2>/dev/null || echo -e "${RED}服务 $svc 不存在${NC}"
                        else
                            systemctl "$action_cmd" "$svc" 2>/dev/null && \
                                echo -e "${GREEN}服务 $svc 已${action_name}${NC}" || \
                                echo -e "${RED}操作失败，请检查服务名称和权限${NC}"
                        fi
                    fi
                fi
                pause
                ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 1.5 系统用户管理
user_management() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 系统用户管理 ━━━${NC}\n"

        echo -e "${CYAN}▶ 当前系统用户:${NC}"
        awk -F: 'BEGIN{OFS="  "} $3>=1000 && $3<65534 {print "  " $1, "(UID:" $3 ")"}' /etc/passwd | head -10
        echo

        echo -e "  ${GREEN}1.${NC}  创建新用户"
        echo -e "  ${GREEN}2.${NC}  删除用户"
        echo -e "  ${GREEN}3.${NC}  修改密码"
        echo -e "  ${GREEN}4.${NC}  添加用户到 sudo 组"
        echo -e "  ${GREEN}5.${NC}  查看用户详细信息"
        echo -e "  ${GREEN}6.${NC}  列出所有用户"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-6/b]:${NC} ")" choice

        case $choice in
            1)
                if check_root; then
                    read -r -p "$(echo -e "${BLUE}输入新用户名:${NC} ")" newuser
                    if [[ -n "$newuser" ]]; then
                        useradd -m -s /bin/bash "$newuser" 2>/dev/null && \
                            echo -e "${GREEN}用户 $newuser 已创建${NC}" || \
                            echo -e "${RED}创建失败（用户可能已存在）${NC}"
                        passwd "$newuser"
                    fi
                fi
                pause
                ;;
            2)
                if check_root; then
                    read -r -p "$(echo -e "${BLUE}输入要删除的用户名:${NC} ")" deluser
                    if [[ -n "$deluser" ]]; then
                        read -r -p "$(echo -e "${RED}同时删除家目录？(y/n):${NC} ")" delhome
                        if [[ "$delhome" =~ ^[Yy]$ ]]; then
                            userdel -r "$deluser" 2>/dev/null
                        else
                            userdel "$deluser" 2>/dev/null
                        fi
                        echo -e "${GREEN}用户 $deluser 已删除${NC}"
                    fi
                fi
                pause
                ;;
            3)
                if check_root; then
                    read -r -p "$(echo -e "${BLUE}输入用户名:${NC} ")" chuser
                    if [[ -n "$chuser" ]]; then
                        passwd "$chuser"
                    fi
                fi
                pause
                ;;
            4)
                if check_root; then
                    read -r -p "$(echo -e "${BLUE}输入用户名:${NC} ")" sudouser
                    if [[ -n "$sudouser" ]]; then
                        usermod -aG sudo "$sudouser" 2>/dev/null
                        usermod -aG wheel "$sudouser" 2>/dev/null
                        echo -e "${GREEN}用户 $sudouser 已添加到 sudo 组${NC}"
                    fi
                fi
                pause
                ;;
            5)
                read -r -p "$(echo -e "${BLUE}输入用户名:${NC} ")" infouser
                if [[ -n "$infouser" ]]; then
                    echo -e "${CYAN}▶ 用户信息:${NC}"
                    id "$infouser" 2>/dev/null || echo -e "${RED}用户不存在${NC}"
                    echo -n "  sudo权限: "
                    groups "$infouser" 2>/dev/null | grep -qE '\bsudo\b|\bwheel\b' && \
                        echo -e "${GREEN}是${NC}" || echo -e "${YELLOW}否${NC}"
                    chage -l "$infouser" 2>/dev/null | head -5
                fi
                pause
                ;;
            6)
                echo -e "${CYAN}▶ 所有系统用户:${NC}"
                awk -F: 'BEGIN{OFS="  "} {print "  " $1, "(UID:" $3 ")", $7}' /etc/passwd
                pause
                ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 1.6 时区设置
timezone_setting() {
    print_header
    echo -e "${WHITE}━━━ 时区设置 ━━━${NC}\n"

    echo -e "${CYAN}▶ 当前时区:${NC} $(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null || date +%Z)"
    echo -e "${CYAN}▶ 当前时间:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo

    echo -e "  ${GREEN}1.${NC}  设置为 Asia/Shanghai（北京时间）"
    echo -e "  ${GREEN}2.${NC}  设置为 Asia/Hong_Kong（香港时间）"
    echo -e "  ${GREEN}3.${NC}  设置为 Asia/Tokyo（东京时间）"
    echo -e "  ${GREEN}4.${NC}  设置为 America/New_York（美东时间）"
    echo -e "  ${GREEN}5.${NC}  设置为 UTC"
    echo -e "  ${GREEN}6.${NC}  手动输入时区"
    echo -e "  ${GREEN}7.${NC}  同步 NTP 时间"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-7/b]:${NC} ")" choice

    if [[ "$choice" =~ ^[1-7]$ ]] && ! check_root; then
        pause
        return
    fi

    local tz=""
    case $choice in
        1) tz="Asia/Shanghai" ;;
        2) tz="Asia/Hong_Kong" ;;
        3) tz="Asia/Tokyo" ;;
        4) tz="America/New_York" ;;
        5) tz="UTC" ;;
        6)
            read -r -p "$(echo -e "${BLUE}输入时区（如 Europe/London）:${NC} ")" tz
            ;;
        7)
            echo -e "${GREEN}▶ 同步 NTP 时间...${NC}"
            if check_cmd timedatectl; then
                timedatectl set-ntp true 2>/dev/null && \
                    echo -e "${GREEN}NTP 同步已启用${NC}" || \
                    echo -e "${RED}NTP 同步启用失败${NC}"
            elif check_cmd ntpdate; then
                ntpdate -u pool.ntp.org && echo -e "${GREEN}时间已同步${NC}"
            else
                echo -e "${YELLOW}安装 ntpdate...${NC}"
                install_pkg "ntpdate" && ntpdate -u pool.ntp.org
            fi
            pause
            return
            ;;
        b|B) return ;;
        *) echo -e "${RED}无效选项${NC}"; pause; return ;;
    esac

    if [[ -n "$tz" ]]; then
        if timedatectl set-timezone "$tz" 2>/dev/null; then
            echo -e "${GREEN}时区已设置为 $tz${NC}"
            echo -e "${GREEN}当前时间: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
        else
            ln -sf "/usr/share/zoneinfo/$tz" /etc/localtime 2>/dev/null && \
                echo -e "${GREEN}时区已设置为 $tz${NC}" || \
                echo -e "${RED}时区设置失败${NC}"
        fi
    fi
    pause
}

# 1.7 修改主机名
change_hostname() {
    print_header
    echo -e "${WHITE}━━━ 修改主机名 ━━━${NC}\n"

    echo -e "${CYAN}▶ 当前主机名:${NC} $(hostname)"
    echo

    if ! check_root; then
        pause
        return
    fi

    read -r -p "$(echo -e "${BLUE}输入新主机名:${NC} ")" newname
    if [[ -n "$newname" ]]; then
        hostnamectl set-hostname "$newname" 2>/dev/null
        echo "$newname" > /etc/hostname 2>/dev/null
        # 更新 hosts
        sed -i "s/127.0.1.1.*/127.0.1.1  $newname/" /etc/hosts 2>/dev/null
        echo -e "${GREEN}主机名已修改为: $newname${NC}"
        echo -e "${YELLOW}建议重新登录或重启以完全生效${NC}"
    fi
    pause
}

# 1.8 SWAP 管理
swap_management() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ SWAP 管理 ━━━${NC}\n"

        echo -e "${CYAN}▶ 当前 SWAP 状态:${NC}"
        swapon --show 2>/dev/null || echo "  无活跃 SWAP"
        if check_cmd free; then
            free -h | grep -i swap
        fi
        echo

        echo -e "  ${GREEN}1.${NC}  查看 SWAP 使用详情"
        echo -e "  ${GREEN}2.${NC}  创建 SWAP 文件 (1GB)"
        echo -e "  ${GREEN}3.${NC}  创建 SWAP 文件 (2GB)"
        echo -e "  ${GREEN}4.${NC}  创建 SWAP 文件 (自定义大小)"
        echo -e "  ${GREEN}5.${NC}  删除所有 SWAP"
        echo -e "  ${GREEN}6.${NC}  SWAP 参数调优"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-6/b]:${NC} ")" choice

        case $choice in
            1)
                swapon --show 2>/dev/null
                echo
                cat /proc/swaps 2>/dev/null
                echo
                echo -e "swappiness = $(cat /proc/sys/vm/swappiness 2>/dev/null)"
                pause
                ;;
            2|3|4)
                if ! check_root; then pause; break; fi
                local size
                case $choice in
                    2) size=1G ;;
                    3) size=2G ;;
                    4)
                        read -r -p "$(echo -e "${BLUE}输入 SWAP 大小（如 4G, 512M）:${NC} ")" size
                        ;;
                esac
                if [[ -n "$size" ]]; then
                    # 关闭已有 swap
                    swapoff -a 2>/dev/null
                    dd if=/dev/zero of=/swapfile bs=1M count=${size%[GgMm]} 2>/dev/null
                    # 处理单位
                    if [[ "$size" =~ [Gg] ]]; then
                        dd if=/dev/zero of=/swapfile bs=1M count=$(( ${size%[Gg]} * 1024 )) status=progress 2>/dev/null
                    else
                        local num=${size%[Mm]}
                        dd if=/dev/zero of=/swapfile bs=1M count=$num status=progress 2>/dev/null
                    fi
                    chmod 600 /swapfile
                    mkswap /swapfile 2>/dev/null
                    swapon /swapfile 2>/dev/null
                    # 写入 fstab
                    grep -q "/swapfile" /etc/fstab 2>/dev/null || \
                        echo "/swapfile none swap sw 0 0" >> /etc/fstab
                    echo -e "${GREEN}SWAP 文件已创建（${size}）${NC}"
                fi
                pause
                ;;
            5)
                if check_root; then
                    swapoff -a 2>/dev/null
                    rm -f /swapfile 2>/dev/null
                    sed -i '/\/swapfile/d' /etc/fstab 2>/dev/null
                    echo -e "${GREEN}所有 SWAP 已删除${NC}"
                fi
                pause
                ;;
            6)
                if check_root; then
                    echo -e "${YELLOW}当前 swappiness: $(cat /proc/sys/vm/swappiness)${NC}"
                    echo -e "  推荐值: 10（桌面），60（默认），100（激进）"
                    read -r -p "$(echo -e "${BLUE}输入新 swappiness 值 [0-100]:${NC} ")" swp
                    if [[ "$swp" =~ ^[0-9]+$ ]] && ((swp >= 0 && swp <= 100)); then
                        sysctl vm.swappiness="$swp" 2>/dev/null
                        echo "vm.swappiness=$swp" > /etc/sysctl.d/99-swap.conf 2>/dev/null
                        echo -e "${GREEN}swappiness 已设置为 $swp${NC}"
                    fi
                fi
                pause
                ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 1.9 系统防火墙管理
firewall_management() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 系统防火墙管理 ━━━${NC}\n"

        local fw=""
        if check_cmd ufw; then
            fw="ufw"
        elif check_cmd firewall-cmd; then
            fw="firewalld"
        elif check_cmd iptables; then
            fw="iptables"
        fi

        echo -e "${CYAN}▶ 当前防火墙:${NC} $([ -n "$fw" ] && echo "$fw" || echo "未检测到已安装的防火墙")"
        if [[ "$fw" == "ufw" ]]; then
            echo -e "${CYAN}▶ 状态:${NC} $(ufw status 2>/dev/null | head -1)"
        elif [[ "$fw" == "firewalld" ]]; then
            echo -e "${CYAN}▶ 默认区域:${NC} $(firewall-cmd --get-default-zone 2>/dev/null)"
        fi
        echo

        echo -e "  ${GREEN}1.${NC}  安装/启用防火墙"
        echo -e "  ${GREEN}2.${NC}  查看规则"
        echo -e "  ${GREEN}3.${NC}  开放端口"
        echo -e "  ${GREEN}4.${NC}  关闭端口"
        echo -e "  ${GREEN}5.${NC}  允许 IP"
        echo -e "  ${GREEN}6.${NC}  拒绝 IP"
        echo -e "  ${GREEN}7.${NC}  关闭防火墙"
        echo -e "  ${GREEN}8.${NC}  重置防火墙"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-8/b]:${NC} ")" choice

        case $choice in
            1)
                if check_root; then
                    if ! check_cmd ufw; then
                        echo -e "${YELLOW}安装 UFW...${NC}"
                        install_pkg "ufw"
                    fi
                    if check_cmd ufw; then
                        echo "y" | ufw enable 2>/dev/null
                        echo -e "${GREEN}UFW 已启用${NC}"
                        ufw default deny incoming
                        ufw default allow outgoing
                        ufw allow 22/tcp
                        echo -e "${YELLOW}SSH(22)端口已放行${NC}"
                    fi
                fi
                pause
                ;;
            2)
                if [[ "$fw" == "ufw" ]]; then
                    ufw status numbered 2>/dev/null || echo -e "${RED}UFW 未安装${NC}"
                elif [[ "$fw" == "firewalld" ]]; then
                    firewall-cmd --list-all 2>/dev/null || echo -e "${RED}firewalld 未运行${NC}"
                else
                    iptables -L -n --line-numbers 2>/dev/null || echo -e "${RED}iptables 不可用${NC}"
                fi
                pause
                ;;
            3)
                if check_root; then
                    read -r -p "$(echo -e "${BLUE}输入端口号及协议（如 80/tcp 或 53/udp）:${NC} ")" port
                    if [[ -n "$port" ]]; then
                        if [[ "$fw" == "ufw" ]]; then
                            ufw allow "$port" && echo -e "${GREEN}端口 $port 已放行${NC}"
                        elif [[ "$fw" == "firewalld" ]]; then
                            local p="${port%%/*}"
                            local proto="${port##*/}"
                            [[ "$proto" == "$port" ]] && proto="tcp"
                            firewall-cmd --permanent --add-port="$p/$proto" && firewall-cmd --reload
                            echo -e "${GREEN}端口 $port 已放行${NC}"
                        else
                            local p="${port%%/*}"
                            local proto="${port##*/}"
                            [[ "$proto" == "$port" ]] && proto="tcp"
                            iptables -A INPUT -p "$proto" --dport "$p" -j ACCEPT
                            echo -e "${GREEN}规则已添加${NC}"
                        fi
                    fi
                fi
                pause
                ;;
            4)
                if check_root; then
                    read -r -p "$(echo -e "${BLUE}输入端口号及协议（如 80/tcp）:${NC} ")" port
                    if [[ -n "$port" ]]; then
                        if [[ "$fw" == "ufw" ]]; then
                            ufw deny "$port" && echo -e "${GREEN}端口 $port 已禁止${NC}"
                        elif [[ "$fw" == "firewalld" ]]; then
                            local p="${port%%/*}"
                            local proto="${port##*/}"
                            [[ "$proto" == "$port" ]] && proto="tcp"
                            firewall-cmd --permanent --remove-port="$p/$proto" && firewall-cmd --reload
                        else
                            local p="${port%%/*}"
                            local proto="${port##*/}"
                            [[ "$proto" == "$port" ]] && proto="tcp"
                            iptables -A INPUT -p "$proto" --dport "$p" -j DROP
                        fi
                        echo -e "${GREEN}端口 $port 已禁止${NC}"
                    fi
                fi
                pause
                ;;
            5)
                if check_root; then
                    read -r -p "$(echo -e "${BLUE}输入 IP 地址:${NC} ")" ip
                    if [[ -n "$ip" ]]; then
                        if [[ "$fw" == "ufw" ]]; then
                            ufw allow from "$ip" && echo -e "${GREEN}已允许 $ip${NC}"
                        else
                            iptables -A INPUT -s "$ip" -j ACCEPT 2>/dev/null
                            echo -e "${GREEN}已允许 $ip${NC}"
                        fi
                    fi
                fi
                pause
                ;;
            6)
                if check_root; then
                    read -r -p "$(echo -e "${BLUE}输入 IP 地址:${NC} ")" ip
                    if [[ -n "$ip" ]]; then
                        if [[ "$fw" == "ufw" ]]; then
                            ufw deny from "$ip" && echo -e "${GREEN}已拒绝 $ip${NC}"
                        else
                            iptables -A INPUT -s "$ip" -j DROP 2>/dev/null
                            echo -e "${GREEN}已拒绝 $ip${NC}"
                        fi
                    fi
                fi
                pause
                ;;
            7)
                if check_root; then
                    if [[ "$fw" == "ufw" ]]; then
                        ufw disable && echo -e "${YELLOW}UFW 已关闭${NC}"
                    else
                        systemctl stop firewalld 2>/dev/null && echo -e "${YELLOW}firewalld 已关闭${NC}"
                    fi
                fi
                pause
                ;;
            8)
                if check_root; then
                    read -r -p "$(echo -e "${RED}确认重置防火墙？(y/n):${NC} ")" confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        if [[ "$fw" == "ufw" ]]; then
                            ufw reset && echo -e "${GREEN}UFW 已重置${NC}"
                        else
                            iptables -F && iptables -X && echo -e "${GREEN}iptables 规则已清空${NC}"
                        fi
                    fi
                fi
                pause
                ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 1.10 SSH 安全配置
ssh_security_config() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ SSH 安全配置 ━━━${NC}\n"

        local sshd_config="/etc/ssh/sshd_config"
        local port=$(grep -oP '^Port\s+\K\d+' "$sshd_config" 2>/dev/null || echo "22")
        local permit_root=$(grep -oP '^PermitRootLogin\s+\K\w+' "$sshd_config" 2>/dev/null || echo "prohibit-password")
        local pass_auth=$(grep -oP '^PasswordAuthentication\s+\K\w+' "$sshd_config" 2>/dev/null || echo "yes")

        echo -e "${CYAN}▶ 当前 SSH 配置概览:${NC}"
        echo -e "  端口:              $port"
        echo -e "  Root 登录:         $permit_root"
        echo -e "  密码认证:          $pass_auth"
        echo -e "  SSH 服务状态:      $(systemctl is-active sshd 2>/dev/null || systemctl is-active ssh 2>/dev/null || echo '未知')"
        echo

        echo -e "  ${GREEN}1.${NC}  修改 SSH 端口"
        echo -e "  ${GREEN}2.${NC}  禁用 Root 登录"
        echo -e "  ${GREEN}3.${NC}  禁用密码认证（仅密钥登录）"
        echo -e "  ${GREEN}4.${NC}  查看 SSH 登录日志"
        echo -e "  ${GREEN}5.${NC}  重启 SSH 服务"
        echo -e "  ${GREEN}6.${NC}  生成 SSH 密钥对"
        echo -e "  ${GREEN}7.${NC}  查看当前配置"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-7/b]:${NC} ")" choice

        case $choice in
            1)
                if check_root; then
                    read -r -p "$(echo -e "${BLUE}输入新 SSH 端口 (1024-65535):${NC} ")" newport
                    if [[ "$newport" =~ ^[0-9]+$ ]] && ((newport >= 1024 && newport <= 65535)); then
                        sed -i "s/^#*Port.*/Port $newport/" "$sshd_config"
                        echo -e "${GREEN}SSH 端口已修改为 $newport${NC}"
                        echo -e "${YELLOW}请确保防火墙已放行新端口，并保留当前连接以免被锁${NC}"
                        read -r -p "$(echo -e "${BLUE}立即重启 SSH？(y/n):${NC} ")" rst
                        [[ "$rst" =~ ^[Yy]$ ]] && systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
                    fi
                fi
                pause
                ;;
            2)
                if check_root; then
                    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$sshd_config"
                    echo -e "${GREEN}Root 登录已禁用${NC}"
                    read -r -p "$(echo -e "${BLUE}立即重启 SSH？(y/n):${NC} ")" rst
                    [[ "$rst" =~ ^[Yy]$ ]] && systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
                fi
                pause
                ;;
            3)
                if check_root; then
                    echo -e "${RED}警告: 请确保已添加 SSH 密钥再禁用密码！${NC}"
                    read -r -p "$(echo -e "${BLUE}确认禁用密码认证？(y/n):${NC} ")" confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config"
                        echo -e "${GREEN}密码认证已禁用${NC}"
                        systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
                    fi
                fi
                pause
                ;;
            4)
                echo -e "${CYAN}▶ SSH 登录日志（最近 20 条）:${NC}"
                if [[ -f /var/log/auth.log ]]; then
                    grep -i "sshd\|ssh" /var/log/auth.log | tail -20
                elif [[ -f /var/log/secure ]]; then
                    grep -i "sshd\|ssh" /var/log/secure | tail -20
                elif check_cmd journalctl; then
                    journalctl -u sshd -u ssh --no-pager -n 20 2>/dev/null
                else
                    echo -e "${YELLOW}无法读取 SSH 日志${NC}"
                fi
                pause
                ;;
            5)
                if check_root; then
                    systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
                    echo -e "${GREEN}SSH 服务已重启${NC}"
                fi
                pause
                ;;
            6)
                echo -e "${YELLOW}正在生成 ED25519 密钥对...${NC}"
                ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q
                echo -e "${GREEN}密钥已生成:${NC}"
                echo -e "  私钥: ~/.ssh/id_ed25519"
                echo -e "  公钥: ~/.ssh/id_ed25519.pub"
                echo
                echo -e "${CYAN}▶ 公钥内容（可复制到服务器）:${NC}"
                cat ~/.ssh/id_ed25519.pub
                pause
                ;;
            7)
                echo -e "${CYAN}▶ 完整 SSH 配置:${NC}"
                grep -v '^#\|^$' "$sshd_config" 2>/dev/null
                pause
                ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# ============================================================
# 2. 常用工具安装
# ============================================================
common_tools() {
    print_header
    echo -e "${WHITE}━━━ 常用工具安装 ━━━${NC}\n"
    echo -e "${YELLOW}输入编号多选安装（如：1 3 5 或 1-5），按回车确认${NC}\n"

    local tools=(
        "curl       网络请求工具"
        "wget       文件下载工具"
        "git        版本控制工具"
        "vim        文本编辑器"
        "htop       进程监控工具"
        "iotop      I/O 监控工具"
        "iftop      网络流量监控"
        "tmux       终端复用器"
        "tree       目录树查看"
        "unzip      解压 ZIP 文件"
        "zip        压缩工具"
        "rsync      文件同步工具"
        "screen     终端会话管理"
        "lsof       文件/端口查看"
        "tcpdump    网络抓包工具"
    )

    local i=1
    for tool in "${tools[@]}"; do
        local name=${tool%% *}
        local desc=${tool#* }
        local installed=""
        check_cmd "$name" && installed="${GREEN}[已安装]${NC}" || installed="${RED}[未安装]${NC}"
        echo -e "  ${GREEN}$(printf "%2d" $i).${NC} $installed ${WHITE}$name${NC} $desc"
        ((i++))
    done

    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo

    read -r -p "$(echo -e "${BLUE}请输入编号（多选用空格分隔，如 1 3 5）:${NC} ")" selections

    if [[ "$selections" =~ ^[bB]$ ]]; then return; fi
    if [[ "$selections" =~ ^[qQ]$ ]]; then return; fi

    if ! check_root; then
        pause
        return
    fi

    local choices=()
    # 解析范围 1-5 和单独数字
    for sel in $selections; do
        if [[ "$sel" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            for ((n = ${BASH_REMATCH[1]}; n <= ${BASH_REMATCH[2]}; n++)); do
                choices+=("$n")
            done
        elif [[ "$sel" =~ ^[0-9]+$ ]]; then
            choices+=("$sel")
        fi
    done

    for idx in "${choices[@]}"; do
        if ((idx >= 1 && idx <= ${#tools[@]})); then
            local name=$(echo "${tools[$((idx-1))]}" | awk '{print $1}')
            if ! check_cmd "$name"; then
                echo -e "${YELLOW}▶ 安装 $name...${NC}"
                if install_pkg "$name"; then
                    echo -e "${GREEN}  $name 安装成功${NC}"
                else
                    echo -e "${RED}  $name 安装失败${NC}"
                fi
            else
                echo -e "${GREEN}  $name 已安装，跳过${NC}"
            fi
        fi
    done

    echo
    echo -e "${GREEN}安装完成！${NC}"
    pause
}

# ============================================================
# 3. 网络工具
# ============================================================
network_tools() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 网络工具 ━━━${NC}\n"

        echo -e "  ${GREEN}1.${NC}  网络测速"
        echo -e "  ${GREEN}2.${NC}  端口检测"
        echo -e "  ${GREEN}3.${NC}  DNS 配置"
        echo -e "  ${GREEN}4.${NC}  路由追踪"
        echo -e "  ${GREEN}5.${NC}  IP 检测"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-5/b]:${NC} ")" choice

        case $choice in
            1) network_speedtest ;;
            2) port_check ;;
            3) dns_config ;;
            4) traceroute_tool ;;
            5) ip_detect ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 3.1 网络测速
network_speedtest() {
    print_header
    echo -e "${WHITE}━━━ 网络测速 ━━━${NC}\n"

    # 检测 speedtest-cli
    if ! check_cmd speedtest-cli && ! check_cmd speedtest; then
        echo -e "${YELLOW}正在安装 speedtest-cli...${NC}"
        if check_cmd pip3; then
            pip3 install speedtest-cli --quiet --break-system-packages 2>/dev/null || \
            pip3 install speedtest-cli --quiet 2>/dev/null
        elif check_cmd pip; then
            pip install speedtest-cli --quiet --break-system-packages 2>/dev/null || \
            pip install speedtest-cli --quiet 2>/dev/null
        fi
        # 尝试 apt
        if ! check_cmd speedtest-cli; then
            install_pkg "speedtest-cli" 2>/dev/null
        fi
    fi

    if check_cmd speedtest-cli; then
        echo -e "${YELLOW}开始测速，请稍候...${NC}"
        speedtest-cli --secure 2>/dev/null || speedtest-cli 2>/dev/null
    elif check_cmd speedtest; then
        echo -e "${YELLOW}开始测速，请稍候...${NC}"
        speedtest
    else
        echo -e "${YELLOW}使用 curl 简易测速（下载测试）...${NC}"
        echo -e "  测试节点: speedtest.net"
        for url in "https://speedtest.net" "https://cachefly.cachefly.net/100mb.test"; do
            local start=$(date +%s%N)
            local size=$(curl -s -o /dev/null --max-time 10 -w "%{size_download}" "$url" 2>/dev/null)
            local end=$(date +%s%N)
            if [[ -n "$size" ]] && ((size > 0)); then
                local speed=$(( size * 8 / ((end - start) / 1000000) / 1000 ))
                echo -e "  下载速度: ${GREEN}${speed} Mbps${NC}"
            fi
        done
    fi
    pause
}

# 3.2 端口检测
port_check() {
    print_header
    echo -e "${WHITE}━━━ 端口检测 ━━━${NC}\n"

    echo -e "  ${GREEN}1.${NC}  检测本机端口开放情况"
    echo -e "  ${GREEN}2.${NC}  检测远程主机端口"
    echo -e "  ${GREEN}3.${NC}  查看本机监听端口"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-3]:${NC} ")" sub

    case $sub in
        1)
            echo -e "${CYAN}▶ 本机开放端口:${NC}"
            if check_cmd ss; then
                ss -tlnp 2>/dev/null | awk 'NR>1 {print "  " $4}' | sort -u
            elif check_cmd netstat; then
                netstat -tlnp 2>/dev/null | awk 'NR>2 {print "  " $4}' | sort -u
            else
                echo -e "${YELLOW}安装 netstat...${NC}"
                install_pkg "net-tools"
                netstat -tlnp 2>/dev/null | awk 'NR>2 {print "  " $4}' | sort -u
            fi
            ;;
        2)
            read -r -p "$(echo -e "${BLUE}输入目标 IP/域名:${NC} ")" host
            read -r -p "$(echo -e "${BLUE}输入端口（如 80 或 22,80,443）:${NC} ")" ports
            if [[ -n "$host" && -n "$ports" ]]; then
                ensure_tool "nc" "netcat-openbsd"
                IFS=',' read -ra port_list <<< "$ports"
                for p in "${port_list[@]}"; do
                    p=$(echo "$p" | xargs)
                    if nc -zv -w3 "$host" "$p" 2>&1 | grep -q "succeeded\|open"; then
                        echo -e "  ${GREEN}端口 $p: 开放${NC}"
                    else
                        echo -e "  ${RED}端口 $p: 关闭${NC}"
                    fi
                done
            fi
            ;;
        3)
            echo -e "${CYAN}▶ 本机监听端口（含进程）:${NC}"
            if check_cmd ss; then
                ss -tlnp 2>/dev/null
            elif check_cmd netstat; then
                netstat -tlnp 2>/dev/null
            else
                echo -e "${YELLOW}安装 net-tools...${NC}"
                install_pkg "net-tools"
                netstat -tlnp 2>/dev/null
            fi
            ;;
    esac
    pause
}

# 3.3 DNS 配置
dns_config() {
    print_header
    echo -e "${WHITE}━━━ DNS 配置 ━━━${NC}\n"

    echo -e "${CYAN}▶ 当前 DNS:${NC}"
    if check_cmd resolvectl; then
        resolvectl status 2>/dev/null | grep -E 'DNS Servers|Current DNS' | head -5
    elif [[ -f /etc/resolv.conf ]]; then
        grep 'nameserver' /etc/resolv.conf | head -5
    fi
    echo

    echo -e "  ${GREEN}1.${NC}  设置为阿里 DNS (223.5.5.5 / 223.6.6.6)"
    echo -e "  ${GREEN}2.${NC}  设置为腾讯 DNS (119.29.29.29)"
    echo -e "  ${GREEN}3.${NC}  设置为 Google DNS (8.8.8.8 / 8.8.4.4)"
    echo -e "  ${GREEN}4.${NC}  设置为 Cloudflare DNS (1.1.1.1 / 1.0.0.1)"
    echo -e "  ${GREEN}5.${NC}  手动设置 DNS"
    echo -e "  ${GREEN}6.${NC}  DNS 解析测试"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-6/b]:${NC} ")" choice

    local dns1="" dns2=""
    case $choice in
        1) dns1="223.5.5.5"; dns2="223.6.6.6" ;;
        2) dns1="119.29.29.29" ;;
        3) dns1="8.8.8.8"; dns2="8.8.4.4" ;;
        4) dns1="1.1.1.1"; dns2="1.0.0.1" ;;
        5)
            read -r -p "$(echo -e "${BLUE}输入主 DNS:${NC} ")" dns1
            read -r -p "$(echo -e "${BLUE}输入备 DNS（可选）:${NC} ")" dns2
            ;;
        6)
            read -r -p "$(echo -e "${BLUE}输入要解析的域名:${NC} ")" domain
            if [[ -n "$domain" ]]; then
                if check_cmd dig; then
                    dig "$domain" +short
                elif check_cmd nslookup; then
                    nslookup "$domain"
                else
                    install_pkg "dnsutils" 2>/dev/null
                    dig "$domain" +short 2>/dev/null
                fi
            fi
            pause
            return
            ;;
        b|B) return ;;
        *) echo -e "${RED}无效选项${NC}"; pause; return ;;
    esac

    if check_root && [[ -n "$dns1" ]]; then
        if check_cmd resolvectl; then
            local iface=$(ip route | grep default | awk '{print $5}' | head -1)
            resolvectl dns "$iface" "$dns1" ${dns2:+"$dns2"} 2>/dev/null
            echo -e "${GREEN}DNS 已通过 systemd-resolved 设置${NC}"
        elif [[ -f /etc/resolv.conf ]]; then
            chattr -i /etc/resolv.conf 2>/dev/null
            echo -e "# Generated by tools-m.sh\nnameserver $dns1" > /etc/resolv.conf
            [[ -n "$dns2" ]] && echo "nameserver $dns2" >> /etc/resolv.conf
            chattr +i /etc/resolv.conf 2>/dev/null
            echo -e "${GREEN}DNS 已设置${NC}"
        fi
    else
        [[ -z "$dns1" ]] && echo -e "${RED}DNS 不能为空${NC}"
    fi
    pause
}

# 3.4 路由追踪
traceroute_tool() {
    print_header
    echo -e "${WHITE}━━━ 路由追踪 ━━━${NC}\n"

    ensure_tool "traceroute"

    read -r -p "$(echo -e "${BLUE}输入目标 IP/域名:${NC} ")" target
    if [[ -n "$target" ]]; then
        echo -e "${YELLOW}正在路由追踪，请稍候...${NC}"
        traceroute -n "$target" 2>/dev/null || traceroute "$target" 2>/dev/null
    fi
    pause
}

# 3.5 IP 检测
ip_detect() {
    print_header
    echo -e "${WHITE}━━━ IP 检测 ━━━${NC}\n"

    echo -e "${CYAN}▶ 本机 IP 地址:${NC}"
    ip -4 addr show 2>/dev/null | grep -oP 'inet \K[\d.]+' | while read -r ip; do
        local iface=$(ip -4 addr show 2>/dev/null | grep -B2 "$ip" | head -1 | awk '{print $2}' | tr -d ':')
        echo -e "  $iface: $ip"
    done

    echo
    echo -e "${CYAN}▶ 公网 IPv4:${NC}"
    local pub_ip=$(curl -s --max-time 5 ip.sb 2>/dev/null || curl -s --max-time 5 ifconfig.me 2>/dev/null || curl -s --max-time 5 icanhazip.com 2>/dev/null)
    echo -e "  ${GREEN}${pub_ip:-获取失败}${NC}"

    echo
    echo -e "${CYAN}▶ 公网 IPv6:${NC}"
    local pub_ip6=$(curl -s --max-time 5 ip.sb -6 2>/dev/null || curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "无 IPv6")
    echo -e "  ${pub_ip6}"

    echo
    echo -e "${CYAN}▶ IP 归属地:${NC}"
    curl -s --max-time 5 "https://ipapi.co/json/" 2>/dev/null | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    print(f'  {d.get(\"city\",\"?\")}, {d.get(\"region\",\"?\")}, {d.get(\"country_name\",\"?\")}')
    print(f'  运营商: {d.get(\"org\",\"?\")}')
except: pass
" 2>/dev/null || echo -e "  ${YELLOW}获取失败${NC}"

    pause
}

# ============================================================
# 4. 安全优化
# ============================================================
security_optimization() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 安全优化 ━━━${NC}\n"

        echo -e "  ${GREEN}1.${NC}  BBR 加速（启用 Google BBR TCP 拥塞控制）"
        echo -e "  ${GREEN}2.${NC}  Fail2Ban 安装（防暴力破解）"
        echo -e "  ${GREEN}3.${NC}  测压工具（stress / sysbench）"
        echo -e "  ${GREEN}4.${NC}  系统调优（内核参数优化）"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-4/b]:${NC} ")" choice

        case $choice in
            1) bbr_setup ;;
            2) fail2ban_setup ;;
            3) stress_tools ;;
            4) system_tuning ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 4.1 BBR 加速
bbr_setup() {
    print_header
    echo -e "${WHITE}━━━ BBR 加速 ━━━${NC}\n"

    echo -e "${CYAN}▶ 当前拥塞控制算法:${NC}"
    sysctl net.ipv4.tcp_congestion_control 2>/dev/null
    echo -e "${CYAN}▶ 当前可用算法:${NC}"
    sysctl net.ipv4.tcp_available_congestion_control 2>/dev/null
    echo

    local bbr_loaded=$(lsmod | grep -o bbr 2>/dev/null)
    if [[ -n "$bbr_loaded" ]]; then
        echo -e "${GREEN}BBR 模块已加载${NC}"
    else
        echo -e "${YELLOW}BBR 模块未加载${NC}"
    fi
    echo

    echo -e "  ${GREEN}1.${NC}  启用 BBR"
    echo -e "  ${GREEN}2.${NC}  禁用 BBR"
    echo -e "  ${GREEN}3.${NC}  查看 BBR 状态"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-3]:${NC} ")" sub

    case $sub in
        1)
            if ! check_root; then pause; return; fi
            echo -e "${GREEN}▶ 启用 BBR...${NC}"
            cat >> /etc/sysctl.d/99-bbr.conf <<'EOF' 2>/dev/null
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
            sysctl -p /etc/sysctl.d/99-bbr.conf 2>/dev/null
            echo -e "${GREEN}BBR 已启用${NC}"
            ;;
        2)
            if ! check_root; then pause; return; fi
            rm -f /etc/sysctl.d/99-bbr.conf 2>/dev/null
            sysctl -w net.ipv4.tcp_congestion_control=cubic 2>/dev/null
            echo -e "${YELLOW}BBR 已禁用，已回退到 cubic${NC}"
            ;;
        3)
            echo -e "${CYAN}▶ BBR 状态:${NC}"
            sysctl net.ipv4.tcp_congestion_control 2>/dev/null
            lsmod | grep bbr 2>/dev/null || echo -e "  BBR 模块: ${RED}未加载${NC}"
            ;;
    esac
    pause
}

# 4.2 Fail2Ban 安装
fail2ban_setup() {
    print_header
    echo -e "${WHITE}━━━ Fail2Ban 安装 ━━━${NC}\n"

    if check_cmd fail2ban-client; then
        echo -e "${GREEN}Fail2Ban 已安装${NC}"
        echo -e "  状态: $(fail2ban-client status 2>/dev/null | head -3)"
    else
        echo -e "${YELLOW}Fail2Ban 未安装${NC}"
        echo
        read -r -p "$(echo -e "${BLUE}是否安装 Fail2Ban？(y/n):${NC} ")" install_f2b
        if [[ "$install_f2b" =~ ^[Yy]$ ]] && check_root; then
            echo -e "${GREEN}▶ 安装 Fail2Ban...${NC}"
            install_pkg "fail2ban"
            if check_cmd fail2ban-client; then
                # 配置 SSH 保护
                cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 86400
EOF
                systemctl enable fail2ban --now 2>/dev/null
                echo -e "${GREEN}Fail2Ban 已安装并启动${NC}"
                echo -e "  SSH 保护已启用: 3 次失败封禁 24 小时"
            else
                echo -e "${RED}安装失败${NC}"
            fi
        fi
    fi

    if check_cmd fail2ban-client; then
        echo
        echo -e "${CYAN}▶ Fail2Ban 状态:${NC}"
        fail2ban-client status 2>/dev/null
        echo
        fail2ban-client status sshd 2>/dev/null
    fi
    pause
}

# 4.3 测压工具
stress_tools() {
    print_header
    echo -e "${WHITE}━━━ 测压工具 ━━━${NC}\n"

    echo -e "  ${GREEN}1.${NC}  安装 stress（CPU/内存压力测试）"
    echo -e "  ${GREEN}2.${NC}  安装 sysbench（综合基准测试）"
    echo -e "  ${GREEN}3.${NC}  运行 stress CPU 测试（4 核 60 秒）"
    echo -e "  ${GREEN}4.${NC}  运行 stress 内存测试（1G 60 秒）"
    echo -e "  ${GREEN}5.${NC}  运行 sysbench CPU 测试"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-5/b]:${NC} ")" sub

    case $sub in
        1)
            if check_root; then
                install_pkg "stress"
                echo -e "${GREEN}stress 已安装${NC}"
            fi
            pause
            ;;
        2)
            if check_root; then
                install_pkg "sysbench"
                echo -e "${GREEN}sysbench 已安装${NC}"
            fi
            pause
            ;;
        3)
            if ! check_cmd stress; then
                echo -e "${YELLOW}stress 未安装，先安装...${NC}"
                check_root && install_pkg "stress"
            fi
            if check_cmd stress; then
                echo -e "${YELLOW}▶ 运行 CPU 压力测试（4 核 60 秒）...${NC}"
                stress --cpu 4 --timeout 60 --verbose 2>/dev/null
                echo -e "${GREEN}测试完成${NC}"
            fi
            pause
            ;;
        4)
            if ! check_cmd stress; then
                echo -e "${YELLOW}stress 未安装，先安装...${NC}"
                check_root && install_pkg "stress"
            fi
            if check_cmd stress; then
                echo -e "${YELLOW}▶ 运行内存压力测试（1G 60 秒）...${NC}"
                stress --vm 1 --vm-bytes 1G --timeout 60 --verbose 2>/dev/null
                echo -e "${GREEN}测试完成${NC}"
            fi
            pause
            ;;
        5)
            if ! check_cmd sysbench; then
                echo -e "${YELLOW}sysbench 未安装，先安装...${NC}"
                check_root && install_pkg "sysbench"
            fi
            if check_cmd sysbench; then
                echo -e "${YELLOW}▶ 运行 sysbench CPU 测试...${NC}"
                sysbench cpu run 2>/dev/null
                echo -e "\n${GREEN}测试完成${NC}"
            fi
            pause
            ;;
        b|B) return ;;
    esac
}

# 4.4 系统调优
system_tuning() {
    print_header
    echo -e "${WHITE}━━━ 系统调优 ━━━${NC}\n"

    echo -e "${YELLOW}即将应用系统内核参数优化（文件描述符、网络等）${NC}"
    echo -e "${YELLOW}不会影响现有连接，重启后持续生效${NC}"
    echo

    if ! check_root; then
        pause
        return
    fi

    read -r -p "$(echo -e "${BLUE}确认应用调优？(y/n):${NC} ")" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}已取消${NC}"
        pause
        return
    fi

    cat > /etc/sysctl.d/99-tuning.conf <<'EOF'
# 系统调优配置 — tools-m.sh

# 文件描述符限制
fs.file-max = 1000000

# 网络优化 - TCP
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.ip_local_port_range = 1024 65000

# 内存优化
vm.vfs_cache_pressure = 50
vm.swappiness = 10
vm.dirty_ratio = 20
vm.dirty_background_ratio = 5
EOF

    sysctl -p /etc/sysctl.d/99-tuning.conf 2>/dev/null
    echo -e "\n${GREEN}系统调优已应用${NC}"
    pause
}

# ============================================================
# 5. 开发者工具
# ============================================================
developer_tools() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 开发者工具 ━━━${NC}\n"

        echo -e "  ${GREEN}1.${NC}  安装 Docker"
        echo -e "  ${GREEN}2.${NC}  安装 Node.js"
        echo -e "  ${GREEN}3.${NC}  安装 Python 环境"
        echo -e "  ${GREEN}4.${NC}  安装 Java"
        echo -e "  ${GREEN}5.${NC}  安装数据库"
        echo -e "  ${GREEN}6.${NC}  安装 Nginx"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-6/b]:${NC} ")" choice

        case $choice in
            1) install_docker ;;
            2) install_nodejs ;;
            3) install_python_env ;;
            4) install_java ;;
            5) install_database ;;
            6) install_nginx ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 5.1 安装 Docker
install_docker() {
    print_header
    echo -e "${WHITE}━━━ 安装 Docker ━━━${NC}\n"

    if check_cmd docker; then
        echo -e "${GREEN}Docker 已安装${NC}"
        docker --version
        echo
        read -r -p "$(echo -e "${BLUE}是否重新安装？(y/n):${NC} ")" reinstall
        [[ ! "$reinstall" =~ ^[Yy]$ ]] && pause && return
    fi

    if ! check_root; then
        pause
        return
    fi

    echo -e "${GREEN}▶ 安装 Docker...${NC}"
    # 使用官方脚本
    if check_cmd curl; then
        curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 2>/dev/null
        sh /tmp/get-docker.sh 2>/dev/null
    elif check_cmd wget; then
        wget -qO /tmp/get-docker.sh https://get.docker.com 2>/dev/null
        sh /tmp/get-docker.sh 2>/dev/null
    fi

    if check_cmd docker; then
        systemctl enable docker --now 2>/dev/null
        echo -e "${GREEN}Docker 安装成功！${NC}"
        docker --version
        # 安装 compose 插件
        if ! docker compose version 2>/dev/null; then
            install_pkg "docker-compose-plugin" 2>/dev/null || \
            curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 2>/dev/null && \
            chmod +x /usr/local/bin/docker-compose 2>/dev/null
        fi
        echo -e "${GREEN}Docker Compose 已安装${NC}"
    else
        echo -e "${RED}Docker 安装失败，请手动安装${NC}"
    fi
    pause
}

# 5.2 安装 Node.js
install_nodejs() {
    print_header
    echo -e "${WHITE}━━━ 安装 Node.js ━━━${NC}\n"

    if check_cmd node; then
        echo -e "${GREEN}Node.js 已安装: $(node --version)${NC}"
        echo -e "npm: $(npm --version 2>/dev/null)"
        echo
        read -r -p "$(echo -e "${BLUE}是否重新安装？(y/n):${NC} ")" reinstall
        [[ ! "$reinstall" =~ ^[Yy]$ ]] && pause && return
    fi

    echo -e "  ${GREEN}1.${NC}  安装 Node.js 18 (LTS)"
    echo -e "  ${GREEN}2.${NC}  安装 Node.js 20 (LTS)"
    echo -e "  ${GREEN}3.${NC}  安装 Node.js 22 (LTS)"
    echo -e "  ${GREEN}4.${NC}  使用 NVM 安装（推荐，可多版本管理）"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-4]:${NC} ")" ver

    if ! check_root; then
        pause
        return
    fi

    case $ver in
        1)
            if check_cmd curl; then
                curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
            fi
            install_pkg "nodejs"
            ;;
        2)
            if check_cmd curl; then
                curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
            fi
            install_pkg "nodejs"
            ;;
        3)
            if check_cmd curl; then
                curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
            fi
            install_pkg "nodejs"
            ;;
        4)
            echo -e "${GREEN}▶ 安装 NVM...${NC}"
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh 2>/dev/null | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            echo -e "${GREEN}NVM 已安装。可使用 nvm install <version> 安装指定版本${NC}"
            echo -e "  例如: nvm install 20"
            pause
            return
            ;;
        *) echo -e "${RED}无效选项${NC}"; pause; return ;;
    esac

    if check_cmd node; then
        echo -e "${GREEN}Node.js $(node --version) 安装成功${NC}"
    fi
    pause
}

# 5.3 安装 Python 环境
install_python_env() {
    print_header
    echo -e "${WHITE}━━━ 安装 Python 环境 ━━━${NC}\n"

    if check_cmd python3; then
        echo -e "${GREEN}Python3 已安装: $(python3 --version 2>/dev/null)${NC}"
    fi
    if check_cmd pip3; then
        echo -e "${GREEN}pip3 已安装: $(pip3 --version 2>/dev/null)${NC}"
    fi
    echo

    echo -e "  ${GREEN}1.${NC}  安装 Python3 + pip + venv"
    echo -e "  ${GREEN}2.${NC}  安装 Python 开发包（dev headers）"
    echo -e "  ${GREEN}3.${NC}  安装常用 Python 包（requests, flask, django 等）"
    echo -e "  ${GREEN}4.${NC}  升级 pip 到最新"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-4/b]:${NC} ")" sub

    if ! check_root; then
        pause
        return
    fi

    case $sub in
        1)
            install_pkg "python3" && \
            install_pkg "python3-pip" && \
            install_pkg "python3-venv"
            echo -e "${GREEN}Python 环境搭建完成${NC}"
            ;;
        2)
            install_pkg "python3-dev" 2>/dev/null || \
            install_pkg "python3-devel" 2>/dev/null
            echo -e "${GREEN}Python 开发包已安装${NC}"
            ;;
        3)
            if check_cmd pip3; then
                for pkg in requests flask django psutil numpy; do
                    echo -e "${YELLOW}▶ 安装 $pkg...${NC}"
                    pip3 install "$pkg" --quiet --break-system-packages 2>/dev/null || \
                    pip3 install "$pkg" --quiet 2>/dev/null
                done
                echo -e "${GREEN}Python 常用包已安装${NC}"
            else
                echo -e "${RED}pip3 未安装${NC}"
            fi
            ;;
        4)
            if check_cmd pip3; then
                pip3 install --upgrade pip --break-system-packages 2>/dev/null || \
                pip3 install --upgrade pip 2>/dev/null
                echo -e "${GREEN}pip 已升级: $(pip3 --version)${NC}"
            fi
            ;;
        b|B) return ;;
    esac
    pause
}

# 5.4 安装 Java
install_java() {
    print_header
    echo -e "${WHITE}━━━ 安装 Java ━━━${NC}\n"

    if check_cmd java; then
        echo -e "${GREEN}Java 已安装: $(java -version 2>&1 | head -1)${NC}"
        echo
        read -r -p "$(echo -e "${BLUE}是否重新安装？(y/n):${NC} ")" reinstall
        [[ ! "$reinstall" =~ ^[Yy]$ ]] && pause && return
    fi

    echo -e "  ${GREEN}1.${NC}  安装 OpenJDK 11"
    echo -e "  ${GREEN}2.${NC}  安装 OpenJDK 17 (LTS)"
    echo -e "  ${GREEN}3.${NC}  安装 OpenJDK 21 (LTS)"
    echo -e "  ${GREEN}4.${NC}  安装 OpenJDK 8"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-4]:${NC} ")" ver

    if ! check_root; then
        pause
        return
    fi

    case $ver in
        1) install_pkg "openjdk-11-jdk" || install_pkg "java-11-openjdk-devel" ;;
        2) install_pkg "openjdk-17-jdk" || install_pkg "java-17-openjdk-devel" ;;
        3) install_pkg "openjdk-21-jdk" || install_pkg "java-21-openjdk-devel" ;;
        4) install_pkg "openjdk-8-jdk" || install_pkg "java-1.8.0-openjdk-devel" ;;
        *) echo -e "${RED}无效选项${NC}"; pause; return ;;
    esac

    if check_cmd java; then
        echo -e "${GREEN}Java $(java -version 2>&1 | head -1) 安装成功${NC}"
    fi
    pause
}

# 5.5 安装数据库
install_database() {
    print_header
    echo -e "${WHITE}━━━ 安装数据库 ━━━${NC}\n"

    echo -e "  ${GREEN}1.${NC}  安装 MySQL 8"
    echo -e "  ${GREEN}2.${NC}  安装 MariaDB"
    echo -e "  ${GREEN}3.${NC}  安装 PostgreSQL"
    echo -e "  ${GREEN}4.${NC}  安装 SQLite"
    echo -e "  ${GREEN}5.${NC}  安装 Redis"
    echo -e "  ${GREEN}6.${NC}  安装 MongoDB"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-6/b]:${NC} ")" sub

    if ! check_root; then
        pause
        return
    fi

    case $sub in
        1)
            install_pkg "mysql-server"
            if check_cmd mysql; then
                systemctl enable mysql --now 2>/dev/null || systemctl enable mysqld --now 2>/dev/null
                echo -e "${GREEN}MySQL 已安装${NC}"
                echo -e "${YELLOW}建议运行: mysql_secure_installation${NC}"
            fi
            ;;
        2)
            install_pkg "mariadb-server"
            if check_cmd mariadb || check_cmd mysql; then
                systemctl enable mariadb --now 2>/dev/null
                echo -e "${GREEN}MariaDB 已安装${NC}"
            fi
            ;;
        3)
            install_pkg "postgresql"
            if check_cmd psql; then
                systemctl enable postgresql --now 2>/dev/null
                echo -e "${GREEN}PostgreSQL 已安装${NC}"
            fi
            ;;
        4)
            install_pkg "sqlite3"
            echo -e "${GREEN}SQLite 已安装: $(sqlite3 --version 2>/dev/null)${NC}"
            ;;
        5)
            install_pkg "redis-server" || install_pkg "redis"
            if check_cmd redis-server; then
                systemctl enable redis-server --now 2>/dev/null || systemctl enable redis --now 2>/dev/null
                echo -e "${GREEN}Redis 已安装${NC}"
            fi
            ;;
        6)
            install_pkg "mongodb" 2>/dev/null || install_pkg "mongodb-server" 2>/dev/null || \
                install_pkg "mongosh" 2>/dev/null || \
                echo -e "${RED}请手动安装 MongoDB：https://www.mongodb.com/docs/manual/installation/${NC}"
            if check_cmd mongod; then
                systemctl enable mongod --now 2>/dev/null
                echo -e "${GREEN}MongoDB 已安装${NC}"
            fi
            ;;
        b|B) return ;;
    esac
    pause
}

# 5.6 安装 Nginx
install_nginx() {
    print_header
    echo -e "${WHITE}━━━ 安装 Nginx ━━━${NC}\n"

    if check_cmd nginx; then
        echo -e "${GREEN}Nginx 已安装: $(nginx -v 2>&1)${NC}"
        echo -e "  状态: $(systemctl is-active nginx 2>/dev/null || echo '未运行')"
        echo
        read -r -p "$(echo -e "${BLUE}是否重新安装？(y/n):${NC} ")" reinstall
        [[ ! "$reinstall" =~ ^[Yy]$ ]] && pause && return
    fi

    if ! check_root; then
        pause
        return
    fi

    echo -e "${GREEN}▶ 安装 Nginx...${NC}"
    install_pkg "nginx"

    if check_cmd nginx; then
        systemctl enable nginx --now 2>/dev/null
        echo -e "${GREEN}Nginx 已安装并启动${NC}"

        # 防火墙放行
        if check_cmd ufw && ufw status | grep -q active; then
            ufw allow 80/tcp
            ufw allow 443/tcp
            echo -e "${YELLOW}防火墙已放行 80/443 端口${NC}"
        fi
    fi
    pause
}

# ============================================================
# 6. Docker 管理
# ============================================================
docker_management() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ Docker 管理 ━━━${NC}\n"

        if ! check_cmd docker; then
            echo -e "${RED}Docker 未安装，请先在开发者工具中安装${NC}"
            pause
            return
        fi

        echo -e "${CYAN}▶ Docker 状态概览:${NC}"
        echo -e "  版本:     $(docker --version 2>/dev/null)"
        echo -e "  容器:     $(docker ps -q 2>/dev/null | wc -l) 运行 / $(docker ps -aq 2>/dev/null | wc -l) 总计"
        echo -e "  镜像:     $(docker images -q 2>/dev/null | wc -l) 个"
        echo -e "  磁盘占用: $(docker system df 2>/dev/null | tail -1 | awk '{print $3 " " $4}')"
        echo

        echo -e "  ${GREEN}1.${NC}  进入 Docker 管理"
        echo -e "  ${GREEN}2.${NC}  Docker 清理"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-2/b]:${NC} ")" choice

        case $choice in
            1) docker_interactive ;;
            2) docker_cleanup ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 6.1 Docker 管理
docker_interactive() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ Docker 管理 ━━━${NC}\n"

        echo -e "  ${GREEN}1.${NC}  查看运行中的容器"
        echo -e "  ${GREEN}2.${NC}  查看所有容器"
        echo -e "  ${GREEN}3.${NC}  查看本地镜像"
        echo -e "  ${GREEN}4.${NC}  启动容器"
        echo -e "  ${GREEN}5.${NC}  停止容器"
        echo -e "  ${GREEN}6.${NC}  重启容器"
        echo -e "  ${GREEN}7.${NC}  查看容器日志"
        echo -e "  ${GREEN}8.${NC}  进入容器 Shell"
        echo -e "  ${GREEN}9.${NC}  删除容器"
        echo -e "  ${GREEN}10.${NC} 删除镜像"
        echo -e "  ${GREEN}11.${NC} 拉取镜像"
        echo -e "  ${GREEN}12.${NC} Docker Compose 管理"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-12/b]:${NC} ")" choice

        case $choice in
            1)
                echo -e "${CYAN}▶ 运行中的容器:${NC}"
                docker ps
                pause
                ;;
            2)
                echo -e "${CYAN}▶ 所有容器:${NC}"
                docker ps -a
                pause
                ;;
            3)
                echo -e "${CYAN}▶ 本地镜像:${NC}"
                docker images
                pause
                ;;
            4)
                read -r -p "$(echo -e "${BLUE}输入容器名称或 ID:${NC} ")" cid
                [[ -n "$cid" ]] && docker start "$cid" 2>/dev/null && \
                    echo -e "${GREEN}容器已启动${NC}" || echo -e "${RED}启动失败${NC}"
                pause
                ;;
            5)
                read -r -p "$(echo -e "${BLUE}输入容器名称或 ID:${NC} ")" cid
                [[ -n "$cid" ]] && docker stop "$cid" 2>/dev/null && \
                    echo -e "${GREEN}容器已停止${NC}" || echo -e "${RED}停止失败${NC}"
                pause
                ;;
            6)
                read -r -p "$(echo -e "${BLUE}输入容器名称或 ID:${NC} ")" cid
                [[ -n "$cid" ]] && docker restart "$cid" 2>/dev/null && \
                    echo -e "${GREEN}容器已重启${NC}" || echo -e "${RED}重启失败${NC}"
                pause
                ;;
            7)
                read -r -p "$(echo -e "${BLUE}输入容器名称或 ID:${NC} ")" cid
                if [[ -n "$cid" ]]; then
                    echo -e "${YELLOW}显示最近 30 条日志（按 Ctrl+C 退出）${NC}"
                    docker logs --tail 30 "$cid" 2>/dev/null
                fi
                pause
                ;;
            8)
                read -r -p "$(echo -e "${BLUE}输入容器名称或 ID:${NC} ")" cid
                if [[ -n "$cid" ]]; then
                    echo -e "${YELLOW}进入容器 Shell（输入 exit 退出）${NC}"
                    docker exec -it "$cid" /bin/bash 2>/dev/null || \
                    docker exec -it "$cid" /bin/sh 2>/dev/null || \
                    echo -e "${RED}无法进入容器${NC}"
                fi
                pause
                ;;
            9)
                read -r -p "$(echo -e "${BLUE}输入要删除的容器名称或 ID:${NC} ")" cid
                if [[ -n "$cid" ]]; then
                    docker rm -f "$cid" 2>/dev/null && \
                        echo -e "${GREEN}容器已删除${NC}" || echo -e "${RED}删除失败${NC}"
                fi
                pause
                ;;
            10)
                read -r -p "$(echo -e "${BLUE}输入要删除的镜像名称或 ID:${NC} ")" iid
                if [[ -n "$iid" ]]; then
                    docker rmi -f "$iid" 2>/dev/null && \
                        echo -e "${GREEN}镜像已删除${NC}" || echo -e "${RED}删除失败${NC}"
                fi
                pause
                ;;
            11)
                read -r -p "$(echo -e "${BLUE}输入要拉取的镜像（如 nginx:latest）:${NC} ")" img
                if [[ -n "$img" ]]; then
                    echo -e "${YELLOW}正在拉取 $img...${NC}"
                    docker pull "$img" 2>/dev/null && \
                        echo -e "${GREEN}拉取完成${NC}" || echo -e "${RED}拉取失败${NC}"
                fi
                pause
                ;;
            12)
                if check_cmd docker-compose || docker compose version &>/dev/null; then
                    echo -e "${YELLOW}请在包含 docker-compose.yml 的目录下操作${NC}"
                    echo -e "  ${GREEN}1.${NC}  启动所有服务"
                    echo -e "  ${GREEN}2.${NC}  停止所有服务"
                    echo -e "  ${GREEN}3.${NC}  查看服务状态"
                    echo -e "  ${GREEN}4.${NC}  重建服务"
                    echo
                    read -r -p "$(echo -e "${BLUE}请选择 [1-4]:${NC} ")" comp
                    case $comp in
                        1) docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null ;;
                        2) docker compose down 2>/dev/null || docker-compose down 2>/dev/null ;;
                        3) docker compose ps 2>/dev/null || docker-compose ps 2>/dev/null ;;
                        4) docker compose up -d --build 2>/dev/null || docker-compose up -d --build 2>/dev/null ;;
                    esac
                fi
                pause
                ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 6.2 Docker 清理
docker_cleanup() {
    print_header
    echo -e "${WHITE}━━━ Docker 清理 ━━━${NC}\n"

    echo -e "${CYAN}▶ 当前 Docker 磁盘占用:${NC}"
    docker system df 2>/dev/null
    echo

    echo -e "  ${GREEN}1.${NC}  清理未使用的容器"
    echo -e "  ${GREEN}2.${NC}  清理未使用的镜像（dangling）"
    echo -e "  ${GREEN}3.${NC}  清理未使用的网络"
    echo -e "  ${GREEN}4.${NC}  清理构建缓存"
    echo -e "  ${GREEN}5.${NC}  一键全面清理（慎用）"
    echo -e "  ${GREEN}6.${NC}  查看可清理的磁盘空间"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-6/b]:${NC} ")" sub

    case $sub in
        1)
            echo -e "${YELLOW}▶ 清理未使用容器...${NC}"
            docker container prune -f 2>/dev/null
            echo -e "${GREEN}已清理${NC}"
            ;;
        2)
            echo -e "${YELLOW}▶ 清理 dangling 镜像...${NC}"
            docker image prune -f 2>/dev/null
            echo -e "${GREEN}已清理${NC}"
            ;;
        3)
            echo -e "${YELLOW}▶ 清理未使用网络...${NC}"
            docker network prune -f 2>/dev/null
            echo -e "${GREEN}已清理${NC}"
            ;;
        4)
            echo -e "${YELLOW}▶ 清理构建缓存...${NC}"
            docker builder prune -f 2>/dev/null
            echo -e "${GREEN}已清理${NC}"
            ;;
        5)
            echo -e "${RED}警告: 将删除所有未使用的 Docker 对象${NC}"
            read -r -p "$(echo -e "${BLUE}确认全面清理？(y/n):${NC} ")" confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                docker system prune -af --volumes 2>/dev/null
                echo -e "${GREEN}全面清理完成${NC}"
            fi
            ;;
        6)
            docker system df 2>/dev/null
            ;;
        b|B) return ;;
    esac
    pause
}

# ============================================================
# 7. 监控日志
# ============================================================
monitor_logs() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 监控日志 ━━━${NC}\n"

        echo -e "  ${GREEN}1.${NC}  实时资源监控"
        echo -e "  ${GREEN}2.${NC}  日志查看"
        echo -e "  ${GREEN}3.${NC}  磁盘分析"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-3/b]:${NC} ")" choice

        case $choice in
            1) resource_monitor ;;
            2) log_viewer ;;
            3) disk_analysis ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 7.1 实时资源监控
resource_monitor() {
    print_header
    echo -e "${WHITE}━━━ 实时资源监控 ━━━${NC}\n"

    echo -e "  ${GREEN}1.${NC}  使用 htop 监控（如已安装）"
    echo -e "  ${GREEN}2.${NC}  使用 top 监控"
    echo -e "  ${GREEN}3.${NC}  快速查看 CPU/内存/磁盘"
    echo -e "  ${GREEN}4.${NC}  查看网络流量"
    echo -e "  ${GREEN}5.${NC}  查看进程列表（按内存排序）"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-5/b]:${NC} ")" sub

    case $sub in
        1)
            if check_cmd htop; then
                htop
            else
                echo -e "${YELLOW}htop 未安装，安装中...${NC}"
                install_pkg "htop" 2>/dev/null && htop
            fi
            ;;
        2)
            echo -e "${YELLOW}按 q 退出 top${NC}"
            sleep 1
            top
            ;;
        3)
            echo -e "${CYAN}▶ CPU 使用率:${NC}"
            top -bn1 | grep "Cpu(s)" | awk '{print "  " $0}'
            echo
            echo -e "${CYAN}▶ 内存使用:${NC}"
            free -h
            echo
            echo -e "${CYAN}▶ 磁盘使用:${NC}"
            df -h --total | grep -v "tmpfs\|loop" | head -10
            ;;
        4)
            echo -e "${CYAN}▶ 网络流量（按 Ctrl+C 退出）:${NC}"
            if check_cmd iftop; then
                iftop
            elif check_cmd nload; then
                nload
            else
                echo -e "${YELLOW}安装 nload...${NC}"
                install_pkg "nload" 2>/dev/null && nload || \
                echo -e "${YELLOW}使用 cat /proc/net/dev:${NC}" && cat /proc/net/dev | head -10
            fi
            ;;
        5)
            echo -e "${CYAN}▶ 进程按内存排序（前 20）:${NC}"
            ps aux --sort=-%mem | head -20
            ;;
        b|B) return ;;
    esac
    pause
}

# 7.2 日志查看
log_viewer() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 日志查看 ━━━${NC}\n"

        echo -e "  ${GREEN}1.${NC}  查看系统日志（journalctl）"
        echo -e "  ${GREEN}2.${NC}  查看系统日志最后 50 行"
        echo -e "  ${GREEN}3.${NC}  实时跟踪系统日志"
        echo -e "  ${GREEN}4.${NC}  查看 Nginx 访问日志"
        echo -e "  ${GREEN}5.${NC}  查看 Nginx 错误日志"
        echo -e "  ${GREEN}6.${NC}  查看 MySQL 日志"
        echo -e "  ${GREEN}7.${NC}  查看 SSH 登录日志"
        echo -e "  ${GREEN}8.${NC}  查看 Docker 日志"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-8/b]:${NC} ")" choice

        case $choice in
            1)
                echo -e "${YELLOW}最近 30 条系统日志（按 q 退出）${NC}"
                journalctl -xe -n 30 --no-pager 2>/dev/null || \
                    echo -e "${RED}journalctl 不可用${NC}"
                pause
                ;;
            2)
                if [[ -f /var/log/syslog ]]; then
                    tail -50 /var/log/syslog
                elif [[ -f /var/log/messages ]]; then
                    tail -50 /var/log/messages
                else
                    journalctl -n 50 --no-pager 2>/dev/null
                fi
                pause
                ;;
            3)
                echo -e "${YELLOW}实时跟踪系统日志（按 Ctrl+C 退出）${NC}"
                if [[ -f /var/log/syslog ]]; then
                    tail -f /var/log/syslog
                elif [[ -f /var/log/messages ]]; then
                    tail -f /var/log/messages
                else
                    journalctl -f 2>/dev/null
                fi
                ;;
            4)
                if [[ -f /var/log/nginx/access.log ]]; then
                    tail -30 /var/log/nginx/access.log
                else
                    echo -e "${YELLOW}Nginx 访问日志不存在${NC}"
                fi
                pause
                ;;
            5)
                if [[ -f /var/log/nginx/error.log ]]; then
                    tail -30 /var/log/nginx/error.log
                else
                    echo -e "${YELLOW}Nginx 错误日志不存在${NC}"
                fi
                pause
                ;;
            6)
                if [[ -f /var/log/mysql/error.log ]]; then
                    tail -30 /var/log/mysql/error.log
                elif [[ -f /var/log/mysqld.log ]]; then
                    tail -30 /var/log/mysqld.log
                else
                    echo -e "${YELLOW}MySQL 日志未找到默认位置${NC}"
                fi
                pause
                ;;
            7)
                if [[ -f /var/log/auth.log ]]; then
                    tail -30 /var/log/auth.log | grep -i "sshd\|ssh"
                elif [[ -f /var/log/secure ]]; then
                    tail -30 /var/log/secure
                else
                    journalctl -u sshd -n 30 --no-pager 2>/dev/null
                fi
                pause
                ;;
            8)
                if check_cmd docker; then
                    read -r -p "$(echo -e "${BLUE}输入容器名称/ID:${NC} ")" cid
                    [[ -n "$cid" ]] && docker logs --tail 30 "$cid" 2>/dev/null
                fi
                pause
                ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 7.3 磁盘分析
disk_analysis() {
    print_header
    echo -e "${WHITE}━━━ 磁盘分析 ━━━${NC}\n"

    echo -e "  ${GREEN}1.${NC}  磁盘使用概览"
    echo -e "  ${GREEN}2.${NC}  查找大文件（>100MB）"
    echo -e "  ${GREEN}3.${NC}  查找大目录（从根目录）"
    echo -e "  ${GREEN}4.${NC}  分析当前目录空间"
    echo -e "  ${GREEN}5.${NC}  Inode 使用情况"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-5/b]:${NC} ")" sub

    case $sub in
        1)
            echo -e "${CYAN}▶ 磁盘分区使用:${NC}"
            df -h | grep -v "tmpfs\|loop" | head -20
            echo
            echo -e "${CYAN}▶ 磁盘 I/O:${NC}"
            iostat -x 1 3 2>/dev/null || echo -e "${YELLOW}请安装 sysstat 获取 iostat${NC}"
            ;;
        2)
            echo -e "${YELLOW}▶ 查找系统中大于 100MB 的文件（前 20）...${NC}"
            echo -e "${YELLOW}（可能需要一些时间）${NC}"
            find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -rh -k5 | head -20
            ;;
        3)
            echo -e "${CYAN}▶ 根目录下各目录大小:${NC}"
            du -sh /* 2>/dev/null | sort -rh | head -20
            ;;
        4)
            local target="."
            read -r -p "$(echo -e "${BLUE}输入目录路径（默认当前目录）:${NC} ")" dir
            [[ -n "$dir" ]] && target="$dir"
            if [[ -d "$target" ]]; then
                echo -e "${CYAN}▶ $target 下目录大小（前 20）:${NC}"
                du -sh "$target"/*/ 2>/dev/null | sort -rh | head -20
            fi
            ;;
        5)
            echo -e "${CYAN}▶ 各分区 Inode 使用:${NC}"
            df -i | grep -v "tmpfs\|loop" | head -20
            ;;
        b|B) return ;;
    esac
    pause
}

# ============================================================
# 8. 备份恢复
# ============================================================
backup_recovery() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 备份恢复 ━━━${NC}\n"

        echo -e "  ${GREEN}1.${NC}  网站打包备份"
        echo -e "  ${GREEN}2.${NC}  数据库备份"
        echo -e "  ${GREEN}3.${NC}  定时任务管理"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-3/b]:${NC} ")" choice

        case $choice in
            1) website_backup ;;
            2) database_backup ;;
            3) cron_management ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 8.1 网站打包备份
website_backup() {
    print_header
    echo -e "${WHITE}━━━ 网站打包备份 ━━━${NC}\n"

    local backup_dir="/var/backups"
    mkdir -p "$backup_dir" 2>/dev/null

    echo -e "${CYAN}▶ 备份目录: $backup_dir${NC}"
    echo

    echo -e "  ${GREEN}1.${NC}  备份网站目录"
    echo -e "  ${GREEN}2.${NC}  查看已有备份"
    echo -e "  ${GREEN}3.${NC}  恢复备份"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-3]:${NC} ")" sub

    case $sub in
        1)
            read -r -p "$(echo -e "${BLUE}输入要备份的目录路径:${NC} ")" src_dir
            if [[ -d "$src_dir" ]]; then
                local name=$(basename "$src_dir")
                local timestamp=$(date +%Y%m%d_%H%M%S)
                local backup_file="$backup_dir/${name}_${timestamp}.tar.gz"
                echo -e "${YELLOW}▶ 打包中...${NC}"
                tar -czf "$backup_file" -C "$(dirname "$src_dir")" "$name" 2>/dev/null
                echo -e "${GREEN}备份完成: $backup_file${NC}"
                ls -lh "$backup_file"
            else
                echo -e "${RED}目录不存在${NC}"
            fi
            ;;
        2)
            echo -e "${CYAN}▶ 已有备份:${NC}"
            ls -lh "$backup_dir"/*.tar.gz 2>/dev/null || echo -e "${YELLOW}暂无备份${NC}"
            ;;
        3)
            echo -e "${CYAN}▶ 已有备份:${NC}"
            local backups=("$backup_dir"/*.tar.gz)
            if [[ ${#backups[@]} -gt 0 ]] && [[ -f "${backups[0]}" ]]; then
                local i=1
                for b in "${backups[@]}"; do
                    echo -e "  ${GREEN}$i.${NC} $(basename "$b") ($(du -h "$b" | cut -f1))"
                    ((i++))
                done
                echo
                read -r -p "$(echo -e "${BLUE}选择要恢复的备份编号:${NC} ")" idx
                if [[ "$idx" =~ ^[0-9]+$ ]] && ((idx >= 1 && idx <= ${#backups[@]})); then
                    read -r -p "$(echo -e "${BLUE}输入恢复目标目录:${NC} ")" target
                    if [[ -d "$target" ]]; then
                        tar -xzf "${backups[$((idx-1))]}" -C "$target" 2>/dev/null
                        echo -e "${GREEN}恢复完成${NC}"
                    fi
                fi
            else
                echo -e "${YELLOW}暂无备份${NC}"
            fi
            ;;
    esac
    pause
}

# 8.2 数据库备份
database_backup() {
    print_header
    echo -e "${WHITE}━━━ 数据库备份 ━━━${NC}\n"

    local backup_dir="/var/backups/db"
    mkdir -p "$backup_dir" 2>/dev/null

    echo -e "  ${GREEN}1.${NC}  备份 MySQL/MariaDB 数据库"
    echo -e "  ${GREEN}2.${NC}  备份 PostgreSQL 数据库"
    echo -e "  ${GREEN}3.${NC}  备份 SQLite 数据库"
    echo -e "  ${GREEN}4.${NC}  查看已有备份"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    read -r -p "$(echo -e "${BLUE}请选择 [1-4/b]:${NC} ")" sub

    case $sub in
        1)
            if check_cmd mysqldump; then
                read -r -p "$(echo -e "${BLUE}输入 MySQL 用户名（默认 root）:${NC} ")" db_user
                db_user=${db_user:-root}
                read -s -p "$(echo -e "${BLUE}输入 MySQL 密码:${NC} ")" db_pass
                echo
                local timestamp=$(date +%Y%m%d_%H%M%S)
                local backup_file="$backup_dir/mysql_all_${timestamp}.sql.gz"
                echo -e "${YELLOW}▶ 备份中...${NC}"
                mysqldump -u "$db_user" -p"$db_pass" --all-databases 2>/dev/null | gzip > "$backup_file"
                if [[ -f "$backup_file" ]] && [[ -s "$backup_file" ]]; then
                    echo -e "${GREEN}备份完成: $backup_file${NC}"
                    ls -lh "$backup_file"
                else
                    echo -e "${RED}备份失败，请检查用户名和密码${NC}"
                    rm -f "$backup_file"
                fi
            else
                echo -e "${RED}mysqldump 未安装${NC}"
            fi
            ;;
        2)
            if check_cmd pg_dump; then
                local timestamp=$(date +%Y%m%d_%H%M%S)
                read -r -p "$(echo -e "${BLUE}输入数据库名（留空备份所有）:${NC} ")" db_name
                if [[ -n "$db_name" ]]; then
                    sudo -u postgres pg_dump "$db_name" 2>/dev/null | gzip > "$backup_dir/postgres_${db_name}_${timestamp}.sql.gz"
                else
                    sudo -u postgres pg_dumpall 2>/dev/null | gzip > "$backup_dir/postgres_all_${timestamp}.sql.gz"
                fi
                echo -e "${GREEN}备份完成${NC}"
                ls -lh "$backup_dir"/*postgres* 2>/dev/null | tail -1
            else
                echo -e "${RED}pg_dump 未安装${NC}"
            fi
            ;;
        3)
            read -r -p "$(echo -e "${BLUE}输入 SQLite 数据库文件路径:${NC} ")" db_file
            if [[ -f "$db_file" ]]; then
                local timestamp=$(date +%Y%m%d_%H%M%S)
                cp "$db_file" "$backup_dir/sqlite_${timestamp}.db"
                echo -e "${GREEN}SQLite 备份完成${NC}"
            else
                echo -e "${RED}文件不存在${NC}"
            fi
            ;;
        4)
            echo -e "${CYAN}▶ 数据库备份列表:${NC}"
            ls -lh "$backup_dir" 2>/dev/null || echo -e "${YELLOW}暂无备份${NC}"
            ;;
        b|B) return ;;
    esac
    pause
}

# 8.3 定时任务管理
cron_management() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 定时任务管理 ━━━${NC}\n"

        echo -e "${CYAN}▶ 当前用户的定时任务:${NC}"
        crontab -l 2>/dev/null || echo -e "${YELLOW}  无定时任务${NC}"
        echo

        echo -e "  ${GREEN}1.${NC}  编辑定时任务（crontab）"
        echo -e "  ${GREEN}2.${NC}  添加定时备份任务"
        echo -e "  ${GREEN}3.${NC}  清除所有定时任务"
        echo -e "  ${GREEN}4.${NC}  查看系统定时任务"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-4/b]:${NC} ")" sub

        case $sub in
            1)
                echo -e "${YELLOW}打开 crontab 编辑器（默认 vi）${NC}"
                crontab -e 2>/dev/null || echo -e "${RED}请安装 cron${NC}"
                ;;
            2)
                if check_root; then
                    local bk_dir="/var/backups"
                    mkdir -p "$bk_dir" 2>/dev/null
                    echo -e "  ${GREEN}1.${NC}  每天凌晨 2 点备份网站"
                    echo -e "  ${GREEN}2.${NC}  每周日备份数据库"
                    echo -e "  ${GREEN}3.${NC}  自定义"
                    echo
                    read -r -p "$(echo -e "${BLUE}请选择:${NC} ")" cron_type

                    local cron_cmd=""
                    case $cron_type in
                        1)
                            read -r -p "$(echo -e "${BLUE}输入要备份的目录:${NC} ")" bk_src
                            if [[ -n "$bk_src" && -d "$bk_src" ]]; then
                                local name=$(basename "$bk_src")
                                cron_cmd="0 2 * * * tar -czf ${bk_dir}/${name}_\$(date +\%Y\%m\%d).tar.gz -C $(dirname "$bk_src") $name"
                            fi
                            ;;
                        2)
                            if check_cmd mysqldump; then
                                cron_cmd="0 3 * * 0 mysqldump -u root --all-databases | gzip > ${bk_dir}/db_\$(date +\%Y\%m\%d).sql.gz"
                            else
                                echo -e "${RED}mysqldump 未安装${NC}"
                            fi
                            ;;
                        3)
                            read -r -p "$(echo -e "${BLUE}输入 crontab 时间表达式（如 0 2 * * *）:${NC} ")" cron_time
                            read -r -p "$(echo -e "${BLUE}输入要执行的命令:${NC} ")" cron_cmd_user
                            cron_cmd="$cron_time $cron_cmd_user"
                            ;;
                    esac

                    if [[ -n "$cron_cmd" ]]; then
                        (crontab -l 2>/dev/null; echo "$cron_cmd") | crontab -
                        echo -e "${GREEN}定时任务已添加${NC}"
                        echo -e "$cron_cmd"
                    fi
                fi
                pause
                ;;
            3)
                read -r -p "$(echo -e "${RED}确认清除所有定时任务？(y/n):${NC} ")" confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    crontab -r 2>/dev/null
                    echo -e "${GREEN}定时任务已清除${NC}"
                fi
                pause
                ;;
            4)
                echo -e "${CYAN}▶ 系统定时任务:${NC}"
                ls /etc/cron.d/ 2>/dev/null
                echo
                echo -e "${CYAN}▶ 每小时任务:${NC}"
                ls /etc/cron.hourly/ 2>/dev/null
                echo
                echo -e "${CYAN}▶ 每日任务:${NC}"
                ls /etc/cron.daily/ 2>/dev/null
                echo
                echo -e "${CYAN}▶ 每周任务:${NC}"
                ls /etc/cron.weekly/ 2>/dev/null
                pause
                ;;
            b|B) return ;;
        esac
    done
}

# ============================================================
# 9. 卸载工具/应用
# ============================================================
uninstall_tools() {
    print_header
    echo -e "${WHITE}━━━ 卸载工具/应用 ━━━${NC}\n"
    echo -e "${YELLOW}输入编号多选卸载（如：1 3 5 或 1-5），按回车确认${NC}\n"

    echo -e "${CYAN}▶ 常用工具:${NC}"
    local common_apps=(curl wget git vim htop tmux tree unzip rsync screen lsof tcpdump)
    local i=1
    declare -a all_items
    declare -a all_cmds

    for app in "${common_apps[@]}"; do
        if check_cmd "$app"; then
            echo -e "  ${GREEN}$(printf "%2d" $i).${NC} $app [已安装]"
        else
            echo -e "  ${GREEN}$(printf "%2d" $i).${NC} $app [未安装]"
        fi
        all_items+=("$app")
        all_cmds+=("$app")
        ((i++))
    done

    echo
    echo -e "${CYAN}▶ 系统应用:${NC}"
    local sys_apps=(nginx mysql-server mariadb-server postgresql redis-server docker-ce fail2ban)
    for app in "${sys_apps[@]}"; do
        if check_root; then
            local installed=false
            case $app in
                nginx) check_cmd nginx && installed=true ;;
                mysql-server) check_cmd mysql && installed=true ;;
                mariadb-server) (check_cmd mariadb || check_cmd mysql) && installed=true ;;
                postgresql) check_cmd psql && installed=true ;;
                redis-server) check_cmd redis-server && installed=true ;;
                docker-ce) check_cmd docker && installed=true ;;
                fail2ban) check_cmd fail2ban-client && installed=true ;;
            esac
            if $installed; then
                echo -e "  ${GREEN}$(printf "%2d" $i).${NC} $app [已安装]"
            else
                echo -e "  ${YELLOW}$(printf "%2d" $i).${NC} $app [未安装]"
            fi
        else
            echo -e "  ${YELLOW}$(printf "%2d" $i).${NC} $app [?需 root]"
        fi
        all_items+=("$app")
        all_cmds+=("")
        ((i++))
    done

    echo
    echo -e "${CYAN}▶ Docker 容器:${NC}"
    if check_cmd docker; then
        local containers=()
        while IFS= read -r line; do
            containers+=("$line")
        done < <(docker ps -a --format "{{.ID}} {{.Image}} {{.Names}} {{.Status}}" 2>/dev/null)
        if [[ ${#containers[@]} -gt 0 ]]; then
            for container in "${containers[@]}"; do
                echo -e "  ${GREEN}$(printf "%2d" $i).${NC} [Docker] $container"
                all_items+=("docker_container:$container")
                all_cmds+=("")
                ((i++))
            done
        else
            echo -e "  ${YELLOW}  无 Docker 容器${NC}"
        fi
    else
        echo -e "  ${YELLOW}  Docker 未安装${NC}"
    fi

    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo

    read -r -p "$(echo -e "${BLUE}请输入要卸载的编号（多选用空格分隔）:${NC} ")" selections

    if [[ "$selections" =~ ^[bB]$ ]]; then return; fi
    if [[ "$selections" =~ ^[qQ]$ ]]; then return; fi

    if ! check_root; then
        pause
        return
    fi

    local choices=()
    for sel in $selections; do
        if [[ "$sel" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            for ((n = ${BASH_REMATCH[1]}; n <= ${BASH_REMATCH[2]}; n++)); do
                choices+=("$n")
            done
        elif [[ "$sel" =~ ^[0-9]+$ ]]; then
            choices+=("$sel")
        fi
    done

    for idx in "${choices[@]}"; do
        if ((idx >= 1 && idx <= ${#all_items[@]})); then
            local item="${all_items[$((idx-1))]}"
            echo -e "${YELLOW}▶ 处理: $item${NC}"

            if [[ "$item" == docker_container:* ]]; then
                # 卸载 Docker 容器
                local cid=$(echo "$item" | awk -F' ' '{print $2}')
                docker rm -f "$cid" 2>/dev/null && \
                    echo -e "${GREEN}  Docker 容器 $cid 已删除${NC}" || \
                    echo -e "${RED}  删除失败${NC}"
            else
                # 卸载系统包
                local pkg_name="$item"
                case $item in
                    mysql-server) pkg_name="mysql-server" ;;
                    mariadb-server) pkg_name="mariadb-server" ;;
                    postgresql) pkg_name="postgresql" ;;
                    redis-server) pkg_name="redis-server" ;;
                    docker-ce) pkg_name="docker-ce" ;;
                esac

                if check_cmd apt-get; then
                    apt-get remove --purge -y "$pkg_name" 2>/dev/null && \
                        echo -e "${GREEN}  $pkg_name 已卸载${NC}" || \
                        echo -e "${YELLOW}  $pkg_name 卸载失败或不存在${NC}"
                elif check_cmd yum; then
                    yum remove -y "$pkg_name" 2>/dev/null && \
                        echo -e "${GREEN}  $pkg_name 已卸载${NC}" || \
                        echo -e "${YELLOW}  $pkg_name 卸载失败或不存在${NC}"
                elif check_cmd dnf; then
                    dnf remove -y "$pkg_name" 2>/dev/null
                elif check_cmd pacman; then
                    pacman -Rs --noconfirm "$pkg_name" 2>/dev/null
                fi
            fi
        fi
    done

    echo -e "\n${GREEN}卸载操作完成！${NC}"
    pause
}

# ============================================================
# 10. Linux 命令大全
# ============================================================
#  通用: 分页显示 + 返回
# ============================================================
linux_show_cmds() {
    local title="$1"
    shift
    print_header
    echo -e "${WHITE}${YELLOW}◆ $title${NC}"
    echo ""
    echo -e "$@"
    echo ""
    echo -e "${CYAN}按 Enter 返回菜单${NC}"
    read -r
}

# ============================================================
#  1. 文件操作
# ============================================================
linux_show_file_ops() {
    linux_show_cmds "文件操作" \
"${GREEN}ls${NC}             列出目录内容
  ls -la          显示所有文件（含隐藏文件）详细信息
  ls -lh          以人类可读格式显示文件大小
  ls -lt          按修改时间排序
  ls -lS          按文件大小排序
  ls -R           递归列出子目录

${GREEN}cp${NC}             复制文件或目录
  cp file1 file2              将 file1 复制为 file2
  cp -r dir1 dir2             递归复制整个目录
  cp -a dir1 dir2             归档复制（保留权限/时间戳）
  cp -p file1 file2           保留文件属性复制
  cp -i file1 file2           覆盖前提示确认
  cp -u file1 file2           只复制更新的文件

${GREEN}mv${NC}             移动或重命名文件
  mv file1 file2              重命名文件
  mv file1 dir1/              移动文件到目录
  mv -i file1 file2           覆盖前提示
  mv -u file1 file2           只移动更新的文件

${GREEN}rm${NC}             删除文件或目录
  rm file                     删除文件
  rm -r dir                   递归删除目录及其内容
  rm -f file                  强制删除（不提示）
  rm -rf dir                  强制递归删除（慎用！）
  rm -i file                  删除前逐一确认

${GREEN}touch${NC}          创建空文件或更新文件时间戳
  touch file                  创建空文件（若存在则更新时间戳）

${GREEN}ln${NC}             创建链接
  ln -s target link_name      创建软链接（符号链接）
  ln target link_name         创建硬链接

${GREEN}file${NC}           查看文件类型
  file filename               显示文件实际类型

${GREEN}stat${NC}           查看文件或文件系统的详细信息
  stat filename               显示文件大小、权限、时间戳等"
}

# ============================================================
#  2. 目录管理
# ============================================================
linux_show_dir_ops() {
    linux_show_cmds "目录管理" \
"${GREEN}pwd${NC}            显示当前工作目录的完整路径

${GREEN}cd${NC}             切换目录
  cd /path/to/dir      切换到指定目录
  cd ..                返回上一级目录
  cd ~ 或 cd           返回主目录
  cd -                 返回上一个工作目录

${GREEN}mkdir${NC}          创建目录
  mkdir dir            创建目录
  mkdir -p a/b/c       创建多级目录（父目录不存在时自动创建）
  mkdir -m 755 dir     创建目录并设置权限

${GREEN}rmdir${NC}          删除空目录
  rmdir dir            删除空目录
  rmdir -p a/b/c       删除多级空目录

${GREEN}tree${NC}           以树形结构显示目录（可能需要安装）
  tree                 显示当前目录树
  tree -L 2            只显示两层深度
  tree -d              只显示目录
  tree -a              包含隐藏文件"
}

# ============================================================
#  3. 文件内容查看
# ============================================================
linux_show_content_view() {
    linux_show_cmds "文件内容查看" \
"${GREEN}cat${NC}            查看或拼接文件内容
  cat file                   显示文件全部内容
  cat -n file                显示行号
  cat file1 file2 > out      将多个文件合并

${GREEN}less${NC}           分页查看文件（支持上下翻页）
  less file                  按 q 退出，/搜索，g 首行，G 尾行

${GREEN}more${NC}           分页查看文件（仅支持向下翻页）
  more file                  Space 下翻，Enter 下一行，q 退出

${GREEN}head${NC}           查看文件开头部分
  head file                  默认显示前10行
  head -n 20 file            显示前20行

${GREEN}tail${NC}           查看文件末尾部分
  tail file                  默认显示后10行
  tail -n 20 file            显示后20行
  tail -f file               实时监控文件追加内容（常用于查看日志）
  tail -F file               监控文件（日志轮转时仍能跟踪）

${GREEN}wc${NC}            统计行数、单词数、字符数
  wc file                    显示 行数/单词数/字节数
  wc -l file                 只显示行数

${GREEN}od${NC}            以八进制/十六进制查看二进制文件
  od -c file                 以 ASCII 字符显示
  od -x file                 以十六进制显示

${GREEN}xxd${NC}           十六进制转储
  xxd file                   以十六进制和 ASCII 显示二进制文件"
}

# ============================================================
#  4. 文本处理
# ============================================================
linux_show_text_ops() {
    linux_show_cmds "文本处理" \
"${GREEN}grep${NC}           搜索文件中的文本模式
  grep pattern file           在文件中搜索模式
  grep -i pattern file        忽略大小写
  grep -r pattern dir         递归搜索目录
  grep -n pattern file        显示匹配行及行号
  grep -c pattern file        统计匹配行数
  grep -v pattern file        显示不匹配的行（反向匹配）
  grep -l pattern dir/*       只列出包含匹配模式的文件名
  grep -w pattern file        精确匹配整个单词
  grep -E 'pat1|pat2' file    扩展正则（或逻辑）
  grep -A 5 pattern file      显示匹配行及之后5行
  grep -B 5 pattern file      显示匹配行及之前5行
  grep -C 5 pattern file      显示匹配行及前后各5行

${GREEN}sort${NC}          排序
  sort file                   按字母顺序排序
  sort -n file                按数字排序
  sort -r file                反向排序
  sort -u file                排序并去重（同 sort | uniq）
  sort -k 2 file              按第2列排序
  sort -t: -k 3 -n file       以冒号分隔，按第3列数字排序

${GREEN}uniq${NC}         去重（需先排序）
  uniq file                   去除连续的重复行
  uniq -c file                统计每行出现次数
  uniq -d file                只显示重复的行

${GREEN}cut${NC}          按列截取文本
  cut -d: -f1 file            以冒号分隔，取第1列
  cut -c1-5 file              取每行的第1-5个字符

${GREEN}tr${NC}           字符替换或删除
  tr 'a-z' 'A-Z' < file       小写转大写
  tr -d ' ' < file            删除所有空格
  tr -s ' ' < file            压缩连续空格为一个空格

${GREEN}diff${NC}         比较文件差异
  diff file1 file2            显示两个文件的差异
  diff -u file1 file2         统一格式显示（常用作补丁）
  diff -r dir1 dir2           递归比较两个目录

${GREEN}comm${NC}         逐行比较两个已排序文件
  comm file1 file2            三列输出：仅file1、仅file2、共有

${GREEN}join${NC}         基于共同字段合并两个文件
  join -t: file1 file2        以冒号分隔，按第一个字段合并

${GREEN}paste${NC}        按列合并文件
  paste file1 file2           将两个文件按列并排显示
  paste -d',' file1 file2     用逗号分隔

${GREEN}fold${NC}         折行显示长行
  fold -w 80 file             每行最多80个字符时换行"
}

# ============================================================
#  5. 权限管理
# ============================================================
linux_show_permissions() {
    linux_show_cmds "权限管理" \
"${GREEN}chmod${NC}         修改文件权限
  chmod 755 file          设置权限为 rwxr-xr-x
  chmod u+x file          给所有者添加执行权限
  chmod g-w file          移除组的写权限
  chmod o+r file          给其他人添加读权限
  chmod a+x file          给所有人添加执行权限
  chmod -R 755 dir        递归设置目录权限

  权限数值说明:
  r=4(读), w=2(写), x=1(执行)
  755 = 所有者(7=rwx) 组(5=r-x) 其他人(5=r-x)

${GREEN}chown${NC}         修改文件所有者
  chown user file             将文件所有者改为 user
  chown user:group file       同时修改所有者和组
  chown -R user dir           递归修改目录所有者
  chown :group file           只修改组

${GREEN}chgrp${NC}        修改文件所属组
  chgrp group file            修改文件所属组
  chgrp -R group dir          递归修改

${GREEN}umask${NC}        设置默认权限掩码
  umask                       查看当前掩码
  umask 022                   设置掩码（新文件默认 644，目录 755）

${GREEN}lsattr / chattr${NC} 查看/修改文件隐藏属性（ext文件系统）
  chattr +i file              设置不可修改（即使是 root 也不行）
  chattr +a file              只能追加内容，不能删除或修改
  lsattr file                 查看隐藏属性"
}

# ============================================================
#  6. 用户管理
# ============================================================
linux_show_user_mgmt() {
    linux_show_cmds "用户管理" \
"${GREEN}useradd${NC}       创建用户
  useradd -m username       创建用户并创建主目录
  useradd -m -s /bin/bash username  创建用户并指定shell

${GREEN}usermod${NC}       修改用户信息
  usermod -aG group user     将用户添加到组（保留现有组）
  usermod -l newname user    修改用户名

${GREEN}userdel${NC}       删除用户
  userdel username           删除用户
  userdel -r username        删除用户及其主目录和邮件池

${GREEN}passwd${NC}       修改密码
  passwd                     修改当前用户密码
  passwd username            修改指定用户密码（需 root）

${GREEN}groupadd${NC}     创建组
  groupadd groupname         创建新组

${GREEN}groups${NC}       查看用户所属组
  groups username            查看用户属于哪些组

${GREEN}id${NC}          查看用户 UID/GID 信息
  id                         显示当前用户 UID, GID, 所属组
  id username                显示指定用户信息

${GREEN}who / w / whoami${NC} 查看登录用户
  who                        显示当前登录系统的用户
  w                          显示登录用户及其活动
  whoami                     显示当前用户名

${GREEN}last${NC}         查看最近登录记录
  last                       显示最近登录记录（读取 /var/log/wtmp）
  last -10                   只显示最近10条

${GREEN}sudo${NC}         以其他用户身份执行命令
  sudo command               以 root 执行命令
  sudo -u user command       以指定用户执行命令
  sudo -i                    切换到 root 交互式 shell
  sudo -l                    查看当前用户可执行的 sudo 命令

${GREEN}su${NC}          切换用户
  su - username              切换到指定用户（加载环境变量）"
}

# ============================================================
#  7. 进程管理
# ============================================================
linux_show_process() {
    linux_show_cmds "进程管理" \
"${GREEN}ps${NC}            查看进程状态
  ps aux                     显示所有进程详细信息
  ps -ef                     标准格式显示所有进程
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem  按内存排序
  ps aux | grep nginx        过滤特定进程
  ps -u user                 查看指定用户的进程

${GREEN}top${NC}           动态查看进程（实时刷新）
  top                        按 q 退出，P 按CPU排序，M 按内存排序
  htop                       增强版 top（需安装）

${GREEN}kill${NC}         终止进程
  kill PID                   发送 SIGTERM 信号（请求终止）
  kill -9 PID                发送 SIGKILL 信号（强制终止）
  kill -15 PID               等同于 kill（优雅终止）

${GREEN}pkill / killall${NC} 按名称终止进程
  pkill process_name         按进程名终止
  killall process_name       终止所有同名进程

${GREEN}nice / renice${NC} 设置进程优先级
  nice -n 10 command         以较低优先级运行（范围 -20~19）
  renice -n 5 -p PID         修改运行中进程的优先级

${GREEN}bg / fg${NC}      后台/前台任务控制
  command &                  在后台运行命令
  Ctrl+Z                     挂起当前任务
  bg                         将挂起的任务放到后台运行
  fg                         将后台任务调到前台
  jobs                       查看后台任务列表

${GREEN}nohup${NC}       退出终端后继续运行
  nohup command &            即使退出终端也继续运行命令
  nohup command > out.log &  输出重定向到指定日志

${GREEN}screen / tmux${NC} 终端复用器
  screen -S name             创建名为 name 的会话
  screen -ls                 列出所有会话
  screen -r name              重新连接会话
  tmux new -s name           创建 tmux 会话
  tmux ls                    列出 tmux 会话
  tmux attach -t name        连接 tmux 会话

${GREEN}systemctl${NC}     管理 systemd 服务
  systemctl start service     启动服务
  systemctl stop service      停止服务
  systemctl restart service   重启服务
  systemctl status service    查看服务状态
  systemctl enable service    设置开机自启
  systemctl disable service   禁用开机自启
  systemctl list-units --type=service  列出所有服务

${GREEN}service${NC}      管理 SysV 服务（旧版）
  service name start          启动服务
  service name status         查看服务状态"
}

# ============================================================
#  8. 系统信息
# ============================================================
linux_show_sysinfo() {
    linux_show_cmds "系统信息" \
"${GREEN}uname${NC}         查看系统内核信息
  uname -a                   显示所有系统信息
  uname -r                   显示内核版本
  uname -m                   显示架构（x86_64, aarch64 等）

${GREEN}lscpu${NC}        查看 CPU 详细信息
  lscpu                      显示 CPU 架构、核心数、型号等

${GREEN}free${NC}         查看内存使用情况
  free -h                    以人类可读格式显示
  free -m                    以 MB 为单位显示

${GREEN}df${NC}           查看磁盘分区使用情况
  df -h                      以人类可读格式显示
  df -T                      显示文件系统类型

${GREEN}du${NC}           查看文件/目录占用空间
  du -sh dir                 显示目录总大小
  du -h --max-depth=1 dir    显示一级子目录大小
  du -ah file                显示所有文件大小

${GREEN}dmesg${NC}       查看内核日志
  dmesg | tail -20           查看最后20条内核消息

${GREEN}lspci / lsusb / lsblk${NC} 查看硬件信息
  lspci                      列出 PCI 设备
  lsusb                      列出 USB 设备
  lsblk                      列出块设备（磁盘和分区）

${GREEN}hostnamectl${NC}   查看/设置主机名
  hostnamectl                查看主机名信息
  hostnamectl set-hostname name  设置主机名

${GREEN}uptime${NC}       查看系统运行时间
  uptime                     显示运行时间、负载等

${GREEN}date${NC}         查看/设置系统日期时间
  date                       显示当前日期时间
  date '+%Y-%m-%d %H:%M:%S'  自定义格式显示

${GREEN}cal${NC}          显示日历
  cal                        显示本月日历
  cal 2026                   显示全年日历
${GREEN}arch${NC}         显示机器架构
  arch                       输出 x86_64 或 aarch64 等"
}

# ============================================================
#  9. 磁盘与存储
# ============================================================
linux_show_disk() {
    linux_show_cmds "磁盘与存储" \
"${GREEN}fdisk${NC}        磁盘分区管理
  fdisk -l                   列出所有磁盘及分区
  fdisk /dev/sda             对 /dev/sda 进行分区操作

${GREEN}parted${NC}       GPT 磁盘分区
  parted -l                  列出所有分区
  parted /dev/sda mklabel gpt   创建 GPT 分区表

${GREEN}mkfs${NC}        格式化分区
  mkfs.ext4 /dev/sda1        格式化为 ext4
  mkfs.xfs /dev/sda1         格式化为 xfs
  mkfs.ntfs /dev/sda1        格式化为 NTFS

${GREEN}mount / umount${NC} 挂载/卸载
  mount /dev/sda1 /mnt       挂载分区到 /mnt
  mount -t ntfs-3g /dev/sda1 /mnt  挂载 NTFS 分区
  umount /mnt                卸载
  umount -l /mnt             强制卸载（延迟）

${GREEN}blkid${NC}       查看块设备 UUID 和标签
  blkid                      显示所有块设备的 UUID 和文件系统类型

${GREEN}lsblk${NC}       列出块设备（树形）
  lsblk                      树形显示磁盘和分区
  lsblk -f                   包含文件系统信息

${GREEN}dd${NC}         数据复制/备份（低级别）
  dd if=/dev/sda of=/backup.img bs=4M  备份整个磁盘
  dd if=/dev/zero of=file bs=1M count=100  创建 100MB 测试文件
  dd if=/dev/random of=file bs=1M count=10  创建随机数据文件

${GREEN}rsync${NC}       高效文件同步
  rsync -av src/ dst/         同步目录（归档模式）
  rsync -avz src/ user@host:/dst/  通过 SSH 远程同步
  rsync --delete src/ dst/    同步并删除目标端多余文件
  rsync --progress src/ dst/  显示传输进度

${GREEN}smartctl${NC}     查看磁盘 S.M.A.R.T. 信息（需安装 smartmontools）
  smartctl -a /dev/sda        显示磁盘健康信息"
}

# ============================================================
#  10. 网络管理
# ============================================================
linux_show_network() {
    linux_show_cmds "网络管理" \
"${GREEN}ip${NC}           网络配置（新标准，替代 ifconfig）
  ip addr                    查看 IP 地址
  ip link                    查看网络接口状态
  ip route                   查看路由表
  ip addr add 192.168.1.2/24 dev eth0  添加 IP 地址

${GREEN}ifconfig${NC}     网络接口配置（旧版）
  ifconfig                   查看/配置网络接口
  ifconfig eth0 up/down      启用/禁用网卡

${GREEN}ping${NC}        测试网络连通性
  ping -c 4 google.com       发送 4 个 ICMP 包
  ping -i 2 google.com       每2秒发送一次

${GREEN}ss${NC}          查看网络连接（比 netstat 更快）
  ss -tuln                   列出所有监听端口
  ss -tup                    显示 TCP 连接及对应进程
  ss -s                      显示网络连接统计

${GREEN}netstat${NC}     查看网络连接（旧版）
  netstat -tuln              列出所有监听端口
  netstat -anp               显示所有连接及进程

${GREEN}curl${NC}        发送 HTTP 请求
  curl https://api.com       发送 GET 请求
  curl -X POST -d 'data' URL  发送 POST 请求
  curl -o file URL           下载文件
  curl -I URL                只查看 HTTP 响应头

${GREEN}wget${NC}        下载文件
  wget URL                   下载文件
  wget -c URL                断点续传
  wget -O file URL           指定输出文件名
  wget -r URL                递归下载

${GREEN}nslookup / dig${NC} DNS 查询
  nslookup example.com       查询域名解析
  dig example.com            更详细的 DNS 查询
  dig -x 8.8.8.8            反向 DNS 查询

${GREEN}hostname${NC}     查看/设置主机名
  hostname                   查看当前主机名

${GREEN}telnet / nc${NC}  端口连通性测试
  telnet host port           测试端口是否开放
  nc -zv host port           测试端口连通性
  nc -l -p 8080              在本机 8080 端口监听

${GREEN}traceroute${NC}   路由追踪
  traceroute google.com      追踪到目标的路由路径
  mtr google.com             动态路由追踪（需安装 mtr）

${GREEN}iptables${NC}    防火墙规则管理
  iptables -L                列出规则
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT  开放 80 端口
  iptables -D INPUT 3        删除第3条规则

${GREEN}scp${NC}         基于 SSH 的文件传输
  scp file user@host:/path/  本地传文件到远程
  scp user@host:/path/file . 远程传文件到本地
  scp -r dir user@host:/path/ 递归传输目录

${GREEN}sftp${NC}        安全文件传输（基于 SSH）
  sftp user@host             连接 SFTP 会话

${GREEN}tcpdump${NC}     网络抓包
  tcpdump -i eth0            抓取 eth0 网卡数据包
  tcpdump -i eth0 port 80    抓取 80 端口的数据
  tcpdump -c 10              抓取 10 个包后停止

${GREEN}hostnamectl${NC}  查看主机名和系统信息
  hostnamectl                显示主机名、系统版本等信息"
}

# ============================================================
#  11. 压缩与归档
# ============================================================
linux_show_archive() {
    linux_show_cmds "压缩与归档" \
"${GREEN}tar${NC}           打包和压缩
  tar -cvf archive.tar dir/     打包目录为 tar（不压缩）
  tar -czvf archive.tar.gz dir/ 打包并用 gzip 压缩
  tar -cjvf archive.tar.bz2 dir/ 打包并用 bzip2 压缩
  tar -xvf archive.tar          解包
  tar -xzvf archive.tar.gz      解压 tar.gz
  tar -xjvf archive.tar.bz2     解压 tar.bz2
  tar -xzvf archive.tar.gz -C /path  解压到指定目录
  tar -tvf archive.tar          查看包内容（不解压）

${GREEN}gzip / gunzip${NC}
  gzip file                  压缩文件（生成 .gz）
  gunzip file.gz             解压
  gzip -d file.gz            解压
  gzip -l file.gz            查看压缩比

${GREEN}bzip2 / bunzip2${NC}
  bzip2 file                 压缩（比 gzip 压缩率更高，速度更慢）
  bunzip2 file.bz2           解压

${GREEN}xz${NC}
  xz file                    压缩（高压缩率，较慢）
  xz -d file.xz              解压
  unxz file.xz               解压

${GREEN}zip / unzip${NC}
  zip -r archive.zip dir/     压缩目录为 zip
  zip file.zip file           压缩单个文件
  unzip archive.zip           解压 zip 文件
  unzip archive.zip -d dir    解压到指定目录
  unzip -l archive.zip        查看 zip 内容
  zip -e archive.zip files    创建加密 zip

${GREEN}7z / 7za${NC}     （需安装 p7zip）
  7z a archive.7z dir/        压缩为 7z 格式
  7z x archive.7z             解压 7z 文件
  7za a archive.zip dir/      也可处理 zip 等格式

${GREEN}zcat / zless / zgrep${NC} 直接查看压缩文件内容
  zcat file.gz               查看压缩文件内容（等效于 gunzip -c）
  zgrep pattern file.gz      在压缩文件中搜索"
}

# ============================================================
#  12. 软件包管理
# ============================================================
linux_show_package() {
    linux_show_cmds "软件包管理" \
"========== Debian/Ubuntu (apt) ==========
${GREEN}apt update${NC}            更新软件源缓存
${GREEN}apt upgrade${NC}           升级所有可升级的软件包
${GREEN}apt install pkg${NC}       安装软件包
${GREEN}apt remove pkg${NC}        卸载软件包（保留配置文件）
${GREEN}apt purge pkg${NC}         彻底卸载软件包（删除配置）
${GREEN}apt autoremove${NC}        自动卸载不需要的依赖
${GREEN}apt search keyword${NC}    搜索软件包
${GREEN}apt show pkg${NC}          显示软件包详细信息
${GREEN}apt list --installed${NC}  列出已安装的软件包
${GREEN}dpkg -i deb_file${NC}      安装本地 .deb 文件
${GREEN}dpkg -l${NC}              列出所有已安装包（dpkg 方式）
${GREEN}dpkg -L pkg${NC}           查看软件包安装了哪些文件

========== RHEL/CentOS/Fedora (dnf/yum) ==========
${GREEN}dnf install pkg${NC}       安装软件包
${GREEN}dnf update${NC}            升级系统
${GREEN}dnf remove pkg${NC}        卸载软件包
${GREEN}dnf search keyword${NC}    搜索软件包
${GREEN}dnf info pkg${NC}          显示软件包信息
${GREEN}yum install pkg${NC}       安装软件包（旧版）
${GREEN}yum update${NC}            升级（旧版）
${GREEN}rpm -ivh rpm_file${NC}     安装本地 .rpm 文件
${GREEN}rpm -qa${NC}              列出所有已安装的 RPM 包

========== Arch Linux (pacman) ==========
${GREEN}pacman -S pkg${NC}         安装软件包
${GREEN}pacman -Syu${NC}          全面系统更新
${GREEN}pacman -R pkg${NC}         卸载软件包
${GREEN}pacman -Rs pkg${NC}        卸载包及其依赖
${GREEN}pacman -Ss keyword${NC}    搜索软件包
${GREEN}pacman -Qs keyword${NC}    在已安装包中搜索

========== Snap / Flatpak / AppImage ==========
${GREEN}snap install pkg${NC}      安装 snap 包
${GREEN}snap list${NC}            列出已安装的 snap 包
${GREEN}flatpak install app${NC}   安装 flatpak 应用
${GREEN}flatpak list${NC}         列出已安装的 flatpak
chmod +x app.AppImage            运行 AppImage 文件前先赋予执行权限"
}

# ============================================================
#  13. SSH 与远程连接
# ============================================================
linux_show_ssh() {
    linux_show_cmds "SSH 与远程连接" \
"${GREEN}ssh${NC}            SSH 远程连接
  ssh user@host               使用密码连接远程服务器
  ssh -p 2222 user@host       指定端口连接
  ssh -i key.pem user@host    使用密钥文件连接
  ssh -J jumpuser@jump host   跳板机连接（Jump Host）
  ssh -v user@host            调试模式（显示详细信息）

${GREEN}ssh-keygen${NC}    生成 SSH 密钥对
  ssh-keygen -t rsa -b 4096   生成 4096 位 RSA 密钥
  ssh-keygen -t ed25519       生成 Ed25519 密钥（推荐）
  ssh-keygen -R hostname      移除已知主机记录

${GREEN}ssh-copy-id${NC}   复制公钥到远程服务器
  ssh-copy-id user@host       将本地公钥添加到远程 authorized_keys

${GREEN}ssh-agent / ssh-add${NC} SSH 密钥管理器
  eval "$(ssh-agent -s)"      启动 SSH 代理
  ssh-add ~/.ssh/id_ed25519   将私钥添加到代理
  ssh-add -l                  列出代理中的密钥

${GREEN}~/.ssh/config${NC}   SSH 配置文件（简化连接）
  配置示例:
  Host myserver
    HostName 192.168.1.100
    Port 2222
    User myuser
    IdentityFile ~/.ssh/mykey
  保存后可直接使用: ssh myserver

${GREEN}sftp${NC}          SSH 文件传输
  sftp user@host              交互式文件传输
  get remote_file             下载文件
  put local_file              上传文件

${GREEN}rsync over SSH${NC}
  rsync -avz -e ssh src/ user@host:/dst/  通过 SSH 同步文件

${GREEN}autossh${NC}      自动重连 SSH（需安装）
  autossh -M 0 -o "ServerAliveInterval 30" -NR 8080:localhost:80 user@host
  创建持久的反向隧道，断开后自动重连

${GREEN}SSH 隧道${NC}
  # 本地端口转发（将远程端口映射到本地）
  ssh -L 8080:localhost:80 user@host
  # 远程端口转发（将本地端口暴露到远程）
  ssh -R 8080:localhost:80 user@host
  # 动态转发 (SOCKS 代理)
  ssh -D 1080 user@host"
}

# ============================================================
#  14. 定时任务
# ============================================================
linux_show_cron() {
    linux_show_cmds "定时任务" \
"${GREEN}crontab${NC}        管理定时任务
  crontab -l                 列出当前用户的定时任务
  crontab -e                 编辑定时任务（默认使用 vi）
  crontab -r                 删除所有定时任务
  crontab -u user -l         查看指定用户的定时任务（需 root）

  格式: 分 时 日 月 周 命令
  示例:
  0 6 * * * /script.sh       每天早上 6:00 执行
  */5 * * * * /script.sh     每5分钟执行一次
  0 2 * * 1 /script.sh       每周一凌晨 2:00 执行
  0 0 1 * * /script.sh       每月1号午夜执行
  0 9-17 * * 1-5 /script.sh  工作日9点到17点每小时执行
  @daily /script.sh          每天执行（等效 0 0 * * *）
  @reboot /script.sh         系统启动后执行

${GREEN}systemd 定时器${NC}
  systemctl list-timers      列出所有 systemd 定时器
  # 创建 .timer 和 .service 文件实现更灵活的定时任务
  # 位于 /etc/systemd/system/ 目录

${GREEN}at${NC}          一次性定时任务
  at now + 1 hour             一小时后执行
  at 15:00                    下午3点执行
  atq                         查看等待中的任务
  atrm job_id                 删除指定任务
  Ctrl+D                      输入完成后按 Ctrl+D 提交

${GREEN}anacron${NC}     补执行未运行的定时任务（适合非7x24系统）
  anacron -f                  强制执行所有任务
  anacron -u                  更新任务时间戳"
}

# ============================================================
#  15. 搜索与查找
# ============================================================
linux_show_search() {
    linux_show_cmds "搜索与查找" \
"${GREEN}find${NC}         在目录树中查找文件
  find /path -name 'file'     按文件名查找
  find /path -iname 'file'    忽略大小写查找
  find /path -type f          只查找文件
  find /path -type d          只查找目录
  find /path -size +100M      查找大于 100MB 的文件
  find /path -mtime -7        查找7天内修改过的文件
  find /path -mtime +30       查找30天前修改的文件
  find /path -perm 644        查找指定权限的文件
  find /path -user user       查找属于某用户的文件
  find /path -name '*.log' -exec rm {} \\;  查找并删除日志文件
  find /path -name '*.jpg' -mtime +90 | xargs rm  查找90天前的 jpg 并删除

${GREEN}locate${NC}       快速查找文件（基于数据库，需 updatedb）
  locate file                 按名称快速搜索（比 find 快）
  locate -i file              忽略大小写
  sudo updatedb               更新 locate 数据库

${GREEN}which${NC}       查找命令的绝对路径
  which python                显示 python 命令所在路径

${GREEN}whereis${NC}      查找命令及其文档路径
  whereis ls                  显示命令、源码和 man 手册路径

${GREEN}type${NC}       判断命令是内部命令还是外部命令
  type command                显示命令类型（alias/builtin/file 等）

${GREEN}man${NC}         查看命令手册
  man command                 查看命令的详细帮助文档
  man -k keyword              搜索手册页关键字

${GREEN}apropos${NC}     搜索命令描述
  apropos keyword             在手册页描述中搜索关键字

${GREEN}whatis${NC}      显示命令简短描述
  whatis command              一行显示命令功能"
}

# ============================================================
#  16. 系统管理
# ============================================================
linux_show_sysadmin() {
    linux_show_cmds "系统管理" \
"${GREEN}shutdown${NC}      关机/重启
  shutdown -h now             立即关机
  shutdown -h +30             30分钟后关机
  shutdown -r now             立即重启
  shutdown -r 23:00           晚上11点重启

${GREEN}reboot / halt / poweroff${NC}
  reboot                      重启系统
  halt                        停止系统
  poweroff                    关闭系统电源

${GREEN}init${NC}        切换运行级别
  init 0                      关机
  init 6                      重启
  init 1                      单用户模式（维护模式）

${GREEN}systemctl${NC}     systemd 系统管理
  systemctl reboot            重启
  systemctl poweroff          关机
  systemctl suspend           挂起（睡眠）
  systemctl hibernate         休眠（写入磁盘）
  systemctl rescue            进入救援模式
  systemctl default           切换到默认运行级别

${GREEN}journalctl${NC}    查看 systemd 日志
  journalctl                  查看所有日志
  journalctl -u nginx         查看特定服务的日志
  journalctl -f               实时跟踪日志（类似 tail -f）
  journalctl --since "1 hour ago"  查看最近1小时日志
  journalctl -p err           查看错误级别日志
  journalctl --disk-usage     查看日志占用磁盘大小
  journalctl --vacuum-time=7d  清理7天前的日志

${GREEN}dmesg${NC}       查看内核环缓冲区消息
  dmesg                       显示内核启动/运行消息
  dmesg -T                    显示人类可读的时间戳

${GREEN}timedatectl${NC}   日期时间与时区设置
  timedatectl                 查看当前时间/时区
  timedatectl list-timezones  列出所有时区
  timedatectl set-timezone Asia/Shanghai  设置时区

${GREEN}locale${NC}      查看/设置系统语言环境
  locale                      显示当前语言环境
  locale -a                   列出所有可用 locale
  localectl set-locale LANG=zh_CN.UTF-8  设置中文语言环境

${GREEN}ldconfig${NC}    配置动态链接库
  ldconfig                    更新动态链接库缓存
  ldconfig -p                 查看已注册的动态库

${GREEN}ulimit${NC}      查看/设置系统资源限制
  ulimit -a                   查看所有限制
  ulimit -n 65535             设置最大打开文件数

${GREEN}sysctl${NC}      运行时修改内核参数
  sysctl -a                   查看所有内核参数
  sysctl net.ipv4.ip_forward=1  开启 IP 转发
  sysctl -p                   从 /etc/sysctl.conf 加载设置"
}

# ============================================================
#  17. Docker
# ============================================================
linux_show_docker() {
    linux_show_cmds "Docker" \
"${GREEN}docker run${NC}              运行容器
  docker run nginx                   运行 nginx 容器
  docker run -d nginx                后台运行
  docker run -it ubuntu bash         交互式运行
  docker run -p 8080:80 nginx        端口映射
  docker run -v /host:/container nginx  挂载卷
  docker run --name mynginx nginx    指定容器名
  docker run --restart=always nginx  设置自动重启

${GREEN}docker ps${NC}              查看容器
  docker ps                     查看运行中的容器
  docker ps -a                  查看所有容器（含停止的）

${GREEN}docker images${NC}          查看镜像
  docker images                 列出本地镜像
  docker images -a              列出所有镜像

${GREEN}docker pull / push${NC}
  docker pull nginx             拉取镜像
  docker push user/image:tag    推送镜像

${GREEN}docker build${NC}           构建镜像
  docker build -t myimage .     从 Dockerfile 构建
  docker build -t myimage:v1 .  构建并指定标签

${GREEN}docker stop / start / restart${NC}
  docker stop container_id      停止容器
  docker start container_id     启动已停止的容器
  docker restart container_id   重启容器

${GREEN}docker exec${NC}            进入容器
  docker exec -it container bash  在运行中的容器中执行命令

${GREEN}docker logs${NC}            查看容器日志
  docker logs container_id      查看日志
  docker logs -f container_id   实时跟踪日志
  docker logs --tail 100 container_id  只查看最后100行

${GREEN}docker rm / rmi${NC}
  docker rm container_id        删除容器
  docker rm $(docker ps -aq)    删除所有容器
  docker rmi image_id           删除镜像
  docker system prune           清理未使用的容器/镜像/网络

${GREEN}docker-compose${NC}
  docker-compose up -d          后台启动所有服务
  docker-compose down           停止并移除所有容器
  docker-compose logs -f        实时查看所有服务日志
  docker-compose ps             查看服务状态

${GREEN}docker network${NC}
  docker network ls             列出网络
  docker network create mynet   创建网络
  docker network connect mynet container  连接到网络

${GREEN}docker volume${NC}
  docker volume ls              列出卷
  docker volume create volname  创建卷
  docker volume inspect volname 查看卷详情"
}

# ============================================================
#  18. Git
# ============================================================
linux_show_git() {
    linux_show_cmds "Git" \
"${GREEN}git init${NC}                初始化仓库
  git init                     在当前目录创建 Git 仓库

${GREEN}git clone${NC}              克隆仓库
  git clone url                克隆远程仓库
  git clone -b branch url      克隆指定分支

${GREEN}git add / commit${NC}
  git add file                 暂存文件
  git add .                    暂存所有修改
  git commit -m 'message'      提交暂存区
  git commit -am 'message'     暂存所有修改并提交（仅跟踪过的文件）
  git commit --amend           修改最后一次提交信息

${GREEN}git status / log${NC}
  git status                   查看工作区状态
  git log                      查看提交历史
  git log --oneline            简洁显示
  git log --graph              图形化显示分支
  git log -p                   显示每次提交的差异

${GREEN}git branch${NC}
  git branch                   列出本地分支
  git branch -a                列出所有分支（含远程）
  git branch name              创建分支
  git branch -d name           删除分支
  git branch -m old new        重命名分支

${GREEN}git checkout / switch${NC}
  git checkout branch          切换分支
  git checkout -b branch       创建并切换分支
  git switch branch            切换分支（新版）
  git switch -c branch         创建并切换（新版）

${GREEN}git merge / rebase${NC}
  git merge branch             合并分支到当前分支
  git rebase branch            变基（历史更干净）
  git rebase -i HEAD~3         交互式 rebase 最近3次提交

${GREEN}git pull / push${NC}
  git pull                     拉取并合并远程更改
  git pull --rebase            拉取并以 rebase 方式合并
  git push                     推送到远程
  git push -u origin branch    推送并建立追踪关系
  git push origin --delete branch  删除远程分支

${GREEN}git remote${NC}
  git remote -v                查看远程仓库
  git remote add origin url    添加远程仓库

${GREEN}git diff / stash${NC}
  git diff                     查看工作区与暂存区的差异
  git diff --cached            查看暂存区与上次提交的差异
  git stash                    暂存当前修改
  git stash pop                恢复暂存的修改
  git stash list               查看暂存列表

${GREEN}git reset / revert${NC}
  git reset HEAD file          取消暂存
  git reset --soft HEAD~1      撤销提交但保留修改
  git reset --hard HEAD~1      完全撤销提交和修改（⚠️慎用）
  git revert commit_id         通过新提交撤销某次提交（更安全）

${GREEN}git tag${NC}
  git tag                      列出标签
  git tag v1.0                 创建标签
  git push origin --tags       推送所有标签到远程

${GREEN}git config${NC}
  git config --global user.name 'name'  设置用户名
  git config --global user.email 'email'  设置邮箱
  git config --global core.editor vim   设置编辑器
  git config --global alias.co checkout  设置别名

${GREEN}.gitignore${NC}
  在项目根目录创建 .gitignore 文件，写入不需要跟踪的文件模式"
}

# ============================================================
#  19. 防火墙 (UFW)
# ============================================================
linux_show_ufw() {
    linux_show_cmds "防火墙 (UFW)" \
"${GREEN}ufw enable${NC}             启用防火墙
${GREEN}ufw disable${NC}            禁用防火墙
${GREEN}ufw status${NC}             查看防火墙状态
${GREEN}ufw status verbose${NC}     查看详细状态

${GREEN}ufw allow${NC}
  ufw allow 22               开放 22 端口
  ufw allow 80/tcp           开放 TCP 80 端口
  ufw allow 3000:4000/tcp    开放端口范围
  ufw allow from 192.168.1.0/24  允许某个网段
  ufw allow from 192.168.1.100 to any port 3306  允许特定 IP 访问特定端口

${GREEN}ufw deny${NC}
  ufw deny 23                拒绝 23 端口
  ufw deny from 10.0.0.0/8   拒绝某个网段

${GREEN}ufw delete${NC}
  ufw delete allow 80        删除规则
  ufw delete 2               按编号删除

${GREEN}ufw default${NC}
  ufw default deny incoming  默认拒绝所有入站
  ufw default allow outgoing 默认允许所有出站

${GREEN}ufw logging${NC}
  ufw logging on             开启日志
  ufw logging off            关闭日志

${GREEN}ufw reset${NC}             重置所有规则

${GREEN}iptables 基础${NC}
  iptables -L -n -v           列出规则及流量统计
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT  允许 SSH
  iptables -P INPUT DROP      默认丢弃入站包（⚠️慎用，先放行SSH）
  iptables-save > rules.v4    导出规则
  iptables-restore < rules.v4 导入规则"
}

# ============================================================
#  20. Sed & Awk
# ============================================================
linux_show_sed_awk() {
    linux_show_cmds "Sed & Awk" \
"========== sed (流编辑器) ==========
  sed 's/old/new/g' file          全局替换文本
  sed -i 's/old/new/g' file       直接修改文件
  sed '/pattern/d' file           删除匹配模式的行
  sed -n '5,10p' file             显示第5到10行
  sed -i '/^$/d' file             删除空行
  sed -i '/^#/d' file             删除注释行（以#开头）
  sed 's/  */ /g' file            将多个空格压缩为1个
  sed -n '/error/,+5p' file       从"error"行起显示5行
  sed '1i\\#!/bin/bash' file      在文件首行插入内容
  sed 's/.*/&,modified/' file     在每行后追加文本
  sed -n '1~2p' file              打印奇数行

========== awk (文本分析工具) ==========
  awk '{print \$1}' file          打印第一列（默认空格分隔）
  awk -F: '{print \$1,\$3}' file  指定分隔符(:)并打印列
  awk '{print \$NF}' file         打印最后一列
  awk 'NR==5{print}' file         打印第5行
  awk '/error/{print}' file       打印包含"error"的行
  awk '{sum+=\$1} END {print sum}' file  计算第一列总和
  awk 'length(\$0)>20' file      只显示超过20个字符的行
  awk '{\$2="";print}' file       删除第二列
  awk '!seen[\$0]++' file         去重（保留首次出现的行）

  # 更多组合用法
  awk -F: '{printf "%-10s %s\\n", \$1, \$NF}' /etc/passwd  格式化输出
  awk 'BEGIN {count=0} /error/ {count++} END {print count}' file  统计错误出现次数
  awk '\$3>50 && \$3<100' file    按条件过滤（第3列在50-100之间）

========== 组合使用 ==========
  ps aux | awk '{print \$11}' | sort | uniq -c | sort -rn | head  统计运行中的进程
  cat log | grep ERROR | awk '{print \$1,\$2,\$NF}'  提取错误日志的关键字段
  find . -name '*.log' | xargs sed -i '/debug/d'  在所有日志中删除包含debug的行"
}

# ============================================================
#  搜索命令
# ============================================================
linux_search_cmd() {
    print_header
    echo -e "${YELLOW}输入关键词搜索命令 (如: grep, sort, Docker, SSH):${NC}"
    echo -n "搜索: "
    read -r keyword
    echo ""
    echo -e "${WHITE}搜索结果:${NC}"

    local found=0
    # 临时保存所有分类的输出并搜索
    local tmpfile=$(mktemp)
    for func in linux_show_file_ops linux_show_dir_ops linux_show_content_view linux_show_text_ops \
                linux_show_permissions linux_show_user_mgmt linux_show_process linux_show_sysinfo \
                linux_show_disk linux_show_network linux_show_archive linux_show_package \
                linux_show_ssh linux_show_cron linux_show_search linux_show_sysadmin \
                linux_show_docker linux_show_git linux_show_ufw show_sed_awk; do
        $func > "$tmpfile" 2>/dev/null < /dev/null
        if grep -qi "$keyword" "$tmpfile" 2>/dev/null; then
            grep -i --color=always "$keyword" "$tmpfile"
            found=1
        fi
    done
    rm -f "$tmpfile"

    if [ "$found" -eq 0 ]; then
        echo -e "${RED}未找到包含 \"$keyword\" 的命令${NC}"
    fi
    echo ""
    echo -e "${CYAN}按 Enter 返回菜单${NC}"
    read -r
}

# ============================================================
#  随机显示一条命令
# ============================================================
linux_random_cmd() {
    print_header
    echo -e "${YELLOW}◆ 随机命令${NC}"
    echo ""
    local tmpfile=$(mktemp)
    # 收集所有命令条目
    for func in linux_show_file_ops linux_show_dir_ops linux_show_content_view linux_show_text_ops \
                linux_show_permissions linux_show_user_mgmt linux_show_process linux_show_sysinfo \
                linux_show_disk linux_show_network linux_show_archive linux_show_package \
                linux_show_ssh linux_show_cron linux_show_search linux_show_sysadmin \
                linux_show_docker linux_show_git linux_show_ufw show_sed_awk; do
        $func >> "$tmpfile" 2>/dev/null < /dev/null
    done

    # 提取所有以转义序列开头的行（命令条目）并随机选一条
    grep -P '^\033' "$tmpfile" | shuf -n 1 | while read -r line; do
        echo -e "$line"
    done | head -5

    rm -f "$tmpfile"
    echo ""
    echo -e "${CYAN}按 Enter 返回菜单${NC}"
    read -r
}

# ============================================================
#  更新函数（从 GitHub 下载最新版）
# ============================================================
linux_update_script() {
    print_header
    echo -e "${YELLOW}◆ 从 GitHub 更新脚本${NC}"
    echo ""
    local target
    target="$(realpath "$0" 2>/dev/null || readlink -f "$0" 2>/dev/null || echo "/usr/local/bin/ML.sh")"

    local github_url="https://raw.githubusercontent.com/surfultra/jianhuo/main/ML.sh"

    echo -e "当前路径: ${CYAN}$target${NC}"
    echo -e "下载地址: ${CYAN}$github_url${NC}"
    echo ""

    if [ ! -w "$(dirname "$target" 2>/dev/null)" ]; then
        echo -e "${YELLOW}需要 sudo 权限来更新脚本${NC}"
        if command -v sudo &>/dev/null; then
            sudo curl -sSL "$github_url" -o "$target" && sudo chmod +x "$target"
        else
            echo -e "${RED}错误: 无写入权限且无 sudo${NC}"
            echo -n "按 Enter 返回..."
            read -r
            return
        fi
    else
        if command -v curl &>/dev/null; then
            curl -sSL "$github_url" -o "$target"
        elif command -v wget &>/dev/null; then
            wget -q "$github_url" -O "$target"
        else
            echo -e "${RED}错误: 需要 curl 或 wget${NC}"
            echo -n "按 Enter 返回..."
            read -r
            return
        fi
    fi

    if [ $? -eq 0 ]; then
        chmod +x "$target" 2>/dev/null
        echo -e "${GREEN}✓ 更新成功！${NC}"
    else
        echo -e "${RED}✗ 更新失败，请检查网络连接${NC}"
    fi
    echo ""
    echo -n "按 Enter 返回..."
    read -r
}

# ============================================================
#  安装函数
# ============================================================
linux_install_script() {
    local script_path
    # 兼容 macOS 和 Linux
    if command -v realpath &>/dev/null; then
        script_path="$(realpath "$0")"
    else
        script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
    fi

    if [ -f ~/.bashrc ]; then
        if ! grep -q "alias m=" ~/.bashrc 2>/dev/null; then
            echo "alias m='$script_path'" >> ~/.bashrc
            echo -e "${GREEN}✓ 已将别名 m 添加到 ~/.bashrc${NC}"
        else
            echo -e "${YELLOW}别名 m 已存在，跳过${NC}"
        fi
    fi

    if [ -f ~/.zshrc ]; then
        if ! grep -q "alias m=" ~/.zshrc 2>/dev/null; then
            echo "alias m='$script_path'" >> ~/.zshrc
            echo -e "${GREEN}✓ 已将别名 m 添加到 ~/.zshrc${NC}"
        else
            echo -e "${YELLOW}别名 m 已存在，跳过${NC}"
        fi
    fi

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}安装完成！请执行以下命令使其生效:${NC}"
    echo -e "${YELLOW}  source ~/.bashrc   (如果你使用 bash)${NC}"
    echo -e "${YELLOW}  或${NC}"
    echo -e "${YELLOW}  source ~/.zshrc    (如果你使用 zsh)${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${WHITE}然后直接输入 m 即可调出本手册${NC}"
    echo ""
    echo -n "按 Enter 继续..."
    read -r
}

# ---------------------------------------------------------
#  Linux 命令大全主菜单
# ---------------------------------------------------------
linux_cmd_menu() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ Linux 命令大全 ━━━${NC}\n"
        echo -e "  ${GREEN} 1${NC}  文件操作          ${GREEN} 2${NC}  目录管理"
        echo -e "  ${GREEN} 3${NC}  文件内容查看      ${GREEN} 4${NC}  文本处理"
        echo -e "  ${GREEN} 5${NC}  权限管理          ${GREEN} 6${NC}  用户管理"
        echo -e "  ${GREEN} 7${NC}  进程管理          ${GREEN} 8${NC}  系统信息"
        echo -e "  ${GREEN} 9${NC}  磁盘与存储        ${GREEN}10${NC}  网络管理"
        echo -e "  ${GREEN}11${NC}  压缩与归档        ${GREEN}12${NC}  软件包管理"
        echo -e "  ${GREEN}13${NC}  SSH 与远程连接    ${GREEN}14${NC}  定时任务"
        echo -e "  ${GREEN}15${NC}  搜索与查找        ${GREEN}16${NC}  系统管理"
        echo -e "  ${GREEN}17${NC}  Docker            ${GREEN}18${NC}  Git"
        echo -e "  ${GREEN}19${NC}  防火墙(UFW)       ${GREEN}20${NC}  Sed & Awk"
        echo
        echo -e "  ${YELLOW} s${NC}  搜索命令关键字"
        echo -e "  ${YELLOW} r${NC}  随机显示一条命令"
        echo -e "  ${YELLOW} b${NC}  返回主菜单"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-20/s/r/b]:${NC} ")" choice
        case $choice in
            1) linux_show_file_ops ;;
            2) linux_show_dir_ops ;;
            3) linux_show_content_view ;;
            4) linux_show_text_ops ;;
            5) linux_show_permissions ;;
            6) linux_show_user_mgmt ;;
            7) linux_show_process ;;
            8) linux_show_sysinfo ;;
            9) linux_show_disk ;;
            10) linux_show_network ;;
            11) linux_show_archive ;;
            12) linux_show_package ;;
            13) linux_show_ssh ;;
            14) linux_show_cron ;;
            15) linux_show_search ;;
            16) linux_show_sysadmin ;;
            17) linux_show_docker ;;
            18) linux_show_git ;;
            19) linux_show_ufw ;;
            20) linux_show_sed_awk ;;
            s|S) linux_search_cmd ;;
            r|R) linux_random_cmd ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

# 11. 主题设置
# ============================================================
theme_setting() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 主题设置 ━━━${NC}\n"

        echo -e "${TITLE}当前主题: ${BORDER}$CURRENT_THEME${NC}\n"

        echo -e "  ${GREEN}1.${NC}  🌊 海洋蓝（默认）"
        echo -e "  ${GREEN}2.${NC}  🌅 落日暖阳"
        echo -e "  ${GREEN}3.${NC}  🌃 暗夜霓虹"
        echo
        echo -e "  ${GREEN}4.${NC}  👁 预览效果"
        echo
        echo -e "  ${YELLOW}b.${NC}  返回主菜单"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-4/b]:${NC} ")" choice

        case $choice in
            1) apply_theme "default"; echo -e "${GREEN}主题已切换为: 海洋蓝${NC}"; pause ;;
            2) apply_theme "sunset"; echo -e "${GREEN}主题已切换为: 落日暖阳${NC}"; pause ;;
            3) apply_theme "neon"; echo -e "${GREEN}主题已切换为: 暗夜霓虹${NC}"; pause ;;
            4) theme_preview ;;
            b|B) break ;;
            *) echo -e "${RED}无效选项${NC}"; pause ;;
        esac
    done
}

theme_preview() {
    print_header
    echo -e "${TITLE}━━━ 主题预览 — 当前: ${BORDER}${CURRENT_THEME}${TITLE} ━━━${NC}\n"

    echo -e "${BORDER}────────────────────────────────────────${NC}"
    echo -e "${TITLE}   标题文字效果 (TITLE)${NC}"
    echo -e "${WHITE}   白色文字效果 (WHITE)${NC}"
    echo -e "${RED}   红色/错误提示 (RED)${NC}"
    echo -e "${GREEN}   绿色/成功提示 (GREEN)${NC}"
    echo -e "${YELLOW}   黄色/警告提示 (YELLOW)${NC}"
    echo -e "${BLUE}   蓝色/交互提示 (BLUE)${NC}"
    echo -e "${CYAN}   青色/信息文字 (CYAN)${NC}"
    echo -e "${PURPLE}   紫色/特殊标记 (PURPLE)${NC}"
    echo -e "${BORDER}   边框/分割线 (BORDER)${NC}"
    echo -e "${BORDER}────────────────────────────────────────${NC}"

    echo
    echo -e "${TITLE}▶ 菜单演示${NC}"
    echo -e "  ${GREEN}1.${NC}  系统管理"
    echo -e "  ${GREEN}2.${NC}  网络工具"
    echo -e "  ${GREEN}3.${NC}  安全优化"
    echo
    echo -e "  ${YELLOW}b.${NC}  返回"
    echo
    echo -e "${GREEN}✔${NC} 操作成功"
    echo -e "${RED}✘${NC} 操作失败"
    echo -e "${YELLOW}⚠${NC} 操作警告"
    echo
    echo -e "${BORDER}────────────────────────────────────────${NC}\n"

    read -r -p "$(echo -e "${BLUE}按回车键返回主题设置...${NC}")"
}

# ============================================================
# 主菜单
# ============================================================
main_menu() {
    while true; do
        print_header
        echo -e "${WHITE}━━━ 主菜单 ━━━${NC}\n"

        echo -e "  ${GREEN}1.${NC}   系统管理"
        echo -e "  ${GREEN}2.${NC}   常用工具"
        echo -e "  ${GREEN}3.${NC}   网络工具"
        echo -e "  ${GREEN}4.${NC}   安全优化"
        echo -e "  ${GREEN}5.${NC}   开发者工具"
        echo -e "  ${GREEN}6.${NC}   Docker 管理"
        echo -e "  ${GREEN}7.${NC}   监控日志"
        echo -e "  ${GREEN}8.${NC}   备份恢复"
        echo -e "  ${GREEN}9.${NC}   卸载工具/应用"
        echo -e "  ${PURPLE}10.${NC}  Linux 命令大全"
        echo -e "  ${PURPLE}11.${NC}  主题设置"
        echo
        echo -e "  ${YELLOW}G.${NC}  更新脚本（GitHub）"
        echo -e "  ${PURPLE}U.${NC}  卸载本脚本"
        echo -e "  ${RED}Q.${NC}  退出"
        echo
        read -r -p "$(echo -e "${BLUE}请选择 [1-11/G/U/Q]:${NC} ")" choice

        case $choice in
            1) system_management ;;
            2) common_tools ;;
            3) network_tools ;;
            4) security_optimization ;;
            5) developer_tools ;;
            6) docker_management ;;
            7) monitor_logs ;;
            8) backup_recovery ;;
            9) uninstall_tools ;;
            10|c|C) linux_cmd_menu ;;
            11|t|T) theme_setting ;;
            G|g)
                echo -e "${YELLOW}▶ 检查更新...${NC}"
                echo -e "${YELLOW}当前版本: v${SCRIPT_VERSION}${NC}"
                local remote_ver=$(curl -s --max-time 5 "https://raw.githubusercontent.com/surfultra/linux-tools/main/tools-m.sh" | grep -oP "SCRIPT_VERSION=\"\K[^\"]+" 2>/dev/null)
                if [[ -n "$remote_ver" ]]; then
                    echo -e "${GREEN}远程版本: v${remote_ver}${NC}"
                    if [[ "$remote_ver" != "$SCRIPT_VERSION" ]]; then
                        echo -e "${YELLOW}发现新版本！${NC}"
                        read -r -p "$(echo -e "${BLUE}是否更新？(y/n):${NC} ")" do_update
                        if [[ "$do_update" =~ ^[Yy]$ ]]; then
                            local script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
                            curl -sL "https://raw.githubusercontent.com/surfultra/linux-tools/main/tools-m.sh" -o "$script_path" 2>/dev/null
                            echo -e "${GREEN}更新完成！请重新加载脚本${NC}"
                            pause
                            exec bash
                        fi
                    else
                        echo -e "${GREEN}已是最新版本${NC}"
                    fi
                else
                    echo -e "${YELLOW}无法检查更新，请访问:${NC}"
                    echo -e "  https://github.com/surfultra/linux-tools"
                fi
                pause
                ;;
            U|u)
                echo -e "${PURPLE}━━━ 卸载脚本 ━━━${NC}\n"
                echo -e "${RED}将删除本脚本文件${NC}"
                read -r -p "$(echo -e "${BLUE}确认卸载？(y/n):${NC} ")" confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    local script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
                    rm -f "$script_path" 2>/dev/null
                    # 移除 alias
                    sed -i '/alias m=/d' ~/.bashrc 2>/dev/null
                    sed -i '/alias m=/d' ~/.zshrc 2>/dev/null
                    echo -e "${GREEN}脚本已卸载${NC}"
                    echo -e "${YELLOW}请重新打开终端或执行 exec bash 刷新${NC}"
                    exit 0
                fi
                pause
                ;;
            Q|q)
                echo -e "${GREEN}感谢使用，再见！${NC}"
                break
                ;;
            *)
                echo -e "${RED}无效选项${NC}"
                pause
                ;;
        esac
    done
}

# ============================================================
# 入口 — 检测是否 source 方式执行
# ============================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 直接执行模式：启动交互式 bash，按 Q 后回到这个新 shell
    # 这样即使退出脚本，也不会断开 SSH 连接
    SHELL_NAME=$(basename "$SHELL")
    m() {
        main_menu
    }
    main_menu
    # 启动一个新的交互式 shell（不退出 SSH 会话）
    exec "$SHELL"
else
    # source 模式：定义 m 函数
    m() {
        main_menu
    }
    echo -e "${GREEN}工具箱已加载！输入 m 调用${NC}"
fi
