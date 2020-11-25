#!/bin/sh

# Usage: ./install-mac.sh github_name github_gmail

github_name="$1"
github_email="$2"

fancy_echo()
{
    printf "\n\n>> %s\n" "$@"
}

set_hostname()
{
    fancy_echo "Setting hostname"
    sudo scutil --set ComputerName $USER
    sudo scutil --set LocalHostName $USER
    dscacheutil -flushcache
}

enable_services()
{
    fancy_echo "Enabling SSH service"
    sudo  systemsetup -f -setremotelogin on

    fancy_echo "Enabling Screen sharing"
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
        -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers
}

set_hostname
enable_services

config()
{
    /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

fancy_echo "Would you like to configure Mac Defaults: Y/n?"
read mac_defaults
if [[ $mac_defaults = "Y" ]]
then
    #Dock size and layout
    defaults write com.apple.dock tilesize -int 36
    defaults write com.apple.dock magnification -bool true
    defaults write com.apple.dock largesize -int 54
    defaults write com.apple.dock mineffect -string "scale"
    defaults write com.apple.dock minimize-to-application -bool true
    #Display only active applications in Dock
    defaults write com.apple.dock static-only -bool TRUE

    #Enable the Recent Items Menu
    defaults write com.apple.dock persistent-others -array-add '{"tile-data" = {"list-type" = 1;}; "tile-type" = "recents-tile";}'

    #Autohide dock
    defaults write com.apple.dock autohide -bool true

    #Add Dock on the left
    defaults write com.apple.dock orientation -string "left"
    defaults write com.apple.dock pinning -string left

    # Show indicator lights for open applications
    defaults write com.apple.dock show-process-indicators -bool true


    # Bottom left screen corner → Start screen saver
    defaults write com.apple.dock wvous-bl-corner -int 5
    defaults write com.apple.dock wvous-bl-modifier -int 0

    killall Dock

fi


fancy_echo "Installing ohh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]
then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

fancy_echo "Installing Homebrew ..."
if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    config checkout $HOME/.zshrc

    echo >> $HOME/.zshrc
    echo '# Recommended by brew doctor' >> $HOME/.zshrc
    echo 'export PATH="/usr/local/bin:$PATH"' >> $HOME/.zshrc
    echo 'export PATH="/usr/local/sbin:$PATH"'>> $HOME/.zshrc

    export PATH="/usr/local/bin:$PATH"
    export PATH="/usr/local/sbin:$PATH"
fi

if [ ! -f "$HOME/.ssh/id_rsa" ]
then
    fancy_echo "Generating & configuringssh keys"
    ssh-keygen -t rsa -b 4096 -C $github_email -N "" -f $HOME/.ssh/id_rsa
    eval "$(ssh-agent -s)"

    touch $HOME/.ssh/config
    echo "
    Host *
        AddKeysToAgent yes
        UseKeychain yes
        IdentityFile $HOME/.ssh/id_rsa" >> $HOME/.ssh/config

    ssh-add -K $HOME/.ssh/id_rsa

    fancy_echo "Please copy your ssh public keys to github"
    open https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account

fi

fancy_echo "Installing brew bundles..."
brew bundle

if [ ! -f "$HOME/.gnupg/gpg-agent.conf" ]
then
    fancy_echo "Creating gpg-agent conf file"

    touch $HOME/.gnupg/gpg-agent.conf
    echo "pinentry-program /usr/local/bin/pinentry-mac" >> $HOME/.gnupg/gpg-agent.conf

    fancy_echo "Import private key from 1password and save it as `private.asc` in $HOME/.gnupg/"
    fancy_echo "Import private keys using `gpg --import private.asc`"
    fancy_echo "Kill gpg-agent using `killall gpg-agent` and then test `echo "test" | gpg --clearsign`"
fi



fancy_echo "Installing spacemacs"
if [ ! -d "$HOME/.emacs.d" ]
then
    git clone https://github.com/syl20bnr/spacemacs $HOME/.emacs.d
fi

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

fancy_echo "Installing asdf"
if [ ! -d "$HOME/.asdf" ]
then
    git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf
    cd $HOME/.asdf
    git checkout "$(git describe --abbrev=0 --tags)"
fi

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

find_latest_asdf() {
    asdf list-all "$1" | grep -v - | sed -e 's/\([0-9|\.]*\).*/\1/' | sed -e '/^$/ d' |tail -1
}
asdf_plugin_present() {
    $(asdf plugin-list | grep "$1" > /dev/null)
    return $?
}

fancy_echo "Adding asdf plugins"
asdf_plugin_present elixir || asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf_plugin_present erlang || asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git

install_asdf_plugin()
{
    plugin_version=$(find_latest_asdf $1)
    fancy_echo "Installing $1 $plugin_version"
    asdf install $1 $plugin_version
    asdf global $1 $plugin_version
}

fancy_echo "Installing asdf plugins"
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
install_asdf_plugin erlang
install_asdf_plugin elixir

fancy_echo "Installing Visual Studio Code"
if [ ! -d "/Applications/Visual Studio Code.app" ]
then
    curl -Lo /Applications/Visual\ Studio\ Code.zip https://go.microsoft.com/fwlink/?LinkID=620882
    tar -xf /Applications/Visual\ Studio\ Code.zip
fi

fancy_echo "Installing Docker"
if [ ! -d "/Applications/Docker.app" ]
then
    curl -Lo ~/Downloads/Docker.dmg  https://download.docker.com/mac/stable/Docker.dmg
    sudo hdiutil attach ~/Downloads/Docker.dmg
    sudo cp -R "/Volumes/Docker/Docker.app" /Applications
    sudo hdiutil unmount "/Volumes/Docker"
fi

fancy_echo "Installing Google Chat"
if [ ! -d "/Applications/Chat.app" ]
then
    curl -Lo ~/Downloads/InstallHangoutsChat.dmg https://dl.google.com/chat/latest/InstallHangoutsChat.dmg
    sudo hdiutil attach ~/Downloads/InstallHangoutsChat.dmg
    sudo cp -R "/Volumes/Install Hangouts Chat/Chat.app" /Applications
    sudo hdiutil unmount "/Volumes/Install Hangouts Chat"
fi

fancy_echo "Installing Google Drive"
if [ ! -d "/Applications/Google Drive File Stream.app" ]
then
    curl -Lo ~/Downloads/GoogleDriveFileStream.dmg https://dl.google.com/drive-file-stream/GoogleDriveFileStream.dmg
    hdiutil mount ~/Downloads/GoogleDriveFileStream.dmg
    sudo installer -pkg /Volumes/Install\ Google\ Drive\ File\ Stream/GoogleDriveFileStream.pkg -target "/Volumes/Macintosh HD"
    hdiutil unmount /Volumes/Install\ Google\ Drive\ File\ Stream/
fi
