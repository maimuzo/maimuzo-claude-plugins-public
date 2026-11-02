"""書き出した mp4 から、0.5秒と1秒ごとのコマを並べた一覧の画像を作る。AI が自分で見て確かめるためのもの。

使い方: uv run --no-project --with pillow python -I contact_sheet.py <mp4> <出力.png>
"""
import os
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw


def main() -> int:
    if len(sys.argv) != 3:
        print("使い方: contact_sheet.py <mp4> <出力.png>", file=sys.stderr)
        return 2
    mp4, out = sys.argv[1], sys.argv[2]
    dur = float(subprocess.check_output(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", mp4]).decode().strip())
    times = [0.5] + [float(s) for s in range(1, int(dur))]
    thumbs = []
    with tempfile.TemporaryDirectory() as d:
        for i, t in enumerate(times):
            p = os.path.join(d, f"{i}.png")
            subprocess.run(["ffmpeg", "-v", "error", "-ss", str(t), "-i", mp4, "-frames:v", "1", "-vf", "scale=270:270", p],
                           check=True)
            im = Image.open(p).convert("RGB")
            ImageDraw.Draw(im).text((6, 4), f"{t:g}s", fill=(255, 0, 0))
            thumbs.append(im)
    cols = 5
    rows = (len(thumbs) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * 270, rows * 270), (255, 255, 255))
    for i, im in enumerate(thumbs):
        sheet.paste(im, ((i % cols) * 270, (i // cols) * 270))
    sheet.save(out)
    print(f"コマ割りの一覧: {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
