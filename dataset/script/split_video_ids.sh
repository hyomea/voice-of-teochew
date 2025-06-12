#!/bin/bash

INPUT_FILE="video_ids.txt"
OUTPUT_DIR="video_batches"
LINES_PER_BATCH=10

# Ensure output folder exists
mkdir -p "$OUTPUT_DIR"

# Use numeric suffixes (-d) and 3-digit suffix length (-a 3) — macOS trick:
# macOS doesn't support `-d`, but you can force numeric names manually
i=0
while read -r line; do
    batch_num=$(printf "%03d" $((i / LINES_PER_BATCH)))
    echo "$line" >> "$OUTPUT_DIR/batch_${batch_num}.txt"
    ((i++))
done < "$INPUT_FILE"

echo "✅ Split complete: created $(ls -1 $OUTPUT_DIR/batch_*.txt | wc -l) batch files in $OUTPUT_DIR/"
