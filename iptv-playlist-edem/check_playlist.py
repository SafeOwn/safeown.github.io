import re
import requests
import time
import os
import hashlib
from urllib.parse import urljoin

# НАСТРОЙКИ
MAIN_PLAYLIST = "EdemTV-main.m3u"
KEYS_FILE = "keys.txt"
MIN_TOTAL_BYTES = 12000 * 1024  # 12 MB
TEST_TIME = 15  # секунд

def has_real_video(ts_segments: list) -> bool:
    """Проверяет, меняется ли изображение (борьба с 'залипшими' потоками)"""
    if len(ts_segments) < 2:
        print("  ⚠️ Недостаточно сегментов для проверки движения")
        return False

    idr_payloads = []
    for idx, ts_data in enumerate(ts_segments[:2]):  # анализ первых 2 сегментов
        # Ищем IDR NAL unit (тип 5) — полный кадр
        found = False
        for i in range(len(ts_data) - 6):
            # Проверка 4-байтного start code: 0x00000001
            if ts_data[i:i+4] == b'\x00\x00\x00\x01':
                nal_type = ts_data[i+4] & 0x1F
                if nal_type == 5:  # IDR
                    payload = ts_data[i+5:i+5+1024]  # первые 1КБ данных кадра
                    if len(payload) > 300:
                        idr_payloads.append(payload)
                        found = True
                        break
            # Проверка 3-байтного start code: 0x000001
            elif ts_data[i:i+3] == b'\x00\x00\x01':
                nal_type = ts_data[i+3] & 0x1F
                if nal_type == 5:
                    payload = ts_data[i+4:i+4+1024]
                    if len(payload) > 300:
                        idr_payloads.append(payload)
                        found = True
                        break
        if not found:
            print(f"  ⚠️ В сегменте {idx+1} не найден IDR-кадр")
    
    if len(idr_payloads) < 2:
        return False

    h1 = hashlib.md5(idr_payloads[0]).hexdigest()[:8]
    h2 = hashlib.md5(idr_payloads[1]).hexdigest()[:8]
    print(f"  🖼️ I-кадры: {h1} vs {h2}")
    
    if h1 != h2:
        print("  🎞️ ✅ Изображение меняется — поток живой")
        return True
    else:
        print("  🖼️ ❌ I-кадры одинаковые — поток 'залипший'")
        return False

def check_aes_key_availability(playlist_url: str, playlist_content: str):
    """Проверяет наличие и доступность #EXT-X-KEY"""
    key_match = re.search(r'#EXT-X-KEY:([^\n]*)', playlist_content)
    if not key_match:
        return True  # шифрования нет — ок

    key_line = key_match.group(1)
    method_match = re.search(r'METHOD=([^,\s]+)', key_line)
    uri_match = re.search(r'URI="([^"]+)"', key_line)

    if not method_match or not uri_match:
        print("  ⚠️ Невозможно распарсить EXT-X-KEY")
        return False

    method = method_match.group(1)
    if method != "AES-128":
        print(f"  ⚠️ Неизвестный метод шифрования: {method}")
        return False

    key_uri = uri_match.group(1)
    full_key_url = urljoin(playlist_url, key_uri)
    print(f"  🔐 Поток зашифрован (AES-128). Проверка ключа: {full_key_url}")

    try:
        key_resp = requests.get(full_key_url, timeout=8)
        if key_resp.status_code == 200:
            key_data = key_resp.content
            if len(key_data) in (16, 32):
                print(f"  ✅ Ключ получен ({len(key_data)} байт)")
                return True
            else:
                print(f"  ❌ Ключ неверного размера: {len(key_data)} байт")
                return False
        else:
            print(f"  ❌ Ключ недоступен (HTTP {key_resp.status_code})")
            return False
    except Exception as e:
        print(f"  ❌ Ошибка при получении ключа: {e}")
        return False

def get_m3u8_total_bytes(url, test_time=TEST_TIME):
    """Проверяет: объём, шифрование, наличие живого видео"""
    print("  📊 Проверка потока...")
    
    try:
        playlist_response = requests.get(url, timeout=10)
        if playlist_response.status_code != 200:
            print("  ❌ Плейлист недоступен")
            return 0, 0, False

        playlist_content = playlist_response.text

        # 🔐 Проверка шифрования
        if not check_aes_key_availability(url, playlist_content):
            print("  ❌ Поток зашифрован, но ключ недоступен")
            return 0, 0, False

        # Извлечение .ts
        ts_urls = re.findall(r'^[^#\n].*\.ts.*$', playlist_content, re.MULTILINE)

        if not ts_urls:
            # Поиск вложенного плейлиста
            sub_playlist_urls = re.findall(r'^[^#\n].*\.m3u8.*$', playlist_content, re.MULTILINE)
            if sub_playlist_urls:
                sub_url = urljoin(url, sub_playlist_urls[0])
                try:
                    sub_response = requests.get(sub_url, timeout=10)
                    if sub_response.status_code == 200:
                        sub_content = sub_response.text
                        if not check_aes_key_availability(sub_url, sub_content):
                            print("  ❌ Вложенный плейлист зашифрован без доступного ключа")
                            return 0, 0, False
                        ts_urls = re.findall(r'^[^#\n].*\.ts.*$', sub_content, re.MULTILINE)
                except Exception as e:
                    print(f"  ❌ Ошибка загрузки вложенного плейлиста: {e}")

        if not ts_urls:
            print("  ❌ Нет сегментов .ts")
            return 0, 0, False

        total_bytes = 0
        start_check_time = time.time()
        segments_checked = 0
        max_segments = min(4, len(ts_urls))  # достаточно 4 сегментов
        segment_bodies = []  # ← храним тела для анализа движения

        for i in range(max_segments):
            elapsed = time.time() - start_check_time
            if elapsed > test_time:
                break

            ts_url = urljoin(url, ts_urls[i])
            try:
                seg_response = requests.get(ts_url, timeout=8)
                if seg_response.status_code == 200:
                    content = seg_response.content
                    seg_size = len(content)
                    total_bytes += seg_size
                    segments_checked += 1

                    # Сохраняем только достаточно большие сегменты (>50 КБ)
                    if seg_size > 50_000:
                        segment_bodies.append(content)
                        print(f"  📦 Сегмент {i+1}: {seg_size//1024} KB")
                elif seg_response.status_code in [403, 404]:
                    print(f"  ❌ Сегмент {i+1} недоступен (HTTP {seg_response.status_code})")
                    break
            except Exception as e:
                print(f"  ❌ Ошибка загрузки сегмента {i+1}: {e}")
                continue

        total_time = time.time() - start_check_time
        print(f"  📊 Итого: {total_bytes//1024} KB за {total_time:.1f} сек ({len(segment_bodies)} сегм. для анализа)")

        # 🔍 Анализ: есть ли движение?
        real_video = has_real_video(segment_bodies)
        return total_bytes, total_time, real_video

    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        return 0, 0, False

def is_stream_good(url, min_bytes=MIN_TOTAL_BYTES):
    total_bytes, total_time, has_video = get_m3u8_total_bytes(url, TEST_TIME)
    good_by_size = total_bytes >= min_bytes
    result = good_by_size and has_video
    return result

def replace_key_in_url(url, new_key):
    pattern = r'(http://[^/]+/iptv/)([^/]+)(/6238/index\.m3u8)'
    return re.sub(pattern, r'\g<1>' + new_key + r'\g<3>', url)

def extract_key_from_playlist(playlist_file):
    try:
        with open(playlist_file, 'r', encoding='utf-8') as f:
            content = f.read()
        match = re.search(r'http://[^/]+/iptv/([^/]+)/6238/index\.m3u8', content)
        if match:
            key = match.group(1)
            print("  ✅ Найден ключ в " + playlist_file + ": " + key[:20] + "...")
            return key
        else:
            print("  ❌ Ключ не найден в " + playlist_file)
            return None
    except Exception as e:
        print("  ❌ Ошибка чтения " + playlist_file + ": " + str(e))
        return None

def load_keys_from_file(filename):
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            keys = [line.strip() for line in f if line.strip()]
        print("  ✅ Загружено " + str(len(keys)) + " ключей")
        return keys
    except Exception as e:
        print("  ❌ Ошибка загрузки ключей: " + str(e))
        return []

def copy_playlist(source, destination):
    try:
        with open(source, 'r', encoding='utf-8') as src:
            with open(destination, 'w', encoding='utf-8') as dst:
                dst.write(src.read())
        print("  ✅ " + source + " → " + destination)
        return True
    except Exception as e:
        print("  ❌ Ошибка копирования: " + str(e))
        return False

def main():
    print("📺 ПЕРЕКЛЮЧЕНИЕ ПЛЕЙЛИСТОВ (v3 — проверка движения)")
    print("=" * 60)
    print("Основной плейлист: " + MAIN_PLAYLIST)
    print("Ключи: " + KEYS_FILE)
    print("Минимум: " + str(MIN_TOTAL_BYTES//1024) + " KB")
    print()

    if not os.path.exists(KEYS_FILE):
        print("❌ Не найден файл ключей: " + KEYS_FILE)
        return False
    if not os.path.exists(MAIN_PLAYLIST):
        print("❌ Не найден основной плейлист: " + MAIN_PLAYLIST)
        return False

    print("🔍 Загрузка ключей...")
    keys = load_keys_from_file(KEYS_FILE)
    if not keys:
        print("❌ Нет ключей для проверки")
        return False
    print()

    print("🔍 ПРОВЕРКА ВСЕХ КЛЮЧЕЙ ПО ПОРЯДКУ...")
    working_key_index = -1

    for i, key in enumerate(keys):
        print(f"🔍 КЛЮЧ {i+1} ({key[:15]}...):")
        test_url = replace_key_in_url("http://kuh5nj4q.rostelekom.xyz/iptv/KEY/6238/index.m3u8", key)
        is_good = is_stream_good(test_url, MIN_TOTAL_BYTES)
        print("  " + ("✅ РАБОЧИЙ" if is_good else "❌ НЕ РАБОТАЕТ"))
        print()
        if is_good:
            working_key_index = i
            break

    if working_key_index == -1:
        print("❌ ВСЕ КЛЮЧИ НЕ РАБОТАЮТ")
        success = False
    else:
        reserve_number = working_key_index + 1
        reserve_filename = f"EdemTV-reserve{reserve_number}.m3u"
        print(f"✅ НАЙДЕН РАБОЧИЙ КЛЮЧ: №{reserve_number}")

        if os.path.exists(reserve_filename):
            print(f"🔄 Обновляем {MAIN_PLAYLIST} из {reserve_filename}...")
            success = copy_playlist(reserve_filename, MAIN_PLAYLIST)
        else:
            print(f"❌ Файл {reserve_filename} отсутствует")
            success = False

    print()
    print("=" * 60)
    if success:
        print(f"🎉 УСПЕХ: {MAIN_PLAYLIST} обновлён на ключ №{working_key_index + 1}")
    else:
        print("❌ ОБНОВЛЕНИЕ НЕ ВЫПОЛНЕНО")
    print("=" * 60)
    return success

if __name__ == "__main__":
    try:
        success = main()
    except Exception as e:
        print(f"❌ Критическая ошибка: {e}")
        success = False

    if os.environ.get('GITHUB_ACTIONS'):
        print("🤖 Завершено в GitHub Actions")
    else:
        try:
            input("Нажмите Enter для выхода...")
        except EOFError:
            print("✅ Автоматическое завершение")
