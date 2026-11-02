# 絵の描かせ方（Codex と Nano Banana）

絵は、AI が書いた英語の依頼文で描かせる。まず Codex で描き、Codex の利用枠が切れたら人間が Nano Banana（ブラウザの Gemini アプリ）で描く。
無料で使える範囲だけを使う。Codex は ChatGPT の定額プランの枠の中で動く。Gemini の API・CLI は無料枠では画像を作れないので使わない。`claude -p` は従量課金なので使わない。

## 依頼文（materials/prompts/）

- 依頼書は1つのファイルに書き、Codex にも人間にも同じものを渡す。各依頼文の上に日本語の1行を添える。
- 形:

````markdown
# 絵の依頼書 <名前>（<日付>）

最初に `materials/ref/<役>.png` を添付してください。上から順に貼り、出た画像を順に `short_movie/inbox/` へ保存してください。

## 1. characters/hero_wave　主人公が手を振る
- 道具: codex
```
Use the attached character sheet. Draw only the hero, waving one hand, front view. <背景の指定> Bold outlines, flat fills with one shade step. Original character.
```
````

- 並行で作るときは、その回の依頼文と元の絵の名前を `<回のid>__` で始める（例: `materials/prompts/feature-one__frames.md`、`materials/raw/feature-one__hero_jump.png`）。回をまたいで使うキャラクターのポーズは、オーケストレーターが先に作る。
- 毎回入れる語: 設定画と同じ絵柄（太い線・影1段の平らな塗り）、オリジナルのキャラクター。既存のキャラクター名・ロゴ名は書かない。

## 背景の指定

| 絵 | Codex | Nano Banana |
| --- | --- | --- |
| キャラクター・小物（動画の上に重ねる） | `Transparent background (real alpha channel, no checkerboard pattern).` | `Solid #00FF00 green background. Do not use green anywhere in the subject.` |
| 背景・絵コンテ（場面全体） | 場面全体を描かせる（透過にしない） | 同左 |

- 白い背景で描かせて抜く形は使わない。キャラクターの白い部分まで抜けるため。
- Codex の透過は 2026-11-02 に1枚で測った: 絵全体の 48.9% が完全に透明、49.8% が alpha 240〜254（わずかに透ける）。`cutout.py` が 240 以上を 255 にそろえる。透過の1枚は 55,428 トークンで、不透明の1枚（約2.9万）の約2倍だった。
- 1本の動画の絵は、片方の道具だけで描く。2つの道具の絵柄はそろわず、コマ送りの途中で顔が変わるため。途中で Codex の枠が切れたら、その回で Codex が描いたキャラクターの絵も Nano Banana で描き直す。

## Codex で描く

`<plugin>/scripts/draw_codex.sh <short_movie> <依頼文のファイル> <保存先> [設定画...]` で1枚ずつ描かせる。

- 1枚に数分かかる（測った例: 83〜353秒、平均155秒）。Bash の時間を最大（600000 ミリ秒）にして叩く。
- 終了コード 4 は利用枠切れ。そこで止め、人間に「待つか、Nano Banana へ回すか」を訊く。利用枠の残りは調べない。
- 保存された PNG が途中で切れていることがある。スクリプトが中身まで読んで確かめ、壊れていれば Codex の元の PNG から拾い直す。拾い直せなければ描き直す。

## Nano Banana で描く（人間がする）

1. 依頼書を人間に渡す。
2. 人間が Gemini アプリで新しいチャットを開き、依頼書の冒頭の設定画を添付する。
3. 依頼文を上から順に1つずつ貼り、出た画像を1枚ずつ `short_movie/inbox/` へ保存する（ファイル名は変えなくてよい）。
4. 人間が「保存した」と伝えたら、`python3 -I <plugin>/scripts/ingest.py <short_movie> <依頼書>` で、保存の順と依頼書の順を突き合わせて `materials/raw/` へ移す。

- 最初に1回だけ、Gemini アプリの設定で「Media watermark」を Off にしてもらう。
- 1日に描ける枚数は公表されていない。1つの依頼書は10枚以内にする。

## 背景を抜く

`uv run --no-project --with pillow --with numpy python -I <plugin>/scripts/cutout.py <元の絵> <動画で使う絵>`

- 透過の絵なら alpha をそろえ、緑一色の絵なら緑を抜く。どちらでもなければ終了コード 3 で止まるので、描き直しに回す。
- 抜いた絵は、設定画と並べて見比べる。色と形がずれていたら描き直す。
