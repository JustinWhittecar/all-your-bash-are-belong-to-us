# all-your-bash-are-belong-to-us

One-command setup for a fully-loaded macOS terminal with Zsh, Powerlevel10k, Hyper, and modern CLI tools.

<img width="1127" height="781" alt="Screenshot 2026-01-27 at 11 15 29 PM" src="https://github.com/user-attachments/assets/44bed99c-61b9-4b7d-a065-985dcfcaa91e" />

## Tools

| Tool | Description | Link |
|------|-------------|------|
| **bat** | A `cat` clone with syntax highlighting and git integration | [sharkdp/bat](https://github.com/sharkdp/bat) |
| **lsd** | Modern replacement for `ls` with icons and colors | [lsd-rs/lsd](https://github.com/lsd-rs/lsd) |
| **fzf** | General-purpose command-line fuzzy finder | [junegunn/fzf](https://github.com/junegunn/fzf) |
| **zoxide** | A smarter `cd` command that learns your habits | [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide) |
| **fastfetch** | Fast, highly customizable system information tool | [fastfetch-cli/fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| **gh** | GitHub's official CLI | [cli/cli](https://github.com/cli/cli) |
| **tldr** | Simplified, community-driven man pages (tealdeer) | [tealdeer-rs/tealdeer](https://github.com/tealdeer-rs/tealdeer) |

## Features

### Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `lsd` | File listing with icons and colors |
| `ll` | `lsd -la` | Detailed file listing |
| `lt` | `lsd --tree` | Tree view of directories |
| `cat` | `bat` | Syntax-highlighted file viewing |
| `glog` | `git log --oneline --graph --decorate -20` | Compact git history |
| `ff` | `fastfetch` | System information at a glance |

### Shell Behavior

- **Auto-correction** enabled for typos in commands
- **50,000-line shared history** with deduplication and blank trimming (`SHARE_HISTORY`, `HIST_IGNORE_ALL_DUPS`, `HIST_REDUCE_BLANKS`)
- **Completion waiting dots** shown while tab-completion loads

### fzf Keybindings

| Keybinding | Action |
|------------|--------|
| `Ctrl-R` | Fuzzy search command history |
| `Ctrl-T` | Fuzzy find files and insert path |
| `Alt-C` | Fuzzy find directories and `cd` into them |

### zoxide Smart `cd`

Use `z` instead of `cd` to jump to frequently visited directories:

```bash
z projects    # jumps to ~/projects (or wherever you go most)
z dot         # jumps to ~/dotfiles
zi            # interactive selection with fzf
```

### Prompt (Powerlevel10k)

- **Pure-style** minimalist prompt with `>` symbol
- **Git status** — branch name, dirty indicator (`*`), ahead/behind arrows
- **Transient prompt** — previous commands collapse to just `>` for a clean scrollback
- **Right prompt** — command duration (>5s), virtualenv, user@host (SSH only), 12h clock
- **Instant prompt** — prompt appears immediately while plugins load in the background

## Shell Plugins

| Plugin | Description |
|--------|-------------|
| **git** | Git aliases and functions (`gst`, `ga`, `gc`, etc.) |
| **sudo** | Press `Esc` twice to prepend `sudo` to the current/last command |
| **copypath** | Copy the current directory path to the clipboard |
| **web-search** | Search the web from the terminal (`google`, `ddg`, etc.) |
| **zsh-autosuggestions** | Fish-like autosuggestions based on history |
| **zsh-syntax-highlighting** | Real-time syntax highlighting as you type |

## Hyper Terminal

- **Tokyo Night** color theme with semi-transparent background (`rgba(26, 27, 38, 0.93)`)
- **JetBrainsMono Nerd Font** at 14px with ligatures enabled
- **WebGL disabled** for transparency support
- **Plugins:**
  - `hyper-search` — in-terminal search
  - `hyperborder` — gradient border effect
  - `hyper-pane` — pane navigation with hotkeys
  - `hyper-tab-icons` — process icons in tabs
  - `hyper-statusline` — status bar with git info

## Prerequisites

- **macOS** (Apple Silicon or Intel)
- **git** (pre-installed on macOS)
- **curl** (pre-installed on macOS)

## Quick Install

```bash
git clone https://github.com/$(gh api user -q .login)/all-your-bash-are-belong-to-us.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

Or manually:

```bash
git clone https://github.com/YOUR_USERNAME/all-your-bash-are-belong-to-us.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## What the Install Script Does

1. **Detects architecture** — identifies Apple Silicon (arm64) vs Intel (x86_64) and maps per-tool arch labels
2. **Creates directories** — `~/.local/bin` for CLI tools, `~/Library/Fonts` for fonts
3. **Adds `~/.local/bin` to PATH** — ensures freshly installed tools are immediately available
4. **Installs Oh-My-Zsh** — unattended install if `~/.oh-my-zsh` doesn't exist
5. **Installs Powerlevel10k** — clones the theme into Oh-My-Zsh's custom themes directory
6. **Installs ZSH plugins** — clones `zsh-autosuggestions` and `zsh-syntax-highlighting`
7. **Installs 7 CLI tools** — `bat`, `lsd`, `fzf`, `zoxide`, `fastfetch`, `gh`, `tldr` — each into `~/.local/bin`, skipping any already installed
8. **Installs JetBrainsMono Nerd Font** — downloads and extracts to `~/Library/Fonts`
9. **Installs Hyper.app** — downloads DMG, mounts it, copies `.app` to `/Applications/`
10. **Symlinks dotfiles** — links `.zshrc`, `.p10k.zsh`, `.hyper.js` from `~/dotfiles/` to `~/`, backing up existing files as `*.backup`

Every step is idempotent — running `./install.sh` again skips anything already set up.

## Post-Install Steps

```bash
exec zsh                 # reload shell with new config
p10k configure           # (optional) reconfigure the prompt interactively
gh auth login            # authenticate GitHub CLI
tldr --update            # download tldr page cache
```

## File Structure

```
~/dotfiles/
├── README.md          # this file
├── install.sh         # idempotent setup script
├── .gitignore         # ignores .DS_Store and *.backup
├── .zshrc             # Zsh configuration (symlinked to ~/.zshrc)
├── .p10k.zsh          # Powerlevel10k prompt config (symlinked to ~/.p10k.zsh)
└── .hyper.js          # Hyper terminal config (symlinked to ~/.hyper.js)
```

## Customization Tips

- **Add more aliases** — edit `.zshrc` and add them below the existing alias block
- **Change the prompt style** — run `p10k configure` or edit `.p10k.zsh` directly
- **Switch terminal theme** — modify the `colors` object and `backgroundColor` in `.hyper.js`
- **Add Oh-My-Zsh plugins** — append to the `plugins=(...)` array in `.zshrc`
- **Install more CLI tools** — add a new `install_toolname()` function to `install.sh` following the existing pattern

## Credits

- [Oh-My-Zsh](https://github.com/ohmyzsh/ohmyzsh) — Zsh framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) — Zsh prompt theme
- [Hyper](https://github.com/vercel/hyper) — Electron-based terminal
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) — color scheme inspiration
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) — patched fonts with icons
- [bat](https://github.com/sharkdp/bat), [lsd](https://github.com/lsd-rs/lsd), [fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide), [fastfetch](https://github.com/fastfetch-cli/fastfetch), [gh](https://github.com/cli/cli), [tealdeer](https://github.com/tealdeer-rs/tealdeer) — the CLI tools
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) — Zsh plugins
