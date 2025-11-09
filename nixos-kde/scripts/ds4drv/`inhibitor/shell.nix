# ~/shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    python3
    python3Packages.evdev
    python3Packages.pyudev
  ];

  shellHook = ''
    echo "Готово! Запускай: python3 gamepad-idle-inhibitor.py"
  '';
}
