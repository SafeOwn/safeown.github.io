# ========================================
# 🐚 /etc/nixos/home/bash/bash_root.nix
# Алиасы и PATH для root (работает в sudo -i, su)
# ========================================
{ config, lib, pkgs, ... }:

{
  # ✅ Правильно: на верхнем уровне
  environment.interactiveShellInit = ''
    export PATH="/home/safe/bin:/home/safe/.local/bin:/home/safe/go/bin:$PATH"

    alias ls='eza --color=always --icons=always'
    alias ll='eza -lbF --color=always --icons=always'
    alias la='eza -la --color=always --icons=always'
    alias tree='eza -aT --color=always --icons=always'
    alias fd='fd --hidden --type file --color=always'

    alias yys='sudo -E yazi'
    alias sstui='sudo -E systemctl-tui'
    alias stui='systemctl-tui'
    alias rboot='sudo /run/current-system/bin/switch-to-configuration boot'

    alias gs='git status'
    alias gc='git commit -m'
    alias gca='git commit -am'
    alias gp='git push';
    alias gpl='git pull';

    # Твои кастомные алиасы
    alias rebuild='sudo nixos-rebuild switch --flake /etc/nixos#yandex && home-manager switch'
    alias backup='bash /etc/nixos/scripts/commit-nixos-git.sh'
    alias restart='pkill -9 plasmashell'
    alias ai-text='bash /etc/nixos/scripts/export-for-ai.sh'
    alias kate-root='sudo -E kate'
  '';

  # Можно включить bash, если нужно
  programs.bash.enable = true;

  # programs.zoxide = {
  #   enable = true;
  #   enableBashIntegration = true;
  # };
  # programs.eza = {
  #   enable = true;
  #   enableBashIntegration = true;
  #   colors = "always";
  #   icons = "always";
  # };
  # programs.fd = {
  #   enable = true;
  #   extraOptions = [
  #     "--hiden --type file --color=always"
  #   ];
  # };
  # programs.fastfetch = {
  #   enable = true;
  #   # settings = {
  #   #   logo = {
  #   #     source = "nixos_small";
  #   #     padding = {
  #   #       right = 1;
  #   #     };
  #   #   };
  #   # };
  # };
  # programs.imv = {
  #   enable = true;
  #   settings = {
  #     options.background = "1D2021";
  #   };
  # };
}
