#!/bin/bash

SUDO_COMMAND=
PKG_MANAGER=

if [ -n "$TERMUX_VERSION" ]; then
    termux-change-repo
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
    which
    man
)

pip_packages=(
    black
    pyright
)


$SUDO_COMMAND $PKG_MANAGER update -y

if [ ! -n $TERMUX_VERSION ];
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


sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


cp zshrc ~/.zshrc
cp p10k.zsh ~/.p10k.zsh

mkdir -p ~/.config
mkdir -p ~/repos
mkdir -p ~/tests


git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

git clone https://github.com/HamletSargsyan/astronvim_config ~/.config/nvim

curl https://getcroc.schollz.com | bash

if [[ $TERMUX_VERSION ]]; then
    rm -rfv ~/.termux/
    cp -r ./termux/ ~/.termux/
fi

go install github.com/bloznelis/typioca@latest
go install github.com/mistakenelf/fm@latest

touch ~/.hushlogin
