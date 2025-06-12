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

## download from search:
1. Download
```
yt-dlp --flat-playlist -J "https://www.youtube.com/@xxx/search?query=xxx" > all_videos.json
```
2. Extract video id: 
`extract_vid.py`
3. Splits the large video_ids.txt file into multiple video_ids_batch_XXX.txt files, each with 10 video IDs.
```
split_video_ids.sh
./split_video_ids.sh
```
4. Download videos:
```
chmod +x download_batch.sh
./download_batch.sh video_batches/batch_000.txt
```
5. Getting files, convert to wav and images：
`process_multiple_format_batch.py`

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

# pass cookies to yt-dlp
https://github.com/yt-dlp/yt-dlp/wiki/FAQ#how-do-i-pass-cookies-to-yt-dlp

