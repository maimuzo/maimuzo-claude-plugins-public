#!/bin/bash
# 回を1本、Remotion Studio で開く。使う側の videos/ を symlink で見せるので、TSX の直しがそのまま映る。
# 使い方: studio.sh <short_movie のパス> <回の id>
# Studio は終わらないプロセスなので、Bash ではバックグラウンドで叩くこと。
# 限界: public/ と theme.json は写しなので、絵・音・色を直したら開き直す。
set -euo pipefail
. "$(dirname "$0")/_common.sh"
. "$(dirname "$0")/_workspace.sh"

[ $# -eq 2 ] || sm_die "使い方: studio.sh <short_movie のパス> <回の id>"
SM="$(cd "$1" && pwd)"
ID="$2"
sm_check_id "$ID"
[ -f "$SM/videos/$ID/index.tsx" ] || sm_die "回が見つかりません: $SM/videos/$ID/index.tsx"

ENGINE="$("$SM_PLUGIN_DIR/scripts/prepare_engine.sh" | tail -n 1)"
sm_make_workspace "$SM" "$ID" studio "$ENGINE"
ln -s "$SM/videos" "$WS/src/videos"
# symlink の先を自分の場所として扱わないようにする（使う側から node_modules を探しに行かないため）。
# render とは別の作業場所なので、この設定は書き出しに効かない
cat >> "$WS/remotion.config.ts" <<'CFG'

// studio.sh が足す: 使う側の videos/ への symlink を、作業場所の中のパスとして解決する
Config.overrideWebpackConfig((c) => ({ ...c, resolve: { ...c.resolve, symlinks: false } }));
CFG
cd "$WS"
# Studio を閉じたら作業場所を消す（残すと、古い版の engine を使用中とみなして消せなくなるため）
trap 'cd /; rm -rf -- "$WS"' EXIT
npx remotion studio src/index.ts
