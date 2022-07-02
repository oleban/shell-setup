#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR

# Update and upgrade and install homebrew dependencies
sudo apt update
sudo apt upgrade -y

# install z shell
sudo apt-get install -y zsh
chsh -s /usr/bin/zsh

# install dependencies
sudo apt install -y build-essential whiptail xclip curl dirmngr file gawk git gpg libbz2-dev libffi-dev liblzma-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libxmlsec1-dev llvm make procps tk-dev wget xz-utils zlib1g-dev

# unlink previous dotfiles
mv ~/.profile ~/.profile.old
mv ~/.zshrc ~/.zshrc.old

# Link dotfiles
ln -sf $SCRIPT_DIR/dotfiles/.* ~/

# Setup git global config
git config --global core.excludesfile ~/.gitignore_global

# Setup ssh file
mkdir -p "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/config" ] ; then
    touch "$HOME/.ssh/config"
fi

SSH_KEY_FILE="nopass_ed25519"
SSH_KEY_FILE_PATH="$HOME/.ssh/$SSH_KEY_FILE"

if [ ! -f "$SSH_KEY_FILE_PATH" ] ; then
    ssh-keygen -t ed25519 -f "$SSH_KEY_FILE_PATH" -q -N ""
fi

# Install homebrew
if [ ! -d /home/linuxbrew/.linuxbrew ] && [ ! -d ~/.linuxbrew ] ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install from Brewfile
if [ -f "$SCRIPT_DIR/Brewfile" ] ; then
    brew bundle --file "$SCRIPT_DIR/Brewfile"
fi

# ASDF
. $(brew --prefix asdf)/libexec/asdf.sh

# Adds all plugins from .tool-versions
cat ~/.tool-versions | cut -d' ' -f1 | grep "^[^\#]" | xargs -i asdf plugin add  {}
# Installs plugins
asdf install
#echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ~/.profile
#asdf plugin-add direnv
asdf direnv setup --shell zsh --version latest
#eval "$(asdf exec direnv hook zsh)"
