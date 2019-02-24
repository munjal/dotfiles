ZSH=$HOME/.oh-my-zsh

ZSH_THEME="robbyrussell"

plugins=(asdf brew bundler docker docker-compose git git-extras git-flow github elixir mix-fast osx rails rake ruby terminalapp textmate tmuxinator urltool zeus zsh-syntax-highlighting)
DEFAULT_USER="munjal"

source $ZSH/oh-my-zsh.sh
source ~/.alias

# Customize to your needs...
export EDITOR='vim'

export ERL_AFLAGS="-kernel shell_history enabled"

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/sbin

#screen sharing
function pair() {
    COMPUTER_IP=$(dscacheutil -q host -a name $1.local | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
    echo $COMPUTER_IP
    open vnc://$COMPUTER_IP
}

autoload bashcompinit && bashcompinit

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

source <(kubectl completion zsh)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/munjal/sdks/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/munjal/sdks/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/munjal/sdks/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/munjal/sdks/google-cloud-sdk/completion.zsh.inc'; fi
