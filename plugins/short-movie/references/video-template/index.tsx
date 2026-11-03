import React from "react";
import { AbsoluteFill, Audio, Sequence, staticFile } from "remotion";
import { Caption } from "../../components/Caption";
import { EndCard } from "../../components/EndCard";
import { TitleCard } from "../../components/TitleCard";
import { sec, theme } from "../../theme";
import { meta, product, script } from "./script";

// 回の雛形。場面ごとに <Sequence> を置き、字幕と絵を出す。
// 回のフォルダは src/videos/<回のid>/ に写されるので、土台の部品は ../../components、色は ../../theme から読む。
// ほかの回のフォルダは import しない（import してよいのは ../_shared/ だけ）
export { meta };

const S = (id: (typeof script.scenes)[number]["id"]) => script.scenes.find((s) => s.id === id)!;

// 効果音の表。音の名前・鳴らす秒・音量。秒は場面の動きの時刻から取る
const SFX: { name: string; at: number; volume: number }[] = [
  { name: "pop", at: S("trouble").from, volume: 0.6 },
  { name: "sparkle", at: S("solve").from + 0.5, volume: 0.6 },
  { name: "whoosh", at: S("end").from - 0.3, volume: 0.5 },
];

const Video: React.FC = () => (
  <AbsoluteFill style={{ background: theme.color.paper }}>
    <Sequence from={sec(S("title").from)} durationInFrames={sec(S("title").to - S("title").from)}>
      <TitleCard text={script.title} outFrom={sec(S("title").to - S("title").from) - 9} />
    </Sequence>
    {script.scenes
      .filter((s) => s.caption)
      .map((s) => (
        <Sequence key={s.id} from={sec(s.from)} durationInFrames={sec(s.to - s.from)}>
          <Caption text={s.caption!} />
        </Sequence>
      ))}
    <Sequence from={sec(S("end").from)}>
      <EndCard text={script.end} productName={product.name} productUrl={product.url} />
    </Sequence>
    {SFX.map((e, i) => (
      <Sequence key={i} from={sec(e.at)}>
        <Audio src={staticFile(`sfx/${e.name}.wav`)} volume={e.volume} />
      </Sequence>
    ))}
  </AbsoluteFill>
);

export default Video;
