#!/usr/bin/env bash
set -euo pipefail

repo_slug=${GIF_TO_PLYMOUTH_REPO:-Kuucheen/gif-to-plymouth}
branch=${GIF_TO_PLYMOUTH_BRANCH:-main}
raw_url=${GIF_TO_PLYMOUTH_RAW_URL:-https://raw.githubusercontent.com/${repo_slug}/${branch}/gif-to-plymouth}
install_dir=${GIF_TO_PLYMOUTH_INSTALL_DIR:-${HOME}/.local/bin}
target=${install_dir}/gif-to-plymouth

say() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

need_downloader() {
  if command -v curl >/dev/null 2>&1; then
    printf 'curl'
  elif command -v wget >/dev/null 2>&1; then
    printf 'wget'
  else
    return 1
  fi
}

download() {
  local url=$1
  local dest=$2
  local downloader

  downloader=$(need_downloader) || {
    warn "curl or wget is required when install.sh is not run from a cloned checkout"
    return 1
  }

  case "$downloader" in
    curl)
      curl -fsSL "$url" -o "$dest"
      ;;
    wget)
      wget -qO "$dest" "$url"
      ;;
  esac
}

print_dependency_hints() {
  cat <<'EOF'

Install dependency hints:

Fedora:
  sudo dnf install ImageMagick plymouth plymouth-scripts polkit

Debian / Ubuntu / Linux Mint:
  sudo apt install imagemagick plymouth policykit-1

Arch / EndeavourOS / Manjaro:
  sudo pacman -S imagemagick plymouth polkit

openSUSE:
  sudo zypper install ImageMagick plymouth polkit
EOF
}

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
local_source=${script_dir}/gif-to-plymouth
tmp_source=

if [[ -f "$local_source" ]]; then
  source_file=$local_source
else
  tmp_source=$(mktemp "${TMPDIR:-/tmp}/gif-to-plymouth.XXXXXX")
  trap 'rm -f "$tmp_source"' EXIT
  say "Downloading gif-to-plymouth from ${raw_url}"
  download "$raw_url" "$tmp_source"
  source_file=$tmp_source
fi

install -d "$install_dir"
install -m 0755 "$source_file" "$target"

say "Installed gif-to-plymouth to ${target}"

missing=()
for cmd in magick identify tar pkexec plymouth-set-default-theme; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing+=("$cmd")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  warn "missing runtime dependencies: ${missing[*]}"
  print_dependency_hints
fi

case ":$PATH:" in
  *":$install_dir:"*) ;;
  *)
    warn "${install_dir} is not currently in PATH"
    say "Add this to your shell profile if your distro does not do it automatically:"
    say "  export PATH=\"${install_dir}:\$PATH\""
    ;;
esac

say "Run: gif-to-plymouth --help"
