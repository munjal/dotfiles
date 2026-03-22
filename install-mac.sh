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

fancy_echo "Opening App Store to accept agreement"
open https://apps.apple.com/us/app/xcode/id497799835?mt=12

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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    config checkout $HOME/.zshrc
    #config checkout $HOME/.zprofile >> No zprofile exists yet in git dotfiles

    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

fancy_echo "Installing brew bundles..."
brew bundle

fancy_echo "Generating & configuring ssh keys"
gh auth login -s write:gpg_key,repo

# GPG Setup (traditional method - keep for GPG signing if preferred)
if [ ! -f "$HOME/.gnupg/gpg-agent.conf" ]
then
    fancy_echo "Creating gpg-agent conf file"

    touch $HOME/.gnupg/gpg-agent.conf
    pinentry_path=$(brew --prefix)
    echo "pinentry-program $pinentry_path/bin/pinentry-mac" >> $HOME/.gnupg/gpg-agent.conf

    fancy_echo "Kill gpg-agent using: killall gpg-agent"
    fancy_echo "Import private key from 1password and save it as private.asc in $HOME/.gnupg/"
    fancy_echo "Import private keys using: gpg --import private.asc"
    fancy_echo "test: echo "test" | gpg --clearsign"
fi

# 1Password SSH Agent Setup (modern alternative to GPG)
fancy_echo "Setting up 1Password SSH Agent..."
fancy_echo "To use 1Password for SSH and Git signing:"
fancy_echo "1. Enable SSH Agent in 1Password Settings > Developer"
fancy_echo "2. Add your SSH keys to 1Password"
fancy_echo "3. Uncomment SSH_AUTH_SOCK in ~/.zshenv"
fancy_echo "4. Configure ~/.ssh/config with:"
cat << 'EOF'

Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

EOF

# Create SSH config if it doesn't exist
if [ ! -f "$HOME/.ssh/config" ]
then
    mkdir -p $HOME/.ssh
    cat << 'EOF' > $HOME/.ssh/config
# Uncomment below to use 1Password SSH Agent
# Host *
#     IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
    chmod 600 $HOME/.ssh/config
fi

# Oh-My-Zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Ghostty terminal configuration
fancy_echo "Setting up Ghostty terminal configuration..."
mkdir -p $HOME/.config/ghostty
if [ ! -f "$HOME/.config/ghostty/config" ]
then
    cat << 'EOF' > $HOME/.config/ghostty/config
font-family = JetBrains Mono
font-size = 14
theme = catppuccin-mocha
window-padding-x = 12
window-padding-y = 8
cursor-style = block
shell-integration = zsh
confirm-close-surface = false
macos-option-as-alt = true
EOF
    fancy_echo "Created Ghostty config at ~/.config/ghostty/config"
fi

# mise - runtime version manager (replaces asdf)
fancy_echo "Setting up mise..."

# mise reads existing .tool-versions files, so migration is seamless
# If you have a global .tool-versions, mise will use it automatically

find_latest_mise() {
    mise ls-remote "$1" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1
}

install_mise_tool() {
    tool_version=$(find_latest_mise "$1")
    fancy_echo "Installing $1 $tool_version"
    mise install "$1@$tool_version"
    mise use -g "$1@$tool_version"
}

ulimit -n 4096

fancy_echo "Installing runtimes with mise..."
export KERL_CONFIGURE_OPTIONS="--without-javac --with-ssl=$(brew --prefix openssl@3)"
install_mise_tool erlang
install_mise_tool elixir
install_mise_tool ruby
install_mise_tool node

fancy_echo "Setting up fzf keybindings..."
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish

fancy_echo "Installing Claude Code CLI..."
mise exec node -- npm install -g @anthropic-ai/claude-code

fancy_echo "Setup complete! Restart your terminal or run: source ~/.zshrc"
