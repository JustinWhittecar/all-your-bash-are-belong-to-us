# History. Set AFTER oh-my-zsh so these win over its defaults.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt SHARE_HISTORY          # live-share history between open shells
setopt HIST_IGNORE_ALL_DUPS   # a repeated command keeps only its newest entry
setopt HIST_REDUCE_BLANKS     # tidy whitespace before saving
setopt HIST_VERIFY            # expand !! onto the line instead of running it blind
setopt EXTENDED_HISTORY       # record timestamps (HIST_STAMPS needs this)
