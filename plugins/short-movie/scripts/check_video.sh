#!/bin/bash
# 書き出した mp4 の形を確かめる。
# 使い方: check_video.sh <mp4> <尺の秒>
# 確かめること: 1080×1080・30fps・コマ数が 尺×30・音の流れがある。音が鳴り始める秒（silencedetect の silence_end）を並べて出す
set -euo pipefail
[ $# -eq 2 ] || { echo "使い方: check_video.sh <mp4> <尺の秒>" >&2; exit 2; }
MP4="$1"; DUR="$2"
want_frames="$(python3 -I -c 'import sys;print(round(float(sys.argv[1])*30))' "$DUR")"
v="$(ffprobe -v error -select_streams v:0 -count_frames -show_entries stream=width,height,r_frame_rate,nb_read_frames -of csv=p=0 "$MP4")"
a="$(ffprobe -v error -select_streams a -show_entries stream=codec_type -of csv=p=0 "$MP4")"
echo "映像: ${v}（期待 1080,1080,30/1,${want_frames}）"
echo "音の流れ: ${a:-無し}"
ok=1
[ "$v" = "1080,1080,30/1,$want_frames" ] || { echo "映像の形が期待と違います"; ok=0; }
[ -n "$a" ] || { echo "音の流れがありません"; ok=0; }
echo "音の鳴り始め（秒）:"
ffmpeg -hide_banner -nostats -i "$MP4" -af "silencedetect=n=-45dB:d=0.12" -f null - 2>&1 | grep -o 'silence_end: [0-9.]*' | sed 's/silence_end: /  /' || true
[ "$ok" = 1 ] || exit 1
