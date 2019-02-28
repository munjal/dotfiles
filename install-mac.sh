#!/bin/bash

export USERNAME=""
export FULLNAME=""

# ./install-mac.sh -u lala -f "Lala Full Name" -e leoheck@gmail.com -n "Lala Git Name"

show_usage()
{
    printf "\nUsage:\n\t./install-mac.sh [-u username -f \"Full Name\"] [-e github_email -n \"Git Name\"]\n\n\n"
}

parse_command_line()
{
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            -h|--help)
                show_usage
                exit 0
                ;;
            -u|--user)
                USERNAME="$2"
                shift
                shift
                ;;
            -f|--name)
                FULLNAME="$2"
                shift
                shift
                ;;
            -e|--git-email)
                GITHUB_EMAIL="$2"
                shift
                shift
                ;;
            -n|--git-name)
                GITHUB_NAME="$2"
                shift
                shift
                ;;
            *)
                POSITIONAL+=("$1") # save it in an array for later
                shift # past argument
            ;;
        esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters
}

fancy_echo() {
    printf "\n\n>>> %s\n" "$@"
}

show_custom_info()
{
    fancy_echo " Check user data"
    printf "\n"
    printf "    Username: %s\n" "$USERNAME"
    printf "   Full Name: %s\n" "$FULLNAME"
    printf "Github Email: %s\n" "$GITHUB_EMAIL"
    printf " Github Name: %s\n" "$GITHUB_NAME"
    printf "\n"
    read -p "Is this right? (Y/n): " option
    [ -z "${option}" ] && option='Y'
    case $option in
        Y )
            printf "Good, go get a cofeee!\n"
        ;;
        * )
            printf "Exiting, start again!\n"
            exit 0
        ;;
    esac
}

install_xcode_cli_tools()
{
    if ! xcode-select -p > /dev/null; then
        fancy_echo "Install XCode CLI Tools"
        xcode-select --install
    fi
#    sleep 1
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
    fancy_echo "Creating user"
    sysadminctl \
        -addUser $USERNAME \
        -fullName "$FULLNAME" \
        -password $USERNAME \
        -hint "Current username: $USERNAME" \
        -admin interactive
}

# sysadminctl -deleteUser pedro interactive 
# || -adminUser <administrator user name> -adminPassword <administrator password>)

# Usage: sysadminctl
#     -deleteUser <user name> [-secure || -keepHome] (interactive || -adminUser <administrator user name> -adminPassword <administrator password>)
#     -newPassword <new password> -oldPassword <old password> [-passwordHint <password hint>]
#     -resetPasswordFor <local user name> -newPassword <new password> [-passwordHint <password hint>] (interactive] || -adminUser <administrator user name> -adminPassword <administrator password>)
#     -addUser <user name> [-fullName <full name>] [-UID <user ID>] [-shell <path to shell>] [-password <user password>] [-hint <user hint>] [-home <full path to home>] [-admin] [-picture <full path to user image>] (interactive] || 
#     -adminUser <administrator user name> -adminPassword <administrator password>)
#     -secureTokenStatus <user name>
#     -secureTokenOn <user name> -password <password> (interactive || -adminUser <administrator user name> -adminPassword <administrator password>)
#     -secureTokenOff <user name> -password <password> (interactive || -adminUser <administrator user name> -adminPassword <administrator password>)
#     -guestAccount <on || off || status>
#     -afpGuestAccess <on || off || status>
#     -smbGuestAccess <on || off || status>
#     -automaticTime <on || off || status>
#     -filesystem status
#     -screenLock <immediate || off> -password <password>

# sudo sysadminctl -secureTokenOn admin_account -password $USERNAME
# sudo sysadminctl -deleteUser pedro -password pedro
# sudo fdesetup remove -user pedro

enable_ssh()
{
    fancy_echo "Enabling SSH service"
    sudo  systemsetup -f -setremotelogin on
}

set_hostname()
{
    fancy_echo "Setting hostname"
    sudo scutil --set ComputerName $username
    dscacheutil -flushcache
}

change_user()
{
    fancy_echo "Changing user"
    sudo su $username
    cd ~/
}

install_oh_my_zsh()
{
    fancy_echo "Installing oh-my-zsh"
    if [ ! -d "$HOME/.oh-my-zsh" ]
    then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi
}

# fancy_git()
# {
#     /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
# }

# install_homebrew()
# {
#     fancy_echo "Installing Homebrew ..."
#     if ! command -v brew >/dev/null; then
#         curl -fsS \
#             'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

#         fancy_git checkout -- $HOME/.zshrc

#         echo | tee -a ~/.zshrc
#         echo '# Recommended by brew doctor' | tee -a ~/.zshrc
#         echo 'export PATH="/usr/local/bin:$PATH"' | tee -a ~/.zshrc
#         echo 'export PATH="/usr/local/sbin:$PATH"' | tee -a ~/.zshrc

#         export PATH="/usr/local/bin:$PATH"
#         export PATH="/usr/local/sbin:$PATH"
#     fi
# }

# configure_ssh_keys_with_git()
# {
#     if [ ! -f "$HOME/.ssh/id_rsa" ]
#     then
#         fancy_echo "Installing git keys"
#         fancy_echo "Writing to $HOME/.gitconfig"

#         /bin/cat > $HOME/.gitconfig <<-EOM
#         [user]
#             name = $GITHUB_NAME
#             email = $GITHUB_EMAIL
#         EOM

#         fancy_echo "Generating & configuring ssh keys"
#         ssh-keygen -t rsa -b 4096 -C $github_email -N "" -f $HOME/.ssh/id_rsa
#         eval "$(ssh-agent -s)"

#         /bin/cat > $HOME/.ssh/config <<-EOM
#         Host *
#             AddKeysToAgent yes
#             UseKeychain yes
#             IdentityFile $HOME/.ssh/id_rsa" >> $HOME/.ssh/config
#         EOM

#         ssh-add -K $HOME/.ssh/id_rsa

#         echo "echo \"Please copy your ssh public keys to github\"" | | tee ~/.adding-a-new-ssh-key-to-your-github-account
#         echo 'open https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account' | tee -a ~/.adding-a-new-ssh-key-to-your-github-account

#         echo | tee -a ~/.zshrc
#         echo '. ~/.adding-a-new-ssh-key-to-your-github-account' | tee -a ~/.zshrc

#     fi
# }

# install_homebrew_brundles()
# {
#     fancy_echo "Installing brew bundles..."
#     brew bundle
# }

# install_spacemacs()
# {
#     fancy_echo "Installing spacemacs"
#     if [ ! -d "$HOME/.emacs.d" ]
#     then
#         git clone https://github.com/syl20bnr/spacemacs $HOME/.emacs.d
#     fi
# }

# install_asdf_version_manager()
# {
#     fancy_echo "Installing asdf version manager"
#     if [ ! -d "$HOME/.asdf" ]
#     then
#         git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf
#         cd $HOME/.asdf
#         git checkout "$(git describe --abbrev=0 --tags)"
#     fi

#     . $HOME/.asdf/asdf.sh
#     . $HOME/.asdf/completions/asdf.bash
# }

# find_latest_asdf()
# {
#     asdf list-all "$1" | grep -v - | tail -1 | sed -e 's/^ *//'
# }

# asdf_plugin_present()
# {
#     $(asdf plugin-list | grep "$1" > /dev/null)
#     return $?
# }

# install_asdf_version_plugins()
# {
#     fancy_echo "Adding asdf plugins"
#     asdf_plugin_present elixir || asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
#     asdf_plugin_present erlang || asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
#     asdf_plugin_present nodejs || asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
# }

# install_asdf_plugins()
# {
#     plugin_version=$(find_latest_asdf $1)
#     fancy_echo "Installing $1 $plugin_version"
#     asdf install $1 $plugin_version
#     asdf global $1 $plugin_version

#     fancy_echo "Installing asdf plugins"
#     export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
#     install_asdf_plugin erlang
#     install_asdf_plugin elixir
# }

# install_visual_studio_code()
# {
#     fancy_echo "Installing Visual Studio Code"
#     if [ ! -d "/Applications/Visual Studio Code.app" ]
#     then
#         curl -Lo /Applications/Visual\ Studio\ Code.zip https://update.code.visualstudio.com/1.31.1/darwin/stable
#         tar -xf /Applications/Visual\ Studio\ Code.zip
#     fi
# }

# install_docker()
# {
#     fancy_echo "Installing Docker"
#     if [ ! -d "/Applications/Docker.app" ]
#     then
#         curl -o ~/Downloads/Docker.dmg  https://download.docker.com/mac/stable/Docker.dmg
#         open Downloads/Docker.dmg
#     fi
# }

# install_google_chat()
# {
#     fancy_echo "Installing Google Chat"
#     if [ ! -d "/Applications/Chat.app" ]
#     then
#         curl -o ~/Downloads/InstallHangoutsChat.dmg https://dl.google.com/chat/latest/InstallHangoutsChat.dmg
#         open Downloads/InstallHangoutsChat.dmg
#     fi
# }


parse_command_line "$@"

show_custom_info

install_xcode_cli_tools
create_user
enable_ssh
set_hostname


# install_homebrew
# install_homebrew_brundles

# configure_ssh_keys_with_git

# install_spacemacs

# install_asdf_version_manager
# install_asdf_plugins

# install_visual_studio_code
# install_docker
# install_google_chat
