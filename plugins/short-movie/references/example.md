# 作りの見本（最初の例）

最初の例は、continuo の紹介動画「置くだけで、始まる」の回。人間が最初に完成と認めた1本で、作りの見本になる。
実物は github.com/maimuzo/continuo-pr-movie の次のファイルにある。

- 動画: `src/videos/PlaceOnReady.tsx`（場面ごとにカットを割り、座標と動きの秒を定数に置く）
- 台本: `src/videos/place_on_ready.script.ts`
- 詳しいコンテ: `docs/spec/detailed_storyboards/place_on_ready.md`
- コンテ: `docs/spec/storyboard.md`（1節に全回の共通の決まり）

注意:

- 見本は、このプラグインに写していない部品（`Kanban`・`IssueCard`・`WorktreeSign`。continuo の話専用）を import しているので、そのままではコンパイルできない。作りを読むためだけに使う。
- 見本は `src/videos/` の直下にあり、`../components`・`../theme` を import している。このプラグインでは回がフォルダ（`videos/<回のid>/`）になるので、`../../components`・`../../theme` になる。
- 見本の台本は id と尺を持たない。このプラグインでは `script.ts` が `meta = { id, durationInSeconds }` を持つ（`references/video-template/script.ts`）。

見本から読み取る作りの要点:

- 1本を「タイトル → 本編 → 締め」に割り、本編で「困った → 製品が片付ける」を1往復させる。
- 無音で自動再生されるので、字幕を焼き込み、動きと表情で伝える。
- 場面ごとに `<Sequence>` を置き、場面の中の時刻はその場面の頭からの秒で書く。
- 効果音は `SFX` の表（音の名前・鳴らす秒・音量）に書き、秒は場面の動きの定数から取る。
- キャラクターはポーズ違いのコマ送り（1秒に6〜8枚）で動かし、切り替えのたびに少し伸び縮みさせる（`Sprite`）。動きの大半は画面側（移動・拡大・揺れ・集中線）で付け、1本あたりのキャラクターの絵は8枚程度を目安にする。
