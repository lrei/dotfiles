
# ---- oh-my-zsh installation and config. ------
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="spaceship"
# Requires:
# git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
# ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
# git clone https://github.com/spaceship-prompt/spaceship-vi-mode.git $ZSH_CUSTOM/plugins/spaceship-vi-mode

ZSH_CUSTOM=$HOME/.zshcustom

plugins=(
  spaceship-vi-mode
  vi-mode 
  git 
  zsh-syntax-highlighting 
  aliases 
  colored-man-pages 
  colorize 
  tmux 
  z
)
# Requires:
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# how often to auto-update (in days).
export UPDATE_ZSH_DAYS=12

# ------------------------------------------- #

# #############################################
#  -------------- SPACESHIP ----------------- # 
# #############################################
SPACESHIP_PROMPT_ASYNC=true
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_TIME_SHOW=false
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_EXIT_CODE_SHOW=true
SPACESHIP_PYTHON_SHOW=true
SPACESHIP_NODE_SHOW=true
SPACESHIP_GIT_SHOW=true
SPACESHIP_UV_SHOW=true
SPACESHIP_DIR_SHOW=true
SPACESHIP_DIR_TRUNC_REPO=false


# SPACESHIP_CHAR_SYMBOL="⚡"
SPACESHIP_CHAR_SYMBOL_ROOT="#"
SPACESHIP_PROMPT_ORDER=(
  vi_mode
  dir
  node
  python
  uv
  git
  exit_code
  char
)


# --------------------------------------- #
setopt clobber               # noclobber is the dumbest most anoying thing ever
setopt NO_BEEP               # no beep sound
setopt NO_CORRECT            # no correct
disable r                    # disable zsh's internal r command



# #############################################
#  -------------- COMPLETION ---------------- # 
# #############################################
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
# --------------------------------------- #


# #############################################
#  -------------- HISTORY ---------------- # 
# #############################################
HIST_STAMPS="yyyy-mm-dd"
# Avoid duplicates in history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
bindkey '^R' history-incremental-search-backward
# ------------------------------- 


# Language (it's actually required e.g. for some python stuff)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EDITOR='nvim'

# if necessary, ensure terminal colors
# export TERM="xterm-256color"

# OSX Specific
if [[ `uname` == 'Darwin' ]]
then
        export OSX=1
        # iterm2 italic
        export TERM=xterm-256color-italic
        alias ssh="TERM=xterm-256color ssh"
        # HomeBrew analytics, cask, path
        export HOMEBREW_NO_ANALYTICS=1
        export HOMEBREW_CASK_OPTS="--appdir=/Applications"
        export PATH="/usr/local/sbin:$PATH"
        # z
        . `brew --prefix`/etc/profile.d/z.sh
        alias o='open'
        # ls colors
        alias ls='ls -G'
else
        export OSX=
fi

# Linux Specific
if [[ `uname` == 'Linux' ]]
then
        export LINUX=1
        # tmux in 24bit color
        alias tmux="env TERM=xterm-256color tmux"
        # ssh agent
        eval "$(ssh-agent -s)"
        if [ ! -S ~/.ssh/ssh_auth_sock ]; then
          eval `ssh-agent`
          ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
        fi
        export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
        ssh-add -l > /dev/null || ssh-add
        # copy / paste
        # alias pbcopy='xsel --clipboard --input'
        # alias pbpaste='xsel --clipboard --output'
        # apps
        if [ -e /home/rei/.nix-profile/etc/profile.d/nix.sh ]; then . /home/rei/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
        export PATH="$HOME/apps:$PATH"

else
        export LINUX=
fi

# Languages, libs
# node: nvm
export NVM_DIR="$HOME/.nvm"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion



# #############################################
#  -------------- ALIAS ---------------- # 
# #############################################
alias vim="nvim"

# basic
alias p='pbpaste'
alias c='tr -d '\n' | pbcopy'

# nix  common
alias mkdir="mkdir -p"
alias v="vim"
alias ll='ls -Gla'
alias lm='ls -Galt | head -n 5'
alias ps='ps aux'
alias psg='ps aux | grep '

# git
alias s='git s'

# github
# gist-pastefilename.ext -- create private/public Gist from the clipboard
# contents and copy the url to the clipboard
alias gist-paste="gist --private --copy --paste --filename"
alias gist-ppaste="gist --copy --paste --filename"
# gist-file filename.ext -- create private/eublic Gist from a file
alias gist-file="gist --private --copy"
alias gist-pfile="gist --private --copy"

# get my internal ip address
alias myip="ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print \$2}'"

# util
# Download file and save it with filename of remote file
alias get="curl -O -L"
# Convert line endings to UNIX
alias dos2unix="perl -pi -e 's/\r\n?/\n/g'"
# Pretty print etc, used as a pipe (needs language name, autodect works poorly)
alias prp="pygmentize -O style=monokai -f console256 -l "
# Pretty print JSON line
alias prpj="python -m json.tool | pygmentize -O style=monokai -f console256 -l json"

# Dotfiles bare repo
# `config` replaces `git`
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

. "$HOME/.local/bin/env"

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Finally, show a fortune when we start the terminal
# fortune

