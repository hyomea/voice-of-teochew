import os
import cv2
import ffmpeg
import json
from difflib import SequenceMatcher
from ocr_engine import OCREngine

# -------- Config --------
VIDEO_DIR = "videos"
AUDIO_DIR = "audio"
FRAME_DIR = "frames_batch"
CLIP_DIR = "clips"
VIDEO_ID_LIST = "video_ids.txt"
METADATA_PATH = os.path.join(CLIP_DIR, "metadata.json")

START = 120        # 从第 2 分钟开始
DURATION = 1140     # 每个视频处理范围（秒）
FPS = 0.5             # 每秒抽帧数
MAX_SPAN = 10       # 最长合并时间（秒）
CONFIDENCE_THRESHOLD = 0.35
SIMILARITY_THRESHOLD = 0.6
OCR_ENGINE = "paddle"  # 可选："paddle" 或 "easy"

FRAME_INTERVAL = 1.0 / FPS
os.makedirs(FRAME_DIR, exist_ok=True)
os.makedirs(CLIP_DIR, exist_ok=True)

# -------- Init OCR --------
ocr = OCREngine(engine_type=OCR_ENGINE, lang='ch')

# -------- Load video IDs --------
with open(VIDEO_ID_LIST) as f:
    video_ids = [line.strip() for line in f if line.strip()]

all_metadata = []

for vid in video_ids:
    print(f"\n🔹 Processing {vid}")
    video_path = os.path.join(VIDEO_DIR, f"{vid}.mp4")
    audio_path = os.path.join(AUDIO_DIR, f"{vid}.wav")

    frame_path = os.path.join(FRAME_DIR, vid)
    clip_path = os.path.join(CLIP_DIR, vid)
    os.makedirs(frame_path, exist_ok=True)
    os.makedirs(clip_path, exist_ok=True)

    # Step 1: 抽帧
    os.system(f'ffmpeg -hide_banner -loglevel error -ss {START} -t {DURATION} -i "{video_path}" -vf "fps={FPS}" {frame_path}/frame_%04d.jpg')

    # Step 2: OCR
    ocr_results = []
    frame_files = sorted(f for f in os.listdir(frame_path) if f.endswith(".jpg"))
    for i, fname in enumerate(frame_files):
        img = cv2.imread(os.path.join(frame_path, fname))
        h = img.shape[0]
        crop = img[int(h * 2 / 3):, :]
        frame_time = START + i * FRAME_INTERVAL
        text = ocr.recognize(crop, conf_threshold=CONFIDENCE_THRESHOLD)
        print(f"[{fname}] → {text}")
        ocr_results.append((frame_time, text))

    # Step 3: 合并字幕段
    i = 0
    while i < len(ocr_results):
        t_start = ocr_results[i][0]
        base_text = ocr_results[i][1]
        t_end = t_start + FRAME_INTERVAL
        j = i + 1
        while j < len(ocr_results) and (ocr_results[j][0] - t_start) < MAX_SPAN:
            text_next = ocr_results[j][1]
            if text_next.strip() and ocr.is_similar(base_text, text_next, threshold=SIMILARITY_THRESHOLD):
                t_end = ocr_results[j][0] + FRAME_INTERVAL
                j += 1
            else:
                break
        if base_text.strip():
            all_metadata.append({
                "video_id": vid,
                "clip": f"{vid}/{vid}_{i:04d}.wav",
                "text": base_text,
                "start": t_start,
                "end": t_end
            })
            # Step 4: 切音频 & 存文本
            ss = max(t_start - 0.2, 0)
            duration = t_end - t_start + 0.2
            out_audio = os.path.join(clip_path, f"{vid}_{i:04d}.wav")
            out_text = os.path.join(clip_path, f"{vid}_{i:04d}.txt")
            ffmpeg.input(audio_path, ss=ss, t=duration).output(out_audio, acodec='copy').run(quiet=True, overwrite_output=True)
            with open(out_text, "w") as f:
                f.write(base_text)
        i = j

# Step 5: 保存总 metadata
with open(METADATA_PATH, "w", encoding="utf-8") as f:
    json.dump(all_metadata, f, ensure_ascii=False, indent=2)

print(f"\n✅ Done. {len(all_metadata)} segments saved to {METADATA_PATH}")
