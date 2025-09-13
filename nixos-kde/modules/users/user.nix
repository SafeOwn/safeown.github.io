# ========================================
# 🐚 /etc/nixos/home/bash/bash_user.nix
# Алиасы и настройки для пользователя safe
# ========================================
{ config, lib, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyFile = "$HOME/.bash_history";

    bashrcExtra = ''
      export PATH="$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$PATH"
    '';

    shellAliases = {
      ls = "eza --color=always --icons=always";
      ll = "eza -lbF --color=always --icons=always";
      la = "eza -la --color=always --icons=always";
      tree = "eza -aT --color=always --icons=always";
      fd = "fd --hidden --type file --color=always";
      yys = "sudo -E yazi";
      sstui = "sudo -E systemctl-tui";
      stui = "systemctl-tui";
      rboot = "sudo /run/current-system/bin/switch-to-configuration boot";

      gs = "git status";
      gc = "git commit -m";
      gca = "git commit -am";
      gp = "git push";
      gpl = "git pull";

      # Твои кастомные алиасы
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#yandex && home-manager switch";
      backup = "sudo bash /etc/nixos/scripts/commit-nixos-git.sh";
      restart = "pkill -9 plasmashell";
      ai-text = "sudo bash /etc/nixos/scripts/export-for-ai.sh";
      kate-root = "sudo -E kate";
    };
  };

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
