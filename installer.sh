#!/bin/bash

git submodule update --init --recursive


SUDO_COMMAND=
PKG_MANAGER=

if [ -n "$TERMUX_VERSION" ]; then
    PKG_MANAGER="pkg"
else
    SUDO_COMMAND="sudo"
    PKG_MANAGER="apt"
fi

packages=(
    python3
    rust
    bat
    bpython
    neofetch
    neovim
    calc
    htop
    curl
    wget
    golang
    tree
    zsh
)

pip_packages=(
    black
    pyright
)


$SUDO_COMMAND $PKG_MANAGER update -y

if [ ! -n $TERMUX_VERSION];
then
    pip install ruff
    curl -sSL https://install.python-poetry.org | python3 -

fi


for package in "${packages[@]}"
do
    yes | $SUDO_COMMAND $PKG_MANAGER install $package
done


for package in "${pip_packages[@]}"
do
    pip install $package
done



chsh --shell $(which zsh)

# ---------------------------------------------------------------------------- #

cp zshrc ~/.zshrc
cp p10k.zsh ~/.p10k.zsh
cp -rv oh-my-zsh ~/.oh-my-zsh

mkdir -p ~/.config

 
