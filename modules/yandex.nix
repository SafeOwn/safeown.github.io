{ config, pkgs, yandex-browser, ... }:

{
    # Устанавливаем Яндекс.Браузер
    environment.systemPackages = [
        yandex-browser.packages."x86_64-linux".yandex-browser-stable
    ];
}
