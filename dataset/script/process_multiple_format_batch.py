import os
import cv2
import ffmpeg
import json
from ocr_engine import OCREngine

# -------- Config --------
VIDEO_DIR = "batch_000/videos"
AUDIO_DIR = "batch_000/audio"
FRAME_DIR = "batch_000/frames_batch"
CLIP_DIR = "batch_000/clips"
VIDEO_ID_LIST = "video_batches/batch_000.txt"
METADATA_PATH = os.path.join(CLIP_DIR, "metadata.json")

START = 20            # 从第 20 秒开始
END_MARGIN = 20       # 到倒数 20 秒结束
FPS = 0.5             # 每秒抽帧数
MAX_SPAN = 10         # 最长合并时间（秒）
CONFIDENCE_THRESHOLD = 0.35
SIMILARITY_THRESHOLD = 0.6
OCR_ENGINE = "paddle"  # 可选："paddle" 或 "easy"

FRAME_INTERVAL = 1.0 / FPS
os.makedirs(FRAME_DIR, exist_ok=True)
os.makedirs(CLIP_DIR, exist_ok=True)
os.makedirs(AUDIO_DIR, exist_ok=True)

# -------- Init OCR --------
ocr = OCREngine(engine_type=OCR_ENGINE, lang='ch')

# -------- Load video IDs --------
with open(VIDEO_ID_LIST) as f:
    video_ids = [line.strip() for line in f if line.strip()]

# -------- Helper to get video duration --------
def get_video_duration(path):
    try:
        probe = ffmpeg.probe(path)
        return float(probe['format']['duration'])
    except Exception as e:
        print(f"⚠️ Error getting duration for {path}: {e}")
        return 0

# -------- Find video file --------
def find_video_file(video_dir, vid):
    for ext in ["mkv", "mp4", "webm"]:
        path = os.path.join(video_dir, f"{vid}.{ext}")
        if os.path.exists(path):
            return path
    return None

all_metadata = []

for vid in video_ids:
    print(f"\n🔹 Processing {vid}")
    video_path = find_video_file(VIDEO_DIR, vid)
    if not video_path:
        print(f"⚠️ Skipped {vid}: no video file found.")
        continue

    audio_path = os.path.join(AUDIO_DIR, f"{vid}.wav")
    total_duration = get_video_duration(video_path)
    if total_duration <= START + END_MARGIN:
        print(f"⚠️ Skipped {vid}: too short ({total_duration:.2f}s)")
        continue

    actual_duration = total_duration - START - END_MARGIN

    frame_path = os.path.join(FRAME_DIR, vid)
    clip_path = os.path.join(CLIP_DIR, vid)
    os.makedirs(frame_path, exist_ok=True)
    os.makedirs(clip_path, exist_ok=True)

    # Step 1: 抽帧 + 裁剪字幕区域
    os.system(f'ffmpeg -hide_banner -loglevel error -ss {START} -t {actual_duration} -i "{video_path}" -vf "fps={FPS},crop=in_w:in_h/6:0:5*in_h/6" {frame_path}/frame_%04d.jpg')

    # Step 2: 提取音频为 wav
    os.system(f'ffmpeg -hide_banner -loglevel error -y -i "{video_path}" -ac 1 -ar 16000 -sample_fmt s16 "{audio_path}"')

    # Step 3: OCR
    ocr_results = []
    frame_files = sorted(f for f in os.listdir(frame_path) if f.endswith(".jpg"))
    for i, fname in enumerate(frame_files):
        img = cv2.imread(os.path.join(frame_path, fname))
        frame_time = START + i * FRAME_INTERVAL
        text = ocr.recognize(img, conf_threshold=CONFIDENCE_THRESHOLD)
        print(f"[{fname}] → {text}")
        ocr_results.append((frame_time, text))

    # Step 4: 合并字幕段 & 导出切片
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
            # 切音频
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
