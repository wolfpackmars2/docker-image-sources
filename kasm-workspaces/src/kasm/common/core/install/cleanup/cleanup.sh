#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

# File cleanups
rm -Rf \
  /home/kasm-default-profile/.cache \
  /home/kasm-user/.cache \
  /tmp/* \
  /var/tmp/*

# Cleanup icon cache files
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;

# Services we don't want started, disabled in xfce init
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
