# Shared exports first (EDITOR, MANPAGER, FZF_DEFAULT_COMMAND).
source "$DOTFILES/shell/shared/20-tools.sh"

# Tokyo Night fzf colours, rendered from the palette by bin/tn-render.
[[ -r ~/.config/tokyonight/fzf.sh ]] && source ~/.config/tokyonight/fzf.sh

# fzf keybindings + completion. Fedora's fzf 0.74 supports `fzf --zsh`; the
# /usr/share path is the fallback for older builds.
if command -v fzf >/dev/null; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    [[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && source /usr/share/fzf/shell/key-bindings.zsh
    [[ -f /usr/share/fzf/shell/completion.zsh   ]] && source /usr/share/fzf/shell/completion.zsh
  fi
fi

# zoxide: `z <partial>` to jump, `zi` to pick interactively.
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
