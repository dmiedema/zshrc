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
  zgen oh-my-zsh plugins/git-extras

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
    mafredri/zsh-async mafredri/zsh-async main
    sindresorhus/pure sindresorhus/pure main

    paulirish/git-recent

    wfxr/forgit
    b4b4r07/emoji-cli
    zdharma/zsh-diff-so-fancy
EOBUNDLES

  ln -s $HOME/.zgen/paulirish/git-recent-master/git-recent /usr/local/bin/
  zgen save
fi

fpath+=$HOME/.zgen/sindresorhus/pure-main
autoload -U promptinit; promptinit
prompt pure

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
  RPROMPT="[\$(date +%H:%M:%S)]"
}

# ZLE hooks for prompt's vi mode status
function zle-line-init zle-keymap-select {
  # Change the cursor style depending on keymap mode.
  # https://askubuntu.com/a/620306
  case $KEYMAP {
    vicmd)
      printf '\e[0 q' # Box.
      ;;

    viins|main)
      printf '\e[2 q' # Steady Box
      ;;
  }
}
zle -N zle-line-init
zle -N zle-keymap-select

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

function video2gif() {
  if (( $+commands[ffmpeg] )); then
    ffmpeg -y -i "${1}" -vf fps=${3:-10},scale=${2:-320}:-1:flags=lanczos,palettegen "${1}.png"
    ffmpeg -i "${1}" -i "${1}.png" -filter_complex "fps=${3:-10},scale=${2:-320}:-1:flags=lanczos[x];[x][1:v]paletteuse" "${1}".gif
    rm "${1}.png"
  else
    echo "'ffmpeg' is required to run 'video2gif'"
  fi
}

function branch_search() {
  git branch | fzf-tmux -d 15
}

# OS X / Homebrew specific
# export HOMEBREW_BUILD_FROM_SOURCE=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

[[ :$PATH: == *:$HOME/bin:* ]] || PATH=$HOME/bin:$PATH
export PATH="/opt/brew/bin:$PATH"

[[ -a "$HOME/.zshrc.local" ]]   && source "$HOME/.zshrc.local"
[[ -a "$HOME/.aliases.local" ]] && source "$HOME/.aliases.local"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ $- =~ i ]] && bindkey -r '\ec'
bindkey '\eq' fzf-cd-widget

fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -r 's/ *[0-9]*\*? *//' | sed -r 's/\\/\\\\/g')
}

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

