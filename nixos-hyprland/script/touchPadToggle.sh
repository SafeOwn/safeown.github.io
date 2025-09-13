#!/bin/sh

HYPRLAND_DEVICE="asuf1204:00-2808:0201-touchpad"


if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR=/run/user/$(id -u)
fi

export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

enable_touchpad() {
  printf "true" > "$STATUS_FILE"
    hyprctl notify -1 3000 "rgb(000000)" "fontsize:20 Touchpad Enable"
    hyprctl keyword "device[${HYPRLAND_DEVICE}]:enabled" 1

}

disable_touchpad() {
  printf "false" > "$STATUS_FILE"
    hyprctl notify -1 3000 "rgb(000000)" "fontsize:20 Touchpad Disable"
    hyprctl keyword "device[${HYPRLAND_DEVICE}]:enabled" 0

}

if ! [ -f "$STATUS_FILE" ]; then
  disable_touchpad
else
  if [ $(cat "$STATUS_FILE") = "true" ]; then
    disable_touchpad
  elif [ $(cat "$STATUS_FILE") = "false" ]; then
    enable_touchpad
  fi
fi
