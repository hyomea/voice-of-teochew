import os
import cv2
import ffmpeg
from ocr_engine import OCREngine

# -------- Config --------
VIDEO_ID = "A-QJsVWmDBQ"
INPUT_VIDEO = f"videos/{VIDEO_ID}.mp4"
INPUT_AUDIO = f"audio/{VIDEO_ID}.wav"
FRAME_DIR = "frames_test"
CLIP_DIR = "clips_test"

START = 120        # 从第 2 分钟开始
DURATION = 120     # 处理范围（秒）
FPS = 0.5            # 每秒抽帧数
MAX_SPAN = 10      # 最长合并时间（秒）
CONFIDENCE_THRESHOLD = 0.35
SIMILARITY_THRESHOLD = 0.6

OCR_ENGINE = "paddle"  # 可选："paddle" 或 "easy"

os.makedirs(FRAME_DIR, exist_ok=True)
os.makedirs(CLIP_DIR, exist_ok=True)

FRAME_INTERVAL = 1.0 / FPS

# -------- Step 1: 抽帧 --------
os.system(f'ffmpeg -ss {START} -t {DURATION} -i "{INPUT_VIDEO}" -vf "fps={FPS}" {FRAME_DIR}/frame_%03d.jpg')

# -------- Step 2: OCR --------
ocr = OCREngine(engine_type=OCR_ENGINE, lang='ch')
ocr_results = []

frame_files = sorted(f for f in os.listdir(FRAME_DIR) if f.endswith(".jpg"))
for i, fname in enumerate(frame_files):
    frame_path = os.path.join(FRAME_DIR, fname)
    img = cv2.imread(frame_path)
    h = img.shape[0]
    crop = img[int(h * 2 / 3):, :]  # bottom 1/3
    frame_time = START + i * FRAME_INTERVAL
    text = ocr.recognize(crop, conf_threshold=CONFIDENCE_THRESHOLD)
    print(f"[{fname}] → {text}")
    ocr_results.append((frame_time, text))

# -------- Step 3: 合并相似字幕段 --------
merged_segments = []
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
        merged_segments.append({
            "start": t_start,
            "end": t_end,
            "text": base_text
        })
    i = j

# -------- Step 4: 切音频 + 保存文本 --------
for idx, seg in enumerate(merged_segments):
    ss = max(seg["start"] - 0.2, 0)  # 前移一点点缓冲
    duration = seg["end"] - seg["start"] + 0.2
    out_audio = os.path.join(CLIP_DIR, f"{VIDEO_ID}_{idx:03d}.wav")
    out_text = os.path.join(CLIP_DIR, f"{VIDEO_ID}_{idx:03d}.txt")

    ffmpeg.input(INPUT_AUDIO, ss=ss, t=duration).output(out_audio, acodec='copy').run(quiet=True, overwrite_output=True)

    with open(out_text, "w") as f:
        f.write(seg["text"])
