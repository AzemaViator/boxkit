#!/usr/bin/env bash
set -euo pipefail

: "${DISTROBOX_USER:?DISTROBOX_USER is required}"
: "${DISTROBOX_USER_HOME:?DISTROBOX_USER_HOME is required}"

INSTALL_ROOT="${DISTROBOX_USER_HOME}/.local/share/JetBrains/Toolbox"
BIN_DIR="${INSTALL_ROOT}/bin"
TOOLBOX_BIN="${BIN_DIR}/jetbrains-toolbox"

if [[ -x "$TOOLBOX_BIN" ]]; then
  exit 0
fi

USER_UID=$(id -ru "${DISTROBOX_USER}")
USER_GID=$(id -rg "${DISTROBOX_USER}")

tmpdir="$(mktemp -d)"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

download_url="$(python3 - <<'PY'
import json
import sys
import urllib.request

URL = "https://data.services.jetbrains.com/products/releases?code=TBA&platform=linux&latest=true&type=release"

try:
    with urllib.request.urlopen(URL, timeout=30) as resp:
        data = json.load(resp)
    print(data["TBA"][0]["downloads"]["linux"]["link"])
except Exception as exc:  # noqa: BLE001
    sys.stderr.write(f"Failed to resolve JetBrains Toolbox download URL: {exc}\n")
    sys.exit(1)
PY
)"

if [[ -z "$download_url" ]]; then
  echo "JetBrains Toolbox download URL not found" >&2
  exit 1
fi

archive="$tmpdir/jetbrains-toolbox.tar.gz"
curl -fsSL "$download_url" -o "$archive"

tar -xzf "$archive" -C "$tmpdir"
toolbox_dir="$(find "$tmpdir" -maxdepth 1 -type d -name 'jetbrains-toolbox-*' | head -n1)"

if [[ -z "$toolbox_dir" ]]; then
  echo "JetBrains Toolbox archive did not contain expected directory" >&2
  exit 1
fi

install -d -m 0755 -o "$USER_UID" -g "$USER_GID" "$BIN_DIR"
install -m 0755 -o "$USER_UID" -g "$USER_GID" "$toolbox_dir/jetbrains-toolbox" "$TOOLBOX_BIN"

echo "JetBrains Toolbox installed to $TOOLBOX_BIN"
