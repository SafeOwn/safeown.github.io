#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Восстанавливаем структуру репозитория..."

WORK_DIR="$HOME/nixos-config-repo"

# Защита от удаления чего-то важного
if [ -z "$WORK_DIR" ] || [ "$WORK_DIR" = "/" ] || [ "$WORK_DIR" = "$HOME" ]; then
  echo "❌ Опасное значение WORK_DIR: '$WORK_DIR'. Отмена."
  exit 1
fi

rm -rf "$WORK_DIR" 2>/dev/null || true
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Запускаем ssh-agent и добавляем ключ — чтобы не спрашивал пароль
eval $(ssh-agent -s) >/dev/null 2>&1
ssh-add /root/.ssh/id_ed25519 2>/dev/null || {
  echo "⚠️ Не удалось добавить SSH-ключ в агент. Убедись, что ключ существует и не требует пароля."
}

echo "📥 Стягиваем репозиторий safeown.github.io..."
git clone git@github.com:SafeOwn/safeown.github.io.git . || {
  echo "❌ Не удалось клонировать репозиторий. Проверь SSH-ключ и доступ к GitHub."
  exit 1
}

# ЖЁСТКО задаём ветку — надёжно и просто
BRANCH="master"

echo "🌿 Переключаемся на ветку: $BRANCH"
git checkout "$BRANCH" || git checkout -b "$BRANCH"

# Очищаем старую копию nixos-config
rm -rf nixos-config 2>/dev/null || true

echo "📂 Копируем ВЕСЬ /etc/nixos рекурсивно с разыменованием симлинков..."
cp -rL /etc/nixos nixos-config

# Создаём .gitignore для исключения временных файлов
cat > .gitignore <<'EOF'
# Временные и системные файлы
*.swp
*~
*.bak
.DS_Store
.nix-*
result*
.direnv
*.backup
*.old
*.tmp

# История и кэш
.bash_history
.zsh_history
.cache/
.local/share/nix/

# Файлы, созданные Nix при сборке
.drv
EOF

git add nixos-config/ .gitignore

if git diff --cached --quiet; then
  echo "✅ Нет изменений — коммит не нужен."
else
  git config --local user.name "SafeOwn"
  git config --local user.email "safe@safeown.ru"
  git commit -m "📦 NixOS config: full backup $(date '+%Y-%m-%d %H:%M')"
  echo "📝 Полный конфиг закоммичен."

  if git push origin "$BRANCH"; then
    echo "🎉 Успешно отправлено в GitHub!"
  else
    echo "❌ Ошибка при push. Попробуй вручную: git push origin $BRANCH"
    exit 1
  fi
fi

# Останавливаем ssh-agent
ssh-agent -k >/dev/null 2>&1 || true
