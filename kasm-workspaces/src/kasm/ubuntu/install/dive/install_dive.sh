#!/usr/bin/env bash
set -ex

# https://github.com/wagoodman/dive
echo "Installing dive for docker..."
DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -fOL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ./dive_${DIVE_VERSION}_linux_amd64.deb
rm ./dive_${DIVE_VERSION}_linux_amd64.deb
