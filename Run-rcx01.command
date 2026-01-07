#!/usr/bin/env bash
# Run-rcx01.command — double-click launcher for SC + Processing on macOS
# Place inside the rcx01nov24 folder before zipping.
# On first run it will chmod itself so future runs don’t need adjustment.

set -euo pipefail

# --- ensure script is executable for future runs ---
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
if [[ ! -x "$SCRIPT_PATH" ]]; then
  echo "[rcx01] fixing permissions on first run..."
  chmod +x "$SCRIPT_PATH" || true
fi

# --- resolve project paths ---
HERE="$(cd "$(dirname "$0")" && pwd)"
SCD_FILE="$HERE/rcx01nov24.scd"
PDE_DIR="$HERE/pde"
BUILD_DIR="$HERE/_p5-build"

# --- sanity checks ---
[[ -f "$SCD_FILE" ]] || { osascript -e 'display alert "Missing rcx01nov24.scd"'; exit 1; }
[[ -d "$PDE_DIR"  ]] || { osascript -e 'display alert "Missing Processing sketch folder: pde/"'; exit 1; }

# --- helpers ---
find_app_by_bundleid() { mdfind "kMDItemCFBundleIdentifier == '$1'" | head -n1; }
first_existing() { for p in "$@"; do [[ -e "$p" ]] && { echo "$p"; return 0; }; done; return 1; }

# --- locate SuperCollider ---
SC_APP="$(find_app_by_bundleid 'org.supercollider.SuperCollider')"
SC_APP="${SC_APP:-$(first_existing '/Applications/SuperCollider.app' "$HOME/Applications/SuperCollider.app")}"
if [[ -z "$SC_APP" ]]; then
  osascript -e 'display alert "SuperCollider.app not found in Applications."'
  exit 1
fi
SCLANG="$SC_APP/Contents/MacOS/sclang"

# --- locate Processing ---
PROC_APP="$(find_app_by_bundleid 'org.processing.app')"
PROC_APP="${PROC_APP:-$(first_existing '/Applications/Processing.app' "$HOME/Applications/Processing.app")}"
PROC_CLI=""
if [[ -n "$PROC_APP" ]]; then
  for CAND in "$PROC_APP/Contents/Java/processing-java" "$PROC_APP/Contents/MacOS/processing-java"; do
    [[ -x "$CAND" ]] && PROC_CLI="$CAND" && break
  done
fi

# --- launch SuperCollider ---
echo "[rcx01] starting SuperCollider..."
( cd "$HERE" && "$SCLANG" "$SCD_FILE" ) &
SC_PID=$!
sleep 1

# --- launch Processing ---
if [[ -n "$PROC_CLI" ]]; then
  echo "[rcx01] starting Processing via processing-java..."
  mkdir -p "$BUILD_DIR"
  "$PROC_CLI" --sketch="$PDE_DIR" --output="$BUILD_DIR" --force --run &
  P5_PID=$!
  P5_MODE=cli
elif [[ -n "$PROC_APP" ]]; then
  echo "[rcx01] opening sketch in Processing IDE..."
  open -a "$PROC_APP" "$PDE_DIR"
  P5_PID=""
  P5_MODE=ide
else
  osascript -e 'display alert "Processing.app not found in Applications."'
  P5_PID=""
  P5_MODE=none
fi

# --- cleanup ---
cleanup() {
  echo "[rcx01] shutting down..."
  [[ -n "${P5_PID:-}" ]] && kill "$P5_PID" 2>/dev/null || true
  kill "$SC_PID" 2>/dev/null || true
}
trap cleanup EXIT

# --- keep terminal alive ---
if [[ "$P5_MODE" == "cli" ]]; then
  wait -n "$SC_PID" "$P5_PID" || true
else
  wait "$SC_PID" || true
fi
