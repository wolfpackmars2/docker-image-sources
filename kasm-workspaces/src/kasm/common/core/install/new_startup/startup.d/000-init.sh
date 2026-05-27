#!/usr/bin/env bash
set -e

source "${STARTUPDIR}/startup.d/__common.insh"

# Set permissions for XDG_RUNTIME_DIR to prevent issues with some applications
if [ -d "${XDG_RUNTIME_DIR}" ]; then
    chmod 700 "${XDG_RUNTIME_DIR}"
fi

# Create an ident file for this image
__IMAGE_STRING=""

if [ ! -z ${KASM_IMAGE_URL+x} ]; then
    __IMAGE_NAME="${KASM_IMAGE_URL%/}"
    __IMAGE_NAME="${__IMAGE_NAME##*/}"
    __IMAGE_STRING="[${__IMAGE_NAME}] "
elif [ ! -z ${KASM_IMAGE_NAME+x} ]; then
    __IMAGE_STRING="[${KASM_IMAGE_NAME}] "
fi

__IMAGE_STRING="${__IMAGE_STRING}BUILD: "
if [ -f "${STARTUPDIR}/image_info/imagebuild.txt" ]; then
    __IMAGE_STRING="${__IMAGE_STRING}$(cat ${STARTUPDIR}/image_info/imagebuild.txt) "
else
    __IMAGE_STRING="${__IMAGE_STRING}N/A "
fi

if [ -f "${STARTUPDIR}/image_info/imagepatch.txt" ]; then
    __IMAGE_STRING="${__IMAGE_STRING}| PATCH: $(cat ${STARTUPDIR}/image_info/imagepatch.txt) |"
fi

echo -e "${__IMAGE_STRING}" > "${HOME}/.kasm_image_ident"

if [[ -n "${OUTPUT:-}" && -w $(dirname "${OUTPUT}") ]]; then
    # This script is special in that it will always output the same result
    # Output format: $KEEPALIVE:$__PID
    echo -n "${_FALSE}:0" > "${OUTPUT}"
fi
