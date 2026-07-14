#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

# Install Anycubic Slicer Next
ASN_PACKAGE_PATH=$(curl -s 'https://cdn-universe-slicer.anycubic.com/prod/dists/noble/main/binary-amd64/Packages' \
    | grep -oP '(?<=Filename: )\S+')
if [[ -z "${ASN_PACKAGE_PATH}" ]]; then
    echo "ERROR: Failed to find Anycubic Slicer Next package URL" >&2
    exit 1
fi
ASN_PACKAGE_URL="https://cdn-universe-slicer.anycubic.com/prod/${ASN_PACKAGE_PATH}"
ASN_PACKAGE_FILE=$(basename "${ASN_PACKAGE_URL}")

curl -fL -o "/tmp/${ASN_PACKAGE_FILE}" "${ASN_PACKAGE_URL}"

# Install pre-deps not declared in the package
apt-get install -y \
    gstreamer1.0-libav \
    libwayland-bin

# Install ASN deb package (auto-resolves declared deps)
apt-get install -y "/tmp/${ASN_PACKAGE_FILE}"

# Desktop icon
cp /usr/share/applications/AnycubicSlicer.desktop "${HOME}/Desktop/"
chmod +x "${HOME}/Desktop/AnycubicSlicer.desktop"

# Add startup item
if [ "${NO_START_AT_BOOT:-0}" == "0" ]; then
    if [ -f "${INST_DIR}/common/core/install/new_startup/add_startup_item.sh" ]; then
        bash "${INST_DIR}/common/core/install/new_startup/add_startup_item.sh" \
            "${INST_DIR}/ubuntu/install/anycubic_slicer_next/900-anycubic_slicer_next" && \
            echo "Startup item added successfully"
    fi
else
    echo "NO_START_AT_BOOT is set to 1, skipping adding startup item."
fi
