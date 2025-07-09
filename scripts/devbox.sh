#!/bin/sh

# Update the container and install packages
dnf5 copr enable atim/starship
dnf5 -y config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
dnf5 update -y
grep -v '^#' ./devbox.packages | xargs dnf5 install -y

BASH_COMP_DIR="/usr/share/bash-completion/completions"
ZSH_COMP_DIR="/usr/share/zsh/site-functions"
FISH_COMP_DIR="/usr/share/fish/vendor_completions.d"

starship completions fish > "$FISH_COMP_DIR/starship.fish"

mkdir -p $NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh \
     | NVM_DIR=$NVM_DIR PROFILE=/dev/null bash

. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default lts/*

npm install -g "corepack@$COREPACK_VERSION"
npm install -g "npm@$NPM_VERSION"

corepack enable
corepack prepare "yarn@$YARN_VERSION" --activate
corepack prepare "pnpm@$PNPM_VERSION" --activate

curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash -s "$BUN_VERSION"

SHELL=bash bun completions $BASH_COMP_DIR
SHELL=zsh bun completions $ZSH_COMP_DIR
SHELL=fish bun completions $FISH_COMP_DIR

curl -fsSL https://deno.land/install.sh | DENO_INSTALL=/usr/local sh -s "$DENO_VERSION"

deno completions bash > "$BASH_COMP_DIR/deno"
deno completions zsh > "$ZSH_COMP_DIR/_deno"
deno completions fish > "$FISH_COMP_DIR/deno.fish"
