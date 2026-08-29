# zoxide: smarter cd. Use `z <partial-dir>` to jump, `zi` to pick interactively.
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# fzf: Ctrl-R history search, Ctrl-T file picker, Alt-C directory jump.
[ -f /usr/share/fzf/shell/key-bindings.bash ] && . /usr/share/fzf/shell/key-bindings.bash
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
command -v fd >/dev/null && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'

# Colored man pages via bat
if command -v bat >/dev/null; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT='-c'
fi

export EDITOR=nvim
export VISUAL=nvim
