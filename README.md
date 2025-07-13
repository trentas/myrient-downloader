# 🎮 Myrient Downloader

A parallel, resumable downloader for any collection hosted on [myrient.erista.me](https://myrient.erista.me/files/), such as:

- No-Intro
- Redump
- TOSEC
- MAME
- and more!

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
- ✅ Optional `--base-url` to support other collections like Redump, TOSEC, etc.

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
./myrient-downloader.sh [--verbose] [--base-url URL] platforms.txt exclude_patterns.txt
```

### 📄 platforms.txt

List of directories to download from Myrient:

```
Nintendo - Game Boy
Sony - PlayStation
Sega - Dreamcast
```

Each line must exactly match the folder name on the Myrient collection URL.

### ❌ exclude_patterns.txt

List of substrings (case-insensitive) to exclude:

```
README
(Proto)
(Unl)
(Alt)
(Japan)
```

---

## 💡 Example

Download from Redump:

```bash
./myrient-downloader.sh --verbose --base-url https://myrient.erista.me/files/Redump platforms.txt exclude_patterns.txt
```

Default (No-Intro):

```bash
./myrient-downloader.sh platforms.txt exclude_patterns.txt
```

---

## 📂 Output

- Each platform will be saved in a local folder like `./Sony - PlayStation`
- A `.completed` file will be created per folder to track finished downloads
- Incomplete or failed downloads will retry on next run

---

## 🙏 Thanks

Special thanks to [myrient.erista.me](https://myrient.erista.me) for hosting and preserving the No-Intro and other archival collections.

---

## 📋 License

MIT License

---

## ❤️ Inspired By

- TOSEC / Redump / No-Intro Projects
- ROM preservation efforts everywhere 🌍
