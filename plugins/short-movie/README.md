# short-movie

製品の特徴を1つ伝える、15〜30秒の紹介動画（1080×1080・30fps の mp4）を作る Claude Code のプラグインです。
コンテ → キャラクター → 絵コンテ → 動画の順に進み、人間が確認する場面ごとにスキルが止まります。
動画は [Remotion](https://www.remotion.dev/) で組み立て、絵は Codex の画像生成（または人間がブラウザの Gemini アプリの Nano Banana）で描きます。

最初の例は [continuo](https://github.com/maimuzo/continuo) の紹介動画12本です。その制作の記録は [maimuzo/continuo-pr-movie](https://github.com/maimuzo/continuo-pr-movie) にあります。

## 入れ方

```
/plugin marketplace add maimuzo/maimuzo-claude-plugins-public
/plugin install short-movie@maimuzo-public
```

設定を書き換えずに試すときは、このリポジトリを clone して `claude --plugin-dir plugins/short-movie` で起動します。

## 流れ

| 順 | スキル | すること | 止まる場面 |
| --- | --- | --- | --- |
| 1 | `/short-movie:start <URL かパス>` | 道具を確かめ、製品を読み、方針と色を決める | 方針 |
| 2 | `/short-movie:concept-work "<伝えたい概要>"` | 人間の概要から全回のコンテを書く | コンテ |
| 3 | `/short-movie:characters` | キャラクター設定と設定画を作る | 絵柄とキャラクター |
| 4 | `/short-movie:storyboard [回のid...]` | 回ごとの詳しいコンテと、代表シーンの絵コンテを作る | 絵コンテ |
| 5 | `/short-movie:first-video <回のid>` | 1本を動画にして、細部を調整する | 最初の1本 |
| 6 | `/short-movie:remaining-videos <最初の1本の回のid>` | 残りを並行で作り、全部まとめて直す | 残りの全部 |

各スキルは最後に、直すときの書き方と、次に実行するスキルを表示して止まります。
公開（release・README への掲載・投稿）は範囲外で、ローカルに mp4 を書き出すところまでです。

## 置き場所

- 使う側のリポジトリには、直下の `short_movie/` の下にだけファイルを作ります（素材・シナリオ・回ごとの動画の中身）。リポジトリ直下の既存のファイルは触りません。
- Remotion の土台（`package.json`・部品）と道具のスクリプトはプラグインの中にあり、使う側には置きません。
- 書き出しに使う npm の依存（約1GB。Chrome Headless Shell を含む）と作業場所は、使う側の外のデータ置き場に置きます。環境変数 `CLAUDE_PLUGIN_DATA` が使えればそこ、使えなければ `~/.cache/short-movie` です。要らなくなったら消してかまいません（次の書き出しで作り直します）。

## 要る道具

Node.js と npm・ffmpeg と ffprobe・[uv](https://docs.astral.sh/uv/)・git・python3。Codex CLI は任意です（無ければ、絵は人間が Nano Banana で描きます）。
`/short-movie:start` が確かめ、足りなければ入れ方を示して止まります。全体へ入れる道具を、断らずに入れることはしません。

## 費用

無料の範囲だけを使います。Codex は ChatGPT の定額プランの枠の中で動きます。Gemini の API・CLI は無料枠では画像を作れないので使いません。`claude -p` は使いません。
Remotion は、個人と従業員3人以下の会社などは無料です。それ以外の会社で使う場合は、[Remotion のライセンス](https://www.remotion.dev/license)を確かめてください。

## 中身

- `skills/` 6つのスキル
- `references/` 流れ・人間から受けた指摘・絵の描かせ方・確かめ方・並行で作るときの依頼文の雛形・回の雛形・作りの見本
- `scripts/` engine の準備・書き出し・Studio・確かめ・背景抜き・効果音・Codex で描く道具
- `engine/` Remotion の土台（書体は M PLUS Rounded 1c に固定）

## ライセンス

MIT
