"""依頼書（materials/prompts/*.md）から、1つの絵の依頼文だけを取り出して標準出力へ出す。

使い方: python3 -I extract_prompt.py <依頼書.md> <絵の id>
依頼書の「## <番号>. <絵の id>　<日本語の1行>」の節の中の、最初の ``` で囲んだ部分を出す。
見つからなければ、何も出さずに終了コード 1 で終わる。
"""
import re
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print("使い方: extract_prompt.py <依頼書.md> <絵の id>", file=sys.stderr)
        return 2
    text = open(sys.argv[1], encoding="utf-8").read()
    want = sys.argv[2]
    sections = re.split(r"^## ", text, flags=re.M)[1:]
    for sec in sections:
        m = re.match(r"\d+\.\s+(\S+)", sec)
        if not m or m.group(1) != want:
            continue
        body = re.search(r"^```[^\n]*\n(.*?)^```", sec, flags=re.S | re.M)
        if not body or not body.group(1).strip():
            print(f"依頼文（``` で囲んだ部分）がありません: {want}", file=sys.stderr)
            return 1
        sys.stdout.write(body.group(1).strip() + "\n")
        return 0
    print(f"依頼書に「## <番号>. {want}」の節がありません", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
