# Path-prober so one file serves Fedora (dnf, /usr/share) and macOS (git clone
# into $ZSH_CUSTOM, or Homebrew). See the note in ~/.zshrc about why these are
# not in the oh-my-zsh plugins array.
for _c in \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -r $_c ]] && { source "$_c"; break; }
done
unset _c

[[ -r ~/.config/tokyonight/zsh-colors.zsh ]] && source ~/.config/tokyonight/zsh-colors.zsh
