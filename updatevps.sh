#!/bin/bash
# 检测是否root权限
if [ "$EUID" -ne 0 ]; then
   echo "This script must be run as root."
   exec sudo bash "$0" "$@"
fi
# 定义 run_command 函数
function run_command() {
    local command="$1"
    echo "Executing: $command"
    if ! $command; then
        echo "Error executing command: $command"
        exit 1
    else
        echo "Command executed successfully: $command"
    fi
}
# 执行部分
run_command "apt update"
run_command "apt upgrade -y"
run_command "apt autoremove -y"
run_command "apt autoclean -y"
