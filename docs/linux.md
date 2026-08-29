# Linux (Fedora) notes

Target: Fedora 44 KDE Plasma 6.7, Wayland. Should work on any dnf-based distro;
add `lib/os-<id>.sh` for anything else.

## What needs root

Exactly three things, all Linux-only:

| thing | why |
|---|---|
| `dnf install` | packages |
| `add-shell` | register zsh in `/etc/shells` (Fedora's zsh RPM usually does this itself) |
| `chsh` | prompts for **your own** password via PAM — this is not sudo |

Fonts, oh-my-zsh, p10k, every symlink, kitty config and every theme file are
user-level. `run_root()` auto-selects `SUDO_ASKPASS=/usr/bin/ksshaskpass` in a
graphical session and falls back to a terminal prompt over SSH.

## Switching login shell

Run `install.sh` without `--set-shell` first and live in `exec zsh` for a day.
The daily-driver decision and the passwd change should not be the same command.

```bash
./install.sh --set-shell --only 80-login-shell
```

It gates on `zsh -n ~/.zshrc`, a full `zsh -lic` startup, and a command
resolution check. Any failure means no chsh.

### If zsh breaks

**A broken `~/.zshrc` cannot affect your desktop session.** The login manager
and systemd user units do not run your login shell — there is no black-screen
path here, even on a machine with no iGPU. Worst case is errors at the top of a
terminal and an unstyled prompt.

- KRunner (Alt-Space) → `konsole -e bash`
- `Ctrl-Alt-F3` for a TTY
- `zsh -f` — no rc files at all
- `chsh -s /bin/bash` to revert
- `~/.zshrc` is a symlink into a git repo, so `git checkout -- zsh/zshrc` is a
  complete revert

## Rolling back the KDE theming

```bash
plasma-apply-colorscheme BreezeDark
```

Only the colour scheme was ever applied, and `plasma-apply-colorscheme` writes
just the `[Colors:*]` and `[WM]` groups of `kdeglobals`. Your panel layout,
tiling config and `kwinrc` were never touched. Full pre-flight backups are in
`backup-<date>/`.

System Settings will show the Global Theme as "modified" after applying a custom
scheme. That is expected — but **re-applying the Fedora global theme to "fix" it
undoes the colour scheme.**

## Blur

There isn't any, deliberately. Plasma 6.7 dropped `org_kde_kwin_blur_manager`
and kitty has not implemented `ext_background_effect_manager_v1`, so
`background_blur` silently no-ops. At 0.93 opacity only 7% of the backdrop
composites through, where a low-pass filter is imperceptible — blur is something
you notice at 0.70–0.85.

Do **not** install `kwin-effects-forceblur`: COPR-only, reimplements a
compositor effect, needs a rebuild every Plasma release, and a misbehaving KWin
effect on a machine whose only display output is the GPU is a bad trade for zero
visible gain.

If you ever drop opacity below ~0.85 and miss blur, the answer is Konsole (which
gets blur natively through KWin), not a third-party effect. The profile is
already installed — `konsole --profile TokyoNight`. You trade ligatures for it.

## Clipboard

`wl-clipboard` and `xdg-utils` are required for oh-my-zsh's `copypath` and
`web-search`. oh-my-zsh gates its `wl-copy` branch on `$WAYLAND_DISPLAY`, which
is unset in a TTY, over SSH and in some tmux contexts — so
`zsh/zshrc.d/60-clipboard.zsh` overrides `clipcopy`/`clippaste` unconditionally
and adds `pbcopy`/`pbpaste` aliases.
