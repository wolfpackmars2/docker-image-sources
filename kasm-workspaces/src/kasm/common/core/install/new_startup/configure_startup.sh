##!/usr/bin/env bash

# This is a shell script include file. It should be sourced early by other scripts and provides common functions for all startup scripts.
# It should be called as source "${STARTUP_DIR}/startup.d/__common_function.insh"

_DEV=0
if [[ "${DEV:-0}" == "1" ]]; then
    # enable early debugging with `DEV=1 __SCRIPTNAME`
    _DEV=1
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

_TRUE=1
_FALSE=0

# Variables will not be modified if they are already set.
__SCRIPT_PID=${__SCRIPT_PID:-$$}
__SCRIPT_ARGS="${__SCRIPT_ARGS:-$*}"
__SCRIPT_ARGS_ARRAY=( "${__SCRIPT_ARGS_ARRAY[@]:-"$@"}" )
__SCRIPT_FULLPATH="${__SCRIPT_FULLPATH:-$(realpath "$0")}"
__SCRIPT_FILENAME=$(basename "${__SCRIPT_FULLPATH}")
__SCRIPT_DIR=$(dirname "${__SCRIPT_FULLPATH}")

# This function looks for a unique string in new_startup.sh to verify that custom_startup.sh is properly configured. It returns $_TRUE or $_FALSE.
verify_new_startup() {
    if [ -f "${STARTUPDIR}/custom_startup.sh" ] && grep -q "I am new_startup.sh" "${STARTUPDIR}/custom_startup.sh"; then
        return $_TRUE
    else
        return $_FALSE
    fi
}

# Implement new_startup.sh
setup_new_startup() {
    if [ -f "${STARTUPDIR}/custom_startup.sh" ]; then
        if [ verify_new_startup != $_TRUE ]; then
            # Move the existing custom_startup.sh to startup.d with a 9?? prefix
            i=900
            while [ -f "${STARTUPDIR}/startup.d/${i}-custom_startup.sh" ]; do
                i=$((i + 1))
            done
            mv "${STARTUPDIR}/custom_startup.sh" "${STARTUPDIR}/startup.d/${i}-custom_startup.sh"
            chmod 755 "${STARTUPDIR}/startup.d/${i}-custom_startup.sh"
        fi
    fi
    # Copy new_startup.sh to custom_startup.sh
    cp "${__SCRIPT_DIR}/new_startup.sh" "${STARTUPDIR}/custom_startup.sh"
    chmod 755 "${STARTUPDIR}/custom_startup.sh"
    #chmod -R 755 "${STARTUPDIR}/startup.d"
}

if [ ! -d "${STARTUPDIR}/startup.d" ]; then
    mkdir -p "${STARTUPDIR}/startup.d"
fi

#echo "realpath: $(realpath "$0")"
#echo "dirname: $(dirname "$(realpath "$0")")"
#echo "STARTUPDIR: ${STARTUPDIR}"
for __FILE in "${__SCRIPT_DIR}/startup.d/"*; do
    #echo "__FILE: ${__FILE}"
    #echo "dirname: $(dirname "${__FILE}")"
    #echo "basename: $(basename "${__FILE}")"
    if [ -f "${__FILE}" ]; then
        __FILENAME=$(basename "${__FILE}")
        #echo "__FILENAME: ${__FILENAME}"
        if [ -f "${STARTUPDIR}/startup.d/${__FILENAME}" ]; then
            rm -f "${STARTUPDIR}/startup.d/${__FILENAME}"
        fi
        cp "${__FILE}" "${STARTUPDIR}/startup.d/${__FILENAME}"
        #if [[ "$__FILENAME" =~ ^[0-9]{3} && "$__FILENAME" != *.insh ]]; then
        if [[ "$__FILENAME" != *.insh ]]; then
            echo "Setting permissions on ${STARTUPDIR}/startup.d/${__FILENAME} to 755"
            chmod 755 "${STARTUPDIR}/startup.d/${__FILENAME}"
        fi
    fi
done

setup_new_startup

ls -alhR "${STARTUPDIR}"
