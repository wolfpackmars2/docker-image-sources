#!/usr/bin/env bash
set -ex

# Install Solvespace
apt update
apt install -y git build-essential cmake zlib1g-dev libpng-dev \
    libcairo2-dev libfreetype6-dev libjson-c-dev \
    libfontconfig1-dev libgtkmm-3.0-dev libpangomm-1.4-dev \
    libgl-dev libglu-dev libspnav-dev qt6-base-dev
echo "Cloning solvespace source..."
git clone https://github.com/solvespace/solvespace
cd solvespace
git checkout 37484dc # temporary: ref https://github.com/solvespace/solvespace/issues/1668
git submodule update --init # Prepare submodules
mkdir build
cd build
echo "Building solvespace"
cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENMP=ON -DENABLE_LTO=ON -DUSE_QT_GUI=ON
make
make install
echo "Cleaning up..."
cd ../..
rm -rf solvespace
echo "Done."

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi