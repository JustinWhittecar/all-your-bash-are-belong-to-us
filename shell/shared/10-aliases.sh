# Modern replacements for classic tools (installed in fedora-setup phase 4).
# Aliases only affect interactive shells, so scripts still get the originals.
if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first'
    alias ll='eza -l --group-directories-first --git'
    alias la='eza -la --group-directories-first --git'
    alias lt='eza --tree --level=2 --group-directories-first'
fi
command -v bat  >/dev/null && alias cat='bat --paging=never' && alias less='bat'
command -v btop >/dev/null && alias top='btop'

alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ..='cd ..'
alias ...='cd ../..'

# dnf helpers
alias dnfs='dnf search'
alias dnfi='sudo dnf install'
alias dnfu='sudo dnf upgrade --refresh'

# git shorthands
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
