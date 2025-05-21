#!/bin/bash

while read -r id; do
  echo "🎬 Downloading: $id"

  # Download best video+audio merged into MP4
  yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best" \
    -o "videos/${id}.mp4" \
    "https://www.youtube.com/watch?v=${id}"

  # Extract audio to .wav
  yt-dlp -x --audio-format wav \
    -o "audio/${id}.%(ext)s" \
    "https://www.youtube.com/watch?v=${id}"
done < video_ids.txt
