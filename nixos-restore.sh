# ========================================
# nixos-restore.sh
# Полное восстановление NixOS из GitHub
# Запускай ВНУТРИ chroot: nixos-enter --root /mnt
# ========================================

set -euo pipefail

echo "🚀 Запуск восстановления NixOS из GitHub..."

# Проверка: в chroot?
if [ "$(stat -c %d:%i /)" = "$(stat -c %d:%i /proc/1/root/.)" ]; then
  echo "❌ Этот скрипт нужно запускать ВНУТРИ chroot (nixos-enter --root /mnt)"
  exit 1
fi

# 1. Включаем flakes
echo "🔧 Включаю flakes..."
mkdir -p /etc/nix
echo 'experimental-features = nix-command flakes' | tee /etc/nix/nix.conf

# 2. Устанавливаем Git
echo "🔧 Устанавливаю Git..."
nix-env -iA nixos.git

# 3. Клонируем репозиторий
echo "📥 Клонирую конфигурацию из GitHub..."
cd /tmp
git clone https://github.com/SafeOwn/safeown.github.io.git repo-temp
mkdir -p /etc/nixos
cp -r repo-temp/nixos-config/* /etc/nixos/
rm -rf repo-temp

# 4. Генерируем новый hardware-configuration.nix
echo "🔧 Генерирую hardware-configuration для этой машины..."
nixos-generate-config --root / --show-hardware-config > /etc/nixos/hardware-configuration.nix

# 5. Проверяем, что flake.nix на месте
if [ ! -f /etc/nixos/flake.nix ]; then
  echo "❌ Не найден flake.nix! Проверь, что nixos-config содержит flake.nix"
  exit 1
fi

# 6. Создаём папку для скриптов
mkdir -p /etc/nixos/scripts

# 7. Восстанавливаем скрипт бэкапа (если есть в репозитории — можно пропустить)
# Если в репозитории нет — раскомментируй и вставь вручную

# 8. Создаём алиасы
echo "🔧 Настраиваю алиасы..."
cat >> /root/.bashrc << 'EOF'

# NixOS aliases
alias nixos-backup="sudo /etc/nixos/scripts/nixos-backup.sh"

# Автобэкап после rebuild
nixos-rebuild() {
  command nixos-rebuild "$@"
  if [[ "$?" == "0" && "$1" == "switch" ]]; then
    echo "🔁 Автобэкап конфигурации..."
    nixos-backup
  fi
}
EOF

# 9. SSH для GitHub (без ключа — только инфраструктура)
echo "🔧 Настраиваю SSH (ключ нужно добавить вручную)"
mkdir -p /root/.ssh
cat >> /root/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_nixos
  IdentitiesOnly yes
EOF

echo "🔑 Чтобы бэкап работал: добавь свой SSH-ключ в ~/.ssh/id_ed25519_nixos"
echo "   Или создай новый: ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_nixos"
echo "   Потом добавь публичный ключ в GitHub: https://github.com/settings/ssh"

# 10. Пересобираем систему
echo "🔄 Пересобираем систему..."
nixos-rebuild switch --flake /etc/nixos#yandex

# 11. Готово
echo "🎉 Восстановление завершено!"
echo "   Система готова к использованию."
echo "   Добавь SSH-ключ, чтобы работал nixos-backup"
echo "   Перезагрузись: reboot"
