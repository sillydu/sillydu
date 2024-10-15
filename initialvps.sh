#!/bin/bash
# 检测是否root权限
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root."
    exec sudo bash "$0" "$@"
fi

function check_and_set_hostname() {
    current_hostname=$(hostname)
    if [ "$current_hostname"!= "hd.rollor.cafe" ]; then
        echo "Current hostname is not hd.rollor.cafe. Setting new hostname..."
        sudo hostnamectl set-hostname hd.rollor.cafe
        if [ $? -eq 0 ]; then
            echo "Hostname set to hd.rollor.cafe successfully."
        else
            echo "Failed to set hostname."
        fi
    else
        echo "Hostname is already hd.rollor.cafe."
    fi
}

function install_ufw_and_configure_ssh() {
    apt install ufw -y
    ufw allow 24172
    sed -i 's/Port 22/Port 24172/g' /etc/ssh/sshd_config
    /etc/init.d/ssh restart
    ufw enable
}

function enable_bbr() {
    is_bbr_enabled=$(sysctl net.ipv4.tcp_congestion_control | grep bbr | wc -l)
    if [ $is_bbr_enabled -eq 0 ]; then
        echo "BBR is not enabled. Enabling BBR..."
        sudo modprobe tcp_bbr
        echo 'net.core.default_qdisc=fq' | sudo tee -a /etc/sysctl.conf
        echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        if [ $? -eq 0 ]; then
            echo "BBR enabled successfully."
        else
            echo "Failed to enable BBR."
        fi
    else
        echo "BBR is already enabled."
    fi
}

function install_docker_and_compose() {
    apt install curl -y && curl -fsSL https://get.docker.com | bash -s docker
    apt install docker-compose-plugin docker-compose
    docker_version=$(docker --version)
    docker_compose_version=$(docker-compose version --short)
    echo "Docker version: $docker_version"
    echo "Docker Compose version: $docker_compose_version"
}

function update_and_clean() {
    apt update
    apt upgrade -y
    apt autoremove -y
    apt autoclean -y
}

echo "Starting automation script..."

check_and_set_hostname
echo "Press any key to continue..."
read -n 1 -s

install_ufw_and_configure_ssh
echo "Press any key to continue..."
read -n 1 -s

enable_bbr
echo "Press any key to continue..."
read -n 1 -s

install_docker_and_compose
echo "Press any key to continue..."
read -n 1 -s

update_and_clean

echo "Automation script completed successfully."
