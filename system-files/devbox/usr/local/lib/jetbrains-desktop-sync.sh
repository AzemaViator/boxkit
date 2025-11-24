#!/usr/bin/env bash
set -euo pipefail

: "${DISTROBOX_HOST_HOME:?DISTROBOX_HOST_HOME is required}"
: "${DISTROBOX_USER_HOME:?DISTROBOX_USER_HOME is required}"

CONTAINER_NAME="${DISTROBOX_CONTAINER_ID:-devbox}"

SRC_DIR="${DISTROBOX_USER_HOME}/.local/share/applications"
DEST_DIR="${DISTROBOX_HOST_HOME}/.local/share/applications"
PREFIX="${CONTAINER_NAME}-"

mkdir -p "${DEST_DIR}"

wrap_exec() {
  local raw="$1"
  if [[ "$raw" != *".local/share/JetBrains/Toolbox"* ]]; then
    return 1
  fi
  local escaped=${raw//\'/\'\"\'\"\'} # escape single quotes for bash -lc
  printf '/usr/bin/distrobox-enter -n %s -- bash -lc '\''%s'\''' "$CONTAINER_NAME" "$escaped"
}

# Sync JetBrains desktop files from container to host
for src in "${SRC_DIR}"/*.desktop; do
  [[ -f "$src" ]] || continue
  exec_line=$(grep -m1 '^Exec=' "$src" || true)
  [[ -n "$exec_line" ]] || continue
  exec_value=${exec_line#Exec=}

  wrapped_exec=$(wrap_exec "$exec_value") || continue

  base=$(basename "$src")
  dest="${DEST_DIR}/${PREFIX}${base}"

  {
    echo "# Generated from ${src} to launch inside container ${CONTAINER_NAME}"
    while IFS= read -r line; do
      if [[ "$line" == Exec=* ]]; then
        echo "Exec=${wrapped_exec}"
      else
        echo "$line"
      fi
    done < "$src"
  } > "$dest"
  chmod 0644 "$dest"
done

# Prune host entries that no longer have a source inside the container
for dest in "${DEST_DIR}/${PREFIX}"*.desktop; do
  [[ -f "$dest" ]] || continue
  base=$(basename "$dest")
  src="${SRC_DIR}/${base#${PREFIX}}"
  if [[ ! -f "$src" ]]; then
    rm -f -- "$dest"
  fi
done
