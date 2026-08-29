# JetBrainsMono Nerd Font. The one thing Fedora does not package, so the
# upstream tarball path is used on BOTH platforms; only $FONT_DIR differs.
_step_fonts() {
    say "JetBrainsMono Nerd Font"
    local dest="$FONT_DIR/JetBrainsMonoNerdFont"
    if [[ -d $dest ]] && compgen -G "$dest/JetBrainsMonoNerdFont-*.ttf" >/dev/null; then
        skip "already installed"; return 0
    fi
    local tag url tmp; tag="$(get_latest_tag ryanoasis nerd-fonts)"
    url="https://github.com/ryanoasis/nerd-fonts/releases/download/${tag}/JetBrainsMono.tar.xz"
    tmp="$(mktemp -d)"
    run curl -fsSL "$url" -o "$tmp/JetBrainsMono.tar.xz"
    run mkdir -p "$dest"
    run tar -xJf "$tmp/JetBrainsMono.tar.xz" -C "$dest"
    # Keep only the 4 core faces of the two useful families. "Propo" is
    # proportional and "NL" is the NO-LIGATURE cut -- both wrong for a terminal
    # that was chosen specifically for its ligatures.
    if ! (( DRY_RUN )); then
        find "$dest" -maxdepth 1 -name '*.ttf' -printf '%f\n' \
          | grep -Ev '^JetBrainsMonoNerdFont(Mono)?-(Regular|Bold|Italic|BoldItalic)\.ttf$' \
          | while IFS= read -r f; do rm -f -- "$dest/$f"; done
    fi
    rm -rf "$tmp"
    font_refresh
    ok "font installed to ${dest/#$HOME/\~}"
}
_step_fonts
