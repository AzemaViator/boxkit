#!/bin/sh

set -euo pipefail

# Update the container and install packages
dnf5 copr enable -y atim/starship
dnf5 -y config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
dnf5 update -y
grep -v '^#' /ctx/packages/devbox.packages | xargs dnf5 install -y

systemctl enable asdf-overlay-setup.service

case "$(uname -m)" in \
        x86_64)   ASDF_ARCH="linux-amd64"  ;; \
        aarch64|arm64) ASDF_ARCH="linux-arm64" ;; \
        *) echo "Unsupported arch: $(uname -m)" && exit 1 ;; \
esac
curl -fsSL "https://github.com/asdf-vm/asdf/releases/download/v${ASDF_VERSION}/asdf-v${ASDF_VERSION}-${ASDF_ARCH}.tar.gz" -o /tmp/asdf.tar.gz
tar -C /usr/local/bin -xzf /tmp/asdf.tar.gz asdf
chmod +x /usr/local/bin/asdf
rm /tmp/asdf.tar.gz
mkdir -p "$ASDF_DATA_DIR"
export PATH="${ASDF_DATA_DIR}/shims:$PATH"

asdf plugin add eza https://github.com/lwiechec/asdf-eza.git
asdf install eza $EZA_VERSION
asdf set -u eza $EZA_VERSION

asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs $NODE_VERSION
asdf set -u nodejs $NODE_VERSION

npm install -g "npm@$NPM_VERSION"
npm install -g "corepack@$COREPACK_VERSION"

corepack enable
corepack prepare "yarn@$YARN_VERSION" --activate
corepack prepare "pnpm@$PNPM_VERSION" --activate

asdf plugin add bun https://github.com/cometkim/asdf-bun.git
asdf install bun $BUN_VERSION
asdf set -u bun $BUN_VERSION

asdf plugin add deno https://github.com/asdf-community/asdf-deno.git
asdf install deno $DENO_VERSION
asdf set -u deno $DENO_VERSION

asdf plugin add rust https://github.com/code-lever/asdf-rust.git
asdf install rust $RUST_VERSION
asdf set -u rust $RUST_VERSION

asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
asdf install golang $GOLANG_VERSION
asdf set -u golang $GOLANG_VERSION

asdf plugin add awscli https://github.com/MetricMike/asdf-awscli.git
asdf install awscli $AWSCLI_VERSION
asdf set -u rust $AWSCLI_VERSION

asdf plugin add kubectl https://github.com/asdf-community/asdf-kubectl.git
asdf install kubectl $KUBECTL_VERSION
asdf set -u kubectl $KUBECTL_VERSION

asdf plugin add terraform https://github.com/asdf-community/asdf-hashicorp.git
asdf install terraform $TERRAFORM_VERSION
asdf set -u terraform $TERRAFORM_VERSION

cp /root/.tool-versions /
