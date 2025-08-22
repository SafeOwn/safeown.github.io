# ======== 1) ПЕРЕУСТАНОВКА с НУЛЯ ========    


# После nixos-generate-config
nixos-enter --root /mnt

# Скачай и запусти скрипт
curl -L https://safeown.github.io/nixos-full-setup.sh | bash

# ======== 2) ПЕРЕУСТАНОВКА ПОСЛЕ СБОЯ ========



# 1. Разметь диск, смонтируй / в /mnt
mount /dev/sda1 /mnt

# 2. Сгенерируй базовый конфиг (нужен для chroot)
nixos-generate-config --root /mnt

# 3. Войди в chroot
nixos-enter --root /mnt

# 4. Запусти восстановление
curl -L https://safeown.github.io/nixos-restore.sh | bash 

✅ Через 2 минуты — всё восстановлено. 
