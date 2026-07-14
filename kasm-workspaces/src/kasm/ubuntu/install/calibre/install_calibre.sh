#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

# Install deps
apt-get update
apt-get install -y \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-keysyms1 \
    libxcb-xinerama0

# Install latest Calibre
wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

# Add startup item
if [ "${NO_START_AT_BOOT:-0}" == "0" ]; then
    if [ -f ${INST_DIR}/common/core/install/new_startup/add_startup_item.sh ]; then
        bash ${INST_DIR}/common/core/install/new_startup/add_startup_item.sh ${INST_DIR}/ubuntu/install/calibre/900-calibre && \
        echo "Startup item added successfully"
    else
        cp ./900-calibre.insh ${STARTUP_DIR}/900-calibre.insh
        chmod +x ${STARTUP_DIR}/900-calibre.insh
        echo "Legacy startup script copied to ${STARTUP_DIR}/900-calibre.insh."
    fi
else
    echo "NO_START_AT_BOOT is set to 1, skipping adding startup item."
fi
