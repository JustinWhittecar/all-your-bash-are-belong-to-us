# On Fedora these came from dnf in 10-packages and live in /usr/share.
# On macOS they are git clones into $ZSH_CUSTOM/plugins.
# Either way they are sourced directly by zsh/zshrc.d/80- and 90-, NOT via the
# oh-my-zsh plugins=() array -- see the comment in zsh/zshrc.
_step_zsh_plugins() {
    say "zsh plugins"
    [[ $OS_ID == fedora ]] && { skip "provided by dnf (/usr/share)"; return 0; }
    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins" repo
    for repo in zsh-autosuggestions zsh-syntax-highlighting; do
        if [[ -d "$custom/$repo" ]]; then skip "$repo already installed"; continue; fi
        run git clone --depth=1 "https://github.com/zsh-users/$repo.git" "$custom/$repo"
        ok "$repo installed"
    done
}
_step_zsh_plugins
