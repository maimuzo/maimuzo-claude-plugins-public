// 回の台本。コンテの表の1行が scenes の1要素になる。秒で書き、フレームへの換算は部品の側で行う。
// meta はこの回の Composition の id（回のフォルダ名と同じケバブ）と尺（15〜30秒）。
// 最後の場面の to は、meta の尺と同じにする（render.sh が確かめる）
export const meta = { id: "feature-one", durationInSeconds: 15 } as const;

export const script = {
  title: "置くだけで、始まる",
  end: "置くだけ",
  scenes: [
    { id: "title", from: 0, to: 2, caption: null },
    { id: "trouble", from: 2, to: 6, caption: "毎回、手で準備していた" },
    { id: "solve", from: 6, to: 11, caption: "製品が代わりに片付ける" },
    { id: "relax", from: 11, to: 13, caption: "あなたは、コーヒーでも" },
    { id: "end", from: 13, to: 15, caption: null },
  ],
} as const;

// 締めに出す製品の名前と URL
export const product = { name: "product", url: "github.com/owner/product" } as const;
