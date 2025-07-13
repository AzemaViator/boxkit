ASDF_USER_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/asdf"
export ASDF_DATA_DIR="$ASDF_USER_DATA"

if command -v asdf >/dev/null 2>&1; then
  if ! asdf reshim >/dev/null 2>&1; then
    printf 'Warning: `asdf reshim` failed.\n' >&2
  fi
fi

SHIMS_PATH="$ASDF_DATA_DIR/shims"
if [ -d "$SHIMS_PATH" ]; then
  case ":$PATH:" in
    *":$SHIMS_PATH:"*) ;;
    *) PATH="$SHIMS_PATH:$PATH" ;;
  esac
  export PATH
fi
