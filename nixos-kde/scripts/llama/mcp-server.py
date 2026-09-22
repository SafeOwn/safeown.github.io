# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "fastmcp",
#   "duckduckgo-search",
#   "httpx",
#   "beautifulsoup4",
# ]
# ///

from fastmcp import FastMCP
import subprocess
from pathlib import Path
import httpx
from datetime import datetime

mcp = FastMCP("All-in-One MCP")


def format_size(size: int) -> str:
    """Красивый размер файла"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024:
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} PB"


def file_icon(p: Path) -> str:
    """Иконка по типу файла"""
    if p.is_dir():
        return "📁"
    ext = p.suffix.lower()
    icons = {
        '.py': '🐍', '.js': '📜', '.sh': '⚙️', '.json': '📋',
        '.txt': '📄', '.md': '📝', '.log': '📃',
        '.jpg': '🖼️', '.jpeg': '🖼️', '.png': '🖼️', '.gif': '🖼️',
        '.mp3': '🎵', '.mp4': '🎬', '.pdf': '📕',
        '.zip': '📦', '.tar': '📦', '.gz': '📦',
        '.html': '🌐', '.css': '🎨',
    }
    return icons.get(ext, '📄')


# ============ ФАЙЛЫ ============
@mcp.tool
def list_files(path: str = "/home/safe") -> str:
    """Список файлов и папок в директории"""
    try:
        p = Path(path).resolve()
        if not p.exists():
            return f"❌ Путь не существует: {path}"
        if not p.is_dir():
            return f"❌ Это не директория: {path}"

        items = sorted(p.iterdir(), key=lambda x: (not x.is_dir(), x.name.lower()))

        lines = [
            f"📂 Содержимое директории: {p}",
            f"📊 Всего элементов: {len(items)}",
            f"🕐 Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "",
            "─" * 60,
        ]

        if not items:
            lines.append("(папка пуста)")
        else:
            for item in items:
                icon = file_icon(item)
                if item.is_dir():
                    lines.append(f"{icon} {item.name}/")
                else:
                    size = format_size(item.stat().st_size)
                    lines.append(f"{icon} {item.name:<40} {size:>10}")

        lines.append("─" * 60)
        return "\n".join(lines)
    except Exception as e:
        return f"❌ Ошибка: {str(e)}"


@mcp.tool
def read_file(path: str) -> str:
    """Прочитать содержимое файла"""
    try:
        p = Path(path).resolve()
        if not p.exists():
            return f"❌ Файл не существует: {path}"
        if not p.is_file():
            return f"❌ Это не файл: {path}"

        content = p.read_text(errors='ignore')
        lines = [
            f"📄 Файл: {p}",
            f"📏 Размер: {format_size(p.stat().st_size)}",
            f"📊 Строк: {len(content.splitlines())}",
            "─" * 60,
            content[:50000],
        ]
        return "\n".join(lines)
    except Exception as e:
        return f"❌ Ошибка: {str(e)}"


@mcp.tool
def write_file(path: str, content: str) -> str:
    """Записать текст в файл"""
    try:
        p = Path(path).resolve()
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(content)
        return f"✅ Записано в: {p}\n📏 Размер: {format_size(len(content.encode()))}\n📊 Строк: {len(content.splitlines())}"
    except Exception as e:
        return f"❌ Ошибка: {str(e)}"


# ============ ПОИСК ============
@mcp.tool
def search(query: str, max_results: int = 10) -> str:
    """Поиск в интернете через DuckDuckGo"""
    from duckduckgo_search import DDGS
    try:
        with DDGS() as ddgs:
            results = list(ddgs.text(query, max_results=max_results))

        lines = [
            f"🔍 Поиск: {query}",
            f"📊 Найдено результатов: {len(results)}",
            "─" * 60,
        ]

        for i, r in enumerate(results, 1):
            lines.append(f"\n[{i}] {r['title']}")
            lines.append(f"    🔗 {r['href']}")
            lines.append(f"    📝 {r['body']}")

        lines.append("\n" + "─" * 60)
        return "\n".join(lines)
    except Exception as e:
        return f"❌ Ошибка поиска: {str(e)}"


@mcp.tool
def search_and_fetch(query: str, num_results: int = 3) -> str:
    """Поиск + получение содержимого первых результатов"""
    from duckduckgo_search import DDGS
    from bs4 import BeautifulSoup

    try:
        with DDGS() as ddgs:
            results = list(ddgs.text(query, max_results=num_results))

        lines = [
            f"🔍 Поиск: {query}",
            f"📊 Будет извлечено содержимое из {len(results)} страниц",
            "═" * 60,
        ]

        for i, r in enumerate(results, 1):
            lines.append(f"\n┌─ [{i}] {r['title']}")
            lines.append(f"│ 🔗 {r['href']}")
            lines.append(f"│ 📝 {r['body']}")
            lines.append(f"├─ Содержимое страницы:")

            try:
                headers = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64)'}
                resp = httpx.get(r['href'], timeout=10, follow_redirects=True, headers=headers)
                if resp.status_code == 200:
                    soup = BeautifulSoup(resp.text, 'html.parser')
                    for tag in soup(["script", "style", "nav", "footer", "header", "aside"]):
                        tag.decompose()
                    text = soup.get_text(separator='\n', strip=True)
                    text_lines = [line.strip() for line in text.split('\n') if line.strip()]
                    text = '\n'.join(text_lines[:40])
                    lines.append(f"│ {text[:2000]}")
                else:
                    lines.append(f"│ ⚠️ HTTP {resp.status_code}")
            except Exception as e:
                lines.append(f"│ ⚠️ Не удалось получить: {str(e)}")

            lines.append(f"└─ {'─' * 56}")

        return "\n".join(lines)
    except Exception as e:
        return f"❌ Ошибка: {str(e)}"


@mcp.tool
def fetch(url: str) -> str:
    """Получить содержимое веб-страницы по URL"""
    from bs4 import BeautifulSoup
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64)'}
        response = httpx.get(url, timeout=30, follow_redirects=True, headers=headers)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, 'html.parser')
        for tag in soup(["script", "style", "nav", "footer"]):
            tag.decompose()

        title = soup.title.string if soup.title else "(без заголовка)"
        text = soup.get_text(separator='\n', strip=True)

        lines = [
            f"🌐 URL: {url}",
            f"📄 Заголовок: {title}",
            f"📏 Размер: {format_size(len(response.content))}",
            "─" * 60,
            text[:50000],
        ]
        return "\n".join(lines)
    except Exception as e:
        return f"❌ Ошибка: {str(e)}"


# ============ ТЕРМИНАЛ ============
@mcp.tool
def run_command(command: str) -> str:
    """Выполнить команду в терминале"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=60,
            cwd="/home/safe"
        )
        output = result.stdout + result.stderr

        lines = [
            f"⚙️ Команда: {command}",
            f"📤 Код возврата: {result.returncode}",
            "─" * 60,
            output[:50000] if output else "(нет вывода)",
        ]
        return "\n".join(lines)
    except subprocess.TimeoutExpired:
        return f"❌ Таймаут (60 сек): {command}"
    except Exception as e:
        return f"❌ Ошибка: {str(e)}"


if __name__ == "__main__":
    mcp.run()
