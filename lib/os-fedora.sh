# Fedora / RHEL-family. Prefer dnf packages; fall back to upstream tarballs
# only for things Fedora genuinely does not package (currently: Nerd Fonts).
# shellcheck shell=bash

FONT_DIR="$HOME/.local/share/fonts"

# tool name -> rpm package name, where they differ.
_pkg_for() {
    case "$1" in
        tldr)   echo tealdeer ;;
        fd)     echo fd-find ;;
        delta)  echo git-delta ;;
        *)      echo "$1" ;;
    esac
}

pkg_missing() {
    local t p out=()
    for t in "$@"; do
        p="$(_pkg_for "$t")"
        rpm -q --quiet "$p" || out+=("$p")
    done
    # An empty array must print NOTHING. `printf '%s\n' "${out[@]}"` on an
    # empty array emits one blank line, which mapfile turns into an empty
    # element and dnf then rejects as "No match for argument: ".
    (( ${#out[@]} )) && printf '%s\n' "${out[@]}"
    return 0
}

pkg_install() {
    (( $# )) || return 0
    # One batched transaction => at most one askpass dialog per run.
    if (( DRY_RUN )); then
        say "would install: $*"
        # A real depsolve, not an echo. On a box whose only display output is
        # the NVIDIA card, seeing the actual transaction -- including anything
        # that would touch kernel/mesa/nvidia -- is the point of --dry-run.
        dnf install --assumeno "$@" 2>&1 | sed 's/^/    /'
        return 0
    fi
    run_root dnf install -y "$@"
}

font_refresh() { run fc-cache -f "$FONT_DIR"; }

zsh_plugin_paths() {
    # Fedora RPMs ship /usr/share/<name>/<name>.zsh with NO <name>.plugin.zsh,
    # so these cannot go in oh-my-zsh's plugins=() array. They are sourced
    # directly from zsh/zshrc.d/80- and 90- instead.
    printf '%s\n' /usr/share/zsh-autosuggestions /usr/share/zsh-syntax-highlighting
}

install_terminal() {
    local missing
    mapfile -t missing < <(pkg_missing kitty kitty-terminfo)
    if (( ${#missing[@]} )); then
        pkg_install "${missing[@]}"
    else
        skip "kitty already installed"
    fi
}
