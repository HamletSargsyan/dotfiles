#!/bin/bash

SUDO_COMMAND=
PKG_MANAGER=

if [ -n "$TERMUX_VERSION" ]; then
    PKG_MANAGER="pkg"
else
    SUDO_COMMAND="sudo"
    PKG_MANAGER="apt"
fi

packages=(
    git
    python3
    python3-pip
    rust
    batcat
    bpython
    neofetch
    neovim
    calc
    htop
    curl
    wget
    golang
)

pip_packages=(
    ruff
    black
    pyright
)

log() {
    local log_level=$1
    shift
    local message=$@
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local log_file="dotfiles_installer.log"
    
    case $log_level in
        "INFO") echo -e "[${timestamp}] [INFO] ${message}" | tee -a "$log_file" ;;
        "WARNING") echo -e "[${timestamp}] [WARNING] ${message}" >&2 | tee -a "$log_file" ;;
        "ERROR") echo -e "[${timestamp}] [ERROR] ${message}" >&2 | tee -a "$log_file" ;;
        *) echo -e "[${timestamp}] [UNKNOWN] ${message}" >&2 | tee -a "$log_file" ;;
    esac
}


log INFO "Start installing packages"
for package in "${packages[@]}"
do
    log INFO "Installing $package"
    $SUDO_COMMAND $PKG_MANAGER install $package
done


log INFO "Start installing packages with pip"
for package in "${pip_packages[@]}"
do
    log INFO "Installing $package"
    pip install $package
done


log INFO "Start installing packages with from scripts"

log INFO "Installing poetry"
curl -sSL https://install.python-poetry.org | python3 -

log INFO "Installing zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

log INFO "changing shell"
chsh $(which zsh)