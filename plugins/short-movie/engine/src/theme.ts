import { loadFont } from "@remotion/google-fonts/MPLUSRounded1c";
import colors from "./theme.json";

// 書体は M PLUS Rounded 1c に固定する。@remotion/google-fonts は書体ごとに別のモジュールで、
// JSON から切り替えられないため。和文は細かい部分に分けて配られるので、subsets を絞らずに全部読む
const { fontFamily } = loadFont("normal", { weights: ["800"], ignoreTooManyRequestsWarning: true });

export type ThemeColors = {
  ink: string;
  paper: string;
  caption: string;
  captionStroke: string;
  accent: string;
  highlight: string;
  endBackground: string;
};

// 色は使う側の short_movie/theme.json を render のときに src/theme.json へ写して読む。
// 尺は持たない（回の meta が持つ）
export const theme = {
  fontFamily,
  fps: 30,
  size: 1080,
  color: colors as ThemeColors,
} as const;

export const sec = (s: number) => Math.round(s * theme.fps);
