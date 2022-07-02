#!/bin/bash

# Update and upgrade and install homebrew dependencies
sudo apt update && sudo apt upgrade -y && sudo apt install whiptail build-essential -y
# Set up private passwordless key
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


# Set up config from git or local config folder
# 
if [ ! -d "$HOME/.config/shell-config" ] ; then
    REPO=$(whiptail --inputbox "Type in github config repo" 8 39 "USER/REPO" --title "Clone your config repo" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then

        brew install gh
        gh auth login

        echo "Host github.com" >> "$HOME/.ssh/config" 
        echo "  IdentityFile ~/.ssh/$SSH_KEY_FILE" >> "$HOME/.ssh/config" 
        echo "  IdentitiesOnly yes" >> "$HOME/.ssh/config" 
        echo "" >> "$HOME/.ssh/config" 
        gh ssh-key add "$SSH_KEY_FILE_PATH.pub"
        
        gh repo clone $REPO "$HOME/.config/shell-config"
    else
        mkdir -p "$HOME/.config/shell-config"
    fi
fi

# Install from Brewfile
if [ -f "$HOME/.config/shell-config/Brewfile" ] ; then
    brew bundle install "$HOME/.config/shell-config/Brewfile"
fi
