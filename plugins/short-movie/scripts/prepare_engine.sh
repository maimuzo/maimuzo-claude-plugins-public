#!/bin/bash
# 書き出しに使う Remotion の土台（engine）を、データ置き場に版ごとに1つだけ用意する。
# 使い方: prepare_engine.sh
# 出力: 最後の行に、用意した engine の版ディレクトリの絶対パスを出す。
# 初回は npm ci と Chrome Headless Shell の取得で数分かかる。Bash の時間切れに注意すること。
set -euo pipefail
. "$(dirname "$0")/_common.sh"

DATA="$(sm_data_dir)"
VER="$(sm_engine_version)"
ROOT="$DATA/engine"
TARGET="$ROOT/$VER"
LOCK="$ROOT/.lock"
mkdir -p "$ROOT"

if [ -f "$TARGET/.ready" ]; then
  printf '%s\n' "$TARGET"
  exit 0
fi

# ロック。mkdir で取り、中に自分の pid を書く。
# pid の書かれたロックで、その pid が動いていなければ取り残しとして消す。
# pid がまだ書かれていないロックは、作られて2分たつまでは取り残しとみなさない（書く途中かもしれないため）。
# 最大10分待ち、過ぎたら止まる
waited=0
until mkdir "$LOCK" 2>/dev/null; do
  pid="$(cat "$LOCK/pid" 2>/dev/null || true)"
  if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
    echo "取り残しのロックを片付けます（pid $pid は動いていません）" >&2
    rm -rf -- "$LOCK"
    continue
  fi
  if [ -z "$pid" ] && [ -n "$(find "$LOCK" -maxdepth 0 -mmin +2 2>/dev/null)" ]; then
    echo "pid の無い古いロックを片付けます" >&2
    rm -rf -- "$LOCK"
    continue
  fi
  if [ "$waited" -ge 600 ]; then
    sm_die "engine の準備のロックを10分待っても取れませんでした（${LOCK}）。ほかの準備が終わっていないか確かめてください"
  fi
  sleep 5
  waited=$((waited + 5))
done
echo $$ > "$LOCK/pid"
trap 'rm -rf -- "$LOCK"' EXIT

# ロックを取ったあとに、もう一度確かめる（待っている間にほかが作ったかもしれないため）
if [ -f "$TARGET/.ready" ]; then
  printf '%s\n' "$TARGET"
  exit 0
fi

# 一時ディレクトリは同じ置き場の中に作る（mv をファイルシステムをまたがない入れ替えにするため）
TMP="$ROOT/.tmp-$VER-$$"
rm -rf -- "$TMP"
mkdir -p "$TMP"
cp "$SM_PLUGIN_DIR/engine/package.json" "$SM_PLUGIN_DIR/engine/package-lock.json" "$TMP/"
echo "npm ci を流します（初回は数分かかります）" >&2
(cd "$TMP" && npm ci --no-audit --no-fund >&2)
echo "Chrome Headless Shell を取得します" >&2
(cd "$TMP" && npx remotion browser ensure >&2)
touch "$TMP/.ready"
rm -rf -- "$TARGET"
mv "$TMP" "$TARGET"

# 使っていない古い版を消す。作業場所（work/）の node_modules の symlink が指している版は、使用中として残す
for d in "$ROOT"/*/; do
  d="${d%/}"
  [ "$d" = "$TARGET" ] && continue
  used=0
  if [ -d "$DATA/work" ]; then
    while IFS= read -r link; do
      if [ "$(readlink "$link")" = "$d/node_modules" ]; then used=1; break; fi
    done < <(find "$DATA/work" -maxdepth 4 -name node_modules -type l 2>/dev/null)
  fi
  if [ "$used" = 0 ]; then
    echo "使っていない古い engine を消します: $d" >&2
    rm -rf -- "$d"
  fi
done

printf '%s\n' "$TARGET"
