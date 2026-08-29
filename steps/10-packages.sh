# CLI tools. On Fedora these are one batched dnf transaction; on macOS they are
# the original per-tool GitHub tarball installers.
_step_packages() {
    say "CLI tools"
    local want=(bat eza fzf zoxide fastfetch gh tldr delta btop ripgrep fd zsh)
    [[ $OS_ID == fedora ]] && want+=(zsh-autosuggestions zsh-syntax-highlighting wl-clipboard xdg-utils gettext)
    local missing
    mapfile -t missing < <(pkg_missing "${want[@]}")
    if (( ${#missing[@]} == 0 )); then
        skip "all CLI tools already present"
        return 0
    fi
    pkg_install "${missing[@]}"
}
_step_packages
