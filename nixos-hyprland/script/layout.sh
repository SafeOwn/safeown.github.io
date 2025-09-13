#!/bin/sh

lang=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')
hyprctl notify -1 3000 "rgb(000000)" "fontsize:20 󰥻 $lang"
