#!/usr/bin/env bash
set -euo pipefail

# This adapts upstream xsdk's Debian/WSL instructions to Lubuntu. Native Linux
# has not been verified by this project; stop on any failed dependency/build step.

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This script expects an Ubuntu/Debian-based system with apt-get." >&2
  exit 1
fi

echo "This will install build dependencies with sudo apt and clone xsdk into $HOME/xsdk."
echo "It will not download or install Microsoft SDK files, firmware, keys, or console files."
read -r -p "Continue? [y/N] " answer
case "$answer" in
  y|Y|yes|YES) ;;
  *) echo "Cancelled."; exit 0 ;;
esac

sudo apt-get update
sudo apt-get install -y \
  build-essential bison flex texinfo libgmp-dev libmpfr-dev libmpc-dev \
  curl ca-certificates xz-utils patch python3 python3-venv cmake ninja-build git

python3 - <<'PY'
import sys
if sys.version_info < (3, 11):
    raise SystemExit("Python 3.11 or newer is required by upstream xsdk.")
print("Python version OK:", sys.version.split()[0])
PY

if [ ! -d "$HOME/xsdk/.git" ]; then
  if [ -e "$HOME/xsdk" ]; then
    echo "$HOME/xsdk exists but is not a Git checkout; refusing to overwrite it." >&2
    exit 1
  fi
  git clone https://github.com/xenosworks/xsdk.git "$HOME/xsdk"
else
  echo "Using existing checkout at $HOME/xsdk (not changing its branch or local modifications)."
fi

echo
echo "Prerequisites and xsdk checkout are ready."
echo "Next inspect and run: bash scripts/build-xsdk.sh"
