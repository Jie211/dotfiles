# if zplug is not installed, automatically clone it and reload shell
if [[ ! -d ~/.zplug ]]; then
  echo "zplug is not installed in this machine."
  echo "Installing zplug..."
  echo ""
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi

if [[ ! -d ~/.tmux/plugins/tpm  ]]; then
  echo "TPM is not installed in this machine."
  echo "Installing TPM///"
  echo ""
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

source ~/.zplug/init.zsh

# Triaging
zplug 'zsh-users/zsh-history-substring-search'
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
zplug 'zsh-users/zsh-completions'
zplug 'supercrabtree/k'

# highlighting
zplug "zsh-users/zsh-syntax-highlighting", nice:10

# histuniq color
zplug "Jxck/dotfiles", as:command, use:"bin/{histuniq,color}"

# git-calender frozen:1 -> no upgrade
zplug "k4rthik/git-cal", as:command, frozen:1

# fzf from:gh-r -> GithubReleases use:* -> OS delect
zplug "junegunn/fzf-bin", \
  from:gh-r, \
  as:command, \
  rename-to:fzf, \
  use:"*darwin*amd64*"

# git plug
zplug "plugins/git", from:oh-my-zsh

# Load if "if" tag returns true
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

# dependencies
zplug "stedolan/jq", \
  from:gh-r, \
  as:command, \
  rename-to:jq
zplug "b4b4r07/emoji-cli", \
  on:"stedolan/jq"

zplug "mollifier/anyframe"

zplug "b4b4r07/enhancd", use:init.sh

zplug "b4b4r07/zsh-gomi", as:command, use:bin/gomi, if:"which fzf"

zplug "mrowa44/emojify", as:command

zplug "plugins/colored-man-pages", from:oh-my-zsh

###############
# theme
###############

setopt prompt_subst
zplug "adambiggs/zsh-theme", use:adambiggs.zsh-theme
zplug "caiogondim/bullet-train-oh-my-zsh-theme"

BULLETTRAIN_PROMPT_ORDER=(
  time
  status
  context
  dir
  git
  hg
  cmd_exec_time
)
BULLETTRAIN_STATUS_SHOW=true
BULLETTRAIN_STATUS_EXIT_SHOW=true
BULLETTRAIN_TIME_12HR=false
BULLETTRAIN_DIR_EXTENDED=0
BULLETTRAIN_EXEC_TIME_SHOW=true

################
# config
################

# anyfame
zstyle ":anyframe:selector:" use fzf
zstyle ":anyframe:selector:fzf:" command 'fzf --extended'
bindkey '^xe' anyframe-widget-execute-history
bindkey '^xr' anyframe-widget-put-history
bindkey '^xk' anyframe-widget-kill
bindkey '^xt' anyframe-widget-tmux-attach

# completiong
zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# ls color
if ls --color > /dev/null 2>&1; then # GNU `ls`
  colorflag="--color"
else # OS X `ls`
  colorflag="-G"
fi

autoload -U compinit && compinit

# Add <TAB> completion handlers for fzf *after* fzf is loaded
_fzf_complete_z() {
  _fzf_complete '--multi --reverse' "$@" < <(raw_z)
}

################
# zplug
################

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  zplug install
fi



###############
# function
###############
function myip {
  ifconfig lo0 | grep 'inet ' | sed -e 's/:/ /' | awk '{print "lo0 : " $2}'
  ifconfig en0 | grep 'inet ' | sed -e 's/:/ /' | awk '{print "en0 (IPv4): " $2 " " $3 " " $4 " " $5 " " $6}'
  ifconfig en0 | grep 'inet6 ' | sed -e 's/ / /' | awk '{print "en0 (IPv6): " $2 " " $3 " " $4 " " $5 " " $6}'
  ifconfig en1 | grep 'inet ' | sed -e 's/:/ /' | awk '{print "en1 (IPv4): " $2 " " $3 " " $4 " " $5 " " $6}'
  ifconfig en1 | grep 'inet6 ' | sed -e 's/ / /' | awk '{print "en1 (IPv6): " $2 " " $3 " " $4 " " $5 " " $6}'
}

function update_zplug {
  echo '———> Updating zplug...';
  zplug update --self
  echo '———> Updating zplug packages...';
  zplug update
}
################
# system
################
alias vi=vim
alias ls='ls ${colorflag}'
alias tree='tree -ACFh --du'

export PATH="/usr/local/bin:/usr/local/lib:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/TeX/texbin:$HOME/.pyenv/shims"

if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
export PYENV_ROOT=/usr/local/var/pyenv
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export TERM="xterm-256color"
export LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"

export XDG_CONFIG_HOME="$HOME/.config"

zplug load --verbose
