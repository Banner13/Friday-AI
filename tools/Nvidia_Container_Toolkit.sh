#!/bin/bash
# from https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

set -e

sudo apt-get update && sudo apt-get install -y --no-install-recommends curl gnupg2

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Optionally
# sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update

NVIDIA_CONTAINER_TOOLKIT_VERSION=1.18.2-1
sudo apt-get install -y \
    nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}

# Optionally configure
if [ -f /etc/docker/daemon.json ]; then
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
    
    # check daemon file
    cat /etc/docker/daemon.json
    # check nvidia runtime
    # docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

fi

if [ -f /etc/containerd/config.toml ]; then
    sudo nvidia-ctk runtime configure --runtime=containerd
    sudo systemctl restart containerd
fi


