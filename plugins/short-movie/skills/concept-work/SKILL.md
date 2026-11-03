---
name: concept-work
description: This skill should be used when the user asks to "write the concept", "コンテを考える", "コンテを書いて", "動画の構成を決める", or runs /short-movie:concept-work with a summary of what to convey. It turns the human's summary into short_movie/concept.md, a storyboard table (seconds, what happens, burned-in captions) for every video.
argument-hint: "<人間がまとめた、伝えたい概要>"
---

# コンテを一緒に考える

人間がまとめた「伝えたい概要」を元に、全回のコンテ（`concept.md`）を書く。人間の「コンテ」の確認で止まる。

## 最初にすること

- このスキルの base directory の2つ上が、プラグインの根（以下 `<plugin>`）。スクリプトは `<plugin>/scripts/`、資料は `<plugin>/references/` にある。
- 使う側のリポジトリの根の `short_movie/`（以下 `<sm>`）だけを書き換える。リポジトリ直下の既存のファイルは触らない。
- 全体の流れと置き場所は `<plugin>/references/workflow.md` を読む。

## 前の工程の確かめ

`<sm>/brief.md` と `<sm>/theme.json` が無ければ、何もせずに「先に /short-movie:start を実行してください」と表示して止まる。

## 手順

1. `<sm>/brief.md` と、引数の概要を読む。概要が無ければ、人間に「伝えたいことの概要」を訊いて止まる（コンテは人間の概要から書く）。
2. `<plugin>/references/lessons.md` と `<plugin>/references/example.md` を読む。
3. `<sm>/concept.md` を書く。
   - 1節に全回の共通の決まり: 尺の割り方（例: タイトル2秒 → 本編11秒 → 締め2秒）、無音で伝わること、字幕の焼き込み、1本で「困った → 製品が片付ける」を1往復、締めに製品名と URL、キャラクターの役の分け方。
   - 回の一覧の表: 回の id（ケバブ。例 `place-on-ready`）・呼び名（例「置くだけの回」）・何を見せるか・尺。**この表が回の id の一覧の正**になる。
   - 回ごとの節: 秒・何が起きるか・字幕の表。タイトルと締めの字幕も書く。
4. 人間の指摘（`lessons.md`）に照らして自分で見直す: 実物の関係のとおりか、紹介するものの機能ではないものを描いていないか、字幕が読む人の言葉か、短すぎる場面が無いか。

## 直すとき

- コンテを直したら、もう動画がある回は、動画もそのコンテで作り直すまでが1つの作業。どの回の動画が古くなったかを報告する。

## 最後に表示すること

作ったもの・決めたこと・人間に確かめてほしいことを短くまとめ、最後に次の2行を表示して止まる。`<…>` は実際の値（回の id など）に置き換えて表示する。人間の評価を待ち、勝手に次の工程へ進まない。

```
---
直すとき: 直したい内容をそのまま書いてください。このスキルの続きで直します
この内容でよいときは次のスキルを実行してください: /short-movie:characters
```
