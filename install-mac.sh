#!/bin/sh

fancy_echo() {
  local fmt="$1"; shift

  printf "\n$fmt\n" "$@"
}

fancy_echo "Installing ohh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

if ! command -v brew >/dev/null; then
  fancy_echo "Installing Homebrew ..."
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    config checkout ~/.zshrc

    append_to_zshrc '# recommended by brew doctor'

    append_to_zshrc 'export PATH="/usr/local/bin:$PATH"' 1
    append_to_zshrc 'export PATH="/usr/local/sbin:$PATH"' 1

    export PATH="/usr/local/bin:$PATH"
fi

if [-d ~/.ssh/id_rsa]
then
  fancy_echo "Installing git keys"
  fancy_echo "What name would you want in your Git commit messages?"
  read github_name
  fancy_echo "What's your email address associated with Github?"
  read github_email

  fancy_echo "Writing to ~/.gitconfig"
  echo "
  [user]
          name = $github_name
          email = $github_email
     " >> ~/.gitconfig


  fancy_echo "Generating & configuringssh keys"
  ssh-keygen -t rsa -b 4096 -C $github_email -N "" -f ~/.ssh/id_rsa
  eval "$(ssh-agent -s)"

  touch ~/.ssh/config
  echo "Host *
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config

  ssh-add -K ~/.ssh/id_rsa

  fancy_echo "Please copy your ssh public keys to github"
  open https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account
fi

fancy_echo "Installing brew bundles..."
brew bundle

fancy_echo "Installing asdf"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"

. $HOME/.zshrc

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
install_asdf_plugin erlang
install_asdf_plugin elixir

curl -Lo /Applications/Visual\ Studio\ Code.zip https://update.code.visualstudio.com/1.31.1/darwin/stable
tar -xf /Applications/Visual\ Studio\ Code.zip

