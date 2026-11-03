import { Config } from "@remotion/cli/config";

Config.setVideoImageFormat("jpeg");
Config.setCodec("h264");
Config.setPixelFormat("yuv420p");
// webpack のキャッシュは使わない。キャッシュの hash に作業場所の絶対パスが入り、
// 作業場所が違うたびに共有のキャッシュを丸ごと消し合うため（@remotion/cli/dist/setup-cache.js）
Config.setCachingEnabled(false);
