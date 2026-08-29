_step_p10k() {
    say "powerlevel10k"
    local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ -d $dest ]]; then skip "already installed"; return 0; fi
    run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dest"
    ok "powerlevel10k installed"
}
_step_p10k
