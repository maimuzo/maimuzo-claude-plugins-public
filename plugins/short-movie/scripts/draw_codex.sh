#!/bin/bash
# Codex の組み込みの画像生成で、絵を1枚描かせる。
# 使い方: draw_codex.sh <short_movie のパス> <依頼文のファイル> <保存先の .png（short_movie からの相対パス）> [添付する設定画 ...]
# 依頼文のファイルには、英語の依頼文だけを書く（背景の指定も含める）。
# 終了コード: 0 描けた / 1 描けなかった / 4 利用枠が切れた（人間に「待つか、Nano Banana へ回すか」を訊く）
# 1枚に数分かかる。Bash の時間切れに注意すること。
set -uo pipefail
. "$(dirname "$0")/_common.sh"

[ $# -ge 3 ] || sm_die "使い方: draw_codex.sh <short_movie のパス> <依頼文のファイル> <保存先の .png> [設定画 ...]"
SM="$(cd "$1" && pwd)"; PROMPT_FILE="$2"; OUT_REL="$3"; shift 3
OUT="$SM/$OUT_REL"
mkdir -p "$(dirname "$OUT")" "$SM/out/review"
LOG="$SM/out/review/codex_$(date +%Y%m%d_%H%M%S).log"

refs=()
for r in "$@"; do refs+=(--image "$r"); done

# 依頼文は標準入力から渡す。--image は後ろの引数を全部画像のパスとして読むため、
# 依頼文を引数に書くと "No prompt provided via stdin." で止まる。末尾の - が「標準入力から読む」の指定
{
  printf 'Use your built-in image generation tool to create ONE image, then save the PNG to %s. Do not write any other files. Image prompt: ' "$OUT_REL"
  cat "$PROMPT_FILE"
} | codex exec -s workspace-write -C "$SM" ${refs[@]+"${refs[@]}"} - > "$LOG" 2>&1
status=$?

if grep -qiE 'usage limit|rate limit|hit your limit' "$LOG"; then
  echo "Codex の利用枠が切れました（記録: ${LOG}）。人間に「待つか、Nano Banana へ回すか」を訊いてください" >&2
  exit 4
fi

# 保存された PNG を、中身まで読めるかで確かめる（Codex が base64 で書き写した PNG が途中で切れていたことがある）
png_ok() { uv run --no-project --with pillow python -I -c 'import sys;from PIL import Image;im=Image.open(sys.argv[1]);im.load()' "$1" >/dev/null 2>&1; }

if [ -s "$OUT" ] && png_ok "$OUT"; then
  echo "描けた: $OUT_REL"
  exit 0
fi

# 読めなければ、Codex が最初に書いた ~/.codex/generated_images/<セッション id>/ から拾い直す。
# そのセッションの PNG が1枚だけのときだけ写す。2枚以上なら、どれが依頼の絵か決められないので止まる
sid="$(grep -m1 -oE 'session id: [0-9a-f-]+' "$LOG" | awk '{print $3}')"
if [ -n "$sid" ] && [ -d "$HOME/.codex/generated_images/$sid" ]; then
  pngs=("$HOME/.codex/generated_images/$sid"/*.png)
  if [ "${#pngs[@]}" -eq 1 ] && [ -f "${pngs[0]}" ] && png_ok "${pngs[0]}"; then
    cp "${pngs[0]}" "$OUT"
    echo "保存された PNG が壊れていたので、Codex の元の PNG から拾い直した: $OUT_REL"
    exit 0
  fi
  echo "拾い直せませんでした。セッション $sid の PNG が ${#pngs[@]} 枚あります。描き直しに回してください（記録: ${LOG}）" >&2
  exit 1
fi
echo "描けませんでした（codex の終了コード ${status}、記録: ${LOG}）" >&2
exit 1
