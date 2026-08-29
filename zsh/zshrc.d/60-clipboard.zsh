# oh-my-zsh's clipcopy prefers wl-copy only when $WAYLAND_DISPLAY is set, so it
# silently no-ops in a TTY, over SSH, and inside some tmux/systemd contexts.
# Override unconditionally when wl-copy exists, so `copypath` always works and
# fails loudly rather than quietly if the tool is ever missing.
if [[ $OSTYPE != darwin* ]] && (( $+commands[wl-copy] )); then
  clipcopy()  { wl-copy < "${1:-/dev/stdin}"; }
  clippaste() { wl-paste --no-newline; }
  # Muscle memory from macOS.
  alias pbcopy=clipcopy
  alias pbpaste=clippaste
fi
