#!/bin/sh

# Usage: ./install-mac.sh [-u username -f "Full Name"] [-g git_email]

export username=
export userfullname=

parse_command_line()
{
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            -u|--user)
                USERNAME="$2"
                shift # past argument
                shift # past value
                ;;
            -n|--name)
                FULLNAME="$2"
                shift # past argument
                shift # past value
                ;;
            -g|--git-email)
                LIBPATH="$2"
                shift # past argument
                shift # past value
                ;;
            *)
                POSITIONAL+=("$1") # save it in an array for later
                shift # past argument
            ;;
        esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters
}

install_xcode_cli_tools()
{
    xcode-select --install
    sleep 1
#     osascript << EOD
#       tell application "System Events"
#         tell process "Install Command Line Developer Tools"
#           keystroke return
#           click button "Agree" of window "License Agreement"
#         end tell
#       end tell
#     EOD
}

create_user()
{
    sudo sysadminctl \
        -addUser "$username" \
        -fullName "$userfullname" \
        -password "$username" \
        -hint "$username" \
        -admin
}

enable_ssh()
{
    sudo  systemsetup -f -setremotelogin on
}

set_hostname()
{
    sudo scutil --set ComputerName $username
    dscacheutil -flushcache
}

change_user()
{
    sudo su $username
    cd ~/
}

fancy_echo() {
    printf "\n\n>>> %s\n" "$@"
}

fancy_git()
{
    /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

fancy_echo "Installing oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]
then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

fancy_echo "Installing Homebrew ..."
if ! command -v brew >/dev/null; then
    curl -fsS \
        'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    change this... not working
    fancy_git checkout $HOME/.zshrc

    append_to_zshrc '# recommended by brew doctor'

    append_to_zshrc 'export PATH="/usr/local/bin:$PATH"' 1
    append_to_zshrc 'export PATH="/usr/local/sbin:$PATH"' 1

    export PATH="/usr/local/bin:$PATH"
fi

if [ ! -f "$HOME/.ssh/id_rsa" ]
then
    fancy_echo "Installing git keys"
    fancy_echo "What name would you want in your Git commit messages?"
    read github_name
    fancy_echo "What's your email address associated with Github?"
    read github_email

    fancy_echo "Writing to $HOME/.gitconfig"
    echo "
    [user]
        name = $github_name
        email = $github_email
    " >> $HOME/.gitconfig

    fancy_echo "Generating & configuringssh keys"
    ssh-keygen -t rsa -b 4096 -C $github_email -N "" -f $HOME/.ssh/id_rsa
    eval "$(ssh-agent -s)"

    touch $HOME/.ssh/config
    echo "Host *
        AddKeysToAgent yes
        UseKeychain yes
        IdentityFile $HOME/.ssh/id_rsa" >> $HOME/.ssh/config

    ssh-add -K $HOME/.ssh/id_rsa

    fancy_echo "Please copy your ssh public keys to github"
    open https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account
fi

fancy_echo "Installing brew bundles..."
brew bundle

fancy_echo "Installing spacemacs"
if [ ! -d "$HOME/.emacs.d" ]
then
    git clone https://github.com/syl20bnr/spacemacs $HOME/.emacs.d
fi

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
  asdf list-all "$1" | grep -v - | tail -1 | sed -e 's/^ *//'
}

asdf_plugin_present() {
  $(asdf plugin-list | grep "$1" > /dev/null)
  return $?
}

fancy_echo "Adding asdf plugins"
asdf_plugin_present elixir || asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf_plugin_present erlang || asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf_plugin_present nodejs || asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git

install_asdf_plugin() {
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
    curl -Lo /Applications/Visual\ Studio\ Code.zip https://update.code.visualstudio.com/1.31.1/darwin/stable
    tar -xf /Applications/Visual\ Studio\ Code.zip
fi

fancy_echo "Installing Docker"
if [ ! -d "/Applications/Docker.app" ]
then
    curl -o ~/Downloads/Docker.dmg  https://download.docker.com/mac/stable/Docker.dmg
    open Downloads/Docker.dmg
fi

fancy_echo "Installing Google Chat"
if [ ! -d "/Applications/Chat.app" ]
then
    curl -o ~/Downloads/InstallHangoutsChat.dmg https://dl.google.com/chat/latest/InstallHangoutsChat.dmg
    open Downloads/InstallHangoutsChat.dmg
fi



parse_command_line "$@"
install_xcode_cli_tools
create_user
enable_ssh
set_hostname
change_user
