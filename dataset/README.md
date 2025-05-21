# Create virtualenv and activate
pyenv virtualenv 3.10.12 paddleocr310
pyenv activate paddleocr310

# Install dependencies
pip install -r requirements.txt


# Download YouTube Videos
yt-dlp --flat-playlist \
  "https://www.youtube.com/playlist?list=####"


yt-dlp --extract-audio --audio-format wav \
  --output "raw_audio/%(id)s.%(ext)s" \
  "https://www.youtube.com/watch?v=###"

yt-dlp -f bestvideo+bestaudio \
  --merge-output-format mp4 \
  -o "videos/%(id)s.%(ext)s" \
  https://www.youtube.com/watch?v=###


video_ids.txt
videos/           # Raw mp4s
audio/            # Extracted .wav files
frames_batch/     # Extracted video frames (per video)
clips/            # Final output (audio/text pairs)
  └── metadata.json


# Tips
Prevent macOS from Sleeping: caffeinate -dimsu python process_batch.py


