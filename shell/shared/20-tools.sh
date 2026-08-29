# Environment shared by bash AND zsh. EXPORTS ONLY — exports behave identically
# in both shells. Anything requiring a shell-specific `eval` (fzf keybindings,
# zoxide init) lives in bash/bashrc.d/40-bash-init.sh or zsh/zshrc.d/20-tools.zsh.
#
# NOTE: FZF_DEFAULT_OPTS is set in the zsh drop-in and the bash init file, not
# here, because the Tokyo Night --color string is rendered from the palette.

# --- fzf source command --------------------------------------------------
# Fedora ships the binary as `fd`; Debian/Ubuntu ship it as `fdfind`.
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
fi

# --- colourised man pages via bat ---------------------------------------
if command -v bat >/dev/null 2>&1; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT='-c'
fi

# --- editor --------------------------------------------------------------
# Deliberately NOT `subl -w`. git resolves core.editor > GIT_EDITOR > VISUAL >
# EDITOR, so leaving Sublime in VISUAL breaks `git commit` anywhere subl is not
# on PATH. Sublime is available as the explicit `e` alias on macOS instead.
if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
    export VISUAL=nvim
elif command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
    export VISUAL=vim
fi

# --- misc ----------------------------------------------------------------
export LESS='-R'
