import re
import requests
import time
import os
from urllib.parse import urljoin
import hashlib

# НАСТРОЙКИ
MAIN_PLAYLIST = "EdemTV-main.m3u"
KEYS_FILE = "keys.txt"
MIN_TOTAL_BYTES = 12000 * 1024  # 12 MB
TEST_TIME = 20  # секунд

def has_h264_video(ts_data: bytes) -> bool:
    """Проверяет, содержит ли TS-данные H.264-видео (по наличию NAL IDR/SPS/PPS)"""
    # Ищем start-code: 0x00000001 или 0x000001
    # Затем тип NAL: 0x65 (IDR), 0x41 (non-IDR), 0x67 (SPS), 0x68 (PPS)
    patterns = [
        b'\x00\x00\x00\x01\x65',  # IDR
        b'\x00\x00\x01\x65',
        b'\x00\x00\x00\x01\x41',  # non-IDR
        b'\x00\x00\x01\x41',
        b'\x00\x00\x00\x01\x67',  # SPS — самый надёжный
        b'\x00\x00\x01\x67',
        b'\x00\x00\x00\x01\x68',  # PPS
        b'\x00\x00\x01\x68',
    ]
    for pat in patterns:
        if pat in ts_data:
            return True
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
    """Проверяет объем данных, шифрование и наличие видео в M3U8 потоке"""
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
        
        # Извлечение TS-сегментов
        ts_urls = re.findall(r'^[^#\n].*\.ts.*$', playlist_content, re.MULTILINE)
        
        if not ts_urls:
            # Попытка найти вложенный плейлист
            sub_playlist_urls = re.findall(r'^[^#\n].*\.m3u8.*$', playlist_content, re.MULTILINE)
            if sub_playlist_urls:
                sub_url = urljoin(url, sub_playlist_urls[0])
                try:
                    sub_response = requests.get(sub_url, timeout=10)
                    if sub_response.status_code == 200:
                        sub_content = sub_response.text
                        # 🔐 Проверка шифрования и во вложенном плейлисте
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
        max_segments = min(6, len(ts_urls))
        video_found = False
        segment_hashes = set()
        
        for i in range(max_segments):
            elapsed = time.time() - start_check_time
            if elapsed > test_time:
                break
            if segments_checked >= 6:
                break
                
            ts_url = urljoin(url, ts_urls[i])
            try:
                seg_response = requests.get(ts_url, timeout=10)
                if seg_response.status_code == 200:
                    content = seg_response.content
                    seg_size = len(content)
                    total_bytes += seg_size
                    segments_checked += 1
                    
                    # 📦 Проверка: есть ли видео в сегменте
                    if not video_found and seg_size > 1000 and has_h264_video(content):
                        video_found = True
                        print(f"  🎥 Видео найдено в сегменте {i+1}")
                    
                    # 🔄 Проверка: не повторяется ли сегмент (защита от заглушки)
                    h = hashlib.md5(content).hexdigest()[:8]
                    segment_hashes.add(h)
                    
                elif seg_response.status_code in [403, 404]:
                    print(f"  ❌ Сегмент {i+1} недоступен (HTTP {seg_response.status_code})")
                    break
            except Exception as e:
                print(f"  ❌ Ошибка загрузки сегмента {i+1}: {e}")
                continue
        
        total_time = time.time() - start_check_time
        unique_segments = len(segment_hashes)
        print(f"  📊 {total_bytes//1024} KB за {total_time:.1f} сек ({segments_checked} сегм., {unique_segments} уникальных)")
        
        # Если все сегменты одинаковые — подозрительно (зацикленная заглушка)
        if segments_checked >= 3 and unique_segments == 1:
            print("  ⚠️ Все сегменты одинаковые — возможно, заглушка")
            video_found = False  # сбрасываем, даже если "похоже на видео"
        
        return total_bytes, total_time, video_found
        
    except Exception as e:
        print(f"  ❌ Ошибка: {e}")
        return 0, 0, False

def is_stream_good(url, min_bytes=MIN_TOTAL_BYTES):
    """Проверяет поток по объёму, шифрованию и наличию видео"""
    total_bytes, total_time, has_video = get_m3u8_total_bytes(url, TEST_TIME)
    good_by_size = total_bytes >= min_bytes
    result = good_by_size and has_video
    if not has_video:
        print("  ⚠️ Видео не обнаружено в сегментах")
    return result

def replace_key_in_url(url, new_key):
    """Заменяет ключ в URL"""
    pattern = r'(http://[^/]+/iptv/)([^/]+)(/6238/index\.m3u8)'
    return re.sub(pattern, r'\g<1>' + new_key + r'\g<3>', url)

def extract_key_from_playlist(playlist_file):
    """Извлекает ключ из основного плейлиста"""
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
    """Загружает ключи из файла"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            keys = [line.strip() for line in f if line.strip()]
        print("  ✅ Загружено " + str(len(keys)) + " ключей")
        return keys
    except Exception as e:
        print("  ❌ Ошибка загрузки ключей: " + str(e))
        return []

def copy_playlist(source, destination):
    """Копирует плейлист"""
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
    print("📺 ПЕРЕКЛЮЧЕНИЕ ПЛЕЙЛИСТОВ (v2 — с проверкой видео и шифрования)")
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
    
    print("🔍 ПРОВЕРКА ОСНОВНОГО ПЛЕЙЛИСТА:")
    main_key = extract_key_from_playlist(MAIN_PLAYLIST)
    
    if main_key:
        main_url = replace_key_in_url("http://kuh5nj4q.rostelekom.xyz/iptv/KEY/6238/index.m3u8", main_key)
        print("  Проверка ключа: " + main_key[:20] + "...")
        main_key_good = is_stream_good(main_url, MIN_TOTAL_BYTES)
        print("  " + ("✅ ХОРОШИЙ" if main_key_good else "❌ ПЛОХОЙ"))
        print()
        
        if main_key_good:
            print("✅ ОСНОВНОЙ ПЛЕЙЛИСТ РАБОТАЕТ")
            print("💡 Нет необходимости в замене")
            print()
            print("=" * 60)
            print("🎉 ГОТОВО! Основной плейлист в порядке")
            print("=" * 60)
            return True
        else:
            print("❌ ОСНОВНОЙ ПЛЕЙЛИСТ НЕ РАБОТАЕТ (объём есть, но видео нет или ключ недоступен)")
            print("🔍 Поиск рабочего ключа...")
            print()
    
    working_key_index = -1
    for i, key in enumerate(keys):
        print(f"🔍 ПРОВЕРКА КЛЮЧА {i+1} ({key[:15]}...):")
        test_url = replace_key_in_url("http://kuh5nj4q.rostelekom.xyz/iptv/KEY/6238/index.m3u8", key)
        is_good = is_stream_good(test_url, MIN_TOTAL_BYTES)
        print("  " + ("✅ ХОРОШИЙ" if is_good else "❌ ПЛОХОЙ"))
        print()
        if is_good:
            working_key_index = i
            break
    
    if working_key_index >= 0:
        reserve_number = working_key_index + 1
        reserve_filename = f"EdemTV-reserve{reserve_number}.m3u"
        print(f"✅ НАЙДЕН РАБОЧИЙ КЛЮЧ: {reserve_number}")
        if os.path.exists(reserve_filename):
            print(f"🔄 Копируем {reserve_filename} → {MAIN_PLAYLIST}...")
            success = copy_playlist(reserve_filename, MAIN_PLAYLIST)
        else:
            print(f"❌ Не найден файл: {reserve_filename}")
            print(f"⚠️  Создайте резервный плейлист для ключа {reserve_number}")
            success = False
    else:
        print("❌ ВСЕ КЛЮЧИ НЕ РАБОТАЮТ")
        print("⚠️  Невозможно обновить плейлист")
        success = False
    
    print()
    print("=" * 60)
    if success:
        print(f"🎉 ГОТОВО! {MAIN_PLAYLIST} обновлён")
    else:
        print("❌ ОШИБКА обновления")
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
