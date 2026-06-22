# 🛠 Linux 系统管理工具箱 (tools-m)

一键式 Linux 服务器管理脚本。输入 `m` 即可调出菜单，涵盖服务器运维的 9 大模块。

## ✨ 功能一览

| 模块 | 功能 |
|------|------|
| 1. 系统管理 | 系统信息、更新、清理、服务管理、用户管理、时区、主机名、SWAP、防火墙、SSH安全配置 |
| 2. 常用工具 | curl/wget/git/vim/htop/tmux 等 15 种工具多选安装 |
| 3. 网络工具 | 网络测速、端口检测、DNS配置、路由追踪、IP检测 |
| 4. 安全优化 | BBR加速、Fail2Ban、压力测试、系统内核调优 |
| 5. 开发者工具 | 一键安装 Docker/Node.js/Python/Java/数据库/Nginx |
| 6. Docker管理 | 容器管理、镜像拉取/删除、Docker清理 |
| 7. 监控日志 | 实时资源监控、日志查看、磁盘分析 |
| 8. 备份恢复 | 网站打包、数据库备份、定时任务管理 |
| 9. 卸载工具 | 列出已安装工具+系统应用+Docker容器，多选卸载 |
| 10. Linux 命令大全 | 20 类 500+ 条 Linux 常用命令中文速查，支持搜索和随机学习 |
| 11. 主题设置 | 海洋蓝/落日暖阳/暗夜霓虹 三种主题切换 |

## 🚀 一键安装

```bash
curl -sL https://raw.githubusercontent.com/surfultra/linux-tools/main/install.sh | bash
```

安装完成后，输入 `m` 即可启动工具箱。

## 📦 手动安装

```bash
# 下载脚本
wget -q https://raw.githubusercontent.com/surfultra/linux-tools/main/tools-m.sh -O /usr/local/bin/tools-m.sh
chmod +x /usr/local/bin/tools-m.sh

# 加载到 shell（bash）
echo "source /usr/local/bin/tools-m.sh" >> ~/.bashrc
source ~/.bashrc

# 如果使用 zsh
echo "source /usr/local/bin/tools-m.sh" >> ~/.zshrc
source ~/.zshrc
```

## 🖥 使用方式

```bash
# 直接运行
bash tools-m.sh

# 或者加载后输入 m（推荐）
source tools-m.sh
m
```
