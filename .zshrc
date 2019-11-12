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
	mix-fast
	osx
	rake
	ruby
	textmate
	tmuxinator
	zeus
)

DEFAULT_USER="$USER"

source $ZSH/oh-my-zsh.sh
source ~/.alias

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

# Recommended by brew doctor
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/munjal/.cargo/bin
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/munjal/.cargo/bin
export RUST_SRC_PATH=/Users/munjal/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/munjal/.cargo/bin:/Users/munjal/.cargo/bin
export RUST_SRC_PATH=/Users/munjal/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src

autoload -Uz compinit && compinit

source ~/.asdf/asdf.sh
source ~/.asdf/completions/asdf.bash


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

fpath+=${ZDOTDIR:-~}/.zsh_functions
