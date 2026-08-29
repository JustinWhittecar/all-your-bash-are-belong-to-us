# macOS-only.
[[ $OSTYPE == darwin* ]] || return 0

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -x /usr/local/bin/brew   ]] && eval "$(/usr/local/bin/brew shellenv)"

# Sublime as an explicit verb, never as $EDITOR — see shell/shared/20-tools.sh.
command -v subl >/dev/null && alias e='subl -w'
