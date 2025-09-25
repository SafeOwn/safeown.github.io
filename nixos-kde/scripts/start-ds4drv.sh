#!/usr/bin/env bash

rm -rf ds4drv && \
EVDEV_PATH="$(nix-build '<nixpkgs>' -A python313Packages.evdev --no-out-link)/lib/python3.13/site-packages" && \
PYUDEV_PATH="$(nix-build '<nixpkgs>' -A python313Packages.pyudev --no-out-link)/lib/python3.13/site-packages" && \
nix-shell -p git python313 python313Packages.evdev python313Packages.pyudev --run "
  git clone https://github.com/chrippa/ds4drv.git;
  cd ds4drv;
  sed -i 's/device\.fn/device.path/g' ds4drv/actions/input.py;
  sed -i 's/SafeConfigParser/ConfigParser/g' ds4drv/config.py;
  export PYTHONPATH=\"\$(pwd):$EVDEV_PATH:$PYUDEV_PATH\";
  python3 -m ds4drv --hidraw
"


chmod +x ~/start-ds4drv.sh
