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
- 見本の台本は `id`（回の id）を持つが、尺は持たない（尺はリポジトリ全体で15秒に決めていた）。このプラグインでは `script.ts` が `export const meta = { id, durationInSeconds }` を持つ（`references/video-template/script.ts`）。

見本から読み取る作りの要点:

- 1本を「タイトル → 本編 → 締め」に割り、本編で「困った → 製品が片付ける」を1往復させる。
- 無音で自動再生されるので、字幕を焼き込み、動きと表情で伝える。
- 場面ごとに `<Sequence>` を置き、場面の中の時刻はその場面の頭からの秒で書く。
- 効果音は `SFX` の表（音の名前・鳴らす秒・音量）に書き、秒は場面の動きの定数から取る。
- キャラクターはポーズ違いのコマ送り（1秒に6〜8枚）で動かし、切り替えのたびに少し伸び縮みさせる（`Sprite`）。動きの大半は画面側（移動・拡大・揺れ・集中線）で付け、1本あたりのキャラクターの絵は8枚程度を目安にする。

見本の作りの抜粋（`src/videos/PlaceOnReady.tsx` から。写していない部品を使う行は省いた）:

```tsx
// 場面ごとにカットを割る。座標はすべて 1080×1080 の画面の座標。各場面の中の時刻は、その場面の頭からの秒で書く
const S = (id: (typeof script.scenes)[number]["id"]) => script.scenes.find((s) => s.id === id)!;
const at = (s: number) => sec(s); // 場面の中の秒をフレームにする

// 机のカット。置き場所を定数にしておき、動きの秒も定数から取る
const DEV = { cx: 610, baseY: 835, height: 545 };

// 効果音の表。秒は場面の動きの時刻の定数（T_ENTER などは場面の中の秒）から取る
const SFX: { name: string; at: number; volume: number }[] = [
  { name: "typing", at: S("throw").from + 0.15, volume: 0.35 }, // issue を書く
  { name: "enter", at: S("throw").from + T_ENTER, volume: 0.7 }, // Enter
  { name: "whoosh", at: S("throw").from + T_FOLD, volume: 0.5 }, // 紙飛行機が飛ぶ
  { name: "splat", at: S("throw").from + T_HIT, volume: 0.8 }, // Ready に貼り付く
  { name: "spout", at: S("pick").from + 0.8, volume: 0.6 }, // コンティが跳ね起きて潮を吹く
];
```
