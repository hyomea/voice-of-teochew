#!/bin/bash

# Check input
if [[ -z "$1" ]]; then
  echo "❌ Usage: $0 <batch_file>"
  echo "Example: $0 video_batches/batch_000.txt"
  exit 1
fi

BATCH_FILE="$1"
BATCH_NAME=$(basename "$BATCH_FILE" .txt)
VIDEO_DIR="${BATCH_NAME}/videos"
FAILED_LOG="${BATCH_NAME}/failed_ids.txt"

mkdir -p "$VIDEO_DIR"
> "$FAILED_LOG"  # Clear previous failures

echo "📦 Processing $BATCH_NAME"

while IFS= read -r VIDEO_ID || [[ -n "$VIDEO_ID" ]]; do
  [[ -z "$VIDEO_ID" ]] && continue  # skip blank lines

  echo "🎬 Downloading: $VIDEO_ID"

  yt-dlp --hls-use-mpegts \
    -o "${VIDEO_DIR}/${VIDEO_ID}.%(ext)s" \
    "https://www.youtube.com/watch?v=${VIDEO_ID}"

    # yt-dlp --cookies-from-browser chrome \
    #   --hls-use-mpegts \
    #   -o "C9cv4Ugfxh8.mp4" \
    #   "https://www.youtube.com/watch?v=C9cv4Ugfxh8"



  # Check if any of the expected formats exist
  if ls "${VIDEO_DIR}/${VIDEO_ID}".{mkv,mp4,webm} &> /dev/null; then
    echo "✅ Downloaded: ${VIDEO_ID}"
  else
    echo "❌ Failed: $VIDEO_ID"
    echo "$VIDEO_ID" >> "$FAILED_LOG"
  fi


done < "$BATCH_FILE"

echo "🏁 Done processing $BATCH_NAME"
echo "⚠️ Failed downloads logged in: $FAILED_LOG"
