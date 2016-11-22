# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Customizations
ZSH_CUSTOM=$HOME/.zshcustom

# Theme
ZSH_THEME="bullet-train"
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
BULLETTRAIN_PROMPT_SEPARATE_LINE=false
BULLETTRAIN_PROMPT_ADD_NEWLIN=false
BULLETTRAIN_TIME_SHOW=false
BULLETTRAIN_CONTEXT_SHOW=true
BULLETTRAIN_DIR_SHOW=false  # already shown in tmux theme

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

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

plugins=(git brew lein npm osx pip virtualenvwrapper)

source $ZSH/oh-my-zsh.sh

# Language (it's actually required e.g. for some python stuff)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# GPG agent
if [ -f ~/.gnupg/.gpg-agent-info ] && [ -n "$(pgrep gpg-agent)" ]; then
    source ~/.gnupg/.gpg-agent-info
    export GPG_AGENT_INFO
else
    eval $(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# if necessary, ensure terminal colors
# export TERM="xterm-256color"

# OSX Specific
if [[ `uname` == 'Darwin' ]]
then
        export OSX=1
        # z
        . `brew --prefix`/etc/profile.d/z.sh
        alias o='open'
else
        export OSX=
fi

# Linux Specific
if [[ `uname` == 'Linux' ]]
then
        export LINUX=1
else
        export LINUX=
fi


# Machine Specific Configurations
if [[ -a $HOME/.zshrc_resolution ]]
then
    source $HOME/.zshrc_resolution
fi


# ALIAS
alias s='git s'
alias p='pbpaste'
alias c='tr -d '\n' | pbcopy'
alias myip="ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print \$2}'"
alias ll='ls -la'

# Download file and save it with filename of remote file
alias get="curl -O -L"
