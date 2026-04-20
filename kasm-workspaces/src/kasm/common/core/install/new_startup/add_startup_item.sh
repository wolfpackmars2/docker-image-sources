#!/usr/bin/env bash
set -e

_DEV=0
if [[ "${DEV:-0}" == "1" ]]; then
    # enable early debugging with `DEV=1 __SCRIPTNAME`
    _DEV=1
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

if [ ! -f "$1" ]; then
    echo "Usage: $0 <startup_file>"
    exit 1
fi

__BASENAME=$(basename "$1")
__START_ID="${__BASENAME%%-*}"
i=$((10#$__START_ID))
#while [ -f "${STARTUPDIR}/startup.d/$(printf "%03d" $i)-*" ]; do
#    i=$((i + 1))
#done
while true; do
    # Expand the pattern into an array
    files=( "${STARTUPDIR}/startup.d/$(printf "%03d" $i)-"* )
    
    # Check if the first element is an actual file
    if [ -f "${files[0]}" ]; then
        i=$((i + 1))
    else
        break
    fi
done
__TARGET_ID=$(printf "%03d" $i)
__TARGET_FILE="${STARTUPDIR}/startup.d/${__TARGET_ID}-${__BASENAME#*-}"
cp "$1" "${__TARGET_FILE}"
chmod 755 "${__TARGET_FILE}"
