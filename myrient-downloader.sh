#!/bin/bash

# Usage:
#   ./myrient-downloader.sh platforms.txt exclude_patterns.txt
#   ./myrient-downloader.sh --verbose --base-url https://myrient.erista.me/files/Redump platforms.txt exclude_patterns.txt

BASE_URL="https://myrient.erista.me/files/No-Intro"
MAX_PARALLEL=5
VERBOSE=0

PLATFORMS_FILE=""
EXCLUDES_FILE=""
TOTAL_FILES=0
SUCCESS_COUNT=0
FAIL_COUNT=0

TMP_QUEUE=""
cleanup() {
  [[ -n "$TMP_QUEUE" && -f "$TMP_QUEUE" ]] && rm -f "$TMP_QUEUE"
  find . -name ".result.*" -delete
}
trap cleanup EXIT SIGINT SIGTERM

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose)
      VERBOSE=1
      shift
      ;;
    --base-url)
      BASE_URL="$2"
      shift 2
      ;;
    *)
      if [[ -z "$PLATFORMS_FILE" ]]; then
        PLATFORMS_FILE="$1"
      elif [[ -z "$EXCLUDES_FILE" ]]; then
        EXCLUDES_FILE="$1"
      else
        echo "❌ Unknown argument: $1"
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "${PLATFORMS_FILE:-}" || -z "${EXCLUDES_FILE:-}" ]]; then
  echo "Usage: $0 [--verbose] [--base-url URL] platforms.txt exclude_patterns.txt"
  exit 1
fi

mapfile -t EXCLUDE_PATTERNS < "$EXCLUDES_FILE"

logv() {
  if [[ "$VERBOSE" -eq 1 ]]; then
    echo "[VERBOSE] $*"
  fi
}

# Cross-platform file size
get_file_size() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    stat -f%z "$1"
  else
    stat -c%s "$1"
  fi
}

download_file() {
  PLATFORM_DIR="$1"
  FILE="$2"
  FILE_URL="$3"
  RESULT_FILE="${PLATFORM_DIR}/.result.$(date +%s%N)"

  DECODED_FILE=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('''$FILE'''))")
  LOCAL_PATH="${PLATFORM_DIR}/${DECODED_FILE}"
  COMPLETED_FILE="${PLATFORM_DIR}/.completed"

  logv "FILE: $FILE"
  logv "DECODED_FILE: $DECODED_FILE"
  logv "LOCAL_PATH: $LOCAL_PATH"
  logv "FILE_URL: $FILE_URL"

  if [[ -f "$COMPLETED_FILE" ]] && grep -Fxq "$FILE" "$COMPLETED_FILE" && [[ -s "$LOCAL_PATH" ]]; then
    echo "✅ Already complete: $FILE"
    return 0
  else
    touch "$COMPLETED_FILE"
  fi

  if [[ -s "$LOCAL_PATH" ]]; then
    REMOTE_SIZE=$(curl -sIL "$FILE_URL" | grep -i '^Content-Length:' | tail -1 | cut -d' ' -f2 | tr -d '\r')
    LOCAL_SIZE=$(get_file_size "$LOCAL_PATH" 2>/dev/null)
    logv "Existing file found. Remote size: $REMOTE_SIZE, Local size: $LOCAL_SIZE"

    if [[ -n "$REMOTE_SIZE" && "$REMOTE_SIZE" == "$LOCAL_SIZE" ]]; then
      echo "📏 Matched size, marking complete: $FILE"
      echo "$FILE" >> "$COMPLETED_FILE"
      return 0
    fi
  fi

  echo "⬇️  Downloading: $FILE"

  if [[ "$VERBOSE" -eq 1 ]]; then
    wget --continue --timestamping \
         --tries=5 \
         --retry-connrefused \
         --timeout=30 \
         --waitretry=5 \
         -P "$PLATFORM_DIR" \
         "$FILE_URL"
  else
    wget --continue --timestamping \
         --tries=5 \
         --retry-connrefused \
         --timeout=30 \
         --waitretry=5 \
         -P "$PLATFORM_DIR" \
         "$FILE_URL" > /dev/null 2>&1
  fi

  if [[ -f "$LOCAL_PATH" ]]; then
    REMOTE_SIZE=$(curl -sIL "$FILE_URL" | grep -i '^Content-Length:' | tail -1 | cut -d' ' -f2 | tr -d '\r')
    LOCAL_SIZE=$(get_file_size "$LOCAL_PATH" 2>/dev/null)
    logv "After wget: Remote size: $REMOTE_SIZE, Local size: $LOCAL_SIZE"

    if [[ -n "$REMOTE_SIZE" && "$REMOTE_SIZE" == "$LOCAL_SIZE" && "$LOCAL_SIZE" -gt 0 ]]; then
      echo "✅ Download verified by size: $FILE"
      echo "$FILE" >> "$COMPLETED_FILE"
      echo "success" >> "$RESULT_FILE"
    else
      echo "⚠️  Download may have failed or file is incomplete: $FILE"
      echo "fail" >> "$RESULT_FILE"
    fi
  else
    echo "⚠️  File missing after attempted download: $FILE"
    echo "fail" >> "$RESULT_FILE"
  fi
}

export -f download_file
export -f get_file_size
export -f logv

while IFS= read -r DIR_NAME || [[ -n "$DIR_NAME" ]]; do
  [[ -z "$DIR_NAME" || "$DIR_NAME" =~ ^# ]] && continue

  ENCODED_DIR=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$DIR_NAME'''))")
  FULL_URL="${BASE_URL}/${ENCODED_DIR}/"
  LOCAL_DIR="./$(basename "$DIR_NAME")"
  mkdir -p "$LOCAL_DIR"

  echo "🔍 Fetching list from: $FULL_URL"
  echo "📁 Local folder: $LOCAL_DIR"

  FILES=$(curl -s "$FULL_URL" | grep -Eo 'href="[^"]+\.(zip|rar|7z|dat|txt)"' | cut -d'"' -f2)

  if [ -z "$FILES" ]; then
    echo "⚠️  No downloadable files found in: $DIR_NAME"
    echo
    continue
  fi

  TMP_QUEUE=$(mktemp)

  for FILE in $FILES; do
    SKIP=0
    for PATTERN in "${EXCLUDE_PATTERNS[@]}"; do
      if echo "$FILE" | grep -iq "$PATTERN"; then
        echo "⏭️  Skipping (excluded): $FILE"
        logv "Excluded by pattern: $PATTERN"
        SKIP=1
        break
      fi
    done
    [[ $SKIP -eq 1 ]] && continue

    echo "$LOCAL_DIR|||$FILE|||${FULL_URL}${FILE}" >> "$TMP_QUEUE"
  done

  echo "🚀 Starting parallel downloads for: $DIR_NAME"
  cat "$TMP_QUEUE" | xargs -P $MAX_PARALLEL -I{} bash -c '
    line="{}"
    dir="${line%%|||*}"
    rest="${line#*|||}"
    file="${rest%%|||*}"
    url="${rest#*|||}"
    download_file "$dir" "$file" "$url"
  '

  echo "📊 Download Summary"
  echo "----------------------"

  SUCCESS_COUNT=$(find "$LOCAL_DIR" -name ".result.*" -exec cat {} + | grep -c "success")
  FAIL_COUNT=$(find "$LOCAL_DIR" -name ".result.*" -exec cat {} + | grep -c "fail")
  TOTAL_FILES=$((SUCCESS_COUNT + FAIL_COUNT))

  echo "🧾 Total attempted: $TOTAL_FILES"
  echo "✅ Completed:       $SUCCESS_COUNT"
  echo "❌ Errors:          $FAIL_COUNT"

  # Clean up result files
  find "$LOCAL_DIR" -name ".result.*" -delete

  sort -u "${LOCAL_DIR}/.completed" -o "${LOCAL_DIR}/.completed"
  rm -f "$TMP_QUEUE"
  echo "✅ Done: $DIR_NAME"
  echo
done < "$PLATFORMS_FILE"

