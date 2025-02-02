#!/bin/bash


export CUR_DIR=$(pwd)
export TEMP_DIRS=()
export DRY_RUN=false

for arg in "$@"; do
  if [ "$arg" == "--dry" ]; then
    DRY_RUN=true
    break
  fi
done

source ./utils.sh
source ./packages

preinstall_pkg() {
  log "success" "Starting pre-installation steps..."

  log "info" "checking yay..."
  if check_command yay; then
    log "success" "yay exists"
  else
    log "warning" "yay not exists. Installing..."
    local tmp_dir=$(mktemp -d)
    TEMP_DIRS+=("$tmp_dir")

    run_command "git clone https://aur.archlinux.org/yay.git $tmp_dir/yay"
    run_command "cd $tmp_dir/yay"
    run_command "makepkg -si --noconfirm"

    run_command "cd $CUR_DIR"
    log "success" "yay installed"
  fi

  log "info" "checking pyenv..."
  if check_command pyenv; then
    log "success" "pyenv exists"
  else
    log "warning" "pyenv not exists. Installing..."
    run_command "curl https://pyenv.run | bash"
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    log "success" "pyenv installed"

    local python_version="3.12.7"

    log "info" "installing python $python_version using pyenv..."
    run_command "pyenv install $python_version"
    run_command "pyenv global $python_version"
    log "info" "python $python_version installed"
  fi

  log "info" "checking rustup..."
  if check_command rustup; then
    log "success" "rustup exists"
  else
    log "warning" "rustup not exists. Installing..."
    run_command "sudo pacman -S --noconfirm rustup"
    log "success" "rustup installed"

    log "info" "installing rustup stable..."
    run_command "rustup install stable"
    run_command "rustup default stable"
    log "success" "rustup stable installed"
  fi

  log "info" "checking flatpak..."
  if check_command flatpak; then
    log "success" "flatpak exists"
  else
    log "warning" "flatpak not exists. Installing..."
    run_command "sudo pacman -S --noconfirm flatpak"
    log "success" "flatpak installed"
  fi

  log "info" "adding flatpak repo"
  run_command "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
}

install_pkg() {
  local cmd=$1
  local array_name=$2
  declare -n pkg_list=$array_name

  for pkg in "${pkg_list[@]}"; do
    local full_cmd="$cmd $pkg"

    log "info" "$full_cmd"

    if ! run_command "$full_cmd"; then
      log "error" "Failed to install $pkg"
    else
      log "success" "Installed $pkg"
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
install_pkg "npm install -g" node_packages

log "info" "enabling services"
run_command "sudo systemctl enable --now sshd"
run_command "sudo systemctl enable --now docker.service"
run_command "sudo systemctl enable --now docker.socket"

log "info" "installing oh-my-zsh..."
run_command "RUNZSH=no KEEP_ZSHRC=yes sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
log "success" "oh-my-zsh installed"

log "info" "installing zsh plugins"

run_command "git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
run_command "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
run_command "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

log "info" "copying zsh configs"
run_command "cp zshrc ~/.zshrc"
run_command "cp p10k.zsh ~/.p10k.zsh"

log "info" "checking sdkman..."
if ! check_command sdk; then
  log "warning" "sdkman not exists. Installing..."
  run_command "curl -s \"https://get.sdkman.io\" | bash"
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  log "success" "sdkman installed"

  java_version="19.0.2-open"
  log "info" "installing java $java_version"
  run_command "sdk install java $java_version"
  log "success" "java $java_version installed"
fi

log "info" "checking nvm"
if ! check_command nvm; then
  log "warning" "nvm not exists. Installing..."
  run_command "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
  source ~/.nvm/nvm.sh
  log "success" "nvm installed"

  log "info" "installing node and npm"
  run_command "nvm install node"
  run_command "nvm use node"
  log "success" "node and npm installed"
fi

log "info" "copying fonts"
run_command "mkdir -p ~/.local/share/fonts/"
run_command "cp meslo-font/* ~/.local/share/fonts/"
run_command "fc-cache -f -v"

log "info" "creating directories"
run_command "mkdir -p ~/.config ~/projects ~/tests"

log "info" "installing nvim config"
run_command "mv ~/.config/nvim ~/.config/nvim.bak"
run_command "mv ~/.local/share/nvim ~/.local/share/nvim.bak"
run_command "mv ~/.local/state/nvim ~/.local/state/nvim.bak"
run_command "mv ~/.cache/nvim ~/.cache/nvim.bak"
run_command "git clone https://github.com/HamletSargsyan/astronvim_config ~/.config/nvim"

run_command "rm -rfv \"\${TEMP_DIRS[@]}\""

log "success" "dotfiles installed"
