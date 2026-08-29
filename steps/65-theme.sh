# Fetch upstream theme artefacts, then render every template from the palette.
_step_theme() {
    say "Tokyo Night theming"

    # bat: a .tmTheme is 300 lines of plist -- fetch upstream, do not hand-write.
    local batdir; batdir="$(have bat && bat --config-dir || echo "$HOME/.config/bat")"
    if [[ -f $batdir/themes/tokyonight_night.tmTheme ]]; then
        skip "bat theme present"
    else
        run mkdir -p "$batdir/themes"
        run curl -fsSL -o "$batdir/themes/tokyonight_night.tmTheme" \
            https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
        ok "bat theme fetched"
    fi

    # eza: schema has churned across releases. If eza ever warns on startup,
    # delete this file and fall back to EZA_COLORS (LS_COLORS syntax, stable).
    if [[ -f $HOME/.config/eza/theme.yml ]]; then
        skip "eza theme present"
    else
        run mkdir -p "$HOME/.config/eza"
        run curl -fsSL -o "$HOME/.config/eza/theme.yml" \
            https://raw.githubusercontent.com/eza-community/eza-themes/main/themes/tokyonight.yml
        ok "eza theme fetched"
    fi

    # btop ships tokyo-night.theme in Fedora's package; fetch only if absent.
    if [[ -f /usr/share/btop/themes/tokyo-night.theme || -f $HOME/.config/btop/themes/tokyo-night.theme ]]; then
        skip "btop theme present"
    else
        run mkdir -p "$HOME/.config/btop/themes"
        run curl -fsSL -o "$HOME/.config/btop/themes/tokyo-night.theme" \
            https://raw.githubusercontent.com/aristocratos/btop/main/themes/tokyo-night.theme
        ok "btop theme fetched"
    fi

    # Render every template from palette/tokyonight.sh.
    if (( DRY_RUN )); then
        DRY_RUN=1 "$DOTFILES/bin/tn-render" --dry-run
    else
        "$DOTFILES/bin/tn-render"
    fi

    # git-delta include, kept out of ~/.gitconfig proper so identity is untouched.
    if git config --global --get-all include.path 2>/dev/null | grep -q 'tokyonight.gitconfig'; then
        skip "git delta include present"
    else
        run git config --global --add include.path "$HOME/.config/git/tokyonight.gitconfig"
        ok "git delta include added"
    fi

    # Konsole fallback profile (real blur + transparency, no ligatures).
    if [[ $OS_ID == fedora ]] && have kwriteconfig6; then
        run kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile "TokyoNight.profile"
        run kwriteconfig6 --file konsolerc --group "UiSettings"    --key ColorScheme   "TokyoNight"
        ok "Konsole profile set"
    fi
}
_step_theme
