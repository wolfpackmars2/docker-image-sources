#!/usr/bin/env bash
set -e

_DEV=0
if [[ "${DEV:-0}" == "1" ]]; then
    # enable early debugging with `DEV=1 __SCRIPTNAME`
    _DEV=1
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

if [[ ! -f "$1" && ! -L "$1" ]]; then
    echo "Usage: $0 <startup_file>"
    echo "<startup_file> must start with 3 digits followed by a hyphen and be a valid file or symlink"
    exit 1
fi

__FILEPATH=$(realpath -s "$1")
__BASENAME=$(basename "${__FILEPATH}")
if [[ "$__BASENAME" =~ ^[0-9]{3} ]]; then
    echo "${__BASENAME} Starts with 3 digits"
    if [[ "$__BASENAME" == *.insh ]]; then
        echo "${__BASENAME} is a .insh file."
        echo "We will check for ${__BASENAME}.sh and use that if it exists."
        if [ -f "${__FILEPATH%.insh}.sh" ]; then
            echo "Found ${__FILEPATH%.insh}.sh. Using that instead."
            __FILEPATH="${__FILEPATH%.insh}.sh"
            __BASENAME=$(basename "${__FILEPATH}")
        elif [ -f "${__FILEPATH%.insh}" ]; then
            echo "Found ${__FILEPATH%.insh}. Using that instead."
            __FILEPATH="${__FILEPATH%.insh}"
            __BASENAME=$(basename "${__FILEPATH}")
        else
            echo "No matching .sh or non-extension file found for ${__FILEPATH}. Invalid call. Fail."
            exit 2
        fi
    fi
else
    echo "${__FILEPATH} is not a valid startup file. Fail."
    exit 2
fi

if [[ "${__BASENAME:3:1}" != "-" ]]; then
    echo "Startup ID and filename must be separated by a hyphen. Invalid filename. Fail."
    exit 2
fi

if [ ! -f "${__FILEPATH}" ]; then
    echo "File ${__FILEPATH} does not exist. Fail."
    exit 2
fi

__INSH_FILEPATH="${__FILEPATH%.sh}.insh"

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



#cp "$1" "${__TARGET_FILE}"
if [[ -L "${__FILEPATH}" ]]; then
    echo "Source file ${__FILEPATH} is a symlink and will be copied as a symlink."
    cp -P "${__FILEPATH}" "${__TARGET_FILE}"
else
    echo "Source file ${__FILEPATH} is not a symlink and will be copied."
    cp "${__FILEPATH}" "${__TARGET_FILE}"
    chmod 755 "${__TARGET_FILE}"
fi

if [ -f "${__INSH_FILEPATH}" ]; then
    __INSH_BASENAME=$(basename "${__INSH_FILEPATH}")
    __TARGET_INSH_FILE="${STARTUPDIR}/startup.d/${__TARGET_ID}-${__INSH_BASENAME#*-}"
    cp "${__INSH_FILEPATH}" "${__TARGET_INSH_FILE}"
    chmod 644 "${__TARGET_INSH_FILE}"
fi
