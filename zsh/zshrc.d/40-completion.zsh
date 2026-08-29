# Completion behaviour. oh-my-zsh already ran compinit.
zstyle ':completion:*' menu select                      # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # colourise the menu
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*:warnings'     format '%F{red}-- no matches --%f'

setopt AUTO_CD                # `..` or a bare dir name cds into it
setopt AUTO_PUSHD             # every cd pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS   # allow # comments when typing interactively
