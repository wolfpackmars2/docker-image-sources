#!/usr/bin/env bash
set -e

_DEV=0
if [[ "${DEV:-0}" == "1" ]]; then
    _DEV=1
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

_TRUE=1
_FALSE=0

__SCRIPT_FULLPATH="${__SCRIPT_FULLPATH:-$(realpath "$0")}"
__SCRIPT_FILENAME=$(basename "${__SCRIPT_FULLPATH}")
__SCRIPT_DIR=$(dirname "${__SCRIPT_FULLPATH}")

# Looks for a unique string in new_startup.sh to verify custom_startup.sh is properly configured.
verify_new_startup() {
    if [ -f "${STARTUPDIR}/custom_startup.sh" ] && grep -q "I am new_startup.sh" "${STARTUPDIR}/custom_startup.sh"; then
        return $_TRUE
    else
        return $_FALSE
    fi
}

setup_new_startup() {
    if [ -f "${STARTUPDIR}/custom_startup.sh" ]; then
        if [ verify_new_startup != $_TRUE ]; then
            i=900
            while [ -f "${STARTUPDIR}/startup.d/${i}-custom_startup.sh" ]; do
                i=$((i + 1))
            done
            mv "${STARTUPDIR}/custom_startup.sh" "${STARTUPDIR}/startup.d/${i}-custom_startup.sh"
            chmod 755 "${STARTUPDIR}/startup.d/${i}-custom_startup.sh"
        fi
    fi
    cp "${__SCRIPT_DIR}/new_startup.sh" "${STARTUPDIR}/custom_startup.sh"
    chmod 755 "${STARTUPDIR}/custom_startup.sh"
}

if [ ! -d "${STARTUPDIR}/startup.d" ]; then
    mkdir -p "${STARTUPDIR}/startup.d"
fi

for __FILE in "${__SCRIPT_DIR}/startup.d/"*; do
    if [ -f "${__FILE}" ]; then
        __FILENAME=$(basename "${__FILE}")
        if [ -f "${STARTUPDIR}/startup.d/${__FILENAME}" ]; then
            rm -f "${STARTUPDIR}/startup.d/${__FILENAME}"
        fi
        cp "${__FILE}" "${STARTUPDIR}/startup.d/${__FILENAME}"
        if [[ "$__FILENAME" != *.insh ]]; then
            echo "Setting permissions on ${STARTUPDIR}/startup.d/${__FILENAME} to 755"
            chmod 755 "${STARTUPDIR}/startup.d/${__FILENAME}"
        fi
    fi
done

setup_new_startup

if [[ "${_DEV}" == "1" ]]; then
    ls -alhR "${STARTUPDIR}"
fi
