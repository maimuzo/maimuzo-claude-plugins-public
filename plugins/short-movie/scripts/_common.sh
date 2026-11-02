# short-movie の道具が共通で使う決まり。ほかのスクリプトが . で読み込む。

SM_PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# データ置き場。環境変数 CLAUDE_PLUGIN_DATA が空でなく、展開されないままの "$..." でもないときだけ使う。
# それ以外は ~/.cache/short-movie。本体と subagent が同じ決まりで決めるので、同じ場所になる
sm_data_dir() {
  case "${CLAUDE_PLUGIN_DATA:-}" in
    ''|'$'*) printf '%s\n' "$HOME/.cache/short-movie" ;;
    *) printf '%s\n' "$CLAUDE_PLUGIN_DATA" ;;
  esac
}

# 文字列の sha1 の先頭12桁
sm_sha12() { printf '%s' "$1" | shasum -a 1 | cut -c1-12; }

# engine の版。依存を決める package.json と package-lock.json の中身から決める。
# 部品（src/）を直しただけでは npm ci と Chrome の取得をやり直さない
sm_engine_version() { cat "$SM_PLUGIN_DIR/engine/package.json" "$SM_PLUGIN_DIR/engine/package-lock.json" | shasum -a 1 | cut -c1-12; }

sm_die() { printf '%s\n' "$*" >&2; exit 1; }

# 回の id はケバブ（英小文字・数字・ハイフン）。Remotion の Composition の id に _ を使えないため
sm_check_id() {
  case "$1" in
    ''|*[!a-z0-9-]*|-*) sm_die "回の id はケバブ（英小文字・数字・ハイフン）で書いてください: $1" ;;
  esac
}
