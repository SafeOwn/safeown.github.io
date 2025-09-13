#!/bin/sh



if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR=/run/user/$(id -u)
fi

export STATUS_FILE="$XDG_RUNTIME_DIR/monitorHz.status"

monitor_120() {
  printf "true" > "$STATUS_FILE"
    hyprctl notify -1 3000 "rgb(000000)" "fontsize:20 monitor 120Hz"
    hyprctl keyword monitor "eDP-1,1920x1200@120.00000, 0x0, 1"
}

monitor_60() {
  printf "false" > "$STATUS_FILE"
    hyprctl notify -1 3000 "rgb(000000)" "fontsize:20 monitor 60Hz"
    hyprctl keyword monitor "eDP-1,1920x1200@60.00100, 0x0, 1"
}

if ! [ -f "$STATUS_FILE" ]; then
  monitor_60
else
  if [ $(cat "$STATUS_FILE") = "true" ]; then
    monitor_60
  elif [ $(cat "$STATUS_FILE") = "false" ]; then
    monitor_120
  fi
fi
