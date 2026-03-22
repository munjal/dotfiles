ZSH_DISABLE_COMPFIX=true
ZSH=$HOME/.oh-my-zsh

ZSH_THEME="robbyrussell"
# ZSH_THEME="agnoster"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

plugins=(
	brew
	bundler
	docker
	docker-compose
	git
	git-extras
	git-flow
	github
	macos
	tmuxinator
	zsh-autosuggestions
	zsh-syntax-highlighting
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

# mise - runtime version manager (replaces asdf)
eval "$(mise activate zsh)"

# zoxide - smarter cd
eval "$(zoxide init zsh)"

# fzf - fuzzy finder
source <(fzf --zsh)

# atuin - shell history
eval "$(atuin init zsh)"

# starship prompt (must be last)
eval "$(starship init zsh)"
