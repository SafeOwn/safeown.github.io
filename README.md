## ==== [!ПЕРЕУСТАНОВКА с НУЛЯ NIXOS KDE 6] ====    


>Как только загрузитесь через live cd:<br/>
  введите `sudo -i` и `setfont sun12x22`<br/> 
Скачай и запусти скрипт
```
curl -L https://safeown.github.io/nixos-kde-install.sh | bash
```
  или
```
bash <(curl -fsSL https://raw.githubusercontent.com/SafeOwn/safeown.github.io/master/nixos-kde-install.sh)
```
  или 
Сократите ссылку через https://bitly.com/

Вся инструкция в скрипте по шагам...



## Для второй системы Windows10 положить файлы efi
смотрим lsblk -f

```
mount /dev/nvme0n1p2 /tmp
cp /tmp/boot/EFI/Microsoft/ /boot/EFI/Microsoft/Boot/
```

Boot сам найдет после перезагрузки
