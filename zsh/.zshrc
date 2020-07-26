# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Customizations
ZSH_CUSTOM=$HOME/.zshcustom

# noclobber is the dumbest most anoying thing ever
setopt clobber

# Theme
ZSH_THEME="bullet-train"
# - Spaceship
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false

# - BULLETTRAIN - #
BULLETTRAIN_PROMPT_SEPARATE_LINE=true
BULLETTRAIN_PROMPT_ADD_NEWLIN=false
BULLETTRAIN_TIME_SHOW=false             # shown in tmux theme
# User / host
BULLETTRAIN_CONTEXT_SHOW=true
BULLETTRAIN_CONTEXT_BG=white
BULLETTRAIN_CONTEXT_FG=black
# DIR
BULLETTRAIN_DIR_BG=white
BULLETTRAIN_DIR_FG=black
BULLETTRAIN_DIR_SHOW=true
BULLETTRAIN_DIR_EXTENDED=2
# NVM
BULLETTRAIN_NVM_SHOW=true
BULLETTRAIN_NVM_BG=yellow
BULLETTRAIN_NVM_FG=black
# BULLETTRAIN_NVM_PREFIX="⬡ "
# RUBY
BULLETTRAIN_RUBY_SHOW=false
# PYTHON
BULLETTRAIN_VIRTUALENV_BG=green
BULLETTRAIN_VIRTUALENV_FG=black
BULLETTRAIN_VIRTUALENV_SHOW=true
# --------------------------------

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=12

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

HIST_STAMPS="yyyy-mm-dd"

plugins=(git lein npm osx vi-mode zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# VI MODE
function zle-line-init zle-keymap-select {
    BULLETTRAIN_CUSTOM_MSG="${${KEYMAP/vicmd/[N]}/(main|viins)/[I]}"
    zle reset-prompt
    zle -R
}
zle -N zle-line-init
zle -N zle-keymap-select


# Language (it's actually required e.g. for some python stuff)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EDITOR='nvim'

# if necessary, ensure terminal colors
export TERM="xterm-256color"

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
        # for pyenv
        #export PYTHON_CONFIGURE_OPTS="--enable-framework"
else
        export OSX=
fi

# Linux Specific
if [[ `uname` == 'Linux' ]]
then
        export LINUX=1
        # ssh agent
        eval "$(ssh-agent -s)"
        # copy / paste
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
	# apps
        export PATH="$HOME/apps:$PATH"

else
        export LINUX=
fi

# Languages, libs
#
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYTHON_CONFIGURE_OPTS="--enable-shared"
eval "$(pyenv init -)"
# ruby: rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
# node: nvm
export NVM_DIR="$HOME/.nvm"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Finally, show a fortune when we start the terminal
fortune


# ALIAS
# tmux in 24bit color
alias tmux="env TERM=xterm-256color tmux"
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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
