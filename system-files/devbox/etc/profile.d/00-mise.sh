#!/usr/bin/env sh

# Skip if already done in this shell
if [ -n "${MISE_PROFILED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
export MISE_PROFILED=1

mise install --silent --quiet >/dev/null 2>&1 || true

# Detect actual shell name (bash or zsh)
case "${ZSH_VERSION:+zsh}${BASH_VERSION:+bash}" in
  zsh*) _mise_shell="zsh" ;;
  bash*) _mise_shell="bash" ;;
  *) _mise_shell="sh" ;;
esac

case "$-" in
  *i*)
    eval "$(mise activate "$_mise_shell")"
    ;;
  *)
    eval "$(mise hook-env -s "$_mise_shell")"
    ;;
esac

unset _mise_shell
