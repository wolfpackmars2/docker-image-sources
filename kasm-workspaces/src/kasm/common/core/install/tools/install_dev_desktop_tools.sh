#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

echo "Installing additional tools..."
if [ "${DISTRO}" == "alpine" ]; then
  # Note: pip version of PySide6 is not compatible with Alpine.
  apk add --no-cache xcb-util-cursor
else
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y libxcb-cursor0 --no-install-recommends
fi
