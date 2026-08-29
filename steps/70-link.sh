# Symlink config into $HOME.
# ~/.bashrc and ~/.bash_profile are NEVER touched: Fedora's stock ~/.bashrc
# already loops over ~/.bashrc.d/*, and that hook is what lets bash keep working
# untouched through the whole zsh migration.

_step_link() {
    say "linking dotfiles"

    # zsh entry points
    link_file "$DOTFILES/zsh/zshenv" "$HOME/.zshenv"
    link_file "$DOTFILES/zsh/zshrc"  "$HOME/.zshrc"

    # Shared shell config — the same files zsh sources, linked into bash's
    # drop-in directory so neither shell can drift from the other.
    run mkdir -p "$HOME/.bashrc.d"
    local f
    for f in "$DOTFILES"/shell/shared/*.sh; do
        link_file "$f" "$HOME/.bashrc.d/$(basename "$f")"
    done
    for f in "$DOTFILES"/bash/bashrc.d/*.sh; do
        link_file "$f" "$HOME/.bashrc.d/$(basename "$f")"
    done

    # neovim
    if [[ -f $DOTFILES/static/nvim/init.lua ]]; then
        link_file "$DOTFILES/static/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    fi

    # macOS-only terminal config
    if [[ $OS_FAMILY == darwin && -f $DOTFILES/terminal/hyper/hyper.js ]]; then
        link_file "$DOTFILES/terminal/hyper/hyper.js" "$HOME/.hyper.js"
    fi
}
_step_link
