#!/usr/bin/env bash
set -euo pipefail

# Prepare and auto-start the devbox container, plus set JetBrains Toolbox autostart.
# - Creates/updates the devbox container from distrobox/devbox.ini
# - Installs a user systemd unit that keeps the container running
# - Writes a desktop autostart entry for JetBrains Toolbox installed inside the devbox

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR%/scripts}"
INI_FILE="${REPO_ROOT}/distrobox/devbox.ini"

DEVBOX_NAME="devbox"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME}/systemd/user"
AUTOSTART_DIR="${XDG_CONFIG_HOME}/autostart"
DEVBOX_HOME="${DEVBOX_HOME:-${HOME}/projects/.devbox}"
TOOLBOX_BIN="${DEVBOX_HOME}/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"
TOOLBOX_ICON="${DEVBOX_HOME}/.local/share/JetBrains/Toolbox/bin/toolbox.svg"

echo "Creating devbox container from ${INI_FILE}..."
distrobox assemble create --replace --file "${INI_FILE}"

echo "Configuring user systemd unit to keep ${DEVBOX_NAME} running..."
mkdir -p "${SYSTEMD_USER_DIR}"
cat > "${SYSTEMD_USER_DIR}/devbox-autostart.service" <<EOF
[Unit]
Description=Auto-start the devbox container
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecCondition=/usr/bin/podman container exists ${DEVBOX_NAME}
ExecStart=/usr/bin/distrobox-enter -n ${DEVBOX_NAME} -- sleep infinity
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now devbox-autostart.service

echo "Adding JetBrains Toolbox desktop autostart entry..."
mkdir -p "${AUTOSTART_DIR}"
cat > "${AUTOSTART_DIR}/jetbrains-toolbox.desktop" <<EOF
[Desktop Entry]
Icon=${TOOLBOX_ICON}
Exec=/bin/sh -lc 'podman container exists ${DEVBOX_NAME} && exec distrobox-enter -n ${DEVBOX_NAME} -- ${TOOLBOX_BIN} --minimize'
Version=1.0
Type=Application
Categories=Development
Name=JetBrains Toolbox
StartupWMClass=jetbrains-toolbox
Terminal=false
MimeType=x-scheme-handler/jetbrains;
X-GNOME-Autostart-enabled=true
StartupNotify=false
X-GNOME-Autostart-Delay=10
X-MATE-Autostart-Delay=10
X-KDE-autostart-after=panel
EOF

echo "Devbox ready. Service enabled and JetBrains Toolbox set to autostart (path: ${AUTOSTART_DIR}/jetbrains-toolbox.desktop)."
