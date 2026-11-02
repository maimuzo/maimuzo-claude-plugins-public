# 並行で作るときの subagent への依頼文（雛形）

`remaining-videos` が、回ごとに1つの subagent へ渡す。`<…>` を埋めて渡す。subagent はこのプラグインの base directory を知らないので、スクリプトは絶対パスで書く。

```markdown
# <回の呼び名>（<回のid>）の動画を作る

## 何を作っているか
<製品名> の紹介動画（1080×1080・30fps・<尺>秒）を、Remotion で作っている。あなたは <回のid> の1本を担当する。

## お手本と正
- お手本: 人間が完成と認めた最初の1本 `<short_movie>/videos/<最初の回のid>/`（作り・台本の形）と、その詳しいコンテ `<short_movie>/storyboards/<最初の回のid>.md`。
- 何が起きるかの正: `<short_movie>/concept.md` の自分の回の節と共通の決まり。字幕の文言は表のとおりに1文字も変えない。
- キャラクターの正: `<short_movie>/characters.md` と `<short_movie>/materials/ref/`。
- 絵コンテ（`<short_movie>/materials/storyboards/<回のid>/`）は構図の見本。食い違ったらコンテが正。
- 人間の指摘: `<plugin>/references/lessons.md`。直すときは、人間の指摘の原文も下に添える。食い違って見えたら原文を優先して報告する。

## 手順
1. 詳しいコンテ `<short_movie>/storyboards/<回のid>.md` を読む（無ければ書く）
2. 要る絵を揃える。既存の絵を使い、無ければ `<plugin>/scripts/draw_codex.sh` で描いて `<plugin>/scripts/cutout.py` で抜く（`<plugin>/references/drawing.md`）
3. `<short_movie>/videos/<回のid>/` に `script.ts` と `index.tsx` を書く（雛形は `<plugin>/references/video-template/`）
4. 効果音を `SFX` の表で鳴らす。新しい音は `<short_movie>/materials/sfx/sfx_<回のid>.py` で合成する（`make_sfx.py` の写しは書き換えない）
5. `<plugin>/scripts/render.sh <short_movie> <回のid>` で書き出す（Bash の時間は最大にする）。型・形・音の鳴り始めの確かめとコマ割りの一覧が出る
6. コマ割りの一覧 `<short_movie>/out/<回のid>_contact.png` を自分で見て直す（`<plugin>/references/checks.md`）

## 書いてよい範囲（厳守）
- `<short_movie>/videos/<回のid>/`・`<short_movie>/storyboards/<回のid>.md`・`<short_movie>/materials/ep/<回のid>/`
- `<short_movie>/materials/prompts/` と `<short_movie>/materials/raw/` の、`<回のid>__` で始まる名前のもの
- `<short_movie>/materials/sfx/sfx_<回のid>.py` と `<short_movie>/materials/sfx/<回のid>_*.wav`
- `<short_movie>/out/<回のid>.mp4` と `<short_movie>/out/<回のid>_*`

`videos/_shared/`・`materials/sfx/make_sfx.py`・ほかの回・`theme.json`・設定画は読むだけ。共通の直しが要るときは、自分では直さず報告する。

## しないこと
`git commit`・`git push`・`git stash`・`git checkout`、`claude -p`、Gemini の API と CLI。

## 報告
作ったファイル、新しく描いた絵、check_video.sh の出力、音の鳴り始めの秒、型の確かめの結果、コマ割りの一覧を見て直したこと、残った問題。
直すときは、指摘ごとに「どう直したか・何秒のコマで確かめたか」。
```
