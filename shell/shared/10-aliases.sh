# Aliases shared by bash AND zsh. POSIX only — no bashisms, no zsh-isms.
# Linked to ~/.bashrc.d/10-aliases.sh and sourced from ~/.zshrc.d/10-aliases.zsh.

# zsh with ENABLE_CORRECTION=true tries to spell-correct alias ARGUMENTS, which
# mangles things like `ls -la`. Prefixing with `nocorrect` fixes it. The prefix
# is expanded into the alias VALUE at definition time, so bash never sees the
# word `nocorrect` at all — which is what lets one file serve both shells.
if [ -n "${ZSH_VERSION-}" ]; then _nc='nocorrect '; else _nc=''; fi

# --- modern replacements -------------------------------------------------
# eza is preferred (actively maintained, git columns, has a Tokyo Night theme).
# lsd is the fallback so `ls` keeps working on any machine where eza is absent
# — notably macOS, for which eza publishes no release binary.
if command -v eza >/dev/null 2>&1; then
    alias ls="${_nc}eza --group-directories-first --icons=auto"
    alias ll="${_nc}eza -l  --group-directories-first --icons=auto --git"
    alias la="${_nc}eza -la --group-directories-first --icons=auto --git"
    alias lt="${_nc}eza --tree --level=2 --group-directories-first --icons=auto"
elif command -v lsd >/dev/null 2>&1; then
    alias ls="${_nc}lsd --group-dirs=first"
    alias ll="${_nc}lsd -l  --group-dirs=first"
    alias la="${_nc}lsd -la --group-dirs=first"
    alias lt="${_nc}lsd --tree --depth=2 --group-dirs=first"
fi

if command -v bat >/dev/null 2>&1; then
    alias cat="${_nc}bat --paging=never"
    alias less="${_nc}bat"
fi
command -v btop >/dev/null 2>&1 && alias top="${_nc}btop"
command -v fastfetch >/dev/null 2>&1 && alias ff="${_nc}fastfetch"

# --- classics ------------------------------------------------------------
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ..='cd ..'
alias ...='cd ../..'

# --- dnf (Fedora only) ---------------------------------------------------
if command -v dnf >/dev/null 2>&1; then
    alias dnfs='dnf search'
    alias dnfi='sudo dnf install'
    alias dnfu='sudo dnf upgrade --refresh'
fi

# --- git -----------------------------------------------------------------
alias gs='git status -sb'
alias gd='git diff'
# gl and glog are the same command. Both kept deliberately: gl is the habit
# from this machine, glog the habit from the Mac. No reason to retrain either.
alias gl='git log --oneline --graph --decorate -20'
alias glog='git log --oneline --graph --decorate -20'

unset _nc
