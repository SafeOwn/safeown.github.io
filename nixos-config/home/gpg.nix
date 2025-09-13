{ pkgs, ... }:
{
  # Кэширует пароли от ваших приватных ключей
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    pinentry.package = pkgs.pinentry-qt;
  };
}
