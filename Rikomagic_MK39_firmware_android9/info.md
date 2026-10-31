[Прошивка для Rikomagic MK39 RK3399] Bluetooth, Led лампочка и Пульт ИК на Android 9: исправленный boot.img

1) Android 9 Yundoo Y8 с приставки  (Проблема. В прошивке не работал Bluetooth, Led лампочка и Пульт ИК. Делаем фикс заливаем "boot.img")
https://drive.google.com/file/d/15kNEmsB2cP-TQCVMKhGZzCXh7faPligu/view

2) Скачиваем строго эту версию RKDevTool_Release_v2.86
	Запускаем RKDevTool и заливаем прошивку https://drive.google.com/file/d/15kNEmsB2cP-TQCVMKhGZzCXh7faPligu/view "updateY8.img"
		Выключите приставку питание из розетки, 
		Подсоединить один конец провода USB к компьютеру другой type-c к приставке в программе RKDevTool -> Loader
		Держите ресет кнопку на задней панели скрепкой и вставляйте провод от питания пока не увидите надпись 
		Upgrade Frimware -> Frimware -> открываем прошивку "Android 9 Yundoo Y8 (updateY8.img)" и нажимаем Upgrade
		Проверяем прошивку
	Убеждаемся какой адрес boot.img (внимание могут быть последствия кирпича, если не на тот адрес залить)
		Advanced Function -> Frimware -> Загрузить "updateY8.img" -> Unpack -> ищем файл parameter.txt и ищем строчку типа "0x00010000@0x0000e800(boot)" значит "0x0000e800"
	Заливаем boot.img исправление Bluetooth, led лампочка спереди и пульт ик
		Download Image -> Снимите все галочки и удалите все строки
		Добавьте новую строку в таблицу: Address 0x0000e800, Name boot, Path к скачанному boot.img. 
		Адрес сверьте со своим parameter.txt: если он другой, берите свой.
		Отметьте галочкой только boot 
		Нажмите «Run».
    Проверяем работает ли Bluetooth в настройках и  led лампочка спереди и пульт ик.

Откат: (Advanced Function -> Frimware -> Загрузить "updateY8.img" -> Unpack -> ищем файл parameter.txt и boot.img) прошейте сохранённый оригинальный boot.img тем же способом. Loader и uboot не затрагиваются, так что приставка всегда восстанавливается через Maskrom.

Если все плохо: Advanced Function -> Go Maskrom (или пробуйте Loader)
				Upgrade Frimware -> EraseFlash или	Advanced Function -> Erase All
				Upgrade Frimware -> Frimware -> открываем прошивку "Android 9 Yundoo Y8 (updateY8.img)" и нажимаем Upgrade
				
-----------------------------------------------------------------------------------------------------------------------
Что исправлено в boot.img (правился только DTB, ядро и ramdisk не трогались):
    Bluetooth: в узле wireless-bluetooth параметр BT,wake_gpio изменён с <0xda 0x1a 0x00> на <0xda 0x1b 0x00>. Остальные параметры остались как были.
    Светодиод: рабочий индикатор (синий) переведён на gpio4 пин 0x1a, retain-state-suspended сохранён.
	Пульт ИК: все кнопки работают ir_key5 {
								  rockchip,usercode = <0xff00>;
								  rockchip,key_table = <0xeb 0x74 0xfe 0x71 0xec 0x8b 0xa3 0x9e 0xfc 0x67 0xfd 0x6c 0xf1 0x69 0xe5 0x6a 0xa7 0x72 0xf4 0x73 0xb7 0x66 0xf8 0xe8>;
							  };

Что не сделано:
    Красная лампочка в режиме ожидания не работает. Она управляется сигналом MCU, а gpio-poweroff не подходит, потому что функцию выключения уже занимает PMIC.

-----------------------------------------------------------------------------------------------------------------------
Важно:

    Образ подходит только для той же прошивки [версия] и платы с чипом Wi-Fi/BT AP6354. На других ревизиях платы номера пинов могут отличаться.
    Отключать vbmeta не потребовалось: образ загружается без этого.
    Шьёте на свой риск. Проверено на одной приставке.

-----------------------------------------------------------------------------------------------------------------------
Как это делалось (для желающих повторить): boot.img 
	распаковывается через imgRePackerRK boot.img
	запаковывалось  через imgRePackerRK boot.img.cfg
	Ищем файл boot.img.dump -> second.dump -> rk-kernel.dtb 
	Декомпилируется DTC-GUI_for_Windows_v1.0.5_compiled командой dtc -I dtb -O dts, пример:
		dtc.exe -I dtb -O dts -o rk-kernel_t.dts rk-kernel_t.dtb
	Открываем файл "rk-kernel_t.dts" в текстовом файле
		Правим одно число, компилируем обратно и собираем в образ. 
		Важный совет: не переписывайте узлы целиком и не заменяйте числовые phandle метками, иначе теряются phandle и приставка уходит в ребут.
	Компилируется
		dtc.exe -I dts -O dtb -o rk-kernel_t2.dtb rk-kernel_t.dts
	Заменяем boot.img.dump -> second.dump -> rk-kernel.dtb
	Запаковываем  через imgRePackerRK boot.img.cfg
	Получаем "boot.img" и заливаем через программу RKDevTool
		


