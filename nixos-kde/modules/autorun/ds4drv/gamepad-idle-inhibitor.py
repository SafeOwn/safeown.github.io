#!/usr/bin/env python3
import evdev
import pyudev
import subprocess
import threading
import time
import sys

INACTIVITY_TIMEOUT = 30
POLL_INTERVAL = 1.0

class GamepadInhibitor:
    def __init__(self):
        self.inhibiting = False
        self.last_activity = 0
        self.inhibit_proc = None
        self.devices = {}
        self.lock = threading.Lock()

    def start_inhibit(self):
        if self.inhibiting:
            return
        print(f"🎮 [{time.strftime('%H:%M:%S')}] Активность — блокирую сон")
        self.inhibiting = True
        self.inhibit_proc = subprocess.Popen([
            "systemd-inhibit",
            "--what=idle:sleep",
            "--why=Gamepad button press",
            "--mode=block",
            "sleep", "infinity"
        ])

    def stop_inhibit(self):
        if not self.inhibiting:
            return
        print(f"💤 [{time.strftime('%H:%M:%S')}] Без активности — разрешаю сон")
        self.inhibiting = False
        if self.inhibit_proc:
            self.inhibit_proc.terminate()
            self.inhibit_proc.wait()
            self.inhibit_proc = None

        # 🔑 КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: сброс состояния KDE
        self.reset_kde_idle()

    def reset_kde_idle(self):
        """Принудительно сбрасываем idle-таймер в KDE Plasma"""
        try:
            # Шаг 1: Симулируем активность (выходим из "зависшего" состояния)
            subprocess.run([
                "qdbus", "org.kde.screensaver", "/ScreenSaver",
                "org.freedesktop.ScreenSaver.SimulateUserActivity"
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(0.1)

            # Шаг 2: Снова симулируем — это "обнуляет" таймер в Plasma 6
            subprocess.run([
                "qdbus", "org.kde.screensaver", "/ScreenSaver",
                "org.freedesktop.ScreenSaver.SimulateUserActivity"
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

    def simulate_user_activity(self):
        """Восстанавливает яркость при нажатии кнопки"""
        try:
            subprocess.run([
                "qdbus", "org.kde.screensaver", "/ScreenSaver",
                "org.freedesktop.ScreenSaver.SimulateUserActivity"
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

    def on_button_press(self):
        now = time.time()
        with self.lock:
            if now - self.last_activity < 0.2:  # защита от дребезга
                return
            self.last_activity = now
            print(f"🕹️  [{time.strftime('%H:%M:%S')}] Нажата кнопка")
            self.start_inhibit()
            self.simulate_user_activity()

    def monitor_devices(self):
        context = pyudev.Context()
        monitor = pyudev.Monitor.from_netlink(context)
        monitor.filter_by(subsystem='input')

        for device in context.list_devices(subsystem='input'):
            self.try_add_device(device)

        for device in iter(monitor.poll, None):
            if device.action == 'add':
                self.try_add_device(device)
            elif device.action == 'remove':
                self.remove_device(device)

    def try_add_device(self, device):
        devnode = device.device_node
        if not devnode or not devnode.startswith('/dev/input/event'):
            return
        try:
            dev = evdev.InputDevice(devnode)
            caps = dev.capabilities()
            if evdev.ecodes.EV_KEY in caps:
                key_codes = set(caps[evdev.ecodes.EV_KEY])
                gamepad_indicators = {
                    evdev.ecodes.BTN_A, evdev.ecodes.BTN_B,
                    evdev.ecodes.BTN_X, evdev.ecodes.BTN_Y,
                    evdev.ecodes.BTN_SOUTH, evdev.ecodes.BTN_EAST,
                    evdev.ecodes.BTN_TRIGGER, evdev.ecodes.BTN_THUMB,
                }
                if key_codes & gamepad_indicators:
                    print(f"🔌 [{time.strftime('%H:%M:%S')}] Геймпад: {dev.name}")
                    self.devices[devnode] = dev
                    threading.Thread(target=self.read_device, args=(dev,), daemon=True).start()
        except Exception:
            pass

    def remove_device(self, device):
        devnode = device.device_node
        if devnode in self.devices:
            print(f"⏏️  [{time.strftime('%H:%M:%S')}] Геймпад отключён")
            del self.devices[devnode]

    def read_device(self, dev):
        try:
            for event in dev.read_loop():
                if event.type == evdev.ecodes.EV_KEY and event.value == 1:
                    if event.code == 0:
                        continue
                    if evdev.ecodes.KEY_RESERVED <= event.code <= evdev.ecodes.KEY_MICMUTE:
                        continue
                    self.on_button_press()
        except OSError:
            pass

    def idle_watcher(self):
        while True:
            time.sleep(POLL_INTERVAL)
            now = time.time()
            with self.lock:
                time_since = now - self.last_activity
                if self.inhibiting and time_since > INACTIVITY_TIMEOUT:
                    self.stop_inhibit()

def main():
    inhibitor = GamepadInhibitor()
    threading.Thread(target=inhibitor.monitor_devices, daemon=True).start()
    threading.Thread(target=inhibitor.idle_watcher, daemon=True).start()

    print("🚀 Gamepad Idle Inhibitor для KDE (исправленный) запущен. Ctrl+C для выхода.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        inhibitor.stop_inhibit()
        print("\n🛑 Остановлен.")

if __name__ == "__main__":
    main()
