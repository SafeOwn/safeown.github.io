# ========================================
# Полная автоматическая настройка NixOS
# Запускай ВНУТРИ chroot: nixos-enter --root /mnt
# ========================================

set -euo pipefail

echo "🚀 Запуск полной настройки NixOS..."

# Проверка: в chroot?
if [ "$(stat -c %d:%i /)" = "$(stat -c %d:%i /proc/1/root/.)" ]; then
  echo "❌ Этот скрипт нужно запускать ВНУТРИ chroot (nixos-enter --root /mnt)"
  exit 1
fi

# 1. Включаем flakes
echo "🔧 Включаю flakes..."
mkdir -p /etc/nix
echo 'experimental-features = nix-command flakes' | tee /etc/nix/nix.conf

# 2. Создаём структуру
echo "📁 Создаю структуру папок..."
mkdir -p /etc/nixos/modules /etc/nixos/scripts

# 3. Переносим конфиг (если есть)
if [ -f /etc/nixos/configuration.nix ]; then
  mv /etc/nixos/configuration.nix /etc/nixos/modules/base.nix
  sed -i '/imports.*hardware/d' /etc/nixos/modules/base.nix
fi

# 4. Создаём flake.nix
echo "🔧 Создаю flake.nix..."
cat > /etc/nixos/flake.nix << 'EOF'
{
  description = "NixOS with Yandex Browser";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, yandex-browser, ... }:
    let
      system = "x86_64-linux";
      mkSystem = modules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = modules;
        specialArgs = { inherit yandex-browser; };
      };
    in
    {
      nixosConfigurations = {
        desktop = mkSystem [
          path:/etc/nixos/hardware-configuration.nix
          ./modules/base.nix
        ];

        yandex = mkSystem [
          path:/etc/nixos/hardware-configuration.nix
          ./modules/base.nix
          ({ config, pkgs, yandex-browser, ... }: {
            environment.systemPackages = [
              yandex-browser.packages."x86_64-linux".yandex-browser-stable
            ];
          })
        ];
      };
    };
}
EOF

# 5. Создаём скрипт бэкапа
echo "🔧 Создаю скрипт бэкапа..."
cat > /etc/nixos/scripts/nixos-backup.sh << 'EOF'
#!/bin/bash
set -euo pipefail
echo "🚀 Сохраняем конфигурацию NixOS в GitHub..."
CONFIG_DIR="$HOME/nixos-config"
COMMIT_MSG="Auto backup: $(date '+%Y-%m-%d %H:%M')"
mkdir -p "$CONFIG_DIR"
cd "$CONFIG_DIR"
if [ ! -d ".git" ]; then
  git clone git@github.com:SafeOwn/safeown.github.io.git .
  git checkout master
else
  git pull origin master --rebase
fi
mkdir -p ./nixos-config
sudo cp /etc/nixos/flake.nix ./nixos-config/
sudo cp /etc/nixos/flake.lock ./nixos-config/ 2>/dev/null || true
sudo rm -rf ./nixos-config/modules
sudo cp -r /etc/nixos/modules ./nixos-config/
git add nixos-config/
if ! git diff --cached --quiet; then
  git config --local user.name "SafeOwn"
  git config --local user.email "safe@safeown.ru"
  git commit -m "$COMMIT_MSG"
  echo "📝 Закоммичено: $COMMIT_MSG"
  if git push origin master; then
    echo "🎉 Успешно отправлено в GitHub!"
  else
    echo "❌ Ошибка при push"
    exit 1
  fi
fi
EOF

chmod +x /etc/nixos/scripts/nixos-backup.sh

# 6. Создаём алиасы
echo "🔧 Создаю алиасы..."
cat >> /root/.bashrc << 'EOF'

# NixOS aliases
alias nixos-backup="sudo /etc/nixos/scripts/nixos-backup.sh"
nixos-rebuild() {
  command nixos-rebuild "$@"
  if [[ "$?" == "0" && "$1" == "switch" ]]; then
    echo "🔁 Автобэкап конфигурации..."
    nixos-backup
  fi
}
EOF

# 7. SSH для GitHub
echo "🔧 Настройка SSH..."
mkdir -p /root/.ssh
cat >> /root/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_nixos
  IdentitiesOnly yes
EOF

# Генерируем ключ (если нет)
if [ ! -f /root/.ssh/id_ed25519_nixos ]; then
  ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519_nixos -C "nixos@safeown.ru" -N ""
  echo "🔑 Скопируй этот ключ в GitHub: https://github.com/settings/ssh"
  cat /root/.ssh/id_ed25519_nixos.pub
fi

# 8. Запускаем SSH-агент
eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_ed25519_nixos

# 9. Пересобираем
echo "🔄 Пересобираем систему..."
nixos-rebuild switch --flake /etc/nixos#yandex

# 10. Готово
echo "🎉 Готово! Теперь:"
echo "   nixos-backup — сохранит конфиг в GitHub"
echo "   Перезагрузись: reboot"
