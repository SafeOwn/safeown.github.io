# List packages installed in system profile. To search, run:
# $ nix search wget
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    xwayland.enable = false;
    hyprland = {
      enable = true;
      # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # portalPackage =
      # inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      xwayland.enable = false;

    };
    # waybar = {
    #   enable = true;
    # };

    # yazi = {
    #   enable = true;
    #   package = inputs.yazi.packages.${pkgs.system}.default;
    # };
    firefox.enable = true;
    amnezia-vpn.enable = true;
    iio-hyprland.enable = true;
    hyprlock.enable = true;
    mtr.enable = true;
    zoxide.enable = true;
    gnupg.agent = {
      enable = true;
      # pinentryPackage = pkgs.pinentry-tty;
      # enableSSHSupport = false;
    };

  };

  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # SYSTEM #
    # hyprland
    # aquamarine
    # hyprutils
    # hyprland-qtutils
    hyprpolkitagent
    # hyprcursor
    hyprland-protocols
    hypridle
    hyprsunset
    hyprpicker
    hyprpaper
    hyprlock
    hyprkeys
    tuigreet
    # xdg-desktop-portal-hyprland
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-wlr
    # xdg-desktop-portal-termfilechooser
    # wlsunset
    # libinput
    waybar
    wofi
    # yofi
    # anyrun
    # onagre
    # bemenu
    dconf
    glib
    mako
    # hyprnotify
    notify-desktop
    wvkbd
    wl-clipboard
    # wl-clipboard-rs
    wl-clip-persist
    hyprland-per-window-layout
    # update-systemd-resolved
    systemctl-tui
    # lazyjournal
    clipse
    udiskie
    # disko
    # virt-manager
    # libvirt
    # qemu
    powertop
    pciutils
    usbutils
    smartmontools
    nvme-cli
    libva-utils
    inxi
    #wluma
    brightnessctl
    dmidecode
    ripgrep
    # zoxide
    # television
    fd
    fzf
    evtest
    eza
    sqlite
    gpu-viewer
    # ollama-rocm
    # unigine-valley

    # PROGRAMMING #
    gcc
    gnumake
    # rustc
    # clippy
    # cargo
    # rust-analyzer
    # rustfmt
    # rustup
    # rustycli
    # rusty-man
    lldb
    go
    gotools
    go-tools
    delve
    gopls
    gofumpt
    golines
    golint
    revive
    golangci-lint
    golangci-lint-langserver
    gdlv
    gdb
    zig
    zls
    bash-language-server
    shfmt
    python313
    python313Packages.python-lsp-server
    # python313Packages.jedi-language-server
    python313Packages.python-lsp-ruff
    python313Packages.python-lsp-black
    python313Packages.debugpy
    # python313Packages.yapf
    ruff
    yapf
    lua
    lua-language-server
    stylua
    taplo
    yaml-language-server
    ansible-language-server
    vscode-langservers-extracted
    jsonrpc-glib
    jq
    nil
    nixfmt-rfc-style
    alejandra
    hexyl

    # WIRELESS/NETWORK/INTERNET #
    iw
    aircrack-ng
    wirelesstools
    airgeddon
    termshark
    sniffnet
    nmap
    tor
    wifite2
    kismet
    hcxtools
    hcxdumptool
    hostapd
    dhcpdump
    lighttpd
    bettercap
    dnsmasq
    openvpn
    bluetuith
    bluetui
    impala
    wget
    git
    # firefox
    # googleearth-pro
    # google-chrome
    chromium
    telegram-desktop
    # zoom-us
    rustmission
    reaverwps
    bully
    pixiewps
    crunch
    ettercap
    nchat
    tdl
    katana

    # CRYPTO #
    # gnupg
    gpg-tui
    pinentry-tty
    gpgme
    # electrum
    liana
    wasabiwallet
    # soteria

    # UTILL #
    gparted
    geteltorito
    # wezterm
    # ghostty
    # inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
    # foot
    fastfetch
    btop
    gnome-logs
    satty
    grim
    # slurp
    # grimblast
    chatgpt-cli
    gtt
    ttyper
    ngrrram
    tui-journal
    nix-tree
    lazysql
    tray-tui
    gvfs

    # MEDIA #
    # celluloid
    # tuicam
    asak
    # vlc
    mpv
    imv
    ffmpeg
    ffmpegthumbnailer
    #ytui-music
    # termusic
    youtube-tui
    yt-dlp
    ueberzugpp
    # loupe
    imagemagick
    # ncpamixer
    wiremix

    # EDITOR/OFFICE #
    # gimp
    poppler
    abiword
    # gnumeric
    zathura
    helix
    # zed-editor
    #evince
    unar
    p7zip
    zip
    unzip
    rar
    unrar
    # micro
    # yazi

    # THEMES #
    # simp1e-cursors
    bibata-cursors
    # gruvbox-plus-icons

  ];
}
