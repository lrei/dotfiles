#!/usr/bin/env bash
# install-tools.sh — install/upgrade fzf, neovim, gh, uv, bun, hf to ~/.local
# Cross-platform: macOS + any Linux. Always pulls latest. No sudo.
#
#   curl -fsSL https://raw.githubusercontent.com/lrei/dotfiles/master/install-tools.sh | bash
#   bash ~/install-tools.sh
set -euo pipefail

PREFIX="$HOME/.local"
BINDIR="$PREFIX/bin"
mkdir -p "$BINDIR" "$PREFIX/share" "$PREFIX/lib"
export PATH="$BINDIR:$PATH"

log()  { printf '>> %s\n' "$*"; }
die()  { printf '!! %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- Platform detection ---
case "$(uname -s)" in
  Linux*)  OS=linux;;
  Darwin*) OS=macos;;
  *)       die "Unsupported OS: $(uname -s)";;
esac
case "$(uname -m)" in
  x86_64|amd64)   ARCH=amd64;;
  arm64|aarch64)  ARCH=arm64;;
  *)              die "Unsupported arch: $(uname -m)";;
esac
log "Platform: $OS/$ARCH  →  $BINDIR"

# --- GitHub release helper -----------------------------------------------
# Args: repo asset_regex
# Sets $REPO_TAG and $EXTRACTED_DIR (path to extracted contents).
# Detects .zip vs .tar.gz by URL.
fetch_gh_release() {
  REPO_OWNER_NAME=$1
  ASSET_REGEX=$2
  local api url
  api=$(curl -fsSL "https://api.github.com/repos/$REPO_OWNER_NAME/releases/latest") \
    || die "Failed to fetch latest release for $REPO_OWNER_NAME"
  REPO_TAG=$(printf '%s\n' "$api" | grep '"tag_name"' | head -1 | cut -d'"' -f4 || true)
  url=$(printf '%s\n' "$api" | grep '"browser_download_url"' \
        | grep -E "$ASSET_REGEX" | head -1 | cut -d'"' -f4 || true)
  [[ -n "$url" ]] || die "No asset matching '$ASSET_REGEX' in $REPO_OWNER_NAME latest ($REPO_TAG). Available:" \
                        $(printf '%s\n' "$api" | grep '"browser_download_url"' | cut -d'"' -f4)

  EXTRACTED_DIR=$(mktemp -d)
  if [[ "$url" == *.zip ]]; then
    curl -fsSL "$url" -o "$EXTRACTED_DIR/a.zip"
    if have unzip; then
      unzip -q "$EXTRACTED_DIR/a.zip" -d "$EXTRACTED_DIR"
    elif have python3; then
      python3 -m zipfile -e "$EXTRACTED_DIR/a.zip" "$EXTRACTED_DIR/"
    else
      die "Need unzip or python3 to extract $REPO_OWNER_NAME release"
    fi
    rm -f "$EXTRACTED_DIR/a.zip"
  else
    curl -fsSL "$url" | tar -xz -C "$EXTRACTED_DIR"
  fi
}

# --- Per-tool installers -------------------------------------------------

install_fzf() {
  log "fzf:"
  fetch_gh_release "junegunn/fzf" "fzf-[0-9.]+-${OS}_${ARCH}\.tar\.gz"
  log "  $REPO_TAG"
  install -m 0755 "$EXTRACTED_DIR/fzf" "$BINDIR/fzf"
}

install_nvim() {
  log "neovim:"
  local arch_native=$ARCH
  [[ "$ARCH" == "amd64" ]] && arch_native=x86_64
  fetch_gh_release "neovim/neovim" "nvim-${OS}-${arch_native}\.tar\.gz"
  log "  $REPO_TAG"
  local top; top=$(ls -A "$EXTRACTED_DIR" | head -1)
  cp -a "$EXTRACTED_DIR/$top/." "$PREFIX/"
}

install_gh() {
  log "gh:"
  if [[ "$OS" == "macos" ]]; then
    fetch_gh_release "cli/cli" "gh_[0-9.]+_macOS_${ARCH}\.zip"
  else
    fetch_gh_release "cli/cli" "gh_[0-9.]+_linux_${ARCH}\.tar\.gz"
  fi
  log "  $REPO_TAG"
  local top; top=$(ls -A "$EXTRACTED_DIR" | head -1)
  cp -a "$EXTRACTED_DIR/$top/." "$PREFIX/"
}

install_uv() {
  log "uv: official installer"
  UV_INSTALL_DIR="$PREFIX" curl -fsSL https://astral.sh/uv/install.sh | sh
}

install_bun() {
  log "bun:"
  # Direct GitHub release download (the official installer hard-requires unzip;
  # we use the same fetch_gh_release that falls back to python3 -m zipfile).
  local bun_os=$OS bun_arch=$ARCH
  [[ "$OS" == "macos" ]] && bun_os=darwin
  case "$ARCH" in
    amd64) bun_arch=x64;;
    arm64) bun_arch=aarch64;;
  esac
  fetch_gh_release "oven-sh/bun" "bun-${bun_os}-${bun_arch}\.zip"
  log "  $REPO_TAG"
  local bun_dir="$HOME/.bun"
  mkdir -p "$bun_dir/bin"
  install -m 0755 "$EXTRACTED_DIR/bun-${bun_os}-${bun_arch}/bun" "$bun_dir/bin/bun"
  ln -sf "$bun_dir/bin/bun" "$BINDIR/bun"
}

install_hf() {
  log "hf: official installer"
  curl -LsSf https://hf.co/cli/install.sh | bash
  # hf installs to ~/.local/bin/hf per the installer's default; ensure symlink
  # exists if the installer placed it elsewhere (TBD per upstream).
  [[ -x "$BINDIR/hf" ]] || have hf || \
    ln -sf "$(command -v hf 2>/dev/null || echo /usr/local/bin/hf)" "$BINDIR/hf" 2>/dev/null || true
}

install_tmux() {
  log "tmux:"
  if have tmux; then
    log "  $(tmux -V) at $(command -v tmux)"
  else
    log "  NOT FOUND — install via your package manager if needed (skipping)"
  fi
}

install_rg() {
  log "ripgrep:"
  # Ripgrep ships different target triples per (os, arch) — musl on linux x86_64,
  # gnu on linux aarch64. Map explicitly.
  local target
  case "$OS-$ARCH" in
    linux-amd64) target=x86_64-unknown-linux-musl;;
    linux-arm64) target=aarch64-unknown-linux-gnu;;
    macos-amd64) target=x86_64-apple-darwin;;
    macos-arm64) target=aarch64-apple-darwin;;
  esac
  # Anchor on the trailing quote to exclude the .sha256 sidecar files.
  fetch_gh_release "BurntSushi/ripgrep" "ripgrep-[0-9.]+-${target}\.tar\.gz\""
  log "  $REPO_TAG"
  local top; top=$(ls -A "$EXTRACTED_DIR" | head -1)
  install -m 0755 "$EXTRACTED_DIR/$top/rg" "$BINDIR/rg"
}

# --- Main ----------------------------------------------------------------
have curl || die "curl not found"
have tar  || die "tar not found"

install_fzf
install_nvim
install_gh
install_rg
install_uv
install_bun
install_hf
install_tmux

log ""
log "Installed:"
for t in fzf nvim gh rg uv bun hf tmux; do
  if have "$t"; then
    case "$t" in
      tmux) v=$(tmux -V 2>&1 | head -1);;
      *)    v=$("$t" --version 2>&1 | head -1);;
    esac
    printf '  %-8s %s (%s)\n' "$t" "$v" "$(command -v "$t")"
  else
    printf '  %-8s NOT FOUND\n' "$t"
  fi
done
