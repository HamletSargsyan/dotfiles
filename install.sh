#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

CUR_DIR=$(pwd)
TEMP_DIRS=()

source ./utils.sh
source ./packages


preinstall_pkg() {
  log "info" "checking yay..."
  if check_command yay; then
    log "success" "yay exists"
  else
    log "warning" "yay not exists. Installing..."
    local tmp_dir=$(mktemp)
    TEMP_DIRS+=(tmp_dir)
    
    git clone https://aur.archlinux.org/yay.git $tmp_dir/yay
    cd $tmp_dir/yay
    makepkg -si --noconfirm

    log "success" "yay installed"
  fi

  log "info" "checking pyenv..."
  if check_command pyenv; then
    log "success" "pyenv exists"
  else
    log "warning" "pyenv not exists. Installing..."
    curl https://pyenv.run | bash
    log "success" "pyenv installed"

    local python_version="3.12.7"
    
    log "info" "installing python $python_version using pyenv..."
    pyenv install 3.12.7
    pyenv global 3.12.7
    log "info" "python $python_version instelled"

    source ~/.pyenv/bin/
  fi

  log "info" "checking rustup..."
  if check_command rustup; then
    log "success" "rustup exists"
  else
    log "warning" "rustup not exists. Installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    log "success" "rustup installed"
  fi

  log "info" "checking flatpak..."
  if check_command flatpak; then
    log "success" "flatpak exists"
  else
    log "warning" "flatpak not exists. Installing..."
    sudo pacman -S flatpak
    log "success" "flatpak installed"
  fi

  log "info" "adding flatpak repo"
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_pkg() {
  local cmd=$1
  local pkg_list=$2


  for pkg in $pkg_list[@]; do
    local full_cmd="$cmd $pkg"

    log "info" "$full_cmd"

    if ! $full_cmd; then
      log "error" "Failed to install `$pkg`"
    else
      log "success" "Installed `$pkg`"
    fi
  done
}

preinstall_pkg
install_pkg "sudo pacman -S --noconfirm" packages
install_pkg "yay -S --noanswerclean --noansweredit --noanswerdiff" aur_packages
install_pkg "pip install --disable-pip-version-check" pypi_packages
install_pkg "go install" go_packages
install_pkg "cargo install" rust_crates
install_pkg "flatpak install -y" flatpak_apps

log "info" "enabling services"
sudo systemctl enable --now sshd
sudo systemstl enable --now docker.service
sudo systemctl enable --now docker.socket

log "info" "installing oh-my-zsh..."
RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
log "success" "oh-my-zsh installed"

log "info" "installing zsh plugins"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

log "info" "copying zsh configs"
cp zshrc ~/.zshrc
cp p10k.zsh ~/.p10k.zsh

log "info" "checking sdkman..."
if ! check_command sdk; then
  log "warning" "sdkman not exists. Installing..."
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  log "success" "sdkman installed"

  java_version="19.0.2-open"
  log "info" "installing java $java_version"
  sdk install java $java_version
  log "success" "java $java_version installed"
fi

log "info" "checking nvm"
if ! check_command nvm; then
  log "warning" "nvm not exists. Installing..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  source ~/.nvm/nvm.sh
  log "success" "nvm installed"

  log "info" "installing node and npm"
  nvm install node
  nvm use node
  log "success" "node and npm installed"
fi

log "info" "copying fonts"
mkdir -p ~/.local/share/fonts/
cp meslo-font/* ~/.local/share/fonts/
fc-cache -f -v

log "info" "creating directories"
mkdir -p ~/.config ~/projects ~/tests

log "info" "instaling nvim config"
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
git clone https://github.com/HamletSargsyan/astronvim_config ~/.config/nvim

read -p "delete temp directories? [Y/n]: "
while true; do
    read -p "delete temp directories? [Y/n] " yn
    case $yn in
        [Yy]* )
          rm -rfv "${TEMP_DIRS[@]}"
          break
          ;;
        [Nn]* )
          exit
          ;;
        *)
          rm -rfv "${TEMP_DIRS[@]}"
    esac
done

log "success" "dotfiles installed"
