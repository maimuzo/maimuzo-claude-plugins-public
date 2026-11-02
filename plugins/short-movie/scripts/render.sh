#!/bin/bash
# 回を1本、mp4 に書き出す。
# 使い方: render.sh <short_movie のパス> <回の id>
# 出力: short_movie/out/<回の id>.mp4 と、確かめの結果（check_video.sh）と、コマ割りの一覧 short_movie/out/<回の id>_contact.png
# キャッシュを使わないので、1本ごとに束ね直す。数分かかることがあるので、Bash の時間切れに注意すること。
set -euo pipefail
. "$(dirname "$0")/_common.sh"
. "$(dirname "$0")/_workspace.sh"

[ $# -eq 2 ] || sm_die "使い方: render.sh <short_movie のパス> <回の id>"
SM="$(cd "$1" && pwd)"
ID="$2"
sm_check_id "$ID"
[ -f "$SM/videos/$ID/index.tsx" ] || sm_die "回が見つかりません: $SM/videos/$ID/index.tsx"
[ -f "$SM/theme.json" ] || sm_die "theme.json がありません。先に /short-movie:start を済ませてください"

# meta の id と尺を、回のフォルダ名と script の最後の場面に合わせているかを先に確かめる
python3 -I - "$SM/videos/$ID" "$ID" <<'PY'
import re, sys
d, id_ = sys.argv[1], sys.argv[2]
src = open(d + "/script.ts", encoding="utf-8").read()
m_id = re.search(r'\bid:\s*"([^"]+)"', src)
m_dur = re.search(r"durationInSeconds:\s*([0-9.]+)", src)
tos = [float(x) for x in re.findall(r"\bto:\s*([0-9.]+)", src)]
if not m_id or not m_dur:
    sys.exit("script.ts に meta（id と durationInSeconds）が見つかりません")
if m_id.group(1) != id_:
    sys.exit(f"meta.id（{m_id.group(1)}）が回のフォルダ名（{id_}）と違います")
dur = float(m_dur.group(1))
if not 15 <= dur <= 30:
    sys.exit(f"尺は15〜30秒にしてください（いまは {dur} 秒）")
if tos and max(tos) != dur:
    sys.exit(f"最後の場面の終わり（{max(tos)} 秒）が meta の尺（{dur} 秒）と違います")
PY
DUR="$(python3 -I -c 'import re,sys;print(re.search(r"durationInSeconds:\s*([0-9.]+)",open(sys.argv[1],encoding="utf-8").read()).group(1))' "$SM/videos/$ID/script.ts")"

ENGINE="$("$SM_PLUGIN_DIR/scripts/prepare_engine.sh" | tail -n 1)"
sm_make_workspace "$SM" "$ID" render "$ENGINE"
cp -R "$SM/videos" "$WS/src/videos"

cd "$WS"
echo "型を確かめます（この回から辿れるファイルだけ）" >&2
npx tsc --noEmit -p tsconfig.json
mkdir -p "$SM/out"
OUT="$SM/out/$ID.mp4"
npx remotion render src/index.ts "$ID" "$OUT"

"$SM_PLUGIN_DIR/scripts/check_video.sh" "$OUT" "$DUR"
uv run --no-project --with pillow python -I "$SM_PLUGIN_DIR/scripts/contact_sheet.py" "$OUT" "$SM/out/${ID}_contact.png"

cd /
rm -rf -- "$WS"
echo "書き出しました: $OUT"
