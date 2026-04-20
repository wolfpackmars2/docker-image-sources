#!/usr/bin/env bash
set -ex

_TRUE=1
_FALSE=0


# This function looks for a unique string in new_startup.sh to verify that custom_startup.sh is properly configured. It returns $_TRUE or $_FALSE.
verify_new_startup() {
    if [ -f "${STARTUPDIR}/custom_startup.sh" ] && grep -q "I am new_startup.sh" "${STARTUPDIR}/custom_startup.sh"; then
        return $_TRUE
    else
        return $_FALSE
    fi
}

# This function tests if startup.d exists and is a directory. It returns $_TRUE or $_FALSE.
#verify_startup_d() {
#    if [ -d "${STARTUPDIR}/startup.d" ]; then
#        return $_TRUE
#    else
#        return $_FALSE
#    fi
#}

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
        fi
    fi
    # Copy new_startup.sh to custom_startup.sh
    cp "$(dirname "$(realpath "$0")")/new_startup.sh" "${STARTUPDIR}/custom_startup.sh"
    chmod 755 "${STARTUPDIR}/custom_startup.sh"
    chmod -R 755 "${STARTUPDIR}/startup.d"
}

# MAIN

# If verify_new_startup returns false, we will fix it
#if [ ! verify_new_startup == $_TRUE ]; then
#    setup_new_startup
#fi

# Verify the files in "$(dirname "$(realpath "$0")")/startup.d" are in "${STARTUPDIR}/startup.d". If not, copy them over with the same name. If the file already exists, copy it if the source file is a newer version than the destination file.



if [ ! -d "${STARTUPDIR}/startup.d" ]; then
    mkdir -p "${STARTUPDIR}/startup.d"
fi

echo "realpath: $(realpath "$0")"
echo "dirname: $(dirname "$(realpath "$0")")"
echo "STARTUPDIR: ${STARTUPDIR}"
for __FILE in "$(dirname "$(realpath "$0")")/startup.d/"*; do
    echo "__FILE: ${__FILE}"
    echo "dirname: $(dirname "${__FILE}")"
    echo "basename: $(basename "${__FILE}")"
    if [ -f "${__FILE}" ]; then
        __FILENAME=$(basename "${__FILE}")
        echo "__FILENAME: ${__FILENAME}"
        if [ -f "${STARTUPDIR}/startup.d/${__FILENAME}" ]; then
            # Need to compare the files by their response to the -V flag. If the source file is newer, copy it over.
            if [ "$(bash "${__FILE}" -V)" != "$(bash "${STARTUPDIR}/startup.d/${__FILENAME}" -V)" ]; then
                rm -f "${STARTUPDIR}/startup.d/${__FILENAME}"
                cp "${__FILE}" "${STARTUPDIR}/startup.d/"
                chmod 755 "${STARTUPDIR}/startup.d/${__FILENAME}"
            fi
        else
            cp "${__FILE}" "${STARTUPDIR}/startup.d/${__FILENAME}"
            chmod 755 "${STARTUPDIR}/startup.d/${__FILENAME}"
        fi
    fi
done

setup_new_startup

ls -alhR "${STARTUPDIR}"
