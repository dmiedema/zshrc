# Get Source
# not an option
if [[ ! -a "$HOME/.zgen/zgen.zsh" ]]; then
  echo "You need to clone zgen."
  echo  "git clone https://github.com/tarjoilija/zgen ~/.zgen"
  exit 127
fi

source "$HOME/.zgen/zgen.zsh"
# optional
[[ -a "$HOME/.aliases" ]]  && source "$HOME/.aliases"
[[ -a "$HOME/.zsh_path" ]] && source "$HOME/.zsh_path"

# Set Editor
export EDITOR='vim'

if ! zgen saved; then
  # Enable zsh-completions
  fpath=(/usr/local/share/zsh-completions $fpath)

  zgen oh-my-zsh

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
    sindresorhus/pure

    paulirish/git-recent
EOBUNDLES

  ln -s $HOME/.zgen/paulirish/git-recent-master/git-recent /usr/local/bin/
  zgen save
fi

# Get our current virtualenv if we have one
# if we do, prepend to the entire prompt.
# Add conditionally the number of susupended jobs
# if we have 1 or more. Otherwise prompt as normal
# We run it as a precmd so it is evaluated after
# just launch
precmd() {
  PROMPT='%F{yellow}%(1j.[%j] .)%(?.%F{green}.%F{red})${PURE_PROMPT_SYMBOL:-❯}%f '
  if [ -n "$VIRTUAL_ENV" ]; then
    PROMPT='%F{white}($(basename $VIRTUAL_ENV)) %F{yellow}%(1j.[%j] .)%(?.%F{green}.%F{red})${PURE_PROMPT_SYMBOL:-❯}%f '
  fi
}

# zsh-autosuggestions
# Accept suggested word without leaving insert mode
bindkey '^f' vi-forward-word

# Setup edit-command-line
# Bound to <esc> v
bindkey -v
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-v' edit-command-line

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '\eOA' history-substring-search-up
bindkey '\eOB' history-substring-search-down

function history_search() {
  cat ~/.zsh_history | ack "$1"
}

function trash() {
  mv $1 ~/.Trash/
}

function submodule-status() {
# this is a file checkout, do nothing
  if [[ -a .gitmodules ]]; then
    git submodule foreach --recursive 'echo "$(tput bold)$path$(tput sgr0) -- \033[1;35m`git rev-parse --abbrev-ref HEAD` \033[0m"'
  fi
}

function fixup() {
  git add "$@"
  local hash=$(git log --oneline --shortstat | head -n 1 | awk '{print $1}')
  git commit --fixup="$hash"
  git rebase --interactive --autosquash "$hash"~1
}

# OS X / Homebrew specific
# export HOMEBREW_BUILD_FROM_SOURCE=1
export HOMEBREW_NO_ANALYTICS=1

[[ -a "$HOME/.zshrc.local" ]]   && source "$HOME/.zshrc.local"
[[ -a "$HOME/.aliases.local" ]] && source "$HOME/.aliases.local"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

