# 🎧 Metadata Fixer for Audio Clips

## tips: how to install tailwindcss: 
https://v3.tailwindcss.com/docs/guides/create-react-app

A simple web-based tool to browse, edit, and export metadata for segmented audio clips (e.g. from YouTube subtitle alignment or OCR-processed speech corpora). Built with React and Tailwind CSS.

## ✨ Features

- ✅ Load `metadata.json` files and preview entries
- 🔊 Audio playback with clip ID and path
- 🖼️ Preview corresponding image frames (e.g., subtitle snapshots)
- ✏️ Inline editing of transcription text
- 🗑️ Per-entry deletion
- 📦 Export updated metadata to JSON
- 🧩 Paginated table for large datasets
- 🖼️ Customizable clip and image base URLs

## 🗂️ Folder Structure Assumptions

This tool assumes the following structure for clips and image frames:

```
your_server_root/
├── clips/
│   ├── metadata.json  <-- This is the file you'll edit in the browser
│   └── bcWBa41EF3U/
│       ├── bcWBa41EF3U_0000.wav
│       └── bcWBa41EF3U_0000.txt
└── frames_batch/
    └── bcWBa41EF3U/
        └── frames_batch/   
            ├── frame_0000.jpg
            └── frame_0001.jpg
```

Inside your data folder, run:
`python -m http.server 8000`