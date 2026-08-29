#!/usr/bin/env bash
# Tokyo Night — THE single source of truth for colour in this repo.
#
# This is the ONLY file that may contain a literal hex colour. Everything else
# (kitty, Konsole, KDE, bat, fzf, delta, btop, tmux, tealdeer, p10k) is a
# template under templates/ rendered by bin/tn-render.
#
# Values are taken verbatim from the macOS .hyper.js so both machines agree.
#
# PRINCIPLE: prefer ANSI indices over hex wherever a tool supports them.
# fastfetch ("keyColor": "blue") and LS_COLORS resolve through the terminal
# palette for free — no templating, and they stay correct if this file changes.
# Hex is only for tools that cannot do that.

# --- core ---------------------------------------------------------------
TN_BG=1a1b26          # background
TN_BG_DARK=16161e     # darker inset surfaces (views, tooltips)
TN_BG_ALT=24283b      # alternate rows
TN_BG_HL=292e42       # buttons / raised surfaces
TN_FG=a9b1d6          # foreground
TN_COMMENT=565f89     # de-emphasised text; also brightBlack
TN_BORDER=3b4261
TN_CURSOR=c0caf5
TN_CURSOR_TEXT=1a1b26

# Selection. The literal 0.6-alpha blend of #283457 over #1a1b26 is #212940,
# but that is so low-contrast it reads as "did that even select?".
# #283457 is canonical Tokyo Night and is what we use; the blend is kept for
# anyone who wants the pedantic pixel-match.
TN_SEL=283457
TN_SEL_FLAT=212940

# --- 16-colour ANSI -----------------------------------------------------
# NOTE: brights 9-14 are deliberately IDENTICAL to 1-6. That is stock
# Tokyo Night, not an oversight. Do not "brighten" them.
TN_BLACK=414868       TN_BRBLACK=565f89
TN_RED=f7768e         TN_BRRED=f7768e
TN_GREEN=9ece6a       TN_BRGREEN=9ece6a
TN_YELLOW=e0af68      TN_BRYELLOW=e0af68
TN_BLUE=7aa2f7        TN_BRBLUE=7aa2f7
TN_MAGENTA=bb9af7     TN_BRMAGENTA=bb9af7
TN_CYAN=7dcfff        TN_BRCYAN=7dcfff
TN_WHITE=a9b1d6       TN_BRWHITE=c0caf5

# --- diff (from tokyonight.nvim's own diff palette) ---------------------
TN_DIFF_ADD=20303b        TN_DIFF_DEL=37222c
TN_DIFF_ADD_EMPH=2c5a66   TN_DIFF_DEL_EMPH=713137

# --- non-colour design tokens -------------------------------------------
TN_OPACITY=0.93
TN_FONT="JetBrainsMono Nerd Font"
TN_FONT_SIZE=14.0
TN_FONT_SIZE_UI=11
TN_LINE_HEIGHT=120        # percent; the .hyper.js lineHeight of 1.2
TN_PAD_V=12
TN_PAD_H=14

# --- derive #rrggbb / r,g,b / 0xrrggbb for every colour -----------------
# Consumers need different encodings: kitty/fzf/delta/tmux want #rrggbb,
# KDE .colors + Konsole .colorscheme + tealdeer want decimal r,g,b.
# Deriving them here means no second representation is ever hand-written.
_tn_derive() {
    local name hex
    for name in $(compgen -v | grep '^TN_'); do
        hex="${!name}"
        [[ $hex =~ ^[0-9a-fA-F]{6}$ ]] || continue
        export "${name}_HASH=#${hex}"
        export "${name}_RGB=$((16#${hex:0:2})),$((16#${hex:2:2})),$((16#${hex:4:2}))"
        export "${name}_0X=0x${hex}"
        export "$name"
    done
    # non-colour tokens still need exporting for envsubst
    export TN_OPACITY TN_FONT TN_FONT_SIZE TN_FONT_SIZE_UI \
           TN_LINE_HEIGHT TN_PAD_V TN_PAD_H
}
_tn_derive
unset -f _tn_derive
