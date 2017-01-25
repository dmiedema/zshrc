# Get Source
# not an option
if [[ ! -a "$HOME/.zgen/zgen.zsh" ]]; then
  echo "You need to clone zgen."
  echo  "git clone https://github.com/tarjoilija/zgen ~/.zgen"
  exit 127
fi

source "$HOME/.zgen/zgen.zsh"
# optional
[[ -a "$HOME/.aliases" ]]     && source "$HOME/.aliases"
[[ -a "$HOME/.zsh_path" ]]    && source "$HOME/.zsh_path"

###
### Default Aliases I want everywhere
###
# Directory Listing
alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'

# Setup History
if [ -z "$HISTFILE" ]; then
  HISTFILE=$HOME/.zsh_history
fi

# Largest History. Because Yes
HISTSIZE=100000
SAVEHIST=100000

# Show History
case $HIST_STAMPS in
  "mm/dd/yyyy") alias history='fc -fl 1' ;;
  "dd.mm.yyyy") alias history='fc -El 1' ;;
  "yyyy-mm-dd") alias history='fc -il 1' ;;
  *) alias history='fc -l 1' ;;
esac


# setup independent histories for each zsh session
setopt append_history # Append our histories
setopt no_inc_append_history 
setopt no_share_history #independent histories
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt auto_cd

# ZGEN_RESET_ON_CHANGE(${HOME}/.zshrc ${HOME}/.zshrc.local)

# Set Editor
export EDITOR='vim'

if ! zgen saved; then
  # Enable zsh-completions
  fpath=(/usr/local/share/zsh-completions $fpath)

  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/osx
  zgen oh-my-zsh plugins/pod
  zgen oh-my-zsh plugins/rsync
  zgen oh-my-zsh plugins/colored-man-pages

  zgen loadall <<EOBUNDLES

    dmiedema/fuck-you

    # Meta?
    Tarrasch/zsh-bd
    tmuxinator/tmuxinator
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-completions
    # dmiedema/zsh-completions agvtool
    arialdomartini/oh-my-git
    zsh-users/zsh-history-substring-search
    rupa/z
    # Vim mode?
    rimraf/k

    # This take care of theme
    mafredri/zsh-async
    # sindresorhus/pure
    dmiedema/pure

    paulirish/git-recent
EOBUNDLES

  ln -s $HOME/.zgen/paulirish/git-recent-master/git-recent /usr/local/bin/
  zgen save
fi

# zsh-autosuggestions
# Accept suggested word without leaving insert mode
bindkey '^f' vi-forward-word

function history_search() {
  cat ~/.zsh_history | ack "$1"
}

function trash() {
  mv $1 ~/.Trash/
}

# OS X / Homebrew specific
# export HOMEBREW_BUILD_FROM_SOURCE=1
export HOMEBREW_NO_ANALYTICS=1

[[ -a "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
