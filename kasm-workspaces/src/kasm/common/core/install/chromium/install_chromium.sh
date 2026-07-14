#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

CHROME_ARGS="--password-store=basic --no-sandbox --ignore-gpu-blocklist --user-data-dir --no-first-run --simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT'"

apk add --no-cache chromium

REAL_BIN=chromium-browser

sed -i 's/-stable//g' /usr/share/applications/${REAL_BIN}.desktop

cp /usr/share/applications/${REAL_BIN}.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/${REAL_BIN}.desktop
chown 1000:1000 $HOME/Desktop/${REAL_BIN}.desktop

mv /usr/bin/${REAL_BIN} /usr/bin/${REAL_BIN}-orig
cat >/usr/bin/${REAL_BIN} <<EOL
#!/usr/bin/env bash

supports_vulkan() {
  command -v vulkaninfo >/dev/null 2>&1 || return 1
  DISPLAY= vulkaninfo --summary 2>/dev/null |
    grep -qE 'PHYSICAL_DEVICE_TYPE_(INTEGRATED_GPU|DISCRETE_GPU|VIRTUAL_GPU)'
}

if ! pgrep chromium > /dev/null; then
  rm -f \$HOME/.config/chromium/Singleton*
fi
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"None"/' ~/.config/chromium/Default/Preferences

VULKAN_FLAGS=
if supports_vulkan; then
  VULKAN_FLAGS="--use-angle=vulkan"
  echo 'vulkan supported'
fi

if [ -f /opt/VirtualGL/bin/vglrun ] && [ ! -z "\${KASM_EGL_CARD}" ] && [ ! -z "\${KASM_RENDERD}" ] && [ -O "\${KASM_RENDERD}" ] && [ -O "\${KASM_EGL_CARD}" ]; then
    echo "Starting Chromium with GPU Acceleration on EGL device \${KASM_EGL_CARD}"
    vglrun -d "\${KASM_EGL_CARD}" /usr/bin/${REAL_BIN}-orig ${CHROME_ARGS} "\${VULKAN_FLAGS}" "\$@"
else
    echo "Starting Chromium"
    /usr/bin/${REAL_BIN}-orig ${CHROME_ARGS} "\${VULKAN_FLAGS}" "\$@"
fi
EOL
chmod +x /usr/bin/${REAL_BIN}

cat >> $HOME/.config/mimeapps.list <<EOF
[Default Applications]
x-scheme-handler/http=${REAL_BIN}.desktop
x-scheme-handler/https=${REAL_BIN}.desktop
x-scheme-handler/ftp=${REAL_BIN}.desktop
x-scheme-handler/chrome=${REAL_BIN}.desktop
text/html=${REAL_BIN}.desktop
application/x-extension-htm=${REAL_BIN}.desktop
application/x-extension-html=${REAL_BIN}.desktop
application/x-extension-shtml=${REAL_BIN}.desktop
application/xhtml+xml=${REAL_BIN}.desktop
application/x-extension-xhtml=${REAL_BIN}.desktop
application/x-extension-xht=${REAL_BIN}.desktop
EOF

mkdir -p /etc/chromium/policies/managed/
cat >>/etc/chromium/policies/managed/default_managed_policy.json <<EOL
{"CommandLineFlagSecurityWarningsEnabled": false, "DefaultBrowserSettingEnabled": false}
EOL
