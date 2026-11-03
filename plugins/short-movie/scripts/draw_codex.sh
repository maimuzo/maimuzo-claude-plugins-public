#!/bin/bash
# Codex の組み込みの画像生成で、依頼書の中の絵を1枚描かせる。
# 使い方: draw_codex.sh <short_movie のパス> <依頼書の .md> <絵の id> <保存先の .png（short_movie からの相対パス）> [添付する設定画 ...]
# 依頼書の「## <番号>. <絵の id>」の節の、``` で囲んだ英語の依頼文だけを Codex に渡す（背景の指定も依頼文に含める）。
# 設定画は、short_movie からの相対パスか絶対パスで渡す。
# 終了コード: 0 描けた / 1 描けなかった / 2 引数の誤り / 4 利用枠が切れた（人間に「待つか、Nano Banana へ回すか」を訊く）
# 1枚に数分かかる。Bash の時間切れに注意すること。
set -uo pipefail
. "$(dirname "$0")/_common.sh"

[ $# -ge 4 ] || { echo "使い方: draw_codex.sh <short_movie のパス> <依頼書の .md> <絵の id> <保存先の .png> [設定画 ...]" >&2; exit 2; }
SM="$(cd "$1" 2>/dev/null && pwd)" || { echo "short_movie のパスが見つかりません: $1" >&2; exit 2; }
[ -n "$SM" ] || exit 2
PROMPT_DOC="$2"; PIC_ID="$3"; OUT_REL="$4"; shift 4
OUT="$SM/$OUT_REL"
mkdir -p "$(dirname "$OUT")" "$SM/out/review"
LOG="$SM/out/review/codex_$(date +%Y%m%d_%H%M%S)_$$.log"

PROMPT="$(python3 -I "$SM_PLUGIN_DIR/scripts/extract_prompt.py" "$PROMPT_DOC" "$PIC_ID")" || exit 2
# 依頼文は1行にまとめる（ログに写った依頼文の行を、利用枠切れの判定から確実に除くため）
PROMPT="$(printf '%s' "$PROMPT" | tr '\n' ' ')"

refs=()
for r in "$@"; do
  case "$r" in /*) ;; *) r="$SM/$r" ;; esac
  [ -f "$r" ] || { echo "設定画が見つかりません: $r" >&2; exit 2; }
  refs+=(--image "$r")
done

# 前に描いた絵を退ける。描けなかったときは戻す（前の絵を「描けた」と取り違えないため）
PREV=""
if [ -e "$OUT" ]; then PREV="$OUT.prev"; mv -f "$OUT" "$PREV"; fi
restore() { if [ -n "$PREV" ] && [ -e "$PREV" ] && [ ! -e "$OUT" ]; then mv -f "$PREV" "$OUT"; fi; }

# 依頼文は標準入力から渡す。--image は後ろの引数を全部画像のパスとして読むため、
# 依頼文を引数に書くと "No prompt provided via stdin." で止まる。末尾の - が「標準入力から読む」の指定
printf 'Use your built-in image generation tool to create ONE image, then save the PNG to %s. Do not write any other files. Image prompt: %s\n' "$OUT_REL" "$PROMPT" \
  | codex exec -s workspace-write -C "$SM" ${refs[@]+"${refs[@]}"} - > "$LOG" 2>&1
status=$?

# 保存された PNG を、中身まで読めるかで確かめる（Codex が base64 で書き写した PNG が途中で切れていたことがある）
png_ok() { uv run --no-project --with pillow python -I -c 'import sys;from PIL import Image;im=Image.open(sys.argv[1]);im.load()' "$1" >/dev/null 2>&1; }

if [ -s "$OUT" ] && png_ok "$OUT"; then
  rm -f "$PREV"
  echo "描けた: $OUT_REL"
  exit 0
fi
rm -f "$OUT"

# 読めなければ、Codex が最初に書いた ~/.codex/generated_images/<セッション id>/ から拾い直す。
# そのセッションの PNG が1枚だけのときだけ写す。2枚以上なら、どれが依頼の絵か決められないので止まる
pngs=()
sid="$(grep -m1 -oE 'session id: [0-9a-f-]+' "$LOG" | awk '{print $3}')"
if [ -n "$sid" ] && [ -d "$HOME/.codex/generated_images/$sid" ]; then
  for f in "$HOME/.codex/generated_images/$sid"/*.png; do [ -f "$f" ] && pngs+=("$f"); done
  if [ "${#pngs[@]}" -eq 1 ] && png_ok "${pngs[0]}"; then
    cp "${pngs[0]}" "$OUT"
    rm -f "$PREV"
    echo "保存された PNG が壊れていたので、Codex の元の PNG から拾い直した: $OUT_REL"
    exit 0
  fi
fi

restore
# 利用枠切れは、描けなかったときだけ、Codex 自身の失敗の行で見分ける。
# ログには渡した依頼文も写るので、依頼文を写した行（Image prompt を含む行）は除く
if grep -v 'Image prompt:' "$LOG" | grep -iE 'error|failed|stream disconnected' | grep -qiE 'usage limit|rate limit|hit your limit|quota'; then
  echo "Codex の利用枠が切れました（記録: ${LOG}）。人間に「待つか、Nano Banana へ回すか」を訊いてください" >&2
  exit 4
fi
echo "描けませんでした（codex の終了コード ${status}、セッション ${sid:-不明} の PNG ${#pngs[@]:-0} 枚、記録: ${LOG}）。描き直しに回してください" >&2
exit 1
