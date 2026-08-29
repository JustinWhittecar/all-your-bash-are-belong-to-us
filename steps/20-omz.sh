_step_omz() {
    say "oh-my-zsh"
    if [[ -d $HOME/.oh-my-zsh ]]; then skip "already installed"; return 0; fi
    # KEEP_ZSHRC stops the installer writing its own ~/.zshrc template, which
    # would otherwise sit there until 70-link replaces it -- and would survive
    # as a shadow copy if a run failed in between.
    run env RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ok "oh-my-zsh installed"
}
_step_omz
