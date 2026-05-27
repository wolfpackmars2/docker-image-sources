#!/usr/bin/env bash
set -eu

if [ ! -z ${DEV+x} ] && [ "$DEV" -eq "1" ]; then
    # enable early debugging with `DEV=1 __SCRIPTNAME`
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

_TRUE=1
_FALSE=0

__SCRIPTARGS="$*"
__SCRIPTFULLNAME=$(realpath "$0")
__SCRIPTNAME=$(basename "${__SCRIPTFULLNAME}")
__SCRIPTFULLPATH=$(dirname "${__SCRIPTFULLNAME}")

if [ ! -d "${STARTUPDIR}/image_info" ]; then
    mkdir -p "${STARTUPDIR}/image_info"
fi

if [ -z ${PATCH_DATE+x} ]; then
    echo "Installing genmon..."
    apt-get update
    apt-get -y install xfce4-genmon-plugin inxi
    echo "Creating imagebuild.txt..."
    printf "%(%Y-%m-%d %H:%M.%S %Z)T" -1 > "${STARTUPDIR}/image_info/imagebuild.txt"
    echo "Copying genmon_image_info.sh..."
    if [ -f "${STARTUPDIR}/genmon_image_info.sh" ]; then
        rm -f "${STARTUPDIR}/genmon_image_info.sh"
    fi
    cp "${__SCRIPTFULLPATH}/genmon_image_info.sh" "${STARTUPDIR}/genmon_image_info.sh"
    chmod 755 "${STARTUPDIR}/genmon_image_info.sh"
else
    echo "Creating imagepatch.txt with contents ${PATCH_DATE}..."
    #printf "%(%Y-%m-%d %H:%M.%S %Z)T" -1 > "${STARTUPDIR}/image_info/imagepatch.txt"
    printf "${PATCH_DATE}" > "${STARTUPDIR}/image_info/imagepatch.txt"
fi
