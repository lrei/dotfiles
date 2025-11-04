# dotfiles

My personal macOS/Linux dotfiles managed with a **bare Git repo**.

---

## Setup on a new machine

```bash
# 1. Clone the bare repo into ~/.cfg
git clone --bare git@github.com:lrei/dotfiles.git $HOME/.cfg

# 2. Define the alias (temporary for this shell) - zshrc includes it
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# 3. Checkout the actual files into $HOME
config checkout

# If you see "would overwrite existing file", back up that file and re-run checkout:
# mv ~/.zshrc ~/.zshrc.bak && config checkout

# 4. Hide untracked files (so your entire home isn’t shown as dirty)
config config --local status.showUntrackedFiles no
```

## Usage

```bash
# Check repo status
config status

# Add and commit changes
config add ~/.zshrc ~/.tmux.conf
config commit -m "Update zsh + tmux config"
config push

# Restore or discard changes
config restore -- ~/.zshrc

# Pull latest changes (on other machines)
config pull
```

## Notes

- The repo is bare and lives at ~/.cfg.
- The working tree is your $HOME.
- **Always use the config alias (never run normal git in $HOME).**
- To keep config status clean:

```bash
config config status.showUntrackedFiles no
```
