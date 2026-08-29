# Linux-only conveniences.
[[ $OSTYPE == linux* ]] || return 0

alias open='xdg-open'
alias jctl='journalctl -xe'
alias sctl='systemctl'
alias sctlu='systemctl --user'

# This box uses ksshaskpass for graphical sudo prompts (see ~/fedora-setup).
if [[ -x /usr/bin/ksshaskpass && -n ${WAYLAND_DISPLAY:-}${DISPLAY:-} ]]; then
  export SUDO_ASKPASS=/usr/bin/ksshaskpass
fi
