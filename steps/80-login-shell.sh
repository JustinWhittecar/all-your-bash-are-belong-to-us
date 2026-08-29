# OPT-IN ONLY: runs when --set-shell is passed. Never part of a default run.
#
# On the daily-driver question: run install.sh without this, then live in
# `exec zsh` for a day from bash. The passwd change and the decision to switch
# should not happen in the same command.
_step_login_shell() {
    (( SET_SHELL )) || { skip "login shell unchanged (pass --set-shell to switch)"; return 0; }
    say "login shell -> zsh"

    local zsh_bin; zsh_bin="$(command -v zsh || true)"
    # A bad shell PATH in /etc/passwd is the one genuinely fatal outcome here,
    # so resolve it rather than hardcoding /usr/bin/zsh.
    [[ -n $zsh_bin && -x $zsh_bin ]] || die "zsh not found or not executable"

    if [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$zsh_bin" ]]; then
        skip "already $zsh_bin"; return 0
    fi

    grep -qxF "$zsh_bin" /etc/shells || run_root /usr/sbin/add-shell "$zsh_bin"

    # --- gates. Any failure here means NO chsh. ---
    say "  smoke tests"
    zsh -n "$HOME/.zshrc"                  || die "~/.zshrc does not parse -- not changing your login shell"
    zsh -lic 'exit 0'                      || die "interactive zsh startup failed -- not changing your login shell"
    [[ "$(zsh -lic 'print READY' 2>/dev/null | tr -d "\r" | tail -1)" == READY ]] \
                                           || die "zsh produced no usable output -- not changing your login shell"
    local resolved
    resolved="$(zsh -lic 'whence -w ls cat z clipcopy 2>/dev/null | wc -l' 2>/dev/null | tail -1)"
    (( resolved >= 3 )) || warn "only $resolved/4 expected commands resolved; continuing anyway"
    ok "smoke tests passed"

    confirm "change login shell for $USER to $zsh_bin?" || { skip "declined"; return 0; }

    # chsh prompts for the USER's own password via PAM -- this is not sudo.
    if ! run chsh -s "$zsh_bin"; then
        warn "chsh failed; trying usermod (safe: the path was validated above)"
        run_root usermod -s "$zsh_bin" "$USER"
    fi
    ok "login shell is now $(getent passwd "$USER" | cut -d: -f7)"
    say "  rollback: chsh -s /bin/bash"
    say "  a broken ~/.zshrc cannot affect your Plasma session -- SDDM and"
    say "  systemd user units do not run your login shell. Escape hatches:"
    say "  KRunner -> 'konsole -e bash', Ctrl-Alt-F3, or 'zsh -f'."
}
_step_login_shell
