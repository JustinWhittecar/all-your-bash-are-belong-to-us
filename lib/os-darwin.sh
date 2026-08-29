# macOS. Behaviour is unchanged from the original flat install.sh -- the
# per-tool installers below are the same GitHub-release tarball fetches, moved
# here verbatim so the macOS path cannot regress while Linux support is added.
# shellcheck shell=bash

FONT_DIR="$HOME/Library/Fonts"

case "$(uname -m)" in
    arm64)  BAT_ARCH=aarch64; LSD_ARCH=aarch64; FZF_ARCH=darwin_arm64
            ZOXIDE_ARCH=aarch64; GH_ARCH=arm64; TLDR_ARCH=aarch64; HYPER_ARCH=arm64 ;;
    x86_64) BAT_ARCH=x86_64;  LSD_ARCH=x86_64;  FZF_ARCH=darwin_amd64
            ZOXIDE_ARCH=x86_64;  GH_ARCH=amd64; TLDR_ARCH=x86_64;  HYPER_ARCH=x64 ;;
    *)      die "Unsupported macOS architecture: $(uname -m)" ;;
esac

_TMP="$(mktemp -d)"
trap 'rm -rf "$_TMP"' EXIT

pkg_missing() {
    local t out=()
    for t in "$@"; do have "$t" || out+=("$t"); done
    # See the note in lib/os-fedora.sh: an empty array must print nothing.
    (( ${#out[@]} )) && printf '%s\n' "${out[@]}"
    return 0
}

pkg_install() {
    local t
    for t in "$@"; do
        case "$t" in
            bat)       _install_bat ;;
            lsd)       _install_lsd ;;
            fzf)       _install_fzf ;;
            zoxide)    _install_zoxide ;;
            fastfetch) _install_fastfetch ;;
            gh)        _install_gh ;;
            tldr)      _install_tldr ;;
            eza)
                # eza publishes NO macOS release binary (Linux/Windows only),
                # so unlike every other tool here it cannot be tarball-installed.
                if have brew; then run brew install eza
                else warn "eza needs Homebrew on macOS: brew install eza (ls falls back to lsd until then)"
                fi ;;
            delta)
                if have brew; then run brew install git-delta
                else warn "git-delta needs Homebrew on macOS: brew install git-delta"
                fi ;;
            *) warn "no macOS installer for '$t', skipping" ;;
        esac
    done
}

_install_bat() {
    say "installing bat"
    local tag ver url; tag="$(get_latest_tag sharkdp bat)"; ver="${tag#v}"
    url="https://github.com/sharkdp/bat/releases/download/${tag}/bat-${ver}-${BAT_ARCH}-apple-darwin.tar.gz"
    run curl -fsSL "$url" -o "$_TMP/bat.tar.gz"
    run tar -xzf "$_TMP/bat.tar.gz" -C "$_TMP"
    run install -m 0755 "$_TMP/bat-${ver}-${BAT_ARCH}-apple-darwin/bat" "$HOME/.local/bin/bat"
}

_install_lsd() {
    say "installing lsd"
    local tag ver url; tag="$(get_latest_tag lsd-rs lsd)"; ver="${tag#v}"
    url="https://github.com/lsd-rs/lsd/releases/download/${tag}/lsd-${ver}-${LSD_ARCH}-apple-darwin.tar.gz"
    run curl -fsSL "$url" -o "$_TMP/lsd.tar.gz"
    run tar -xzf "$_TMP/lsd.tar.gz" -C "$_TMP"
    run install -m 0755 "$_TMP/lsd-${ver}-${LSD_ARCH}-apple-darwin/lsd" "$HOME/.local/bin/lsd"
}

_install_fzf() {
    say "installing fzf"
    local tag ver url; tag="$(get_latest_tag junegunn fzf)"; ver="${tag#v}"
    url="https://github.com/junegunn/fzf/releases/download/${tag}/fzf-${ver}-${FZF_ARCH}.tar.gz"
    run curl -fsSL "$url" -o "$_TMP/fzf.tar.gz"
    run tar -xzf "$_TMP/fzf.tar.gz" -C "$_TMP"
    run install -m 0755 "$_TMP/fzf" "$HOME/.local/bin/fzf"
}

_install_zoxide() {
    say "installing zoxide"
    local tag ver url; tag="$(get_latest_tag ajeetdsouza zoxide)"; ver="${tag#v}"
    url="https://github.com/ajeetdsouza/zoxide/releases/download/${tag}/zoxide-${ver}-${ZOXIDE_ARCH}-apple-darwin.tar.gz"
    run curl -fsSL "$url" -o "$_TMP/zoxide.tar.gz"
    run tar -xzf "$_TMP/zoxide.tar.gz" -C "$_TMP"
    run install -m 0755 "$_TMP/zoxide" "$HOME/.local/bin/zoxide"
}

_install_fastfetch() {
    say "installing fastfetch"
    local tag url; tag="$(get_latest_tag fastfetch-cli fastfetch)"   # no v prefix
    url="https://github.com/fastfetch-cli/fastfetch/releases/download/${tag}/fastfetch-macos-universal.tar.gz"
    run curl -fsSL "$url" -o "$_TMP/fastfetch.tar.gz"
    run tar -xzf "$_TMP/fastfetch.tar.gz" -C "$_TMP"
    run install -m 0755 "$_TMP/fastfetch/usr/bin/fastfetch" "$HOME/.local/bin/fastfetch"
}

_install_gh() {
    say "installing gh"
    local tag ver url; tag="$(get_latest_tag cli cli)"; ver="${tag#v}"
    url="https://github.com/cli/cli/releases/download/${tag}/gh_${ver}_macOS_${GH_ARCH}.zip"
    run curl -fsSL "$url" -o "$_TMP/gh.zip"
    run unzip -qo "$_TMP/gh.zip" -d "$_TMP"
    run install -m 0755 "$_TMP/gh_${ver}_macOS_${GH_ARCH}/bin/gh" "$HOME/.local/bin/gh"
}

_install_tldr() {
    say "installing tldr (tealdeer)"
    local tag url; tag="$(get_latest_tag tealdeer-rs tealdeer)"
    url="https://github.com/tealdeer-rs/tealdeer/releases/download/${tag}/tealdeer-macos-${TLDR_ARCH}"
    run curl -fsSL "$url" -o "$HOME/.local/bin/tldr"
    run chmod +x "$HOME/.local/bin/tldr"
}

font_refresh() { :; }   # macOS picks up ~/Library/Fonts with no cache step

zsh_plugin_paths() {
    printf '%s\n' \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
}

install_terminal() {
    if [[ -d /Applications/Hyper.app ]]; then skip "Hyper.app already installed"; return 0; fi
    say "installing Hyper.app"
    local tag url mount; tag="$(get_latest_tag vercel hyper)"
    url="https://github.com/vercel/hyper/releases/download/${tag}/Hyper-mac-${HYPER_ARCH}.dmg"
    run curl -fsSL "$url" -o "$_TMP/Hyper.dmg"
    (( DRY_RUN )) && return 0
    # The original called hdiutil attach a SECOND time in its fallback branch,
    # against an already-mounted image. Mount once, parse once.
    mount="$(hdiutil attach "$_TMP/Hyper.dmg" -nobrowse -quiet | grep -o '/Volumes/.*' | head -1)"
    [[ -n $mount ]] || die "could not mount Hyper.dmg"
    cp -R "$mount/Hyper.app" /Applications/
    hdiutil detach "$mount" -quiet || true
    ok "Hyper.app installed"
}
