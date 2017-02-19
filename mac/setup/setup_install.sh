#!/usr/bin/env bash

echo "Make sure to copy ssh and gnupg keys and call ssh-add"
echo "Better to signin and dowload something on the MAS before"

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Setup username
echo -n "Enter hostname > "
read chostname
echo "You entered: $chostname"
sudo scutil --set HostName $chostname

# Install all available updates
sudo softwareupdate -iva

# Ensure XCode
xcode-select --install

# install apps
export HOMEBREW_NO_ANALYTICS=1
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap Homebrew/bundle
brew tap caskroom/cask
brew tap caskroom/versions
brew update
brew install mas
mas signin me@luisrei.com
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew bundle
brew cleanup
export PATH="/usr/local/sbin:$PATH"

# Re-ensure Xcode commandline tools are ok (in case of some MAS XCode issue)
xcode-select --install

# Install OMZ/Switch to zsh, remove stupid oh-my-zsh default rc
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s /usr/local/bin/zsh
rm ~/.zshrc

# dotfiles
STOWDIRS=(
code
git
gnupg
mutt
tmux
zsh
)

cd
git clone git@github.com:lrei/dotfiles.git
cd ~/dotfiles
for item in ${STOWDIRS[*]}
do
	stow $item
done
if [ -d "~/dotfiles/$chostname" ]; then
	echo "Found host-specific dotfiles"
else
	echo "No host-specific dotfiles found"
fi
cd

# Network stuff
pip install SpoofMAC
# Copy file to the OS X launchd folder
sudo cp "~/dotfiles/hosts/local.macspoof.plist" /Library/LaunchDaemons
cd /Library/LaunchDaemons
sudo chown root:wheel local.macspoof.plist
sudo chmod 0644 local.macspoof.plist
cd

# hosts file and privoxy
sudo cat ~/dotfiles/hosts/hosts > /etc/hosts

brew services start privoxy
sudo networksetup -setwebproxy "Wi-Fi" 127.0.0.1 8118
sudo networksetup -setsecurewebproxy "Wi-Fi" 127.0.0.1 8118

# vimfiles, plugins
git clone git@github.com:lrei/vimfiles.git ~/.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
cd ~/.vim/bundle/YouCompleteMe
python install.py
cd ~

# install languages
# ruby: rbenv
eval "$(rbenv init -)"
ruby_latest=$(rbenv install -l 2>/dev/null | awk '$1 ~ /^[0-9.]*$/ {latest=$1} END {print latest}')
rbenv install $ruby_latest
rbenv global $ruby_latest
rbenv rehash

# node: nvm
export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"
nvm install node
npm install -g vtop
npm install -g standard
npm install -g markdownlint
npm install spoof -g

# python: pyenv
eval "$(pyenv init -)"
export PATH="~/.pyenv/shims:$PATH"
PYTHON2_VERSION="$(pyenv install -l | grep -e '2.[0-9].[0-9]' | grep -v - | tail -1)"
PYTHON3_VERSION="$(pyenv install -l | grep -e '3.[0-9].[0-9]' | grep -v - | tail -1)"
export PYTHON_CONFIGURE_OPTS="--enable-framework"
pyenv install $PYTHON2_VERSION
pyenv install $PYTHON3_VERSION
pyenv rehash
pyenv global $PYTHON3_VERSION $PYTHON2_VERSION
pip install virtualenvwrapper


# italic and colors in terminal
tic ~/dotfiles/iterm2/xterm-256color-italic.terminfo

# tmux tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

