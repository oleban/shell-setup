#!/bin/bash

# Update and upgrade and install homebrew dependencies
sudo apt update && sudo apt upgrade -y && sudo apt install whiptail build-essential -y
# Set up private passwordless key
mkdir -p "$HOME/.ssh"
touch "$HOME/.ssh/config"

SSH_KEY_FILE="nopass_ed25519"
ssh-keygen -t ed25519 -f "$HOME/.ssh/$SSH_KEY_FILE" -q -N ""

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


# Set up config from git or local config folder
mkdir -p "$HOME/.config/shell-config"

REPO=$(whiptail --inputbox "Type in github config repo" USER/REPO 8 39 --title "Example Dialog" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Host github.com" >> "$HOME/.ssh/config" 
    echo "  IdentityFile ~/.ssh/$SSH_KEY_FILE" >> "$HOME/.ssh/config" 
    echo "  IdentitiesOnly yes" >> "$HOME/.ssh/config" 
    echo "" >> "$HOME/.ssh/config" 

    brew install gh
    gh auth login
    gh ssh-key add "$HOME/.ssh/$SSH_KEY_FILE.pub"
    gh repo clone $REPO "$HOME/.config/shell-config"
else
    mkdir -p "$HOME/.config/shell-config"
fi

# Install from Brewfile
if [ -d "$HOME/.config/shell-config/Brewfile" ] ; then
    brew bundle install "$HOME/.config/shell-config/Brewfile"
fi