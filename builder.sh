#!/bin/bash

# Определение команд для sudo и пакетного менеджера
SUDO_COMMAND=""
PKG_MANAGER=""

if [[ -n "$TERMUX_VERSION" ]]; then
    termux-change-repo
    PKG_MANAGER="pkg"
else
    if command -v sudo &>/dev/null; then
        SUDO_COMMAND="sudo"
    fi
    PKG_MANAGER="apt"
fi

# Обновление пакетов
$SUDO_COMMAND $PKG_MANAGER update -y && $SUDO_COMMAND $PKG_MANAGER upgrade -y

# Список пакетов для установки
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
    "gh"
)

pip_packages=(
    "black"
    "pyright"
    "isort"
    "mypy"
    "pre-commit"
)

# Установка пакетов
for package in "${packages[@]}"; do
    $SUDO_COMMAND $PKG_MANAGER install -y "$package"
done

# Проверка и установка pip3
if ! command -v pip3 &>/dev/null; then
    $SUDO_COMMAND $PKG_MANAGER install -y python3-pip
fi

curl https://pyenv.run | bash
pyenv install 3.12.7
pyenv global 3.12.7

# Установка других программ и инструментов в зависимости от окружения
if [[ -n "$TERMUX_VERSION" ]]; then
    # Termux-specific setup
    pkg install rust python-cryptography
    pip install poetry
    cp meslo-font/"MesloLGS NF Regular.ttf" termux/font.ttf
    # Отключение приветственного сообщения
    touch ~/.hushlogin
else
    # Ubuntu-specific setup
    curl -sSL https://install.python-poetry.org | python3 -
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    sudo dpkg-divert --rename --add /usr/lib/$(py3versions -d)/EXTERNALLY-MANAGED
    pip install ruff

    sudo apt install -y openssh-server python3.12-venv flatpak

    sudo systemctl start ssh
    sudo systemctl enable ssh
    
    mkdir -p ~/.local/share/fonts/
    cp meslo-font/* ~/.local/share/fonts/
    fc-cache -f -v

    snap uninstall firefox --purge

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.mozilla.firefox
    flatpak install flathub com.spotify.Client
    flatpak install flathub com.github.jgraph.drawio
    flatpak install flathub org.gimp.GIMP
    flatpak install flathub org.inkscape.Inkscape
    flatpak install flathub com.visualstudio.code
    flatpak install flathub io.telegram.desktop
    flatpak install flathub com.obsidian.Obsidian
    flatpak install flathub com.github.Anuken.Mindustry
    flatpak install flathub org.openttd.OpenTTD
    flatpak install flathub org.gnome.Extensions


fi

# Установка pip пакетов
for package in "${pip_packages[@]}"; do
    pip3 install "$package"
done

# Установка oh-my-zsh и смена оболочки
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
$SUDO_COMMANDchsh -s $(which zsh)

# Копирование конфигураций
cp zshrc ~/.zshrc
cp p10k.zsh ~/.p10k.zsh

# Создание необходимых директорий
mkdir -p ~/.config ~/repos ~/tests

# Клонирование репозиториев для zsh плагинов
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Установка дополнительных инструментов
curl https://getcroc.schollz.com | bash

# Установка дополнительных инструментов
go install github.com/bloznelis/typioca@latest
go install github.com/mistakenelf/fm@latest
go install github.com/go-task/task/v3/cmd/task@latest

# Установка SDKMAN! и Java
if [[ ! -d "$HOME/.sdkman" ]]; then
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk install java 19.0.2-open
fi

# Установка NVM и Node.js
if [[ ! -d "$HOME/.nvm" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source ~/.nvm/nvm.sh
    nvm install 20
fi

# Установка Rust инструментов
cargo install numbat-cli


# Переключение оболочки на zsh
exec "$SHELL"
