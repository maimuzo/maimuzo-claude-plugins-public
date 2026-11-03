---
name: remaining-videos
argument-hint: <人間が完成と認めた最初の1本の回のid>
description: This skill should be used when the user asks to "make the remaining videos", "残りの動画を作る", "他の動画を並行で作る", "全部まとめて直す", or runs /short-movie:remaining-videos after the first video is approved. It builds the remaining videos in parallel with one subagent per video, renders them all, and applies the human's feedback to all of them at once.
---

# 残りの動画を並行で作り、全部一気に細部を調整する

最初の1本をお手本に、残りの回を subagent で並行して作る。全部を書き出し直して見比べ、人間の指摘を全部の回へまとめて直す。人間の「残りの全部」の確認で止まる。

## 最初にすること

- このスキルの base directory の2つ上が、プラグインの根（以下 `<plugin>`）。スクリプトは `<plugin>/scripts/`、資料は `<plugin>/references/` にある。
- 使う側のリポジトリの根の `short_movie/`（以下 `<sm>`）だけを書き換える。リポジトリ直下の既存のファイルは触らない。
- 全体の流れと置き場所は `<plugin>/references/workflow.md` を読む。

## 前の工程の確かめ

引数の回の id が、人間が完成と認めた最初の1本（お手本）になる。人間がこのスキルを引数付きで実行したことを、その1本の了承とみなす（会話の記憶には頼らない。セッションを開き直しても進めるため）。

- 引数が無ければ、`<sm>/concept.md` の回の一覧と `<sm>/videos/` を見て、動画のある回を挙げ、「お手本にする回の id を付けて実行してください（例: /short-movie:remaining-videos <回のid>）」と表示して止まる。
- `<sm>/videos/<回のid>/` が無ければ、何もせずに「先に /short-movie:first-video <回のid> を実行してください」と表示して止まる。

## 手順

1. 残りの回を決める。`<sm>/concept.md` の回の一覧の表のうち、`<sm>/videos/<回のid>/` がまだ無い回。
2. 先に共通のものを済ませる。subagent が書く範囲を回ごとに分けるため。
   - `bash <plugin>/scripts/prepare_engine.sh` を1回叩く（engine の準備を並行で取り合わないため）。
   - 回をまたいで使うキャラクターのポーズ・背景・小物で、まだ無いものを先に描いて置く。
   - 詳しいコンテと絵コンテが無い回があれば、先に /short-movie:storyboard を案内して止まる（前の工程が固まる前に次を作らない）。
3. 回ごとに1つの subagent を立てる。依頼文は `<plugin>/references/parallel-brief.md` の雛形を埋めたもの（`<最初の回のid>` は引数の回の id）。`<plugin>` と `<sm>` は絶対パスで書く（subagent には base directory が示されない）。
4. 全部が終わったら、全部の回を `render.sh` で書き出し直し、コマ割りの一覧を並べて見比べる（回をまたいでキャラクター・色・字幕の位置がそろっているか）。
5. 人間に全部の mp4 を見てもらう。

## 直すとき（全部一気に）

1. 人間の指摘を、回ごとに分ける。コンテを直す必要があれば、先にオーケストレーターがコンテを直し、それを正にする。
2. 直す回ごとに subagent を立て、正のコンテと人間の指摘の原文を添えて並行で直させる。
3. 全部を書き出し直して見比べ、指摘ごとに「どう直したか・何秒のコマで確かめたか」を報告する。

## 最後に表示すること

作ったもの・直したこと・人間に確かめてほしいことを短くまとめ、最後に次の2行を表示して止まる。

```
---
直すとき: 直したい内容をそのまま書いてください。このスキルの続きで直します
この内容でよいときは: これで全部の動画ができました（mp4 は short_movie/out/ にあります）
```
