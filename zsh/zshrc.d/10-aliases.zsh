# Aliases live in shell/shared/ so bash and zsh cannot drift apart.
# The shared file detects $ZSH_VERSION and adds `nocorrect` where needed.
source "$DOTFILES/shell/shared/10-aliases.sh"
