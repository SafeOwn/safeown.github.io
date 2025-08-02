import re
import requests
import time
import os
from urllib.parse import urljoin

# НАСТРОЙКИ
MAIN_PLAYLIST = "EdemTV-main.m3u"
KEYS_FILE = "keys.txt"
MIN_TOTAL_BYTES = 2000 * 1024  # 2000 KB
TEST_TIME = 10  # секунд

def get_m3u8_total_bytes(url, test_time=TEST_TIME):
    """Проверяет объем данных M3U8 потока"""
    print("  📊 Проверка потока...")
    
    try:
        playlist_response = requests.get(url, timeout=10)
        if playlist_response.status_code != 200:
            print("  ❌ Плейлист недоступен")
            return 0, 0
        
        playlist_content = playlist_response.text
        ts_urls = re.findall(r'^[^#\n].*\.ts.*$', playlist_content, re.MULTILINE)
        
        if not ts_urls:
            sub_playlist_urls = re.findall(r'^[^#\n].*\.m3u8.*$', playlist_content, re.MULTILINE)
            if sub_playlist_urls:
                sub_url = urljoin(url, sub_playlist_urls[0])
                try:
                    sub_response = requests.get(sub_url, timeout=10)
                    if sub_response.status_code == 200:
                        sub_content = sub_response.text
                        ts_urls = re.findall(r'^[^#\n].*\.ts.*$', sub_content, re.MULTILINE)
                except:
                    pass
        
        if not ts_urls:
            print("  ❌ Нет сегментов")
            return 0, 0
        
        total_bytes = 0
        start_check_time = time.time()
        segments_checked = 0
        max_segments = min(6, len(ts_urls))
        
        for i in range(max_segments):
            if time.time() - start_check_time > test_time:
                break
            if segments_checked >= 6:
                break
                
            ts_url = urljoin(url, ts_urls[i])
            
            try:
                seg_response = requests.get(ts_url, timeout=10)
                if seg_response.status_code == 200:
                    total_bytes += len(seg_response.content)
                    segments_checked += 1
                elif seg_response.status_code in [403, 404]:
                    break
            except:
                continue
        
        total_time = time.time() - start_check_time
        print("  📊 " + str(total_bytes//1024) + " KB за " + f"{total_time:.1f}" + " сек")
        
        return total_bytes, total_time
        
    except Exception as e:
        print("  ❌ Ошибка")
        return 0, 0

def is_stream_good(url, min_bytes=MIN_TOTAL_BYTES):
    """Проверяет поток по объему данных"""
    total_bytes, total_time = get_m3u8_total_bytes(url, TEST_TIME)
    return total_bytes >= min_bytes

def replace_key_in_url(url, new_key):
    """Заменяет ключ в URL"""
    pattern = r'(http://[^/]+/iptv/)([^/]+)(/6238/index\.m3u8)'
    return re.sub(pattern, r'\g<1>' + new_key + r'\g<3>', url)

def extract_key_from_playlist(playlist_file):
    """Извлекает ключ из основного плейлиста"""
    try:
        with open(playlist_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Ищем URL с ключом в плейлисте
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

def find_reserve_file_by_key(key, keys_list):
    """Находит номер резервного файла по ключу"""
    try:
        index = keys_list.index(key)
        return index + 1
    except ValueError:
        return None

def main():
    """Основная логика с проверкой основного плейлиста"""
    print("📺 ПЕРЕКЛЮЧЕНИЕ ПЛЕЙЛИСТОВ")
    print("=" * 50)
    print("Основной плейлист: " + MAIN_PLAYLIST)
    print("Ключи: " + KEYS_FILE)
    print("Минимум: " + str(MIN_TOTAL_BYTES//1024) + " KB")
    print()
    
    # Проверяем существование файлов
    if not os.path.exists(KEYS_FILE):
        print("❌ Не найден файл ключей: " + KEYS_FILE)
        return False
    
    if not os.path.exists(MAIN_PLAYLIST):
        print("❌ Не найден основной плейлист: " + MAIN_PLAYLIST)
        return False
    
    # Загружаем ключи
    print("🔍 Загрузка ключей...")
    keys = load_keys_from_file(KEYS_FILE)
    if not keys:
        print("❌ Нет ключей для проверки")
        return False
    
    print()
    
    # Сначала проверяем основной плейлист
    print("🔍 ПРОВЕРКА ОСНОВНОГО ПЛЕЙЛИСТА:")
    main_key = extract_key_from_playlist(MAIN_PLAYLIST)
    
    if main_key:
        main_url = replace_key_in_url("http://jexywacp.tvclub.xyz/iptv/KEY/6238/index.m3u8", main_key)
        print("  Проверка ключа: " + main_key[:20] + "...")
        main_key_good = is_stream_good(main_url, MIN_TOTAL_BYTES)
        print("  " + ("✅ ХОРОШИЙ" if main_key_good else "❌ ПЛОХОЙ"))
        print()
        
        if main_key_good:
            print("✅ ОСНОВНОЙ ПЛЕЙЛИСТ РАБОТАЕТ")
            print("💡 Нет необходимости в замене")
            print()
            print("=" * 50)
            print("🎉 ГОТОВО! Основной плейлист в порядке")
            print("=" * 50)
            return True
        else:
            print("❌ ОСНОВНОЙ ПЛЕЙЛИСТ НЕ РАБОТАЕТ")
            print("🔍 Поиск рабочего ключа...")
            print()
    
    # Проверяем ключи по порядку из файла
    working_key_index = -1
    
    for i, key in enumerate(keys):
        print("🔍 ПРОВЕРКА КЛЮЧА " + str(i+1) + " (" + key[:15] + "...):")
        test_url = replace_key_in_url("http://jexywacp.tvclub.xyz/iptv/KEY/6238/index.m3u8", key)
        is_good = is_stream_good(test_url, MIN_TOTAL_BYTES)
        print("  " + ("✅ ХОРОШИЙ" if is_good else "❌ ПЛОХОЙ"))
        print()
        
        if is_good:
            working_key_index = i
            break
    
    # Определяем, какой плейлист использовать
    if working_key_index >= 0:
        reserve_number = working_key_index + 1
        reserve_filename = "EdemTV-reserve" + str(reserve_number) + ".m3u"
        
        print("✅ НАЙДЕН РАБОЧИЙ КЛЮЧ: " + str(working_key_index + 1))
        
        # Проверяем существование резервного файла
        if os.path.exists(reserve_filename):
            print("🔄 Копируем " + reserve_filename + " → " + MAIN_PLAYLIST + "...")
            success = copy_playlist(reserve_filename, MAIN_PLAYLIST)
        else:
            print("❌ Не найден файл: " + reserve_filename)
            print("⚠️  Создайте резервный плейлист для ключа " + str(working_key_index + 1))
            success = False
    else:
        print("❌ ВСЕ КЛЮЧИ НЕ РАБОТАЮТ")
        print("⚠️  Невозможно обновить плейлист")
        success = False
    
    print()
    print("=" * 50)
    if success:
        print("🎉 ГОТОВО! " + MAIN_PLAYLIST + " обновлен")
    else:
        print("❌ ОШИБКА обновления")
    print("=" * 50)
    
    return success

if __name__ == "__main__":
    try:
        success = main()
    except Exception as e:
        print("❌ Критическая ошибка: " + str(e))
        success = False
    
if os.environ.get('GITHUB_ACTIONS'):
    print("🤖 Завершено в GitHub Actions")
else:
    try:
        input("Нажмите Enter для выхода...")
    except EOFError:
        print("✅ Автоматическое завершение")