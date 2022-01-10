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