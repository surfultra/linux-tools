#!/bin/bash
# Linux 系统管理工具箱 — 一键安装脚本
set -e

REPO_OWNER="surfultra"
REPO_NAME="linux-tools"
SCRIPT_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/tools-m.sh"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="tools-m.sh"

echo "======================================"
echo " Linux 系统管理工具箱 — 一键安装"
echo "======================================"
echo ""

# 检测 root
if [[ $EUID -eq 0 ]]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

echo "📥 下载脚本..."
if command -v curl &>/dev/null; then
    curl -sL "$SCRIPT_URL" -o "${INSTALL_DIR}/${SCRIPT_NAME}"
elif command -v wget &>/dev/null; then
    wget -q "$SCRIPT_URL" -O "${INSTALL_DIR}/${SCRIPT_NAME}"
else
    echo "❌ 需要 curl 或 wget"
    exit 1
fi

chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
echo "✅ 脚本已安装到 ${INSTALL_DIR}/${SCRIPT_NAME}"
echo ""

# 添加到 shell 配置
SHELL_RC=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_RC="$HOME/.bash_profile"
fi

if [[ -n "$SHELL_RC" ]]; then
    if ! grep -q "tools-m.sh" "$SHELL_RC" 2>/dev/null; then
        echo "source ${INSTALL_DIR}/${SCRIPT_NAME}" >> "$SHELL_RC"
        echo "✅ 已添加到 $SHELL_RC（输入 m 启动）"
    else
        echo "ℹ️  已在 $SHELL_RC 中存在，跳过"
    fi
fi

echo ""
echo "🎉 安装完成！"
echo ""
echo "📌 使用方法："
echo "   1. 执行 source ~/.bashrc（或重新打开终端）"
echo "   2. 输入 m 启动工具箱"
echo "   3. 或直接运行: bash ${INSTALL_DIR}/${SCRIPT_NAME}"
echo ""
echo "🔗 项目地址: https://github.com/${REPO_OWNER}/${REPO_NAME}"
