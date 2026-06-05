#!/usr/bin/env bash
# bootstrap.sh — set up lrei/dotfiles on macOS or any Linux.
# Public. No secrets. Idempotent (safe to re-run).
#
# Two equivalent invocations:
#   curl -fsSL https://raw.githubusercontent.com/lrei/dotfiles/master/bootstrap.sh | bash
#   bash ~/bootstrap.sh
set -euo pipefail

REPO_URL="https://github.com/lrei/dotfiles.git"
CFG_DIR="$HOME/.cfg"

log()  { printf '>> %s\n' "$*"; }
die()  { printf '!! %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
config() { git --git-dir="$CFG_DIR" --work-tree="$HOME" "$@"; }

# 1. Preflight
have git  || die "git not found. Install with:  brew install git  (macOS)  |  apt/dnf install git  (Linux)"
have curl || die "curl not found. Install with: brew install curl (macOS)  |  apt/dnf install curl (Linux)"

# 2. Acquire / refresh dotfiles
if [[ -d "$CFG_DIR" ]]; then
  log "Refreshing $CFG_DIR..."
  config fetch origin master
  config reset --hard FETCH_HEAD
else
  log "Cloning bare repo to $CFG_DIR..."
  git clone --bare "$REPO_URL" "$CFG_DIR"
fi

# 3. Hide untracked files (HOME is the work-tree)
config config --local status.showUntrackedFiles no

# 4. Force-checkout tracked files (overwrites local edits to tracked files)
log "Checking out dotfiles..."
config checkout -f

# 5. oh-my-zsh (unattended; keep the just-checked-out .zshrc)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing oh-my-zsh..."
  omz_script="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    || die "Failed to download oh-my-zsh installer"
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$omz_script"
else
  log "oh-my-zsh already installed."
fi

# 6. Next steps
cat <<EOF

>> Done. Next:
>>   - Open a new zsh shell (or 'exec zsh') — missing plugins auto-install.
>>   - To make zsh default:  chsh -s \$(which zsh)
EOF
