#!/usr/bin/env bash

# Цвета
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
BOLD='\e[1m'
NC='\e[0m'

echo -e "${CYAN}${BOLD}"
echo "🔧 ИНСТРУКЦИЯ: Ручная разметка диска через cgdisk (рекомендуется)"
echo -e "${NC}"
echo -e "${RED}⚠️  ВАЖНО: Эта операция может УДАЛИТЬ ВСЕ ДАННЫЕ на выбранном диске.${NC}"
echo -e "${YELLOW}   Убедитесь, что вы выбрали ПРАВИЛЬНЫЙ диск (например, /dev/sda, /dev/nvme0n1).${NC}"
echo ""
echo -e "${YELLOW}📌 Шаг 1. Посмотрите список дисков:${NC}"
echo ""
lsblk -f
echo ""
echo -e "${YELLOW}📌 Шаг 2. Запустите cgdisk на выбранном диске (замените YOUR_DISK):${NC}"
echo -e "${BLUE}        cgdisk /dev/YOUR_DISK${NC}"
echo ""
echo -e "${YELLOW}         Пример для UEFI + GPT:${NC}"
echo -e "${BLUE}         1. Удалите старые разделы (если есть) — клавиша [d]${NC}"
echo -e "${BLUE}         2. Создайте EFI-раздел:${NC}"
echo -e "${BLUE}            - [n] → Enter → First sector: 2048, Last: +512M → Type: EF00${NC}"
echo -e "${BLUE}         3. Создайте swap-раздел:${NC}"
echo -e "${BLUE}            - [n] → Enter → First: (авто), Last: +8G → Type: 8200${NC}"
echo -e "${BLUE}         4. Создайте корневой раздел:${NC}"
echo -e "${BLUE}            - [n] → Enter → First: (авто), Last: (оставшееся место) → Type: 8300${NC}"
echo -e "${BLUE}         5. Проверьте таблицу — [p]${NC}"
echo -e "${BLUE}         6. Запишите изменения — [w] → YES${NC}"
echo ""
echo -e "${YELLOW}📌 Шаг 3. Форматирование разделов:  ( Обязательно перепроверяем разделы lsblk -f) ${NC}"
echo -e "${BLUE}         mkfs.fat -F 32 -n boot /dev/YOUR_DISK1    # EFI (обычно part1 или p1)${NC}"
echo -e "${BLUE}         mkswap -L swap /dev/YOUR_DISK2            # swap${NC}"
echo -e "${BLUE}         mkfs.ext4 -L nixos /dev/YOUR_DISK3        # root${NC}"
echo ""
echo -e "${YELLOW}📌 Шаг 4. Смонтировать разделы:${NC}"
echo -e "${BLUE}         mount /dev/YOUR_DISK3 /mnt                # корень${NC}"
echo -e "${BLUE}         mkdir -p /mnt/boot${NC}"
echo -e "${BLUE}         mount /dev/YOUR_DISK1 /mnt/boot           # EFI${NC}"
echo -e "${BLUE}         swapon /dev/YOUR_DISK2                    # swap${NC}"
echo ""
echo -e "${YELLOW}📌 Шаг 5. Проверить монтирование:${NC}"
echo -e "${BLUE}         lsblk -f${NC}"
echo -e "${BLUE}         mount | grep /mnt${NC}"
echo ""
echo -e "${RED}${BOLD} Сфотографируйте инструкцию на телефон!!!!! ${NC}"
echo ""
echo -e "${GREEN}👉 После того, как вы ВРУЧНУЮ выполнили разметку и монтирование — нажмите [Enter], чтобы продолжить.${NC}"
echo -e "${RED}   [Ctrl+C] — отменить установку.${NC}"
read -r

set -euo pipefail  # Сразу падать при ошибках — безопаснее

export NIX_CONFIG="experimental-features = nix-command flakes"

echo -e "${GREEN}📥 Клонируем репозиторий...${NC}"
git clone https://github.com/SafeOwn/safeown.github.io.git   /tmp/tmp-nixos-kde

echo -e "${GREEN}📂 Копируем конфиги в /mnt/etc/nixos...${NC}"
mkdir -p /mnt/etc/nixos
cp -r /tmp/tmp-nixos-kde/nixos-kde/* /mnt/etc/nixos/
rm -rf /tmp/tmp-nixos-kde

echo -e "${YELLOW}⚠️  Отключаем потенциально опасные модули...${NC}"
mv /mnt/etc/nixos/modules/boot-disk.nix /mnt/etc/nixos/modules/boot-disk.nix.DISABLED 2>/dev/null || true
mv /mnt/etc/nixos/modules/hardware/mount.nix /mnt/etc/nixos/modules/mount.nix.DISABLED 2>/dev/null || true

echo ""
echo -e "${RED}❗ ПРИ УСТАНОВКЕ НА НОВОЕ ЖЕЛЕЗО:${NC}"
echo -e "${BLUE}1. Откройте nano /mnt/etc/nixos/configuration.nix${NC}"
echo -e "${BLUE}2. Закомментируйте импорты:${NC}"
echo -e "${BLUE}      # ./modules/boot-disk.nix${NC}"
echo -e "${BLUE}      # ./modules/hardware/mount.nix${NC}"
echo -e "${YELLOW}3. Сохраните файл в nano Ctrl + O и Enter, для выхода Ctrl + X.${NC}"
echo ""
echo -e "${GREEN}👉 Нажмите [Enter] для редактирования. [Ctrl+C] для отмены.${NC}"
read -r
nano /mnt/etc/nixos/configuration.nix

echo -e "${YELLOW}⚙️  Генерируем hardware-configuration.nix под текущее железо...${NC}"
nixos-generate-config --root /mnt

echo -e "${GREEN}🚀 Запускаем установку системы...${NC}"
nixos-install --root /mnt --flake /mnt/etc/nixos#pc

# ============ УСТАНОВКА ПАРОЛЯ ДЛЯ ПОЛЬЗОВАТЕЛЯ ============
while true; do
    echo ""
    echo -e "${GREEN}👤 Введите имя пользователя, для которого нужно установить пароль (например: safe, alice, user):${NC}"
    read -r USERNAME

    if [ -z "$USERNAME" ]; then
        echo -e "${YELLOW}→ Пропускаем установку пароля пользователя.${NC}"
        break
    fi

    if nixos-enter --root /mnt --command id "$USERNAME" >/dev/null 2>&1; then
        echo -e "${GREEN}→ Устанавливаем пароль для: $USERNAME${NC}"
        nixos-enter --root /mnt --command passwd "$USERNAME"
        break
    else
        echo -e "${RED}⚠️  Пользователь '$USERNAME' не существует в системе.${NC}"
        echo -e "${YELLOW}   → Убедитесь, что он объявлен в /mnt/etc/nixos/configuration.nix, например:${NC}"
        echo -e "${BLUE}     users.users.$USERNAME.isNormalUser = true;${NC}"
        echo -e "${GREEN}   → Нажмите Enter, чтобы ввести имя снова, или Ctrl+C для пропуска.${NC}"
        read -r
    fi
done

echo -e "${GREEN}✅ Установка завершена.${NC}"
echo ""
echo -e "${GREEN}👉 Вы уверены что хотите перезагрузится [Enter] для продолжения. [Ctrl+C] для отмены.${NC}"
read -r
reboot
