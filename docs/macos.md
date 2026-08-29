# macOS notes

The macOS path is unchanged from the original flat `install.sh` — every
per-tool installer moved verbatim into `lib/os-darwin.sh`.

## Migrating an existing Mac to this layout

```bash
cd ~/dotfiles && git pull
brew install eza git-delta     # see below
./install.sh
exec zsh
```

Your old `~/.zshrc`, `~/.p10k.zsh` and `~/.hyper.js` are backed up with a
timestamped suffix before anything is linked.

## Two things that changed for macOS

**1. eza replaces lsd.** eza publishes no macOS release binary (Linux and
Windows only), so it cannot be tarball-installed the way the other tools are —
it needs Homebrew. Until you run `brew install eza`, the alias block falls back
to lsd automatically and `ls` keeps working, so there is no broken window.

**2. The prompt is recoloured.** `.p10k.zsh` hardcoded Snazzy hex values while
the terminal ran Tokyo Night — the two never actually matched. The seven colour
variables are now rendered from `palette/tokyonight.sh`. The most consequential
is `grey`, which was the 256-palette index `242`: a neutral grey with no blue in
it, now `#565f89`, Tokyo Night's own de-emphasis colour. It drives the vcs,
virtualenv, context and time segments, i.e. most of the prompt.

## Fixed on the way through

- `export EDITOR='subl -w'` is gone. git resolves
  `core.editor > GIT_EDITOR > VISUAL > EDITOR`, so leaving Sublime in `VISUAL`
  breaks `git commit` anywhere `subl` is not on `PATH`. Sublime is now the
  explicit `e` alias instead.
- zsh-syntax-highlighting was loading from the oh-my-zsh `plugins=()` array,
  i.e. during `oh-my-zsh.sh` — **before** the fzf init at the bottom of
  `.zshrc`. It therefore never wrapped fzf's `^R`/`^T`/`M-c` widgets. It now
  loads last, from `zsh/zshrc.d/90-`.
- `install_hyper` called `hdiutil attach` a second time in its fallback branch,
  against an already-mounted image.
- `link_dotfiles` used a fixed `.backup` suffix, so a second run overwrote the
  first backup. Backups are now timestamped.
- `get_latest_tag` had no empty-result guard: hitting GitHub's 60/hr anonymous
  rate limit returned an empty tag, which built a URL with no version in it and
  aborted the run mid-install. It now uses `gh` when authenticated (5000/hr).
