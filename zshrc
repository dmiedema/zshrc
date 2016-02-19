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

# setup independent histories for each zsh session
setopt append_history no_inc_append_history no_share_history

# ZGEN_RESET_ON_CHANGE(${HOME}/.zshrc ${HOME}/.zshrc.local)

# Set Editor
export EDITOR='vim'

if ! zgen saved; then
  # load up oh-my-zsh
  zgen oh-my-zsh

  # Enable zsh-completions
  fpath=(/usr/local/share/zsh-completions $fpath)

  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/git-extras
  zgen oh-my-zsh plugins/sudo
  zgen oh-my-zsh plugins/command-not-found
  zgen oh-my-zsh plugins/tmux
  zgen oh-my-zsh plugins/osx
  zgen oh-my-zsh plugins/xcode
  zgen oh-my-zsh plugins/brew
  zgen oh-my-zsh plugins/rsync
  zgen oh-my-zsh plugins/colored-man-pages
  zgen oh-my-zsh plugins/jira
  zgen oh-my-zsh plugins/vim-interaction
  # zgen oh-my-zsh plugins/vi-mode

  zgen loadall <<EOBUNDLES

    dmiedema/fuck-you

    # Meta?
    Tarrasch/zsh-bd
    tmuxinator/tmuxinator
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-completions
    # dmiedema/zsh-completions agvtool
    arialdomartini/oh-my-git
    zsh-users/zsh-history-substring-search
    rupa/z
    # Vim mode?
    hchbaw/opp.zsh
    rimraf/k

    # This take care of theme
    mafredri/zsh-async
    # sindresorhus/pure
    dmiedema/pure
EOBUNDLES

  zgen save
fi

# zsh-autosuggestions
# Start the server
#zle-line-init() {
  # zle autosuggest-start
# }
# zle -N zle-line-init
# Accept suggested word without leaving insert mode
# bindkey '^f' vi-forward-word

function history_search() {
  cat ~/.zsh_history | ack "$1"
}

# OS X / Homebrew specific
export HOMEBREW_BUILD_FROM_SOURCE=1

