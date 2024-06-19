#!/bin/bash

SUDO_COMMAND=
PKG_MANAGER=

if [[ -n "$TERMUX_VERSION" ]]; then
    termux-change-repo
    PKG_MANAGER="pkg"
else
    SUDO_COMMAND="sudo"
    PKG_MANAGER="apt"
fi


yes | $SUDO_COMMAND $PKG_MANAGER update
yes | $SUDO_COMMAND $PKG_MANAGER upgrade

packages=(
    "python3"
    "bat"
    "bpython"
    "neofetch"
    "neovim"
    "calc"
    "htop"
    "curl"
    "wget"
    "golang"
    "tree"
    "zsh"
    "which"
    "man"
    "zip"
)

pip_packages=(
    "black"
    "pyright"
    "isort"
    "mypy"
    "pre-commit"
)

$SUDO_COMMAND $PKG_MANAGER update -y

mkdir -p meslo-font
tar -xvf meslo-font.tar -C ./meslo-font

if [[ -z "$TERMUX_VERSION" ]]; then
    curl -sSL https://install.python-poetry.org | python3 -
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    sudo dpkg-divert --rename --add /usr/lib/$(py3versions -d)/EXTERNALLY-MANAGED
    
    pip install ruff
    
    sudo apt install openssh-server
    sudo systemctl start ssh
    sudo systemctl enable ssh

    mkdir -p ~/.local/share/fonts/
    cp meslo-font/* ~/.local/share/fonts/
    fc-cache -f -v
else
    pkg install rust

    cp meslo-font/"MesloLGS NF Regular.ttf" termux/font.ttf
fi

for package in "${packages[@]}"; do
    yes | $SUDO_COMMAND $PKG_MANAGER install "$package"
done

if ! command -v pip &> /dev/null; then
    sudo apt-get install python3-pip
fi

for package in "${pip_packages[@]}"; do
    pip install "$package"
done

RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# echo zsh | chsh

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

if [[ -n "$TERMUX_VERSION" ]]; then
    rm -rfv ~/.termux/
    cp -r ./termux/ ~/.termux/
fi

go install github.com/bloznelis/typioca@latest
go install github.com/mistakenelf/fm@latest

curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 19.0.2-open

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 20


touch ~/.hushlogin

exec zsh
