"""描かせた絵から背景を抜き、動画で使う透明な PNG にする。

使い方: uv run --no-project --with pillow --with numpy python -I cutout.py <入力> <出力.png>

入力の見分け方:
- alpha があり、完全に透明な画素が1%以上ある → 透過で描かせた絵（Codex）として扱う。
  体の画素が alpha 240〜254 でわずかに透けることがあるので（2026-11-02 に1枚で測った）、240 以上を 255 にそろえる
- 透明な画素が無く、四隅が #00FF00 に近い → 緑一色で描かせた絵（Nano Banana）として緑を抜く
- どちらでもない → 何も書かずに終了コード 3 で止まる（描き直しに回す）
最後に、絵のある範囲で切り抜く（8px の余白を残す）。
"""
import sys

import numpy as np
from PIL import Image


def is_green(px) -> bool:
    r, g, b = (int(v) for v in px[:3])
    return g > 180 and r < 90 and b < 90


def from_alpha(rgba: np.ndarray) -> np.ndarray:
    out = rgba.copy()
    a = out[..., 3]
    a[a >= 240] = 255
    return out


def from_green(rgb: np.ndarray) -> np.ndarray:
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    # 緑の強さ: 緑が赤と青の大きいほうをどれだけ上回るか
    excess = g - np.maximum(r, b)
    alpha = np.clip(1.0 - (excess - 40.0) / 80.0, 0.0, 1.0)
    alpha[(g > 150) & (excess > 120)] = 0.0
    # 輪郭ににじんだ緑を消す
    g2 = np.minimum(g, np.maximum(r, b) + 10.0)
    return np.dstack([r, g2, b, alpha * 255.0]).astype(np.uint8)


def main() -> int:
    if len(sys.argv) != 3:
        print("使い方: cutout.py <入力> <出力.png>", file=sys.stderr)
        return 2
    src, dst = sys.argv[1], sys.argv[2]
    img = Image.open(src)
    img.load()
    rgba = np.asarray(img.convert("RGBA"))
    transparent = (rgba[..., 3] == 0).mean()
    h, w = rgba.shape[:2]
    corners = [rgba[0, 0], rgba[0, w - 1], rgba[h - 1, 0], rgba[h - 1, w - 1]]
    if transparent >= 0.01:
        out, kind = from_alpha(rgba), "透過"
    elif all(is_green(c) for c in corners):
        out, kind = from_green(rgba[..., :3].astype(np.float32)), "緑一色"
    else:
        print(f"背景を見分けられない（透明な画素 {transparent:.1%}、四隅が緑ではない）。描き直しに回してください: {src}")
        return 3
    res = Image.fromarray(out, "RGBA")
    bbox = res.getchannel("A").point(lambda a: 255 if a > 16 else 0).getbbox()
    if bbox:
        pad = 8
        l, t, r, b = bbox
        res = res.crop((max(l - pad, 0), max(t - pad, 0), min(r + pad, res.width), min(b + pad, res.height)))
    res.save(dst)
    print(f"{kind}として抜いた: {dst}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
