---
name: first-video
description: This skill should be used when the user asks to "make the first video", "1本目を作る", "まず1本動画にする", or runs /short-movie:first-video with a video id after the storyboard is approved. It builds one video with Remotion from the detailed storyboard, synthesizes sound effects, renders an mp4 locally, checks it, and iterates on the details with the human.
argument-hint: <回のid>
---

# まず1本を動画にして、細部を調整する

1本の回を Remotion で組み立て、効果音を付けて mp4 に書き出し、自分で確かめてから人間に見せる。人間が完成と認めるまで、指摘を受けて直す。人間の「最初の1本」の確認で止まる。

## 最初にすること

- このスキルの base directory の2つ上が、プラグインの根（以下 `<plugin>`）。スクリプトは `<plugin>/scripts/`、資料は `<plugin>/references/` にある。
- 使う側のリポジトリの根の `short_movie/`（以下 `<sm>`）だけを書き換える。リポジトリ直下の既存のファイルは触らない。
- 全体の流れと置き場所は `<plugin>/references/workflow.md` を読む。

## 前の工程の確かめ

`<sm>/storyboards/<回のid>.md` と `<sm>/materials/storyboards/<回のid>/` が無ければ、何もせずに「先に /short-movie:storyboard を実行してください」と表示して止まる。

## 手順

1. `<plugin>/references/example.md`・`<plugin>/references/checks.md`・`<plugin>/references/lessons.md` を読む。
2. 要る絵を揃える。詳しいコンテの「要る絵」のうち無いものを描かせ（`<plugin>/references/drawing.md`）、`cutout.py` で抜いて `<sm>/materials/characters/<役>/`・`props/`・`backgrounds/`・`ep/<回のid>/` に置く。描かせたままの絵は `<sm>/materials/raw/` に残す。
3. 共通の効果音を作る（初回だけ）。
   - `<plugin>/scripts/make_sfx.py` を `<sm>/materials/sfx/make_sfx.py` へ写し、写しを流す: `uv run --no-project --python 3.12 --with numpy==2.5.4 python -I <sm>/materials/sfx/make_sfx.py`
   - `<sm>/materials/sfx/README.md` に、使った Python と numpy の版と、この呼び方を書く（何年後でも同じ音を作り直せるようにするため）。
   - 回だけの音は `<sm>/materials/sfx/sfx_<回のid>.py` に書く。自分のフォルダを `sys.path` に足してから `make_sfx` を import し、同じフォルダへ `<回のid>_<名前>.wav` を書き出す。`make_sfx.py` の写しは書き換えない。
4. 回を組み立てる。`<plugin>/references/video-template/` を `<sm>/videos/<回のid>/` へ写し、詳しいコンテのとおりに `script.ts`（`meta`・場面の表・製品名と URL）と `index.tsx`（場面ごとの `<Sequence>`・絵・動き・`SFX` の表）を書く。
   - 土台の部品は `../../components/`、色は `../../theme` から読む。回だけの部品は回のフォルダに置く。
   - 製品全体で効かせたい部品の直しは `<sm>/videos/_shared/` に写して直す（`../theme` を `../../theme` に書き換える）。
5. 書き出す。`bash <plugin>/scripts/render.sh <sm> <回のid>` を Bash の時間を最大にして叩く。型・形・音の鳴り始めの確かめと、コマ割りの一覧が出る。
6. コマ割りの一覧を自分で見て直す（`checks.md`。3周まで）。直しながら見るときは `bash <plugin>/scripts/studio.sh <sm> <回のid>` をバックグラウンドで叩く。
7. 人間に `<sm>/out/<回のid>.mp4` を見て・聞いてもらう。音は AI が聞いていないことを書く。

## 直すとき

- 人間の指摘ごとに「どう直したか・何秒のコマで確かめたか」を書く。
- コンテの「何が起きるか」を変えたくなったら、止めて人間に訊く。部品の形・配色の細部・字幕の位置・コマの枚数・効果の付け方は、コンテが変わらない範囲で AI が決めてよい。

## 最後に表示すること

作ったもの・決めたこと・人間に確かめてほしいことを短くまとめ、最後に次の2行を表示して止まる。人間の評価を待ち、勝手に次の工程へ進まない。

```
---
直すとき: 直したい内容をそのまま書いてください。このスキルの続きで直します
この内容でよいときは次のスキルを実行してください: /short-movie:remaining-videos
```
