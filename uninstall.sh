#!/usr/bin/env bash
set -euo pipefail

install_dir=${GIF_TO_PLYMOUTH_INSTALL_DIR:-${HOME}/.local/bin}
target=${install_dir}/gif-to-plymouth

if [[ -e "$target" ]]; then
  rm -f "$target"
  printf 'Removed %s\n' "$target"
else
  printf 'gif-to-plymouth is not installed at %s\n' "$target"
fi

cat <<'EOF'

Generated Plymouth themes are not removed automatically.
Remove a generated theme manually if needed, for example:
  pkexec rm -rf /usr/share/plymouth/themes/MyTheme
EOF
