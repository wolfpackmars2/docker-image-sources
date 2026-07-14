#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

echo "Installing additional tools..."
if [[ "${DISTRO}" == @(centos|oracle7) ]] ; then
  yum install -y nano iputils less
elif [[ "${DISTRO}" == @(fedora37|fedora38|fedora39|fedora40|fedora41|oracle8|oracle9|rockylinux9|rockylinux8|almalinux8|almalinux9) ]]; then
  dnf install -y nano iputils less # untested
elif [[ "${DISTRO}" == @(rhel9) ]]; then
  dnf install -y nano iputils less # untested
elif [ "${DISTRO}" == "opensuse" ]; then
  zypper install -yn nano iputils less
elif [ "${DISTRO}" == "alpine" ]; then
  apk add --no-cache nano iputils less
else
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y iputils-ping nano less mousepad meld unzip --no-install-recommends
fi
