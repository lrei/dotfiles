# This is a draft i.e. "alpha version"

# dotfiles and stow
sudo apt-get install stow
git clone git@github.com:lrei/dotfiles.git
stow dotfiles/code dotfiles/git dotfiles/gnupg dotfiles/tmux dotfiles/zsh

# zsh
sudo apt-get install zsh fortune
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# NVM and Node
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install node
nvm use node
npm install -g typescript
npm install -g vtop
npm install -g standard
npm install -g markdownlint

# pyenv
sudo apt-get install -y  make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev bzip2 libbz2-dev sqlite3 libsqlite3-dev libreadline7
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
PYTHON2_VERSION="$(pyenv install -l | grep -e '2.[0-9].[0-9]' | grep -v - | tail -1 |xargs)"
PYTHON3_VERSION="$(pyenv install -l | grep -e '3.[0-9].[0-9]' | grep -v - | tail -1 | xargs)"
export PYTHON_CONFIGURE_OPTS="--enable-shared"
pyenv install $PYTHON2_VERSION
pyenv install $PYTHON3_VERSION
pyenv rehash
pyenv global $PYTHON3_VERSION $PYTHON2_VERSION

# rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
$HOME/.rbenv/bin/rbenv init
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
ruby_latest=$(rbenv install -l 2>/dev/null | awk '$1 ~ /^[0-9.]*$/ {latest=$1} END {print latest}')
rbenv install $ruby_latest
rbenv global $ruby_latest
rbenv rehash

# golang
sudo apt-get install golang

# vim
sudo apt-get install -y build-essential cmake python-dev python3-dev vim-gtk \
    xclip gnome-terminal sakura
git clone git@github.com:lrei/vimfiles.git ~/.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
cd ~/.vim/bundle/YouCompleteMe
python install.py --clang-completer --tern-completer
cd ~

# tmux tpm
sudo apt-get install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# python stuff
sudo apt-get install -y libcupti-dev
pip install numpy scipy scikit-learn pandas tensorflow-gpu ipython \
    powerline-status
