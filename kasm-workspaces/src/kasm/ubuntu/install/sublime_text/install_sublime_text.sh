#!/usr/bin/env bash
set -e
if [[ "${DEV:-0}" == "1" ]]; then
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

# Install Sublime Text
apt-get update
apt-get install -y apt-transport-https

# apt-key is deprecated in trixie and later, use keyrings instead
if grep -q "trixie" /etc/os-release; then
  mkdir -p /usr/share/keyrings
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
  echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | tee /etc/apt/sources.list.d/sublime-text.sources
  apt-get update && apt-get install -y sublime-text
else
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" |  tee /etc/apt/sources.list.d/sublime-text.list
  apt-get update
  apt-get install -y sublime-text
fi

# Desktop icon
cp /usr/share/applications/sublime_text.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/sublime_text.desktop

