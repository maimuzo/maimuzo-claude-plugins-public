---
name: start
description: This skill should be used when the user asks to "start a short movie", "make a product intro video", "短い紹介動画を作りたい", "製品の紹介動画を作る", or runs /short-movie:start with a repository URL or path. It checks the required tools, prepares the Remotion engine, reads the product, and writes short_movie/brief.md and theme.json for a 15-30 second feature video.
argument-hint: <紹介したいもののリポジトリの URL かローカルのパス>
---

# 紹介動画づくりを始める（方針）

紹介したい製品の情報を受け取り、道具を確かめ、方針（`brief.md`）と色（`theme.json`）を決める。人間の「方針」の確認で止まる。

## 最初にすること

- このスキルの base directory の2つ上が、プラグインの根（以下 `<plugin>`）。スクリプトは `<plugin>/scripts/`、資料は `<plugin>/references/` にある。
- 使う側のリポジトリの根の `short_movie/`（以下 `<sm>`）だけを書き換える。リポジトリ直下の既存のファイルは触らない。
- 全体の流れと置き場所は `<plugin>/references/workflow.md` を読む。

## 手順

1. 道具を確かめる。`bash <plugin>/scripts/check_tools.sh` を叩く。
   - 足りない道具があれば、表示された入れ方を人間に示して止まる。全体へ入れる道具を、人間に断らずに入れない。
   - Codex CLI だけは任意。無ければ「絵は人間が Nano Banana で描く形になる」と伝え、進めてよいかを訊く。
2. engine を用意する。`bash <plugin>/scripts/prepare_engine.sh` を、Bash の時間を最大（600000 ミリ秒）にして叩く。初回は npm の依存と Chrome Headless Shell を、使う側の外（データ置き場）に入れる。
3. `<sm>/.gitignore` を作る。中身は `out/`・`inbox/`・`__pycache__/` の3行。
4. 製品の情報を読む。
   - ローカルのパスなら、そのまま読む。
   - git のリポジトリの URL なら、データ置き場（環境変数 `CLAUDE_PLUGIN_DATA` が使えればそこ、無ければ `~/.cache/short-movie`）の `sources/<URL の sha1 の先頭12桁>/` へ `git clone --depth 1` して読む。既にあれば `git -C <そこ> pull --ff-only` で取り直す。使う側には置かない。
   - git でない URL（製品の Web ページなど）なら、WebFetch で読む。
   - README・ドキュメント・機能の一覧を読み、紹介できる機能の候補を挙げる。
5. `<sm>/brief.md` を書く。中身:
   - どこから読んだか（URL かパスと、git なら commit）
   - 製品の一言の説明と、紹介できる機能の候補（1本に1機能）
   - 方針の案: 尺（15〜30秒）・本数・投稿先と画面の比率（既定は X 向けの 1080×1080）・見せ方（デフォルメした画面と、コミカルな動き。無音でも伝わるよう字幕を焼き込む）・締めに出す製品名と URL
   - 費用の条件: 無料の範囲だけを使う（Codex は定額プランの枠、Nano Banana はブラウザの Gemini アプリ。`claude -p` と Gemini の API・CLI は使わない）
6. `<sm>/theme.json` を書く。`<plugin>/engine/theme.default.json` を写し、製品の色（ロゴや README の色）に合わせて `accent`・`highlight`・`endBackground` などを直す。キーは7つのまま変えない。
7. Remotion のライセンスを伝える。個人と従業員3人以下の会社などは無料だが、それ以外の会社で使う場合は Remotion の会社向けライセンスの確認が要る。

## 最後に表示すること

作ったもの・決めたこと・人間に確かめてほしいことを短くまとめ、最後に次の2行を表示して止まる。人間の評価を待ち、勝手に次の工程へ進まない。

```
---
直すとき: 直したい内容をそのまま書いてください。このスキルの続きで直します
この内容でよいときは次のスキルを実行してください: /short-movie:concept-work "<伝えたい概要>"
```
