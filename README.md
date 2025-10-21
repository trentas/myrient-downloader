<div align="center">

# 🎮 Myrient Downloader

### *Fast, reliable, resumable downloads from Myrient ROM archives*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform: macOS | Linux](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)]()

Download entire ROM collections from [myrient.erista.me](https://myrient.erista.me/files/) with ease!

[Features](#-features) • [Quick Start](#-quick-start) • [Usage](#-usage) • [Examples](#-examples) • [FAQ](#-faq)

</div>

---

## 🌟 What is This?

**Myrient Downloader** is a powerful bash script that automates downloading ROM collections from Myrient's archives (No-Intro, Redump, TOSEC, MAME, and more). It handles everything from parallel downloads to smart resumption and verification.

Perfect for:
- 🕹️ **Retro gaming enthusiasts** building their collection
- 📚 **Preservationists** archiving gaming history
- 🎯 **Power users** who want efficient, hands-off downloads

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| ⚡ **Parallel Downloads** | Download up to 5 files simultaneously (configurable) |
| 🔄 **Smart Resumption** | Automatically resumes interrupted downloads |
| ✅ **Verification** | Validates file integrity by comparing sizes |
| 🎯 **Flexible Filtering** | Exclude unwanted files with pattern matching |
| 🛡️ **Robust Error Handling** | Retries failed downloads with exponential backoff |
| 🚦 **Graceful Interruption** | Ctrl-C safely stops all downloads and cleans up |
| 🔍 **Progress Tracking** | Per-platform `.completed` cache prevents re-downloads |
| 🌐 **Multi-Collection** | Supports No-Intro, Redump, TOSEC, MAME, and more |
| 💬 **Verbose Mode** | Detailed logging for debugging |
| 🍎 **Cross-Platform** | Works on macOS and Linux |

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/trentas/myrient-downloader.git
cd myrient-downloader

# Make the script executable
chmod +x myrient-downloader.sh
```

### First Run

1. **Create your platforms list** (or use the example):
```bash
cp platforms-example.txt platforms.txt
nano platforms.txt  # Edit to add your desired platforms
```

2. **Create your exclusions list** (or use the example):
```bash
cp exclude_patterns-example.txt exclude_patterns.txt
nano exclude_patterns.txt  # Edit to add patterns you want to skip
```

3. **Start downloading!**
```bash
./myrient-downloader.sh platforms.txt exclude_patterns.txt
```

---

## 📦 Requirements

| Tool | Purpose | Installation |
|------|---------|--------------|
| `bash` | Shell (v4+) | Pre-installed on most systems |
| `wget` | Download engine | `brew install wget` (macOS) |
| `curl` | Metadata fetching | Pre-installed on most systems |
| `python3` | URL decoding | Pre-installed on most systems |

### macOS Setup
```bash
brew install wget
```

### Linux Setup
```bash
# Debian/Ubuntu
sudo apt-get install wget curl python3

# Fedora/RHEL
sudo dnf install wget curl python3
```

---

## 📖 Usage

### Basic Syntax

```bash
./myrient-downloader.sh [OPTIONS] platforms.txt exclude_patterns.txt
```

### Options

| Option | Description | Example |
|--------|-------------|---------|
| `--verbose` | Enable detailed logging | `--verbose` |
| `--base-url URL` | Override default collection URL | `--base-url https://myrient.erista.me/files/Redump` |

### Configuration Files

#### `platforms.txt`
List platforms to download (one per line). Names must **exactly** match folder names on Myrient:

```text
Nintendo - Game Boy
Nintendo - Game Boy Advance
Sony - PlayStation
Sega - Mega Drive - Genesis
```

💡 **Tip**: Browse [myrient.erista.me](https://myrient.erista.me/files/No-Intro) to find exact platform names.

#### `exclude_patterns.txt`
Pattern matching (case-insensitive) to skip unwanted files:

```text
# Skip documentation
README
datfile

# Skip certain regions
(Japan)
(Germany)
(France)

# Skip certain types
(Proto)
(Beta)
(Demo)
(Unl)
(Pirate)
```

---

## 💡 Examples

### Download No-Intro Collection (Default)
```bash
./myrient-downloader.sh platforms.txt exclude_patterns.txt
```

**Output:**
```
🔍 Fetching list from: https://myrient.erista.me/files/No-Intro/Nintendo%20-%20Game%20Boy/
📁 Local folder: ./Nintendo - Game Boy
⏭️  Skipping (excluded): README.txt
✅ Already complete: Pokemon - Red Version (USA, Europe).zip
⬇️  Downloading: Tetris (World).zip
✅ Download verified by size: Tetris (World).zip
🚀 Starting parallel downloads for: Nintendo - Game Boy
📊 Download Summary
----------------------
🧾 Total attempted: 127
✅ Completed:       126
❌ Errors:          1
✅ Done: Nintendo - Game Boy
```

### Download Redump Collection
```bash
./myrient-downloader.sh --base-url https://myrient.erista.me/files/Redump platforms.txt exclude_patterns.txt
```

### Verbose Mode (Debug)
```bash
./myrient-downloader.sh --verbose platforms.txt exclude_patterns.txt
```

### Download Multiple Collections
```bash
# No-Intro
./myrient-downloader.sh --base-url https://myrient.erista.me/files/No-Intro platforms-no-intro.txt exclude_patterns.txt

# Redump
./myrient-downloader.sh --base-url https://myrient.erista.me/files/Redump platforms-redump.txt exclude_patterns.txt

# TOSEC
./myrient-downloader.sh --base-url https://myrient.erista.me/files/TOSEC platforms-tosec.txt exclude_patterns.txt
```

---

## 📂 Output Structure

```
myrient-downloader/
├── myrient-downloader.sh
├── platforms.txt
├── exclude_patterns.txt
├── Nintendo - Game Boy/
│   ├── .completed              # Tracks finished downloads
│   ├── Pokemon Red (USA).zip
│   ├── Tetris (World).zip
│   └── ...
├── Sony - PlayStation/
│   ├── .completed
│   └── ...
└── ...
```

- Each platform gets its own directory
- `.completed` files track successfully downloaded ROMs
- Interrupted downloads resume automatically on next run
- Files are verified by size comparison with remote server

---

## 🛠️ Advanced Usage

### Adjust Parallel Download Count

Edit `MAX_PARALLEL` in the script:

```bash
MAX_PARALLEL=10  # Download 10 files at once (default: 5)
```

### Interrupting Downloads

Press **Ctrl-C** to safely stop:
```
^C
🛑 Interrupting downloads...
✅ Cleanup complete
```

All temporary files are cleaned up automatically, and you can resume where you left off!

### Resume After Failure

Simply run the same command again:
```bash
./myrient-downloader.sh platforms.txt exclude_patterns.txt
```

The script automatically:
- ✅ Skips completed files (tracked in `.completed`)
- ✅ Validates existing files by size
- ✅ Re-downloads incomplete/corrupted files

---

## ❓ FAQ

<details>
<summary><strong>Q: Can I download from other Myrient collections?</strong></summary>

**A:** Yes! Use `--base-url`:
```bash
# Redump
./myrient-downloader.sh --base-url https://myrient.erista.me/files/Redump platforms.txt exclude_patterns.txt

# TOSEC
./myrient-downloader.sh --base-url https://myrient.erista.me/files/TOSEC platforms.txt exclude_patterns.txt

# MAME
./myrient-downloader.sh --base-url https://myrient.erista.me/files/MAME platforms.txt exclude_patterns.txt
```
</details>

<details>
<summary><strong>Q: How do I only download specific regions?</strong></summary>

**A:** Use exclusion patterns. For USA-only ROMs:
```text
# exclude_patterns.txt
(Japan)
(Europe)
(Germany)
(France)
(Spain)
(Italy)
(Korea)
(World)
```
</details>

<details>
<summary><strong>Q: Downloads are slow. Can I speed them up?</strong></summary>

**A:** Yes! Edit `MAX_PARALLEL` in the script:
```bash
MAX_PARALLEL=10  # Increase from default 5
```
⚠️ **Warning**: Too many parallel downloads may trigger rate limiting.
</details>

<details>
<summary><strong>Q: What if a download fails?</strong></summary>

**A:** Just run the script again! It will:
1. Skip verified files
2. Re-check file sizes
3. Re-download incomplete/failed files
</details>

<details>
<summary><strong>Q: Can I pause and resume later?</strong></summary>

**A:** Yes! Press **Ctrl-C** to stop. Run the same command again to resume exactly where you left off.
</details>

<details>
<summary><strong>Q: How do I find exact platform names?</strong></summary>

**A:** Browse the collection on Myrient:
- No-Intro: https://myrient.erista.me/files/No-Intro
- Redump: https://myrient.erista.me/files/Redump
- TOSEC: https://myrient.erista.me/files/TOSEC

Copy folder names exactly as they appear (including spaces and special characters).
</details>

<details>
<summary><strong>Q: Does this work on Windows?</strong></summary>

**A:** Not natively, but you can use:
- **WSL** (Windows Subsystem for Linux)
- **Git Bash**
- **Cygwin**
</details>

---

## 🐛 Troubleshooting

### "No downloadable files found"
- ✅ Check platform name matches exactly (case-sensitive)
- ✅ Verify the URL is accessible in your browser
- ✅ Try `--verbose` mode for more details

### Downloads keep failing
- ✅ Check your internet connection
- ✅ Lower `MAX_PARALLEL` count
- ✅ Run with `--verbose` to see detailed errors

### "Command not found: wget"
```bash
# macOS
brew install wget

# Linux
sudo apt-get install wget
```

### Files not resuming properly
- ✅ Check disk space (`df -h`)
- ✅ Delete the `.completed` file to force re-download
- ✅ Check file permissions in the download directory

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- 🐛 Report bugs
- 💡 Suggest features
- 🔧 Submit pull requests

### Development

```bash
# Run in verbose mode for testing
./myrient-downloader.sh --verbose platforms.txt exclude_patterns.txt

# Test interrupt handling
# (Press Ctrl-C during downloads to verify cleanup)
```

---

## 📋 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **[Myrient](https://myrient.erista.me)** for hosting and preserving gaming history
- **[No-Intro](https://no-intro.org/)** for ROM verification and cataloging
- **[Redump](http://redump.org/)** for disc preservation standards
- **[TOSEC](https://www.tosecdev.org/)** for comprehensive archival efforts
- The entire ROM preservation community 🌍💾

---

## ⭐ Support

If this tool helped you build your collection, consider:
- ⭐ Starring this repository
- 🐛 Reporting issues you encounter
- 📢 Sharing with other retro gaming enthusiasts
- 💝 Supporting [Myrient](https://myrient.erista.me) for hosting costs

---

<div align="center">

**Happy Gaming! 🎮✨**

Made with ❤️ by the ROM preservation community

</div>
