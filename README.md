# 🎬 Ultimate Video Optimizer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![PowerShell: 5.1+](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://microsoft.com/powershell)

A **professional-grade, interactive PowerShell utility** designed to automate the mass-optimization of video libraries. It leverages FFmpeg to convert videos into ultra-efficient **HEVC (H.265)** or **AV1** formats, significantly reducing file size while maintaining visual fidelity.

---

## 🌟 Why Ultimate Video Optimizer?

Unlike simple "one-click" converters, this tool is built for **power users and creators** who need to process hundreds of files safely.

- **Intelligence First:** Automatically detects your hardware (NVIDIA, AMD, Intel) and picks the fastest encoder.
- **Safety Guaranteed:** Uses a **Verify-then-Swap** workflow. It never deletes an original file unless the optimized version is verified for size, duration, and integrity.
- **Smart Logic:** Automatically skips files that are already efficient (HEVC/AV1) or that have failed optimization with your current settings in the past.
- **No Installation:** Runs directly from your terminal or via a single `.bat` file.

---

## 🚀 Quick Start

### 1. Recommended: Run via Web (Zero Download)
Open Windows Terminal in your video folder and run:
```powershell
irm https://raw.githubusercontent.com/BishnuMahali/Video-Optimizer/main/Video%20Optimizer.ps1 | iex
```

### 2. Standard Launch
Double-click `Video Optimizer.bat` or run `.\Video Optimizer.ps1` in PowerShell.

---

## 🧠 How It Works (The Technical Workflow)

The script follows a rigorous 6-stage pipeline for every file:

1.  **Detection:** Identifies hardware acceleration support (NVENC, AMF, QSV) via dummy encodes.
2.  **Analysis:** Checks source codec, duration, and metadata using `ffprobe`.
3.  **Optimization:** Executes FFmpeg with your chosen quality/preset. 
4.  **Verification:** Compares output vs. input duration (±2s) and file size.
5.  **Multi-Pass Fallback:** If the output is larger than the original, it automatically retries with a lower quality setting (if provided).
6.  **Atomic Replacement:** Only if verified, it replaces the original file with the optimized version using an atomic swap to prevent data loss.

---

## ⚙️ Configuration & Encoders

### Supported Encoders

| Hardware | Encoder | Codec | Best For |
| :--- | :--- | :--- | :--- |
| **NVIDIA** | `av1_nvenc`, `hevc_nvenc` | AV1 / HEVC | Maximum speed & efficiency |
| **Intel** | `av1_qsv`, `hevc_qsv` | AV1 / HEVC | High-quality QuickSync encoding |
| **AMD** | `av1_amf`, `hevc_amf` | AV1 / HEVC | Radeon GPU acceleration |
| **CPU** | `libsvtav1`, `libx265` | AV1 / HEVC | Maximum quality (slowest) |

### Key Features Explained

- **Multi-Pass Quality:** Enter `23,27,31`. If `23` results in a larger file, it immediately tries `27`, ensuring you never waste space.
- **Audio Actions:** Choose to `Copy` original audio or re-encode to `AAC`, `Opus`, or `AC3`. It automatically fixes MP4/MOV compatibility issues.
- **Unoptimizable Cache:** Remembers files that couldn't be compressed and skips them in future runs to save time.
- **Failed Actions:** Configure what happens to files that can't be optimized:
    - 📁 Move to a dedicated "Unoptimizable" folder.
    - 🗑️ Delete them (useful for temp/proxy cleanup).
    - 🛑 Ignore and keep in place.

---

## 🛠️ Requirements

- **Windows 10/11** (PowerShell 5.1 or 7+)
- **FFmpeg** (Must be in your system `PATH`)
    - [Download FFmpeg here](https://ffmpeg.org/download.html)
- **Optional:** NVIDIA/AMD/Intel GPU for hardware acceleration.

---

## 📜 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

Copyright (c) 2026 Bishnu Mahali
