{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    # historyFile = "/etc/nixos/bash/.bash_history";
    historyFile = "$HOME/.bash_history";

    bashrcExtra = ''

      # export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/go_work"
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      # eval "$(tjournal init bash)"
      # eval "$(tv init bash)"

    '';
    shellAliases = {

      ls = "eza";
      yys = "sudo -E yazi";
      sstui = "sudo -E systemctl-tui";
      stui = "systemctl-tui";
      rboot = "sudo /run/current-system/bin/switch-to-configuration boot";
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
