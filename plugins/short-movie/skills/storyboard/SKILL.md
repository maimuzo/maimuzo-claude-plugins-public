---
name: storyboard
description: This skill should be used when the user asks to "make the storyboard", "絵コンテを描く", "回ごとの詳しいコンテ", "代表シーンを描いて", or runs /short-movie:storyboard after the characters are approved. It writes a detailed storyboard per video (cuts, layout, timing, sound effects) and has Codex draw representative scenes to fix the image.
argument-hint: "[回のid ...]（省略すると concept.md の全部の回）"
---

# 回ごとに詳しいコンテと絵コンテを作る

作ったキャラクターを使い、動画ごとに詳しいコンテを決める。代表的な場面を Codex か Nano Banana に描かせて、イメージを固める。人間の「絵コンテ」の確認で止まる。

## 最初にすること

- このスキルの base directory の2つ上が、プラグインの根（以下 `<plugin>`）。スクリプトは `<plugin>/scripts/`、資料は `<plugin>/references/` にある。
- 使う側のリポジトリの根の `short_movie/`（以下 `<sm>`）だけを書き換える。リポジトリ直下の既存のファイルは触らない。
- 全体の流れと置き場所は `<plugin>/references/workflow.md` を読む。

## 前の工程の確かめ

`<sm>/characters.md` と `<sm>/materials/ref/` の設定画が無ければ、何もせずに「先に /short-movie:characters を実行してください」と表示して止まる。

## 手順

1. 対象の回を決める。引数があればその回、無ければ `<sm>/concept.md` の回の一覧の表の全部。
2. 回ごとに `<sm>/storyboards/<回のid>.md` を書く。
   - カット（場面）ごとに: 秒、構図（誰がどこにいるか。1080×1080 の座標の目安）、動き（何秒に何が起きるか）、字幕（`concept.md` の文言のまま）、効果音（音の名前と鳴らす秒）、要る絵（キャラクターのポーズ・背景・小物）。
   - 要る絵は、既にある絵を使い回せるものと、新しく描くものに分ける。1本あたりのキャラクターの絵は8枚程度を目安にし、動きの大半は画面側で付ける。
3. 代表的な場面の絵（絵コンテ）を描かせる。本編の場面ごとに1枚、場面全体の不透明な絵として描く。
   - 依頼文を `<sm>/materials/prompts/<回のid>__storyboard.md` に書く。設定画を添付し、絵柄は設定画と同じ平らな塗りで簡素に。
   - `bash <plugin>/scripts/draw_codex.sh <sm> <依頼文> materials/storyboards/<回のid>/<秒>.png <設定画...>` で1枚ずつ描かせる（Bash の時間は最大）。
   - 枠が切れたら、人間に「待つか、Nano Banana へ回すか」を訊いて止まる。
4. 絵コンテとコンテを突き合わせる。話の因果が絵で追えるか、同じキャラクターが別の役に見えないか、混みすぎていないかを見る。作業の文脈を持たない subagent にも、絵コンテとコンテだけを渡して見させる。
5. 回ごとの絵コンテを並べた一覧を `<sm>/out/review/storyboards_<回のid>.png` に作り、人間に見せて止まる。

## 直すとき

- 絵コンテとコンテが食い違ったら、コンテが正。コンテを変えたくなったら人間に訊く。
- もう動画がある回は、絵コンテを描き直さない。

## 最後に表示すること

作ったもの・決めたこと・人間に確かめてほしいことを短くまとめ、最後に次の2行を表示して止まる。人間の評価を待ち、勝手に次の工程へ進まない。

```
---
直すとき: 直したい内容をそのまま書いてください。このスキルの続きで直します
この内容でよいときは次のスキルを実行してください: /short-movie:first-video <最初に作る回のid>
```
