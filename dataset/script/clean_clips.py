import json
import os
import re
import shutil

METADATA_PATH = "clips/metadata.json"
CLEANED_METADATA_PATH = "clips/metadata_cleaned.json"
CLIPS_ROOT = "clips"
TRASH_DIR = os.path.join(CLIPS_ROOT, "trash")

os.makedirs(TRASH_DIR, exist_ok=True)

with open(METADATA_PATH, "r") as f:
    data = json.load(f)

def clean_text(text):
    return re.sub(r"[^\u4e00-\u9fff ]", "", text.strip())

def is_valid_clip(entry):
    cleaned = clean_text(entry.get("text", ""))
    duration = entry.get("end", 0) - entry.get("start", 0)
    if len(cleaned) < 2:
        return False
    if duration < 0.5 or duration > 15:
        return False
    return True

cleaned_data = []
moved_count = 0

for idx, entry in enumerate(data):
    original_text = entry.get("text", "")
    cleaned_text = clean_text(original_text)
    entry["text"] = cleaned_text

    # 解析 .wav 和 .txt 的路径（支持子目录）
    clip_rel_path = entry["clip"]  # e.g., "-gjql5dhY2g/-gjql5dhY2g_0000.wav"
    clip_path = os.path.join(CLIPS_ROOT, clip_rel_path)
    txt_path = os.path.splitext(clip_path)[0] + ".txt"  # same as .wav but .txt

    print(f"\n🔍 Processing clip {idx + 1}/{len(data)}")
    print(f"Video ID: {entry['video_id']}")
    print(f"Clip: {entry['clip']}")
    print(f"Original text: '{original_text}'")
    print(f"Cleaned  text: '{cleaned_text}'")

    if is_valid_clip(entry):
        print("✅ Valid clip. Keeping it.")
        cleaned_data.append(entry)

        # 清洗并覆盖 .txt 内容
        if os.path.exists(txt_path):
            with open(txt_path, "w", encoding="utf-8") as txt_file:
                txt_file.write(cleaned_text)
                print(f"📝 Updated text file: {txt_path}")
    else:
        print("❌ Invalid clip. Moving to trash.")

        # 移动 .wav 文件
        if os.path.exists(clip_path):
            dest_wav = os.path.join(TRASH_DIR, os.path.basename(clip_path))
            shutil.move(clip_path, dest_wav)
            print(f"🗑️ Moved .wav to: {dest_wav}")

        # 移动 .txt 文件
        if os.path.exists(txt_path):
            dest_txt = os.path.join(TRASH_DIR, os.path.basename(txt_path))
            shutil.move(txt_path, dest_txt)
            print(f"🗑️ Moved .txt to: {dest_txt}")

        moved_count += 1

# 保存清洗后的 metadata
with open(CLEANED_METADATA_PATH, "w") as f:
    json.dump(cleaned_data, f, ensure_ascii=False, indent=2)

print(f"\n✅ Done. Moved {moved_count} bad clips to trash.")
print(f"📝 Cleaned metadata saved to: {CLEANED_METADATA_PATH}")
print(f"✅ Total kept entries: {len(cleaned_data)}")
