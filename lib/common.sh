# Shared helpers. Sourced by install.sh before any step runs.
# shellcheck shell=bash

: "${DRY_RUN:=0}"
: "${NO_SUDO:=0}"
: "${ASSUME_YES:=0}"

if [[ -t 1 ]]; then
    _c_dim=$'\e[2m'; _c_red=$'\e[31m'; _c_grn=$'\e[32m'
    _c_ylw=$'\e[33m'; _c_blu=$'\e[34m'; _c_off=$'\e[0m'
else
    _c_dim=; _c_red=; _c_grn=; _c_ylw=; _c_blu=; _c_off=
fi

say()  { printf '%s==>%s %s\n' "$_c_blu" "$_c_off" "$*"; }
ok()   { printf '  %s✓%s %s\n'  "$_c_grn" "$_c_off" "$*"; }
skip() { printf '  %s·%s %s\n'  "$_c_dim" "$_c_off" "$*"; }
warn() { printf '  %s!%s %s\n'  "$_c_ylw" "$_c_off" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$_c_red" "$_c_off" "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# run <cmd...> — the mutation wrapper. Everything that changes the system goes
# through this or run_root, which is what makes --dry-run meaningful.
run() {
    if (( DRY_RUN )); then printf '  %s[dry-run]%s %s\n' "$_c_dim" "$_c_off" "$*"; return 0; fi
    "$@"
}

# run_root <cmd...> — privileged mutation.
# Only three things in this repo need root, all Linux-only: dnf, add-shell, and
# chsh (which uses PAM and the user's OWN password, not sudo). Fonts, oh-my-zsh,
# p10k, every symlink and every theme file are user-level.
run_root() {
    if (( NO_SUDO )); then warn "skipping privileged step (--no-sudo): $*"; return 0; fi
    if (( DRY_RUN )); then printf '  %s[dry-run]%s sudo %s\n' "$_c_dim" "$_c_off" "$*"; return 0; fi
    if [[ $EUID -eq 0 ]]; then "$@"; return; fi
    have sudo || die "sudo is required for: $*"
    if sudo -n true 2>/dev/null; then sudo -n "$@"; return; fi
    # Graphical session: use KDE's askpass so this matches how ~/fedora-setup
    # already operates, instead of a dead terminal prompt.
    if [[ -z ${SUDO_ASKPASS:-} && -x /usr/bin/ksshaskpass && -n ${WAYLAND_DISPLAY:-}${DISPLAY:-} ]]; then
        export SUDO_ASKPASS=/usr/bin/ksshaskpass
    fi
    if [[ -n ${SUDO_ASKPASS:-} && -x ${SUDO_ASKPASS} ]]; then sudo -A "$@"; return; fi
    warn "about to run as root: $*"
    sudo "$@"
}

confirm() {
    (( ASSUME_YES )) && return 0
    (( DRY_RUN ))    && return 0
    local reply
    read -r -p "  $* [y/N] " reply
    [[ $reply == [yY]* ]]
}

# get_latest_tag <owner> <repo> — newest release tag from the GitHub API.
get_latest_tag() {
    local owner="$1" repo="$2" tag
    if have gh && gh auth status >/dev/null 2>&1; then
        # 5000 req/hr authenticated vs 60 anonymous.
        tag="$(gh api "repos/${owner}/${repo}/releases/latest" --jq .tag_name 2>/dev/null)" || tag=
    else
        tag="$(curl -fsSL "https://api.github.com/repos/${owner}/${repo}/releases/latest" \
               | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)" || tag=
    fi
    # Without this guard an empty tag builds a URL with no version in it, and
    # the resulting 404 aborts the whole run under `set -e` — the classic
    # symptom of hitting the anonymous rate limit.
    [[ -n $tag ]] || die "could not resolve latest release tag for ${owner}/${repo} (GitHub API rate limited?)"
    printf '%s\n' "$tag"
}

# link_file <src> <dest> — idempotent symlink with a timestamped backup.
link_file() {
    local src="$1" dest="$2" pretty="${2/#$HOME/\~}"

    [[ -e $src ]] || { warn "missing source, skipping: $src"; return 0; }

    if [[ -L $dest ]]; then
        if [[ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
            skip "$pretty already linked"; return 0
        fi
        run rm -f "$dest"
    elif [[ -e $dest ]]; then
        # A regular file that differs from the repo copy may be a tool having
        # overwritten our symlink. p10k configure does exactly this: it renames
        # a temp file over ~/.p10k.zsh, turning the symlink into a real file and
        # silently divorcing it from the repo. Warn rather than discard.
        if ! diff -q "$src" "$dest" >/dev/null 2>&1; then
            warn "$pretty is a regular file and differs from the repo copy (backing it up)."
            if [[ ${dest##*/} == .p10k.zsh ]]; then
                warn "  looks like \`p10k configure\` ran. To keep those changes:"
                warn "    cp ${bak:-$pretty} \$DOTFILES/templates/.p10k.zsh.in"
                warn "    then re-apply the \${TN_*} colour variables and run bin/tn-render"
            fi
        fi
        local bak="${dest}.bak.$(date +%s)"
        run mv "$dest" "$bak"
        ok "backed up $pretty -> ${bak##*/}"
    fi

    run mkdir -p "$(dirname "$dest")"
    run ln -s "$src" "$dest"
    ok "linked $pretty"
}
