#!/bin/sh

set -euo pipefail

# Add package repos
dnf5 copr enable -y atim/starship
dnf5 -y config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
dnf5 -y config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo

# -.- As this project is trying to be an isolated devbox xdg-utils-distrobox causes major issues
dnf5 swap xdg-utils-distrobox xdg-utils -y

# Install updates and packages
dnf5 update -y
grep -v '^#' /ctx/packages/devbox.packages | xargs dnf5 install -y

systemctl enable tools-overlay-setup.service
systemctl enable jetbrains-toolbox-install.service
systemctl enable jetbrains-desktop-sync.timer
