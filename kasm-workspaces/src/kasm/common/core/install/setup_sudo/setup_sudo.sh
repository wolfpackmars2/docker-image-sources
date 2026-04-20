#!/usr/bin/env bash
set -ex

#_TRUE=1
#_FALSE=0

# Install sudo - disabled because it is already on the image
# if [[ "${DISTRO}" == @(centos|oracle7) ]] ; then
#   yum install -y sudo
# elif [[ "${DISTRO}" == @(fedora37|fedora38|fedora39|fedora40|fedora41|oracle8|oracle9|rockylinux9|rockylinux8|almalinux8|almalinux9) ]]; then
#   dnf install -y sudo # untested
# elif [[ "${DISTRO}" == @(rhel9) ]]; then
#   dnf install -y sudo # untested
# elif [ "${DISTRO}" == "opensuse" ]; then
#   zypper install -yn sudo
# elif [ "${DISTRO}" == "alpine" ]; then
#   apk add --no-cache sudo
# else
#   apt-get update
#   DEBIAN_FRONTEND=noninteractive apt-get install -y sudo --no-install-recommends
# fi

# Need to add 'kasm-user ALL=(ALL) NOPASSWD: ALL' to /etc/sudoers.d/kasm-user
if [ -f "/etc/sudoers.d/kasm-user" ]; then
    if ! grep -q "kasm-user ALL=(ALL) NOPASSWD: ALL" "/etc/sudoers.d/kasm-user"; then
        echo "kasm-user ALL=(ALL) NOPASSWD: ALL" >> "/etc/sudoers.d/kasm-user"
    fi
else
    echo "kasm-user ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/kasm-user"
fi
chmod 440 "/etc/sudoers.d/kasm-user"

