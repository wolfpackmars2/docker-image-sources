#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

# Reinstall gnome-keyring-daemon if needed, since Kasm likes to remove it from their images...
echo "Enable gnome-keyring-daemon..."
if [ ! -x "/usr/bin/gnome-keyring-daemon" ]; then
    echo "Repairing gnome-keyring-daemon..."
    apt-get update
    apt-get install --reinstall -y gnome-keyring
else
    echo "gnome-keyring-daemon already exists, skipping."
fi
