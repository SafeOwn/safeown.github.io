{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.stable; [
    # gcc
    #    wezterm
    # zathura
    duckstation
    clash-verge-rev             # Прокси
    anydesk                     # Удалённый доступ
    rpcs3                       # PlayStation 3
    python313Packages.python-lsp-black   # Интеграция Black в LSP
  ];
}
