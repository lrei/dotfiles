
# ---- oh-my-zsh installation and config. ------
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="spaceship"
# Requires:
# git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
# ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
# git clone https://github.com/spaceship-prompt/spaceship-vi-mode.git $ZSH_CUSTOM/plugins/spaceship-vi-mode

ZSH_CUSTOM=$HOME/.zshcustom

plugins=(
  vi-mode
  spaceship-vi-mode
  git 
  zsh-syntax-highlighting 
  aliases 
  colored-man-pages 
  colorize 
  tmux 
  fzf 
  history-substring-search
  z
)
# Requires:
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# how often to auto-update (in days).
export UPDATE_ZSH_DAYS=12
# -------------------------------------------------------------------------  #


# #############################################
#  -------------- SPACESHIP ----------------- # 
# #############################################
SPACESHIP_PROMPT_ASYNC=true
[[ -n "$TMUX" ]] && SPACESHIP_PROMPT_ASYNC=false
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=false
SPACESHIP_RPROMPT_FIRST_PREFIX_SHOW=false
SPACESHIP_RPROMPT_SHOW=false
SPACESHIP_RPROMPT_ORDER=()
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
# -------------------------------------------------------------------------  #



# #############################################
#  -------------- BASIC OPTS ---------------- # 
# #############################################
setopt clobber               # noclobber is the dumbest most anoying thing ever
setopt NO_BEEP               # no beep sound
disable r                    # disable zsh's internal r command
# no correct
setopt NO_CORRECT
ENABLE_CORRECTION="false"
unsetopt correct correct_all


# Clear screen only
bindkey -M emacs '^X^G' clear-screen
bindkey -M viins '^X^G' clear-screen
bindkey -M vicmd '^X^G' clear-screen
# -------------------------------------------------------------------------  #


# #############################################
#  -------------- INTERNAL TOOLS ------------ # 
# #############################################
# Requires
# brew install fzf
#
# portable fzf bindings
# Key-bindings
for f in \
  "$HOME/.fzf/shell/key-bindings.zsh" \
  "/usr/share/fzf/key-bindings.zsh" \
  "/usr/local/share/fzf/key-bindings.zsh" \
  "$(command -v brew >/dev/null 2>&1 && brew --prefix)/opt/fzf/shell/key-bindings.zsh"
do [[ -r "$f" ]] && source "$f" && break; done
# -------------------------------------------------------------------------  #


# #############################################
#  -------------- COMPLETION ---------------- # 
# #############################################
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

for f in \
  "$HOME/.fzf/shell/completion.zsh" \
  "/usr/share/fzf/completion.zsh" \
  "/usr/local/share/fzf/completion.zsh" \
  "$(command -v brew >/dev/null 2>&1 && brew --prefix)/opt/fzf/shell/completion.zsh"
do [[ -r "$f" ]] && source "$f" && break; done

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
# -------------------------------------------------------------------------  #


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

# Lets make sure that history is not shared between multiple running shells.
# prevent sharing history between running shells.
unsetopt SHARE_HISTORY
# stop shells from immediately writing commands to the shared file.
unsetopt INC_APPEND_HISTORY
unsetopt INC_APPEND_HISTORY_TIME
# Shell append its history when it exits
setopt APPEND_HISTORY

# search
bindkey '^R' history-incremental-search-backward


# fzf defaults
# fzf UI
export FZF_DEFAULT_OPTS='--height=30% --min-height=10 --layout=reverse --border --info=inline'
export FZF_TMUX_HEIGHT='30%'
export FZF_CTRL_R_OPTS='
  --prompt="history> "
  --preview-window=down,3,wrap,hidden
  --bind=alt-p:toggle-preview,ctrl-/:toggle-preview
'

# -------------------------------------------------------------------------  #

# #############################################
#  -------------- OS SPECIFIC --------------- # 
# #############################################

# OSX Specific
if [[ `uname` == 'Darwin' ]]
then
        export OSX=1
        # iterm2 italic
        if [[ -z "$TMUX" ]]; then export TERM=xterm-256color-italic; fi
        alias ssh="TERM=xterm-256color ssh"
        # HomeBrew analytics, cask, path
        export HOMEBREW_NO_ANALYTICS=1
        export HOMEBREW_CASK_OPTS="--appdir=/Applications"
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
        export PATH="$HOME/apps:$PATH"

else
        export LINUX=
fi
# -------------------------------------------------------------------------  #

# ###############################################
#  -------------- HOST SPECIFIC --------------- # 
# ###############################################

HOST_SHORT="${HOST%%.*}"
: "${HOST_SHORT:=$(hostname -s 2>/dev/null || print $HOST)}"
case "$HOST_SHORT" in
  shinigami)
    ;;
  erstation)
    ;;
esac



# ##############################################
#  -------------- Interpreters --------------- # 
# ##############################################
# node: nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# (optional but nice) load nvm bash completion
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"




# #############################################
#  -------------- ALIAS ---------------- # 
# #############################################
# basic
alias p='pbpaste'
alias c='tr -d '\n' | pbcopy'

# nix  common
alias mkdir="mkdir -p"
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

# Editor aliases
alias v="nvim"
alias n="nvim"
# -------------------------------------------------------------------------  #

# #############################################
#  -------------- Env & Tools --------------- # 
# #############################################
# Language (it's actually required e.g. for some python stuff)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EDITOR='nvim'
export VISUAL='nvim'

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# . "$HOME/.local/bin/env"


# -------------------------------------------------------------------------  #


# #############################################
#  -------------- OMZ LOAD --------------- # 
# #############################################
# -- Load Oh My Zsh
DISABLE_AUTO_TITLE="true"
DISABLE_LS_COLORS="true"
source $ZSH/oh-my-zsh.sh

# fixes for spaceship issues with RPOMPT and double lines in tmux
if [[ -n "$TMUX" ]]; then
  typeset -ga precmd_functions
  precmd_functions=(${(@u)precmd_functions})
  precmd_functions=(${precmd_functions:#omz_termsupport_precmd})
  precmd_functions=(${precmd_functions:#omz_termsupport_cwd})
fi
# --- Kill the first RPROMPT inside tmux (runs once, after spaceship) ---
fix_first_prompt_tmux() {
  [[ -z "$TMUX" ]] && return       # only inside tmux
  RPROMPT='' RPS1=''               # remove right-prompt so zsh doesn't reserve space
  ZLE_RPROMPT_INDENT=0
  unsetopt PROMPT_CR PROMPT_SP
  PROMPT_EOL_MARK=''

  # remove ourselves after the first run
  precmd_functions=(${precmd_functions:#fix_first_prompt_tmux})
}
typeset -ga precmd_functions
precmd_functions+=fix_first_prompt_tmux

# --- force-disable zsh command correction ---
unsetopt correct
unsetopt correct_all

# ---- LS COLORS ---
case "$OSTYPE" in
  linux*)
    unset LS_COLORS
    if command -v dircolors >/dev/null 2>&1; then
      eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
    else
      export LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
    fi
    alias ls='ls --color=auto'
    ;;
esac

# -------------------------------------------------------------------------  #

# Finally, show a fortune when we start the terminal
# fortune
