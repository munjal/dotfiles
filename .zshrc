ZSH=$HOME/.oh-my-zsh

ZSH_THEME="robbyrussell"
# ZSH_THEME="agnoster"

plugins=(
	asdf
	brew
	bundler
	docker
	docker-compose
	git
	git-extras
	git-flow
	github
	elixir
	mix-fast
	osx
	rake
	ruby
	terminalapp
	textmate
	tmuxinator
	urltool
	zeus
	zsh-syntax-highlighting)

DEFAULT_USER="$USER"

source $ZSH/oh-my-zsh.sh
source ~/.alias

autoload bashcompinit && bashcompinit

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

source <(kubectl completion zsh)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/munjal/sdks/google-cloud-sdk/path.zsh.inc' ]; then
	source '/Users/munjal/sdks/google-cloud-sdk/path.zsh.inc';
fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/munjal/sdks/google-cloud-sdk/completion.zsh.inc' ]; then
	source '/Users/munjal/sdks/google-cloud-sdk/completion.zsh.inc';
fi

# Pair with hostname or ip
pair()
{
	ip_or_hostname=$1
	if grep "^[a-zA-Z]" <<(echo $ip_or_hostname) > /dev/null; then
		ip_or_hostname=${ip_or_hostname}.lan
	fi
	open vnc://$ip_or_hostname
}
