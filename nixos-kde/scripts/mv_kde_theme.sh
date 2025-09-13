#!/usr/bin/env bash

OUTPUT1="$HOME/.config/plasma*"
OUTPUT2="$HOME/.config/kdeglobals"
OUTPUT3="$HOME/.config/kwin*"
OUTPUT4="$HOME/.config/kscreen*"
OUTPUT5="$HOME/.config/klipper*"
OUTPUT6="$HOME/.local/share/plasma*"
#OUTPUT7="$HOME/.cache/plasma*"
#OUTPUT8="$HOME/.cache/kpc*"
#OUTPUT9="$HOME/.cache/ksysguard"

INPUT="/etc/nixos/script/theme"
mkdir -p "$INPUT" 2>/dev/null


sudo cp -r $OUTPUT1 "$INPUT" 2>/dev/null
sudo cp -r "$OUTPUT2" "$INPUT" 2>/dev/null
sudo cp -r $OUTPUT3 "$INPUT" 2>/dev/null
sudo cp -r $OUTPUT4 "$INPUT" 2>/dev/null
sudo cp -r $OUTPUT5 "$INPUT" 2>/dev/null
sudo cp -r $OUTPUT6 "$INPUT" 2>/dev/null
#sudo cp -r $OUTPUT7 "$INPUT" 2>/dev/null
#sudo cp -r $OUTPUT8 "$INPUT" 2>/dev/null
#sudo cp -r "$OUTPUT9" "$INPUT" 2>/dev/null


echo "✅ Файл скопирован: $OUTPUT1"
echo "✅ Файл скопирован: $OUTPUT2"
echo "✅ Файл скопирован: $OUTPUT3"
echo "✅ Файл скопирован: $OUTPUT4"
echo "✅ Файл скопирован: $OUTPUT5"
echo "✅ Файл скопирован: $OUTPUT6"
#echo "✅ Файл скопирован: $OUTPUT7"
#echo "✅ Файл скопирован: $OUTPUT8"
#echo "✅ Файл скопирован: $OUTPUT9"

echo "✅ Файл скопированы в папку: $INPUT"

