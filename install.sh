#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# all-your-bash-are-belong-to-us — dotfiles installer
# Idempotent setup script for a full macOS terminal environment.
# ==============================================================================

# --- 1. Detect architecture ---------------------------------------------------
ARCH="$(uname -m)"
case "$ARCH" in
  arm64)
    BAT_ARCH="aarch64"
    LSD_ARCH="aarch64"
    FZF_ARCH="darwin_arm64"
    ZOXIDE_ARCH="aarch64"
    FASTFETCH_ARCH="aarch64"
    GH_ARCH="arm64"
    TLDR_ARCH="aarch64"
    FONT_ARCH=""  # fonts are arch-independent
    ;;
  x86_64)
    BAT_ARCH="x86_64"
    LSD_ARCH="x86_64"
    FZF_ARCH="darwin_amd64"
    ZOXIDE_ARCH="x86_64"
    FASTFETCH_ARCH="x86_64"
    GH_ARCH="amd64"
    TLDR_ARCH="x86_64"
    FONT_ARCH=""
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

echo "Detected architecture: $ARCH"

# --- 2. Set up directories ----------------------------------------------------
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Library/Fonts"

TMPDIR_INSTALL="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_INSTALL"' EXIT

# --- 3. Add ~/.local/bin to PATH ----------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# --- Helper: get latest release tag from GitHub --------------------------------
get_latest_tag() {
  local owner="$1"
  local repo="$2"
  curl -fsSL "https://api.github.com/repos/${owner}/${repo}/releases/latest" \
    | grep '"tag_name"' \
    | sed -E 's/.*"tag_name":\s*"([^"]+)".*/\1/'
}

# --- 4. Install Oh-My-Zsh (if missing) ----------------------------------------
install_omz() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "Oh-My-Zsh already installed, skipping."
  else
    echo "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
}

# --- 5. Install Powerlevel10k theme -------------------------------------------
install_p10k() {
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [[ -d "$dest" ]]; then
    echo "Powerlevel10k already installed, skipping."
  else
    echo "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dest"
  fi
}

# --- 6. Install ZSH plugins ---------------------------------------------------
install_zsh_plugins() {
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

  if [[ -d "$custom/zsh-autosuggestions" ]]; then
    echo "zsh-autosuggestions already installed, skipping."
  else
    echo "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$custom/zsh-autosuggestions"
  fi

  if [[ -d "$custom/zsh-syntax-highlighting" ]]; then
    echo "zsh-syntax-highlighting already installed, skipping."
  else
    echo "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/zsh-syntax-highlighting"
  fi
}

# --- 7. CLI tool installers ---------------------------------------------------

install_bat() {
  if command -v bat &>/dev/null; then
    echo "bat already installed, skipping."
    return
  fi
  echo "Installing bat..."
  local tag ver
  tag="$(get_latest_tag sharkdp bat)"
  ver="${tag#v}"
  local url="https://github.com/sharkdp/bat/releases/download/${tag}/bat-${ver}-${BAT_ARCH}-apple-darwin.tar.gz"
  curl -fsSL "$url" -o "$TMPDIR_INSTALL/bat.tar.gz"
  tar -xzf "$TMPDIR_INSTALL/bat.tar.gz" -C "$TMPDIR_INSTALL"
  cp "$TMPDIR_INSTALL/bat-${ver}-${BAT_ARCH}-apple-darwin/bat" "$HOME/.local/bin/bat"
  chmod +x "$HOME/.local/bin/bat"
  echo "bat ${ver} installed."
}

install_lsd() {
  if command -v lsd &>/dev/null; then
    echo "lsd already installed, skipping."
    return
  fi
  echo "Installing lsd..."
  local tag ver
  tag="$(get_latest_tag lsd-rs lsd)"
  ver="${tag#v}"
  local url="https://github.com/lsd-rs/lsd/releases/download/${tag}/lsd-${ver}-${LSD_ARCH}-apple-darwin.tar.gz"
  curl -fsSL "$url" -o "$TMPDIR_INSTALL/lsd.tar.gz"
  tar -xzf "$TMPDIR_INSTALL/lsd.tar.gz" -C "$TMPDIR_INSTALL"
  cp "$TMPDIR_INSTALL/lsd-${ver}-${LSD_ARCH}-apple-darwin/lsd" "$HOME/.local/bin/lsd"
  chmod +x "$HOME/.local/bin/lsd"
  echo "lsd ${ver} installed."
}

install_fzf() {
  if command -v fzf &>/dev/null; then
    echo "fzf already installed, skipping."
    return
  fi
  echo "Installing fzf..."
  local tag ver
  tag="$(get_latest_tag junegunn fzf)"
  ver="${tag#v}"
  local url="https://github.com/junegunn/fzf/releases/download/${tag}/fzf-${ver}-${FZF_ARCH}.tar.gz"
  curl -fsSL "$url" -o "$TMPDIR_INSTALL/fzf.tar.gz"
  tar -xzf "$TMPDIR_INSTALL/fzf.tar.gz" -C "$TMPDIR_INSTALL"
  cp "$TMPDIR_INSTALL/fzf" "$HOME/.local/bin/fzf"
  chmod +x "$HOME/.local/bin/fzf"
  echo "fzf ${ver} installed."
}

install_zoxide() {
  if command -v zoxide &>/dev/null; then
    echo "zoxide already installed, skipping."
    return
  fi
  echo "Installing zoxide..."
  local tag ver
  tag="$(get_latest_tag ajeetdsouza zoxide)"
  ver="${tag#v}"
  local url="https://github.com/ajeetdsouza/zoxide/releases/download/${tag}/zoxide-${ver}-${ZOXIDE_ARCH}-apple-darwin.tar.gz"
  curl -fsSL "$url" -o "$TMPDIR_INSTALL/zoxide.tar.gz"
  tar -xzf "$TMPDIR_INSTALL/zoxide.tar.gz" -C "$TMPDIR_INSTALL"
  cp "$TMPDIR_INSTALL/zoxide" "$HOME/.local/bin/zoxide"
  chmod +x "$HOME/.local/bin/zoxide"
  echo "zoxide ${ver} installed."
}

install_fastfetch() {
  if command -v fastfetch &>/dev/null; then
    echo "fastfetch already installed, skipping."
    return
  fi
  echo "Installing fastfetch..."
  local tag
  # fastfetch tags have NO v prefix
  tag="$(get_latest_tag fastfetch-cli fastfetch)"
  local url="https://github.com/fastfetch-cli/fastfetch/releases/download/${tag}/fastfetch-macos-universal.tar.gz"
  curl -fsSL "$url" -o "$TMPDIR_INSTALL/fastfetch.tar.gz"
  tar -xzf "$TMPDIR_INSTALL/fastfetch.tar.gz" -C "$TMPDIR_INSTALL"
  cp "$TMPDIR_INSTALL/fastfetch/usr/bin/fastfetch" "$HOME/.local/bin/fastfetch"
  chmod +x "$HOME/.local/bin/fastfetch"
  echo "fastfetch ${tag} installed."
}

install_gh() {
  if command -v gh &>/dev/null; then
    echo "gh already installed, skipping."
    return
  fi
  echo "Installing gh..."
  local tag ver
  tag="$(get_latest_tag cli cli)"
  ver="${tag#v}"
  local url="https://github.com/cli/cli/releases/download/${tag}/gh_${ver}_macOS_${GH_ARCH}.zip"
  curl -fsSL "$url" -o "$TMPDIR_INSTALL/gh.zip"
  unzip -qo "$TMPDIR_INSTALL/gh.zip" -d "$TMPDIR_INSTALL"
  cp "$TMPDIR_INSTALL/gh_${ver}_macOS_${GH_ARCH}/bin/gh" "$HOME/.local/bin/gh"
  chmod +x "$HOME/.local/bin/gh"
  echo "gh ${ver} installed."
}

install_tldr() {
  if command -v tldr &>/dev/null; then
    echo "tldr already installed, skipping."
    return
  fi
  echo "Installing tldr (tealdeer)..."
  local tag
  tag="$(get_latest_tag tealdeer-rs tealdeer)"
  local url="https://github.com/tealdeer-rs/tealdeer/releases/download/${tag}/tealdeer-macos-${TLDR_ARCH}"
  curl -fsSL "$url" -o "$HOME/.local/bin/tldr"
  chmod +x "$HOME/.local/bin/tldr"
  echo "tldr (tealdeer) ${tag} installed."
}

# --- 8. Install JetBrainsMono Nerd Font ----------------------------------------
install_nerd_font() {
  if ls "$HOME/Library/Fonts"/JetBrainsMonoNerd* &>/dev/null; then
    echo "JetBrainsMono Nerd Font already installed, skipping."
    return
  fi
  echo "Installing JetBrainsMono Nerd Font..."
  local tag
  tag="$(get_latest_tag ryanoasis nerd-fonts)"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${tag}/JetBrainsMono.tar.xz"
  curl -fsSL "$url" -o "$TMPDIR_INSTALL/JetBrainsMono.tar.xz"
  tar -xJf "$TMPDIR_INSTALL/JetBrainsMono.tar.xz" -C "$HOME/Library/Fonts"
  echo "JetBrainsMono Nerd Font installed."
}

# --- 9. Install Hyper.app ------------------------------------------------------
install_hyper() {
  if [[ -d "/Applications/Hyper.app" ]]; then
    echo "Hyper.app already installed, skipping."
    return
  fi
  echo "Installing Hyper.app..."
  local tag
  tag="$(get_latest_tag vercel hyper)"
  local url="https://github.com/vercel/hyper/releases/download/${tag}/Hyper-mac-arm64.dmg"
  if [[ "$ARCH" == "x86_64" ]]; then
    url="https://github.com/vercel/hyper/releases/download/${tag}/Hyper-mac-x64.dmg"
  fi
  curl -fsSL "$url" -o "$TMPDIR_INSTALL/Hyper.dmg"
  local mount_point
  mount_point="$(hdiutil attach "$TMPDIR_INSTALL/Hyper.dmg" -nobrowse -quiet | grep '/Volumes/' | awk '{print $NF}')"
  # Some DMGs mount with spaces in the name
  if [[ -z "$mount_point" ]]; then
    mount_point="$(hdiutil attach "$TMPDIR_INSTALL/Hyper.dmg" -nobrowse -quiet | tail -1 | sed 's/.*\(\/Volumes\/.*\)/\1/')"
  fi
  cp -R "${mount_point}/Hyper.app" /Applications/
  hdiutil detach "$mount_point" -quiet || true
  echo "Hyper.app installed."
}

# --- 10. Symlink dotfiles ------------------------------------------------------
link_dotfiles() {
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "$0")" && pwd)"

  local files=(".zshrc" ".p10k.zsh" ".hyper.js")
  for file in "${files[@]}"; do
    local src="${dotfiles_dir}/${file}"
    local dest="${HOME}/${file}"

    if [[ ! -f "$src" ]]; then
      echo "Warning: ${src} not found in dotfiles repo, skipping."
      continue
    fi

    # Back up existing file if it's not already a symlink to our dotfile
    if [[ -f "$dest" && ! -L "$dest" ]]; then
      echo "Backing up existing ${dest} to ${dest}.backup"
      mv "$dest" "${dest}.backup"
    elif [[ -L "$dest" ]]; then
      local current_target
      current_target="$(readlink "$dest")"
      if [[ "$current_target" == "$src" ]]; then
        echo "${file} already linked, skipping."
        continue
      fi
      rm "$dest"
    fi

    ln -s "$src" "$dest"
    echo "Linked ${file} -> ${src}"
  done
}

# ==============================================================================
# Main
# ==============================================================================
main() {
  echo ""
  echo "=== all-your-bash-are-belong-to-us ==="
  echo "Setting up your macOS terminal environment..."
  echo ""

  install_omz
  install_p10k
  install_zsh_plugins

  echo ""
  echo "--- Installing CLI tools ---"
  install_bat
  install_lsd
  install_fzf
  install_zoxide
  install_fastfetch
  install_gh
  install_tldr

  echo ""
  echo "--- Installing font & apps ---"
  install_nerd_font
  install_hyper

  echo ""
  echo "--- Linking dotfiles ---"
  link_dotfiles

  echo ""
  echo "=== Setup complete! ==="
  echo ""
  echo "Next steps:"
  echo "  1. Run: exec zsh"
  echo "  2. Run: p10k configure  (if you want to reconfigure the prompt)"
  echo "  3. Run: gh auth login    (to authenticate with GitHub)"
  echo "  4. Run: tldr --update    (to download tldr pages)"
  echo ""
}

main "$@"
