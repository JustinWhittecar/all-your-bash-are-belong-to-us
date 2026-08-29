# bash-specific initialisation. The shared exports/aliases come from
# ~/.bashrc.d/{10-aliases,20-tools,30-python}.sh, which are symlinks into
# dotfiles/shell/shared/ and are also sourced by zsh.

# Tokyo Night fzf colours, rendered from the palette by bin/tn-render.
[ -r "$HOME/.config/tokyonight/fzf.sh" ] && . "$HOME/.config/tokyonight/fzf.sh"

# fzf keybindings + completion. `fzf --bash` (0.48+) gives BOTH; the
# /usr/share key-bindings file alone gives keybindings but no completion.
if command -v fzf >/dev/null 2>&1; then
    if fzf --bash >/dev/null 2>&1; then
        eval "$(fzf --bash)"
    else
        [ -f /usr/share/fzf/shell/key-bindings.bash ] && . /usr/share/fzf/shell/key-bindings.bash
        [ -f /usr/share/fzf/shell/completion.bash   ] && . /usr/share/fzf/shell/completion.bash
    fi
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
