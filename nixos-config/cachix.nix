# ========================================
# 🧩 /etc/nixos/cachix.nix
# Автоматически управляемый файл для Cachix
# Добавляет бинарные кэши (substituters) через .nix файлы в /etc/nixos/cachix/
#
# ⚠️ ВАЖНО: Этот файл ПЕРЕЗАПИСЫВАЕТСЯ при выполнении `cachix use <name>`
# Если вы хотите сохранить изменения — не редактируйте его вручную
# ========================================
{ pkgs, lib, ... }:

let
  # 📁 Папка, где хранятся .nix файлы с конфигурацией кэшей
  folder = ./cachix;

  # 🔧 Функция: создаёт путь к файлу в папке cachix
  toImport = name: value: folder + ("/" + name);

  # 🔍 Фильтр: выбирает только обычные .nix файлы (не директории, не .git)
  filterCaches = key: value:
    value == "regular" && lib.hasSuffix ".nix" key;

  # 📥 Импортируем все .nix файлы из /etc/nixos/cachix/
  imports = lib.mapAttrsToList toImport (
    lib.filterAttrs filterCaches (builtins.readDir folder)
  );
in
{
  # ========================================
  # 📦 Импорты модулей
  # Подключает все файлы вида:
  #   ./cachix/hyprland.nix
  #   ./cachix/chaotic.nix
  #   ./cachix/yazi.nix
  # ========================================
  inherit imports;

  # ========================================
  # 🔗 Основной бинарный кэш NixOS
  # Используется по умолчанию для всех пакетов
  # ========================================
  nix.settings.substituters = [
    "https://cache.nixos.org/"
  ];
}
