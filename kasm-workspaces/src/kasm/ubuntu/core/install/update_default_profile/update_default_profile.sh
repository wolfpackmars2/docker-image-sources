#!/usr/bin/env bash
set -ex
DEFAULT_PROFILE_HOME=/home/kasm-default-profile

cp -rpfv "${INST_DIR}/ubuntu/core/resources/config/xfce/.config" "${DEFAULT_PROFILE_HOME}"
