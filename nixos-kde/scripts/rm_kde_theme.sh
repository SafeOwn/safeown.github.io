#!/usr/bin/env bash

OUTPUT1="~/.config/plasma*"
OUTPUT2="~/.config/kdeglobals"
OUTPUT3="~/.config/kwin*"
OUTPUT4="~/.config/kscreen*"
OUTPUT5="~/.config/klipper*"
OUTPUT6="~/.local/share/plasma*"
OUTPUT7="~/.cache/plasma*"
OUTPUT8="~/.cache/kpc*"
OUTPUT9="~/.cache/ksysguard"

rm -rf "$OUTPUT1" 2>/dev/null
rm -rf "$OUTPUT2" 2>/dev/null
rm -rf "$OUTPUT3" 2>/dev/null
rm -rf "$OUTPUT4" 2>/dev/null
rm -rf "$OUTPUT5" 2>/dev/null
rm -rf "$OUTPUT6" 2>/dev/null
rm -rf "$OUTPUT7" 2>/dev/null
rm -rf "$OUTPUT8" 2>/dev/null
rm -rf "$OUTPUT9" 2>/dev/null


echo "✅ Файл удален: $OUTPUT1"
echo "✅ Файл удален: $OUTPUT2"
echo "✅ Файл удален: $OUTPUT3"
echo "✅ Файл удален: $OUTPUT4"
echo "✅ Файл удален: $OUTPUT5"
echo "✅ Файл удален: $OUTPUT6"
echo "✅ Файл удален: $OUTPUT7"
echo "✅ Файл удален: $OUTPUT8"
echo "✅ Файл удален: $OUTPUT9"

plasma-apply-colorscheme BreezeClassic
plasma-apply-colorscheme BreezeDark


