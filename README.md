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

### zsh setup

```bash
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
git clone https://github.com/spaceship-prompt/spaceship-vi-mode.git $ZSH_CUSTOM/plugins/spaceship-vi-mode
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

Ensure fzf is installed:

```bash
brew install fzf
```

## Usage

```bash
# Check repo status
config status

# Add and commit changes
config add ~/.zshrc ~/.tmux.conf
config commit -m "Update zsh + tmux config"
# first time
config push -u origin master
# or do
# git config --global push.autoSetupRemote true
# after
config push

# Restore or discard changes
config restore -- ~/.zshrc

# Pull latest changes (on other machines)
config pull
```

If there's an error like
```
config push
fatal: The current branch master has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin master

To have this happen automatically for branches without a tracking
upstream, see 'push.autoSetupRemote' in 'git help config'.
```

just do:
```bash
config push -u origin master
```

## Notes

- The repo is bare and lives at ~/.cfg.
- The working tree is your $HOME.
- **Always use the config alias (never run normal git in $HOME).**
- To keep config status clean:

```bash
config config status.showUntrackedFiles no
```
