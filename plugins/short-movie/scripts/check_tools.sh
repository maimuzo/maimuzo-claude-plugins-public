#!/bin/bash
# 動画を作るのに要る道具がそろっているかを確かめる。足りなければ入れ方を示して、終了コード 1 で終わる。
# 全体へ入れる道具は、人間に断らずには入れない（このスクリプトは確かめるだけで、何も入れない）。
# 使い方: check_tools.sh
set -u
missing=0
need() {
  local cmd="$1" hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '有る: %s（%s）\n' "$cmd" "$("$cmd" --version 2>&1 | head -n 1)"
  else
    printf '無い: %s\n  入れ方: %s\n' "$cmd" "$hint"
    missing=1
  fi
}
need node   "https://nodejs.org/ の LTS 版を入れる（macOS なら brew install node）"
need npm    "Node.js と一緒に入る"
need ffmpeg "macOS なら brew install ffmpeg、Debian 系なら sudo apt install ffmpeg"
need ffprobe "ffmpeg と一緒に入る"
need uv     "https://docs.astral.sh/uv/ の手順（macOS なら brew install uv）"
need git    "macOS なら xcode-select --install、Debian 系なら sudo apt install git"
need python3 "macOS なら xcode-select --install、Debian 系なら sudo apt install python3"
if command -v codex >/dev/null 2>&1; then
  printf '有る: codex（%s）\n' "$(codex --version 2>&1 | head -n 1)"
else
  printf '任意で無い: codex（絵は Nano Banana で人間が描く形になる）\n  入れ方: npm install -g @openai/codex\n'
fi
exit "$missing"
