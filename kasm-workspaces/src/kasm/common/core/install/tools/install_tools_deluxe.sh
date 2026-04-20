#!/usr/bin/env bash
set -ex

echo "Installing deluxe tools..."
if [[ "${DISTRO}" == @(centos|oracle7) ]] ; then
  yum install -y vlc git tmux
elif [[ "${DISTRO}" == @(fedora37|fedora38|fedora39|fedora40|fedora41|oracle8|oracle9|rockylinux9|rockylinux8|almalinux8|almalinux9) ]]; then
  dnf install -y vlc git tmux # untested
elif [[ "${DISTRO}" == @(rhel9) ]]; then
  dnf install -y vlc git tmux # untested
elif [ "${DISTRO}" == "opensuse" ]; then
  zypper install -yn vlc git tmux
elif [ "${DISTRO}" == "alpine" ]; then
  apk add --no-cache vlc git tmux
else
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y vlc git tmux --no-install-recommends
fi
