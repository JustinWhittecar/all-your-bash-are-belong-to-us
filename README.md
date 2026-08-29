# all-your-bash-are-belong-to-us

One-command setup for a fully-loaded terminal on **macOS and Fedora**: Zsh,
Powerlevel10k, Tokyo Night everywhere, and modern CLI tools.

<img width="1127" height="781" alt="macOS / Hyper" src="https://github.com/user-attachments/assets/44bed99c-61b9-4b7d-a065-985dcfcaa91e" />

## Quick install

```bash
git clone https://github.com/JustinWhittecar/all-your-bash-are-belong-to-us.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run     # review first — shows the real package transaction
./install.sh
exec zsh                   # try it without committing
./install.sh --set-shell   # later: make zsh the login shell
```

Everything is idempotent. A second run on a configured machine does nothing and
never asks for a password.

| flag | effect |
|---|---|
| `--dry-run` | show what would happen, including the real `dnf` transaction |
| `--no-sudo` | skip every privileged step; still does all user-level setup |
| `--set-shell` | change the login shell to zsh (opt-in, runs smoke tests first) |
| `--only STEP` / `--skip STEP` | run or skip one step; `--list-steps` to see them |

## Platform matrix

| | macOS | Fedora |
|---|---|---|
| Terminal | Hyper.app | **kitty** |
| Packages | GitHub release tarballs → `~/.local/bin` | `dnf`, one batched transaction |
| Fonts | `~/Library/Fonts` | `~/.local/share/fonts` + `fc-cache` |
| zsh plugins | git clone → `$ZSH_CUSTOM/plugins` | `dnf` → `/usr/share` |
| Desktop theming | — | KDE colour scheme |

**Why kitty and not Ghostty on Linux?** Ligatures are a hard requirement, which
rules out Konsole (KDE bug 361659, open since 2016), Alacritty (upstream
WONTFIX) and foot. Of the emulators that *do* ligate, kitty is the only one
packaged first-party for Fedora — Ghostty is COPR-only and WezTerm is
Flathub-only, both poor bets for a machine's primary terminal.

## Layout

```
install.sh          dispatcher: detect OS, source lib/os-$OS_ID.sh, run steps/
lib/                common.sh + one file per OS
steps/              numbered, idempotent, individually runnable via --only
palette/            tokyonight.sh — THE only file with a literal hex colour
bin/tn-render       renders templates/ into $HOME from the palette
templates/          mirrors $HOME; *.in files, path IS the mapping
static/             files needing no substitution (nvim/init.lua)
zsh/                zshenv, zshrc, and numbered zshrc.d/ drop-ins
shell/shared/       POSIX — sourced by BOTH bash and zsh
bash/bashrc.d/      bash-only init
terminal/           kitty (rendered), konsole, hyper
```

### One palette, everything generated

`palette/tokyonight.sh` is the only file permitted to contain a hex colour. It
derives `_HASH` (`#7aa2f7`), `_RGB` (`122,162,247`), `_R`/`_G`/`_B` and `_0X`
forms automatically, because consumers disagree: kitty/fzf/delta/tmux want hex,
KDE and Konsole want decimal triples, tealdeer wants separate components.

`bin/tn-render` walks `templates/`, which mirrors `$HOME`, so there is no
manifest to keep in sync — the path is the mapping.

> **The load-bearing detail:** `envsubst` is passed an explicit list of only
> `${TN_*}` names. Bare `envsubst` expands *every* `$foo` it sees and would
> shred the tmux, p10k and zsh templates, which are full of legitimate shell
> variables. That restriction is what makes a 25-line renderer sufficient
> instead of needing chezmoi or nix.

Where a tool accepts ANSI colour *names* (fastfetch, `LS_COLORS`), use those
instead of hex — they resolve through the terminal palette for free and stay
correct if the palette changes.

### The transparency rule

The terminal runs at 93% opacity. **Any TUI that paints its own background
destroys that effect**, so each one must be told to inherit instead:

| tool | setting |
|---|---|
| fzf | `bg:-1`, `gutter:-1`, `preview-bg:-1` |
| btop | `theme_background = False` |
| tmux | `status-style bg=default` |
| nvim | `transparent = true` |

Any new TUI joins this list. It is the failure mode that keeps recurring, and
the fix is always the same shape.

## Tools

| Tool | Replaces | Link |
|---|---|---|
| **eza** | `ls` | [eza-community/eza](https://github.com/eza-community/eza) |
| **bat** | `cat`, man pager | [sharkdp/bat](https://github.com/sharkdp/bat) |
| **delta** | `git diff` pager | [dandavison/delta](https://github.com/dandavison/delta) |
| **fzf** | `Ctrl-R`, `Ctrl-T`, `Alt-C` | [junegunn/fzf](https://github.com/junegunn/fzf) |
| **zoxide** | `cd` → `z` | [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide) |
| **btop** | `top` | [aristocratos/btop](https://github.com/aristocratos/btop) |
| **fastfetch** | `ff` | [fastfetch-cli/fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| **tldr** | `man`, but useful | [tealdeer-rs/tealdeer](https://github.com/tealdeer-rs/tealdeer) |

> **eza vs lsd:** eza is preferred, lsd is the fallback. eza publishes no macOS
> release binary, so on a Mac it needs `brew install eza`; until then the alias
> block silently falls back to lsd and `ls` keeps working either way.

## Shell

`~/.bashrc` is **never touched**. Fedora's stock `~/.bashrc` already sources
`~/.bashrc.d/*`, and that hook is what lets bash keep working untouched through
the whole zsh migration. `shell/shared/*.sh` is symlinked there *and* sourced by
zsh, so the two shells cannot drift.

Drop-ins are numbered; **overrides need a higher number, not just an OS
suffix** — alphabetically `10-x.linux.zsh` sorts *before* `10-x.zsh`, so a
suffix alone would let shared config clobber OS-specific config.

`zsh-autosuggestions` and `zsh-syntax-highlighting` are deliberately **not** in
the oh-my-zsh `plugins=()` array. Fedora's RPMs ship no `.plugin.zsh`, so they
would not load at all — and sourcing them from numbered drop-ins also fixes a
real ordering bug: syntax-highlighting must load *after* every ZLE widget
exists, including fzf's, but inside the array it loads during `oh-my-zsh.sh`,
before the fzf init.

## Gotchas

- **`p10k configure` breaks the link.** It renames a temp file over
  `~/.p10k.zsh`, replacing the rendered file. To keep the result, copy it back
  to `templates/.p10k.zsh.in` and re-apply the `${TN_*}` variables.
- **Never run `install.sh` as root.** It calls sudo only where needed; as root
  it would leave `~/.oh-my-zsh`, the font dir and every symlink root-owned.
  There is a hard guard, but the mistake is easy if you also use a provisioning
  repo whose scripts all *require* root.
- **Fonts:** use the `JetBrainsMono Nerd Font` family — not `Mono` (icons
  squeezed into one cell) or `Propo` (proportional), and not the `NL` cut (no
  ligatures). Custom fontconfig rules go in `conf.d/`, never `fonts.conf`, which
  KDE regenerates.
- **Never leave stray files in `~/.bashrc.d/`.** Fedora's `~/.bashrc` globs
  `~/.bashrc.d/*`, not `*.sh`, so *anything* in there is sourced — and a
  `10-aliases.sh.bak` sorts **after** `10-aliases.sh` and silently wins. This is
  why `link_file` backs up into `backup-<date>/` rather than beside the file.
- **`bat cache --build`** must be rerun after every bat upgrade or the theme
  vanishes with "unknown theme". `bin/tn-render` does it for you.
- **eza's `theme.yml` schema** has churned across releases. If eza starts
  warning on every invocation, delete the file and use `EZA_COLORS` instead.

See [`docs/linux.md`](docs/linux.md) and [`docs/macos.md`](docs/macos.md).

## Credits

[Oh-My-Zsh](https://github.com/ohmyzsh/ohmyzsh) ·
[Powerlevel10k](https://github.com/romkatv/powerlevel10k) ·
[kitty](https://github.com/kovidgoyal/kitty) ·
[Hyper](https://github.com/vercel/hyper) ·
[Tokyo Night](https://github.com/folke/tokyonight.nvim) ·
[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
