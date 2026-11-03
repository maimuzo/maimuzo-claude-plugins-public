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
# meta は「export const meta = { … }」の中だけ、場面の秒は「scenes: [ … ]」の中だけを見る
m_meta = re.search(r"export\s+const\s+meta\s*=\s*\{(.*?)\}", src, flags=re.S)
if not m_meta:
    sys.exit("script.ts に export const meta = { id, durationInSeconds } が見つかりません（雛形は references/video-template/script.ts）")
meta = m_meta.group(1)
m_id = re.search(r"\bid:\s*[\"']([^\"']+)[\"']", meta)
m_dur = re.search(r"durationInSeconds:\s*([0-9.]+)", meta)
if not m_id or not m_dur:
    sys.exit("meta に id と durationInSeconds がありません")
m_scenes = re.search(r"scenes:\s*\[(.*?)\]\s*,?\s*\}", src, flags=re.S)
tos = [float(x) for x in re.findall(r"\bto:\s*([0-9.]+)", m_scenes.group(1))] if m_scenes else []
if m_id.group(1) != id_:
    sys.exit(f"meta.id（{m_id.group(1)}）が回のフォルダ名（{id_}）と違います")
dur = float(m_dur.group(1))
if not 15 <= dur <= 30:
    sys.exit(f"尺は15〜30秒にしてください（いまは {dur} 秒）")
if tos and max(tos) != dur:
    sys.exit(f"最後の場面の終わり（{max(tos)} 秒）が meta の尺（{dur} 秒）と違います")
PY
DUR="$(python3 -I -c 'import re,sys;s=open(sys.argv[1],encoding="utf-8").read();m=re.search(r"export\s+const\s+meta\s*=\s*\{(.*?)\}",s,flags=re.S);print(re.search(r"durationInSeconds:\s*([0-9.]+)",m.group(1)).group(1))' "$SM/videos/$ID/script.ts")"

ENGINE="$("$SM_PLUGIN_DIR/scripts/prepare_engine.sh" | tail -n 1)"
sm_make_workspace "$SM" "$ID" render "$ENGINE"
cp -R "$SM/videos" "$WS/src/videos"

cd "$WS"
echo "型を確かめます（この回から辿れるファイルだけ）" >&2
npx tsc --noEmit -p tsconfig.json
mkdir -p "$SM/out"
OUT="$SM/out/$ID.mp4"
npx remotion render src/index.ts "$ID" "$OUT"

# 形の確かめが落ちても、直すためのコマ割りの一覧は作ってから終了コードを返す
check=0
"$SM_PLUGIN_DIR/scripts/check_video.sh" "$OUT" "$DUR" || check=$?
uv run --no-project --with pillow python -I "$SM_PLUGIN_DIR/scripts/contact_sheet.py" "$OUT" "$SM/out/${ID}_contact.png"

cd /
rm -rf -- "$WS"
if [ "$check" -ne 0 ]; then
  echo "書き出しましたが、形の確かめが通りませんでした: $OUT" >&2
  exit "$check"
fi
echo "書き出しました: $OUT"
