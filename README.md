# 🎮 Myrient Downloader

A parallel, resumable downloader for [myrient.erista.me](https://myrient.erista.me/files/) ROM sets.  
Works on **macOS** and **Linux**, supports exclusions, parallelism, retries, and file verification by size.

---

## 🚀 Features

- ✅ Parallel downloads (configurable, default: 5)
- ✅ Resumable downloads using `.completed` cache
- ✅ Skips already completed and validated files
- ✅ Exclude patterns using text file
- ✅ Smart size check between remote and local files
- ✅ Supports URL redirection and encoded filenames
- ✅ Cross-platform (macOS/Linux)
- ✅ Optional `--verbose` mode for detailed logs

---

## 📦 Requirements

- `bash` (v4+)
- `wget`
- `curl`
- `python3` (for URL decoding)
- `stat` (standard on Unix/macOS)

Install missing dependencies on macOS with:

```bash
brew install wget curl python
```

---

## 📝 Usage

```bash
./myrient-downloader.sh [--verbose] platforms.txt exclude_patterns.txt
```

### 📄 platforms.txt

List of directories to download from Myrient:

```
Nintendo - Game Boy
Nintendo - Nintendo 3DS (Digital) (CDN)
Sega - Mega Drive - Genesis
```

Each line must exactly match the folder name on:  
[https://myrient.erista.me/files/No-Intro/](https://myrient.erista.me/files/No-Intro/)

### ❌ exclude_patterns.txt

List of substrings (case-insensitive) to exclude:

```
README
(Proto)
(Unl)
(Alt)
(Japan)
```

If a filename contains any of these, it will be skipped.

---

## 💡 Example

```bash
./myrient-downloader.sh --verbose platforms.txt exclude_patterns.txt
```

---

## 📂 Output

- Each platform will be saved in a local folder like `./Nintendo - Game Boy`
- A `.completed` file will be created per folder to track finished downloads
- Incomplete or failed downloads will retry on next run

---

## 📋 License

MIT License

---

## ❤️ Inspired By

- No-Intro Project
- TOSEC / Redump / No-Intro
- ROM preservation efforts everywhere 🌍
