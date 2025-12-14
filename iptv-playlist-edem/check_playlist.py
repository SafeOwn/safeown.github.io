import re
import requests
import time
import os
from urllib.parse import urljoin

# НАСТРОЙКИ
MAIN_PLAYLIST = "EdemTV-main.m3u"
KEYS_FILE = "keys.txt"
MIN_TOTAL_BYTES = 8000 * 1024  # 8 MB — достаточно для 5–7 сек HD
TEST_TIME = 10  # секунд

def is_stream_really_good(url):
    """Простая и надёжная проверка: 200 + объём"""
    try:
        # Получаем плейлист
        pl_resp = requests.get(url, timeout=8)
        if pl_resp.status_code != 200:
            return False

        # Ищем .ts
        ts_urls = re.findall(r'^[^#\n].*\.ts.*$', pl_resp.text, re.MULTILINE)
        if not ts_urls:
            # Пробуем вложенный
            sub_urls = re.findall(r'^[^#\n].*\.m3u8.*$', pl_resp.text, re.MULTILINE)
            if sub_urls:
                sub_url = urljoin(url, sub_urls[0])
                sub_resp = requests.get(sub_url, timeout=8)
                if sub_resp.status_code == 200:
                    ts_urls = re.findall(r'^[^#\n].*\.ts.*$', sub_resp.text, re.MULTILINE)

        if not ts_urls:
            return False

        total_bytes = 0
        start = time.time()
        checked = 0

        for ts in ts_urls[:4]:  # первые 4 сегмента
            if time.time() - start > TEST_TIME:
                break
            try:
                r = requests.get(urljoin(url, ts), timeout=6)
                if r.status_code == 200:
                    total_bytes += len(r.content)
                    checked += 1
                else:
                    return False  # любой 403/404 — сразу ❌
            except:
                return False

        return total_bytes >= MIN_TOTAL_BYTES

    except:
        return False

def replace_key_in_url(url, new_key):
    return re.sub(r'(http://[^/]+/iptv/)([^/]+)(/6238/index\.m3u8)', 
                  r'\g<1>' + new_key + r'\g<3>', url)

def extract_key_from_playlist(pf):
    try:
        with open(pf, encoding='utf-8') as f:
            match = re.search(r'/iptv/([^/]+)/6238/index\.m3u8', f.read())
            return match.group(1) if match else None
    except:
        return None

def load_keys():
    try:
        with open(KEYS_FILE, encoding='utf-8') as f:
            return [k.strip() for k in f if k.strip()]
    except:
        return []

def copy_file(src, dst):
    try:
        with open(src, encoding='utf-8') as s, open(dst, 'w', encoding='utf-8') as d:
            d.write(s.read())
        return True
    except:
        return False

def main():
    print("📺 Переключение (MINIMAL — только 200 + объём)")
    print("="*50)
    
    if not (os.path.exists(KEYS_FILE) and os.path.exists(MAIN_PLAYLIST)):
        print("❌ Файлы не найдены")
        return False

    keys = load_keys()
    if not keys:
        print("❌ Нет ключей")
        return False

    print(f"🔍 Проверка {len(keys)} ключей...")
    for i, key in enumerate(keys):
        print(f"  {i+1}. {key[:12]}...", end=" ")
        url = replace_key_in_url("http://kuh5nj4q.rostelekom.xyz/iptv/KEY/6238/index.m3u8", key)
        if is_stream_really_good(url):
            print("✅")
            # Обновляем плейлист
            reserve = f"EdemTV-reserve{i+1}.m3u"
            if os.path.exists(reserve):
                if copy_file(reserve, MAIN_PLAYLIST):
                    print(f"\n🎉 Готово: {MAIN_PLAYLIST} → ключ {i+1}")
                    return True
                else:
                    print(f"\n❌ Ошибка копирования {reserve}")
            else:
                print(f"\n❌ Нет файла {reserve}")
            return False
        else:
            print("❌")
    
    print("\n❌ Все ключи не работают")
    return False

if __name__ == "__main__":
    main()
    if not os.environ.get('GITHUB_ACTIONS'):
        input("\nНажмите Enter...")
