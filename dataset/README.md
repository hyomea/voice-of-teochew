# Voice of Teochew Dataset Builder

This project processes Teochew-language YouTube videos (with embedded subtitles) to generate audio-text training data. It uses OCR on extracted frames and clips audio based on subtitle presence.


# Create and activate a Python virtual environment
```
pyenv install 3.10.12
pyenv virtualenv 3.10.12 paddleocr310
pyenv activate paddleocr310
```

# Install dependencies
```
pip install -r requirements.txt
```

# Download YouTube Videos

## Get playlist (IDs only)
```
yt-dlp --flat-playlist \
  "https://www.youtube.com/playlist?list=YOUR_PLAYLIST_ID"
  ```

Create a video_ids.txt with one YouTube ID per line. 

you can print them:
```
yt-dlp --flat-playlist --print "%(id)s" "https://www.youtube.com/playlist?list=LIST_ID"
```


## Download audio as .wav
```
yt-dlp --extract-audio --audio-format wav \
  --output "raw_audio/%(id)s.%(ext)s" \
  "https://www.youtube.com/watch?v=VIDEO_ID"
```

## Download full video (best quality)
```
yt-dlp -f bestvideo+bestaudio \
  --merge-output-format mp4 \
  -o "videos/%(id)s.%(ext)s" \
  "https://www.youtube.com/watch?v=VIDEO_ID"
```

# Directory Structure
```
video_ids.txt         # List of YouTube video IDs
videos/               # Raw downloaded .mp4 files
audio/                # Extracted .wav audio files
frames_batch/         # Extracted frames (per video)
clips/                # Final output: audio/text pairs
  └── metadata.json   # Alignment metadata
```
# Tip: Prevent macOS from sleeping during long runs
```
caffeinate -dimsu python process_batch.py
```

