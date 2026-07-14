#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

echo "Installing deluxe tools..."
if [ "${DISTRO}" == "alpine" ]; then
  apk add --no-cache vlc git tmux
else
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y vlc git tmux --no-install-recommends
fi
