---
name: characters
description: This skill should be used when the user asks to "design the characters", "キャラクターを作る", "設定画を描いて", "絵柄を決める", or runs /short-movie:characters after the concept is approved. It writes short_movie/characters.md and drawing prompts, has Codex (or the human via Nano Banana) draw style candidates and character sheets, and cuts out the backgrounds.
---

# コンテに要るキャラクターを描く

コンテに出るキャラクターの設定（`characters.md`）と、絵柄の候補・設定画を作る。絵は Codex か Nano Banana に描かせる。人間の「絵柄とキャラクター」の確認で止まる。

## 最初にすること

- このスキルの base directory の2つ上が、プラグインの根（以下 `<plugin>`）。スクリプトは `<plugin>/scripts/`、資料は `<plugin>/references/` にある。
- 使う側のリポジトリの根の `short_movie/`（以下 `<sm>`）だけを書き換える。リポジトリ直下の既存のファイルは触らない。
- 全体の流れと置き場所は `<plugin>/references/workflow.md` を読む。

## 前の工程の確かめ

`<sm>/concept.md` が無ければ、何もせずに「先に /short-movie:concept-work を実行してください」と表示して止まる。

## 手順

1. `<plugin>/references/drawing.md` を読む（依頼文の形・背景の指定・Codex と Nano Banana の使い分け）。
2. `<sm>/concept.md` から、出てくる役を拾い、`<sm>/characters.md` を書く。役ごとに、見た目・色（16進）・性格・依頼文の核（英語）。
   - 製品やツールを擬人化するときは、既存のマスコットやロゴに似せない。
   - 似た形の役を並べるときは、色で見分けられるようにし、名前の札を頭の上に出す前提にする。
3. 絵柄の候補を描かせる。依頼文を `<sm>/materials/prompts/style_candidates.md` に書き、絵柄の違う案を2〜3案、Codex で1案ずつ描かせる（`bash <plugin>/scripts/draw_codex.sh <sm> <sm>/materials/prompts/style_candidates.md style_candidates/<案> materials/raw/style_candidates/<案>.png`。依頼書の中の `## <番号>. style_candidates/<案>` の節の依頼文だけが渡る。Bash の時間は最大にする）。
   - Codex が無い、または枠が切れた（終了コード 4）ときは、人間に「待つか、Nano Banana へ回すか」を訊いて止まる。Nano Banana へ回すときは、`to_nanobanana.py` で背景の指定を緑一色に替えた写しを作って人間に渡し、保存されたら `ingest.py` で受け取る（`references/drawing.md`）。
4. 候補を1枚の比較画像に並べ（Pillow で横に並べる。`<sm>/out/review/style_candidates.png`）、人間に選んでもらう。ここで止まる。
5. 人間が選んだら、その絵柄で役ごとの設定画を描かせる。設定画は、1枚の絵に正面・横・後ろの3つを並べたもの。描かせたままの絵は `<sm>/materials/raw/ref/<役>.png` に残し、`cutout.py` で背景を抜いて `<sm>/materials/ref/<役>.png` に置く。設定画は以後、毎回添付する正の絵になる。

## 最後に表示すること

作ったもの・決めたこと・人間に確かめてほしいことを短くまとめ、最後に次の2行を表示して止まる。`<…>` は実際の値（回の id など）に置き換えて表示する。人間の評価を待ち、勝手に次の工程へ進まない。

```
---
直すとき: 直したい内容をそのまま書いてください。このスキルの続きで直します
この内容でよいときは次のスキルを実行してください: /short-movie:storyboard
```
