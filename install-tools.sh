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
    have unzip || die "unzip required for $REPO_OWNER_NAME release (macOS gh)"
    curl -fsSL "$url" -o "$EXTRACTED_DIR/a.zip"
    unzip -q "$EXTRACTED_DIR/a.zip" -d "$EXTRACTED_DIR"
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
  log "bun: official installer"
  # Bun's installer appends to ~/.zshrc; back it up and restore — we symlink
  # ~/.bun/bin/bun into $BINDIR instead, so the PATH modification isn't needed.
  local rc_backup; rc_backup=$(mktemp)
  cp ~/.zshrc "$rc_backup" 2>/dev/null || true
  BUN_INSTALL="$HOME/.bun" curl -fsSL https://bun.sh/install | bash
  cp "$rc_backup" ~/.zshrc 2>/dev/null || true
  rm -f "$rc_backup"
  ln -sf "$HOME/.bun/bin/bun" "$BINDIR/bun"
}

install_hf() {
  log "hf: official installer"
  curl -LsSf https://hf.co/cli/install.sh | bash
  # hf installs to ~/.local/bin/hf per the installer's default; ensure symlink
  # exists if the installer placed it elsewhere (TBD per upstream).
  [[ -x "$BINDIR/hf" ]] || have hf || \
    ln -sf "$(command -v hf 2>/dev/null || echo /usr/local/bin/hf)" "$BINDIR/hf" 2>/dev/null || true
}

# --- Main ----------------------------------------------------------------
have curl || die "curl not found"
have tar  || die "tar not found"

install_fzf
install_nvim
install_gh
install_uv
install_bun
install_hf

log ""
log "Installed:"
for t in fzf nvim gh uv bun hf; do
  if have "$t"; then
    v=$("$t" --version 2>&1 | head -1)
    printf '  %-8s %s (%s)\n' "$t" "$v" "$(command -v "$t")"
  else
    printf '  %-8s NOT FOUND\n' "$t"
  fi
done
