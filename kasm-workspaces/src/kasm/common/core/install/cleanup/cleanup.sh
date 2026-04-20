#!/usr/bin/env bash
set -ex

_TRUE=1
_FALSE=0

# SKIP_PKG_CLEANUP is used to skip the package cleanup step in the build process.
# Typically the package caches are mounted as temporary volumes during the build, so the cleanup is not necessary and can be skipped to save time.
# Set SKIP_PKG_CLEANUP=1 in the environment to skip the package cleanup step.
SKIP_PKG_CLEANUP="${SKIP_PKG_CLEANUP:-$_FALSE}"

# Distro package cleanup
if [ "${SKIP_PKG_CLEANUP:-$_FALSE}" != "$_TRUE" ]; then # Skip ONLY if SKIP_PKG_CLEANUP is set to true
  if [[ "${DISTRO}" == @(almalinux8|almalinux9|fedora39|fedora40|fedora41|oracle8|oracle9|rhel9|rockylinux8|rockylinux9) ]]; then
    dnf clean all
  elif [ "${DISTRO}" == "opensuse" ]; then
    zypper clean --all
  elif [[ "${DISTRO}" == @(debian|kali|parrotos6|ubuntu) ]]; then
    apt-get autoremove -y
    apt-get clean -y
  fi
fi
# File cleanups
rm -Rf \
  /home/kasm-default-profile/.cache \
  /home/kasm-user/.cache \
  /tmp/* \
  /var/tmp/*
#mkdir -m 1777 /tmp

if [ "${SKIP_PKG_CLEANUP:-$_FALSE}" != "$_TRUE" ]; then
  rm -Rf /var/lib/apt/lists/*
fi
# Cleanup icon cache files
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;

# Services we don't want to start disable in xfce init
rm -f \
  /etc/xdg/autostart/blueman.desktop \
  /etc/xdg/autostart/geoclue-demo-agent.desktop \
  /etc/xdg/autostart/gnome-keyring-pkcs11.desktop \
  /etc/xdg/autostart/gnome-keyring-secrets.desktop \
  /etc/xdg/autostart/gnome-keyring-ssh.desktop \
  /etc/xdg/autostart/gnome-shell-overrides-migration.desktop \
  /etc/xdg/autostart/light-locker.desktop \
  /etc/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.A11ySettings.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Color.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Datetime.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Housekeeping.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Keyboard.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.MediaKeys.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Power.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.PrintNotifications.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Rfkill.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.ScreensaverProxy.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Sharing.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Smartcard.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Sound.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.UsbProtection.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Wacom.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Wwan.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.XSettings.desktop \
  /etc/xdg/autostart/pulseaudio.desktop \
  /etc/xdg/autostart/xfce4-power-manager.desktop \
  /etc/xdg/autostart/xfce4-screensaver.desktop \
  /etc/xdg/autostart/xfce-polkit.desktop \
  /etc/xdg/autostart/xscreensaver.desktop

# Bins we don't want in the final image
#if which gnome-keyring-daemon; then
#  rm -f $(which gnome-keyring-daemon)
#fi
