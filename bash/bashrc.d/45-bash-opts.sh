# bash shell options roughly matching the zsh history behaviour.
shopt -s histappend      # append rather than overwrite on exit
shopt -s checkwinsize
shopt -s cdspell
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth   # closest bash has to HIST_IGNORE_ALL_DUPS + REDUCE_BLANKS
HISTTIMEFORMAT='%F %T '
