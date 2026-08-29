# MUST be the last drop-in. zsh-syntax-highlighting wraps every ZLE widget that
# exists at the moment it loads — including fzf's ^R/^T/M-c, which 20-tools.zsh
# installs. Loading it earlier (e.g. from the oh-my-zsh plugins array, which
# runs during oh-my-zsh.sh) means those widgets silently go unhighlighted.
for _c in \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -r $_c ]] && { source "$_c"; break; }
done
unset _c

# Styles are set in ~/.config/tokyonight/zsh-colors.zsh, sourced from the 80-
# drop-in above; re-source so they apply to the highlighter just loaded.
[[ -r ~/.config/tokyonight/zsh-colors.zsh ]] && source ~/.config/tokyonight/zsh-colors.zsh
