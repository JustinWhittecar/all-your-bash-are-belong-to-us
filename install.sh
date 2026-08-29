#!/usr/bin/env bash
# all-your-bash-are-belong-to-us — cross-platform dotfiles installer.
#
# Dispatcher only: OS detection, flag parsing, then each steps/*.sh in order.
# Steps are SOURCED, not executed, so they inherit lib/common.sh helpers and
# the per-OS function overrides without re-sourcing anything.
set -euo pipefail

# ${BASH_SOURCE[0]}, not $0: $0 breaks when the script is sourced or reached
# through a symlink.
DOTFILES="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES

DRY_RUN=0 ASSUME_YES=0 NO_SUDO=0 SET_SHELL=0
ONLY=() SKIP=()

usage() {
    cat <<EOF
usage: install.sh [options]

  --dry-run      show what would happen, including the real dnf transaction
  --yes, -y      do not prompt for confirmation
  --no-sudo      skip every privileged step (still does all user-level setup)
  --set-shell    also change the login shell to zsh (opt-in; runs smoke tests first)
  --only STEP    run only this step (repeatable), e.g. --only 70-link
  --skip STEP    skip this step (repeatable)
  --list-steps   list step names and exit
  -h, --help     this message

Steps are idempotent: a second run on a configured machine does nothing and
never asks for a password.
EOF
}

list_steps() { local f; for f in "$DOTFILES"/steps/*.sh; do basename "$f" .sh; done; }

while (($#)); do
    case "$1" in
        --dry-run)    DRY_RUN=1 ;;
        --yes|-y)     ASSUME_YES=1 ;;
        --no-sudo)    NO_SUDO=1 ;;
        --set-shell)  SET_SHELL=1 ;;
        --only)       ONLY+=("${2:?--only needs a step name}"); shift ;;
        --skip)       SKIP+=("${2:?--skip needs a step name}"); shift ;;
        --list-steps) list_steps; exit 0 ;;
        -h|--help)    usage; exit 0 ;;
        *)            echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done
export DRY_RUN ASSUME_YES NO_SUDO SET_SHELL

# Every ~/fedora-setup script REQUIRES root, so reaching for sudo here is a
# very easy mistake -- and it would leave ~/.oh-my-zsh, the font dir and every
# symlink owned by root. This repo uses sudo only where it must (dnf, add-shell).
[[ ${EUID:-$(id -u)} -eq 0 ]] && {
    echo "error: do not run this as root; it calls sudo only where needed." >&2
    exit 1
}

# shellcheck source=lib/common.sh
source "$DOTFILES/lib/common.sh"

detect_os() {
    case "$(uname -s)" in
        Darwin) OS_ID=darwin; OS_FAMILY=darwin ;;
        Linux)
            OS_FAMILY=linux
            [[ -r /etc/os-release ]] || die "cannot read /etc/os-release"
            # shellcheck disable=SC1091
            . /etc/os-release
            case " ${ID:-} ${ID_LIKE:-} " in
                *fedora*|*rhel*) OS_ID=fedora ;;
                *) die "unsupported Linux distro: ${ID:-unknown} (add lib/os-<id>.sh)" ;;
            esac ;;
        *) die "unsupported OS: $(uname -s)" ;;
    esac
    export OS_ID OS_FAMILY
}
detect_os
# shellcheck source=/dev/null
source "$DOTFILES/lib/os-${OS_ID}.sh"

should_run() {
    local name="$1" s
    for s in "${SKIP[@]-}"; do [[ $name == "$s" ]] && return 1; done
    (( ${#ONLY[@]} == 0 )) && return 0
    for s in "${ONLY[@]}"; do [[ $name == "$s" ]] && return 0; done
    return 1
}

printf '\n%s=== all-your-bash-are-belong-to-us ===%s\n' "$_c_blu" "$_c_off"
say "$OS_ID ($(uname -m)), DOTFILES=$DOTFILES"
(( DRY_RUN )) && warn "dry run: probes reflect CURRENT state, so steps downstream of an
       install that did not happen may report work that would already be done."
echo

run mkdir -p "$HOME/.local/bin"

for step in "$DOTFILES"/steps/*.sh; do
    name="$(basename "$step" .sh)"
    should_run "$name" || continue
    # shellcheck source=/dev/null
    source "$step"
done

echo
printf '%s=== done ===%s\n' "$_c_grn" "$_c_off"
cat <<EOF

next:
  exec zsh                 try the new shell without committing to it
  kitty                    the themed terminal
  ./install.sh --set-shell  make zsh the login shell (after living in it a while)
  gh auth login            if not already authenticated
  tldr --update            populate the tldr cache
EOF
