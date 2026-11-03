# render.sh と studio.sh が共通で使う、作業場所の作り方。. で読み込む。
# 引数: $1 short_movie の絶対パス、$2 回の id、$3 作業場所の種類（render か studio）、$4 engine の版ディレクトリ
# 出力: 変数 WS に作業場所の絶対パスを入れる

sm_make_workspace() {
  local sm="$1" id="$2" kind="$3" engine="$4"
  local data; data="$(sm_data_dir)"
  WS="$data/work/$(sm_sha12 "$sm")/$id/$kind"
  # symlink を辿らずに消す（rm -rf は中の symlink の先を消さない。末尾に / を付けない）
  rm -rf -- "$WS"
  mkdir -p "$WS/src" "$WS/public"
  cp "$SM_PLUGIN_DIR/engine/package.json" "$SM_PLUGIN_DIR/engine/remotion.config.ts" "$SM_PLUGIN_DIR/engine/tsconfig.json" "$WS/"
  cp -R "$SM_PLUGIN_DIR/engine/src/." "$WS/src/"
  ln -s "$engine/node_modules" "$WS/node_modules"
  cp "$sm/theme.json" "$WS/src/theme.json"
  # public の根には、動画で使う絵と wav だけを写す（依頼文・元の絵・設定画・絵コンテ・コードは写さない）
  local d
  for d in characters props backgrounds ep; do
    if [ -d "$sm/materials/$d" ]; then cp -R "$sm/materials/$d" "$WS/public/$d"; fi
  done
  if [ -d "$sm/materials/sfx" ]; then
    mkdir -p "$WS/public/sfx"
    find "$sm/materials/sfx" -maxdepth 1 -name '*.wav' -exec cp {} "$WS/public/sfx/" \;
  fi
  # Root はその回1本だけを登録する。ほかの回が書きかけでも束ねる段で巻き込まないため
  cat > "$WS/src/Root.tsx" <<ROOT
import React from "react";
import { Composition } from "remotion";
import Video, { meta } from "./videos/$id";

// render.sh / studio.sh が作る。この回 1 本だけを登録する
export const Root: React.FC = () => (
  <Composition
    id={meta.id}
    component={Video}
    durationInFrames={Math.round(meta.durationInSeconds * 30)}
    fps={30}
    width={1080}
    height={1080}
  />
);
ROOT
}
