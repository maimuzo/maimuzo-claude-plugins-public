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
# pid の書かれたロックで、その pid が動いていなければ取り残しとみなす。
# pid がまだ書かれていないロックは、作られて2分たつまでは取り残しとみなさない（書く途中かもしれないため）。
# 取り残しは、まず自分だけの名前へ mv で退けてから消す。mv は1つしか成功しないので、
# 2つが同時に片付けても、ほかが取り直したばかりのロックを消さない。
# 最大10分待ち、過ぎたら止まる
waited=0
until mkdir "$LOCK" 2>/dev/null; do
  pid="$(cat "$LOCK/pid" 2>/dev/null || true)"
  stale=0
  if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then stale=1; fi
  if [ -z "$pid" ] && [ -n "$(find "$LOCK" -maxdepth 0 -mmin +2 2>/dev/null)" ]; then stale=1; fi
  if [ "$stale" = 1 ]; then
    if mv "$LOCK" "$LOCK.stale.$$" 2>/dev/null; then
      # 退けたあとで中の pid を読み直し、片付けると決めたときと同じロックかを確かめる
      if [ "$(cat "$LOCK.stale.$$/pid" 2>/dev/null || true)" = "$pid" ]; then
        echo "取り残しのロックを片付けます（pid ${pid:-無し}）" >&2
        rm -rf -- "$LOCK.stale.$$"
      else
        mv "$LOCK.stale.$$" "$LOCK" 2>/dev/null || rm -rf -- "$LOCK.stale.$$"
      fi
    fi
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
if [ -e "$TARGET" ]; then
  # 既にあるなら（.ready の無い作りかけでも）入れ替えない。使用中のものを消さないため。作った方を捨てる
  if [ -f "$TARGET/.ready" ]; then
    rm -rf -- "$TMP"
  else
    mv "$TARGET" "$ROOT/.broken-$VER-$$" && mv "$TMP" "$TARGET"
  fi
else
  mv "$TMP" "$TARGET"
fi

# 落ちた準備の跡（.tmp-*・.broken-*・.lock.stale.*）で、1時間より古いものを消す
find "$ROOT" -maxdepth 1 \( -name '.tmp-*' -o -name '.broken-*' -o -name '.lock.stale.*' \) -mmin +60 -exec rm -rf -- {} + 2>/dev/null || true

# 使っていない古い版を消す。作業場所（work/）の node_modules の symlink が指している版と、
# 用意してから7日たっていない版は残す（ほかのセッションが古い版で書き出し始めたところかもしれないため）
for d in "$ROOT"/*/; do
  d="${d%/}"
  [ "$d" = "$TARGET" ] && continue
  [ -n "$(find "$d/.ready" -mtime +7 2>/dev/null)" ] || continue
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
