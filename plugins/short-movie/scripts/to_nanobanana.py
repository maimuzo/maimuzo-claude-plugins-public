"""Codex 向けに書いた依頼書を、人間が Nano Banana に貼るための写しにする。

使い方: python3 -I to_nanobanana.py <依頼書.md>
出力: 同じフォルダの <名前>__nanobanana.md（元の依頼書は書き換えない）

Codex 向けの透過の指定を、Nano Banana 向けの緑一色の指定に置き換え、「道具: codex」を「道具: nano_banana」にする。
ブラウザの Gemini アプリで透過の PNG を保存できるかは確かめていないため、Nano Banana には緑一色で描かせる。
背景・絵コンテ（透過の指定が無い依頼文）は、そのまま写す。
"""
import os
import re
import sys

TRANSPARENT = re.compile(r"Transparent background \(real alpha channel, no checkerboard pattern\)\.?", re.I)
GREEN = "Solid #00FF00 green background. Do not use green anywhere in the subject."


def main() -> int:
    if len(sys.argv) != 2:
        print("使い方: to_nanobanana.py <依頼書.md>", file=sys.stderr)
        return 2
    src = sys.argv[1]
    text = open(src, encoding="utf-8").read()
    out, n = TRANSPARENT.subn(GREEN, text)
    out = out.replace("道具: codex", "道具: nano_banana")
    base, ext = os.path.splitext(src)
    dst = f"{base}__nanobanana{ext}"
    open(dst, "w", encoding="utf-8").write(out)
    print(f"Nano Banana 用の依頼書: {dst}（背景の指定を {n} か所、緑一色に替えた）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
