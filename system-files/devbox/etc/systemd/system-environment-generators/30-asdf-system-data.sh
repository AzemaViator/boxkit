#!/usr/bin/env bash

set -euo pipefail

emit() {
    printf '%s=%s\n' "$1" "$2"
}

asdf_dir=
while IFS='=' read -r k v; do
    [[ $k == ASDF_SYSTEM_DATA_DIR ]] && { asdf_dir=$v; break; }
done < <(tr '\0' '\n' </proc/1/environ)

[[ -z $asdf_dir ]] && exit 0

emit ASDF_SYSTEM_DATA_DIR "$asdf_dir"

shims_dir="$asdf_dir/shims"
if [[ -d $shims_dir ]]; then

    current_path=${PATH-}
    case ":$current_path:" in
        *":$shims_dir:"*) ;;
        *) emit PATH "${current_path:+$current_path:}$shims_dir" ;;
    esac
fi
