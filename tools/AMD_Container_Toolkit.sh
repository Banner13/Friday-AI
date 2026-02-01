#!/bin/bash
# from https://instinct.docs.amd.com/projects/container-toolkit/en/latest/container-runtime/quick-start-guide.html

set -e

sudo apt-get install jq

sudo apt update || true

sudo usermod -a -G render,video $LOGNAME || true

sudo apt update && sudo apt install vim wget gpg

sudo mkdir --parents --mode=0755 /etc/apt/keyrings

wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amd-container-toolkit/apt/ noble main" | sudo tee /etc/apt/sources.list.d/amd-container-toolkit.list

sudo apt update

sudo apt install amd-container-toolkit

sudo amd-ctk runtime configure

sudo systemctl restart docker



# check nvidia runtime
# docker run --runtime=amd --gpus all -e AMD_VISIBLE_DEVICES=all rocm/dev-ubuntu-24.04 amd-smi monitor

