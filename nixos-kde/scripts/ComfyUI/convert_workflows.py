#!/usr/bin/env python3
import json
from pathlib import Path

def fix_paths(obj):
    if isinstance(obj, str):
        return obj.replace('\\', '/')
    elif isinstance(obj, dict):
        return {k: fix_paths(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [fix_paths(item) for item in obj]
    return obj

def convert_all():
    workflows_dir = Path("user/default/workflows")
    linux_dir = Path("user/default/workflows/linux")

    if not workflows_dir.exists():
        return

    linux_dir.mkdir(parents=True, exist_ok=True)

    count = 0
    for json_file in workflows_dir.rglob("*.json"):
        try:
            json_file.relative_to(linux_dir)
            continue
        except ValueError:
            pass

        try:
            rel_path = json_file.relative_to(workflows_dir)

            with open(json_file, 'r', encoding='utf-8') as f:
                workflow = json.load(f)

            fixed = fix_paths(workflow)

            output_path = linux_dir / rel_path
            output_path.parent.mkdir(parents=True, exist_ok=True)

            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(fixed, f, indent=2, ensure_ascii=False)

            count += 1
        except Exception as e:
            print(f"[convert] Ошибка в {json_file}: {e}")

    if count > 0:
        print(f"[convert] Создано {count} Linux-workflow в {linux_dir}")

if __name__ == "__main__":
    convert_all()
