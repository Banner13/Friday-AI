#!/bin/bash

set -e 

arm64_url="https://links.fortinet.com/forticlient/debarm/vpnagent"
amd64_url="https://links.fortinet.com/forticlient/deb/vpnagent"

ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    wget -O /tmp/forticlient_vpn.deb $amd64_url
elif [ "$ARCH" = "arm64" ]; then
    wget -O /tmp/forticlient_vpn.deb $arm64_url
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

sudo apt install -y -f /tmp/forticlient_vpn.deb || true
rm /tmp/forticlient_vpn.deb
echo "FortiClient VPN installed successfully."
echo "You can start FortiClient VPN using the command: forticlient"
echo "For more information, visit: https://www.fortinet.com/support/product-downloads"


