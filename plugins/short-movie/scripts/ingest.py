"""人間が Nano Banana で描いて short_movie/inbox/ に保存した画像に、依頼書の順で名前を付ける。

使い方: python3 -I ingest.py <short_movie のパス> <依頼書の .md のパス> [--dry-run]

依頼書の「## 1. characters/hero_wave　…」のような見出しの順と、inbox の画像を保存した時刻の順を
突き合わせ、short_movie/materials/raw/<id>.<拡張子> へ移す。枚数が合わなければ、何も動かさずに止まる。
人間にファイル名を付け直させないため、保存の順で突き合わせる。
"""
import os
import re
import shutil
import sys

EXTS = (".png", ".jpg", ".jpeg", ".webp")


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) != 2:
        print("使い方: python3 -I ingest.py <short_movie のパス> <依頼書の .md> [--dry-run]", file=sys.stderr)
        return 2
    root, prompt_file = os.path.abspath(args[0]), args[1]
    dry = "--dry-run" in sys.argv
    inbox = os.path.join(root, "inbox")
    ids = re.findall(r"^## \d+\. (\S+)", open(prompt_file, encoding="utf-8").read(), flags=re.M)
    files = sorted(
        (os.path.join(inbox, f) for f in os.listdir(inbox) if f.lower().endswith(EXTS)),
        key=os.path.getmtime,
    )
    if len(files) != len(ids):
        print(f"枚数が合わない: 依頼書 {len(ids)} 枚 / inbox {len(files)} 枚。何も動かしていない")
        for f in files:
            print("  inbox:", os.path.basename(f))
        return 1
    for id_, src in zip(ids, files):
        ext = os.path.splitext(src)[1].lower()
        dst = os.path.join(root, "materials", "raw", id_ + ext)
        print(f"{os.path.basename(src)} -> {os.path.relpath(dst, root)}")
        if not dry:
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.move(src, dst)
    return 0


if __name__ == "__main__":
    sys.exit(main())
