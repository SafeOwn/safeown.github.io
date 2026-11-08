adb start-server
adb connect 192.168.1.xx:5555
adb shell 
su

1. Телевизор HD (50 Гц) — для российского ТВ и сериалов (25 fps)
setprop persist.vendor.resolution.main "1920x1080@50-2448-2492-2640-1084-1089-1125-5"; setprop persist.vendor.framebuffer.main "1920x1080@50-2448-2492-2640-1084-1089-1125-5"; reboot

2. Телевизор HD (60 Гц) — для YouTube и спорта
setprop persist.vendor.resolution.main "1920x1080@60-2008-2052-2200-1084-1089-1125-5"; setprop persist.vendor.framebuffer.main "1920x1080@60-2008-2052-2200-1084-1089-1125-5"; reboot

3. Монитор 4K (24 Гц) — для кино в 4K
setprop persist.vendor.resolution.main "3840x2160@24-5116-5204-5500-2168-2178-2250-5"; setprop persist.vendor.framebuffer.main "3840x2160@24-5116-5204-5500-2168-2178-2250-5"; reboot

4. Монитор 4K (30 Гц) — если хочешь чуть более быстрый интерфейс на мониторе
setprop persist.vendor.resolution.main "3840x2160@30-4016-4104-4400-2168-2178-2250-5"; setprop persist.vendor.framebuffer.main "3840x2160@30-4016-4104-4400-2168-2178-2250-5"; reboot

Проверка разрешения и частоты кадров
dumpsys display | grep fps= 
