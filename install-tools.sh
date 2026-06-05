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

# --- System deps (one sudo prompt for everything apt/brew needs) ---------
install_system_deps() {
  if [[ "$OS" == "macos" ]]; then
    have brew || die "brew not found; install from https://brew.sh"
    local brew_pkgs=()
    have tmux || brew_pkgs+=(tmux)
    # python3 venv ships with brew's python3 by default
    if [[ ${#brew_pkgs[@]} -gt 0 ]]; then
      log "brew install: ${brew_pkgs[*]}"
      brew install "${brew_pkgs[@]}"
    fi
    return
  fi

  # Linux — prefer apt, fall back to dnf/pacman
  local pm pkgs=()
  if have apt-get; then
    pm="apt-get"
    have tmux || pkgs+=(tmux)
    # Ubuntu ships python3 without venv/ensurepip; detect and install the
    # versioned python3.X-venv package.
    if have python3 && ! python3 -c "import ensurepip" >/dev/null 2>&1; then
      pkgs+=("$(python3 -c 'print(f"python3.{__import__("sys").version_info.minor}-venv")')")
    fi
    [[ ${#pkgs[@]} -gt 0 ]] || return 0
    log "sudo $pm install: ${pkgs[*]}"
    sudo apt-get install -y "${pkgs[@]}"
  elif have dnf; then
    pm="dnf"
    have tmux || pkgs+=(tmux)
    have python3 || pkgs+=(python3)
    [[ ${#pkgs[@]} -gt 0 ]] || return 0
    log "sudo $pm install: ${pkgs[*]}"
    sudo dnf install -y "${pkgs[@]}"
  elif have pacman; then
    pm="pacman"
    have tmux || pkgs+=(tmux)
    have python3 || pkgs+=(python)
    [[ ${#pkgs[@]} -gt 0 ]] || return 0
    log "sudo $pm -S: ${pkgs[*]}"
    sudo pacman -S --noconfirm "${pkgs[@]}"
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
    log "  already installed: $(tmux -V) at $(command -v tmux)"
  else
    # Should already be installed by install_system_deps; if not, bail loudly.
    die "tmux still missing — install_system_deps should have caught this. Install manually."
  fi

  # TPM (Tmux Plugin Manager) — required by .tmux.conf plugin declarations.
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ ! -d "$tpm_dir" ]]; then
    log "  installing TPM → $tpm_dir"
    mkdir -p "$HOME/.tmux/plugins"
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
  else
    log "  TPM already installed"
  fi

  # Install all plugins declared in .tmux.conf (idempotent).
  if [[ -x "$tpm_dir/bin/install_plugins" ]]; then
    log "  installing tmux plugins via TPM"
    "$tpm_dir/bin/install_plugins" >/dev/null 2>&1 || \
      log "  (TPM plugin install emitted warnings; open tmux and press prefix + I if any are missing)"
  fi
}

# --- Main ----------------------------------------------------------------
have curl || die "curl not found"
have tar  || die "tar not found"

install_system_deps

install_fzf
install_nvim
install_gh
install_uv
install_bun
install_hf
install_tmux

log ""
log "Installed:"
for t in fzf nvim gh uv bun hf tmux; do
  if have "$t"; then
    v=$("$t" --version 2>&1 | head -1)
    printf '  %-8s %s (%s)\n' "$t" "$v" "$(command -v "$t")"
  else
    printf '  %-8s NOT FOUND\n' "$t"
  fi
done
