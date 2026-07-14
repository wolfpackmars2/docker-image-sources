#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi
DEFAULT_PROFILE_HOME=/home/kasm-default-profile

cp -rpfv "${INST_DIR}/ubuntu/core/resources/config/xfce/.config" "${DEFAULT_PROFILE_HOME}"
