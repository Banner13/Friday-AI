#!/bin/bash
# from https://docs.docker.com/engine/install/ubuntu/

set -e

# check user is't root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run as root."
    exit 1
fi

# check os is ubuntu
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo "This script only supports Ubuntu."
        exit 1
    fi
else
    echo "Cannot determine the operating system."
    exit 1
fi

sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Optionally, manage Docker as a non-root user:
sudo groupadd docker || true

# fix error when running in sudo 
sudo usermod -aG docker $USER || true


# modify default configuration file
# refer to https://docs.docker.com/engine/daemon/

sudo systemctl stop docker.service
sudo systemctl stop containerd.service

sudo mkdir -p /data/docker
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak || true
sudo tee /etc/docker/daemon.json <<EOF
{
  "data-root": "/data/docker-data"
}
EOF

sudo mkdir -p /data/containerd-data
sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.bak || true
sudo tee /etc/containerd/config.toml <<EOF
version = 2
root = "/data/containerd-data"
EOF

sudo systemctl start docker.service
sudo systemctl start containerd.service




