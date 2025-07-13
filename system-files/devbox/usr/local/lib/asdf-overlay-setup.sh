#!/usr/bin/env bash
set -euo pipefail

USERNAME="$(stat -c '%U' "${HOME}")"
LOGIN_ENV="$(su -l "$USERNAME" -c 'printenv')"
env_get() {
  printf '%s\n' "${LOGIN_ENV}" | awk -F= -v key="$1" '$1==key{print substr($0,length(key)+2)}'
}

OVERLAY_ROOT="/var/lib/asdf-overlay"
XDG_DATA_HOME="$(env_get XDG_DATA_HOME)"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

ASDF_USER_DATA="${XDG_DATA_HOME}/asdf"

mkdir -p "${OVERLAY_ROOT}/upper" "${OVERLAY_ROOT}/work"  "$ASDF_USER_DATA"
chown $(id -ur $USERNAME):$(id -gr $USERNAME) $ASDF_USER_DATA

if mountpoint -q "$ASDF_USER_DATA"; then
  exit 0
fi

MOUNT_UNIT="$(systemd-escape -p --suffix=mount "$ASDF_USER_DATA")"

cat > "/etc/systemd/system/${MOUNT_UNIT}" <<EOF
[Unit]
Description=Overlay for ${TARGET_USER}'s asdf data at ${ASDF_USER_DATA}

[Mount]
What=overlay
Where=${ASDF_USER_DATA}
Type=overlay
Options=lowerdir=${ASDF_SYSTEM_DATA_DIR},upperdir=${OVERLAY_ROOT}/upper,workdir=${OVERLAY_ROOT}/work

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable --now "${MOUNT_UNIT}"
