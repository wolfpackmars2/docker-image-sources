#!/usr/bin/env bash
set -ex

# Install Anycubic Slicer Next
apt-get update
apt-get install -y apt-transport-https
ASN_PACKAGE_URL="https://cdn-universe-slicer.anycubic.com/prod/$(curl -s 'https://cdn-universe-slicer.anycubic.com/prod/dists/noble/main/binary-amd64/Packages' | grep -oP '(?<=Filename: )\S+')"
ASN_PACKAGE_FILE=$(basename "$ASN_PACKAGE_URL")
curl -o "/tmp/$ASN_PACKAGE_FILE" "$ASN_PACKAGE_URL"
# Install ASN dependencies
apt-get install -y libgstreamer-ocaml libstdlib-ocaml libwayland-bin ocaml-base gstreamer1.0-libav
# Install ASN deb package
dpkg -i "/tmp/$ASN_PACKAGE_FILE"

# Desktop icon
cp /usr/share/applications/AnycubicSlicer.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/AnycubicSlicer.desktop

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi