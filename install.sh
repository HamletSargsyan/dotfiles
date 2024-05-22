SUDO_COMMAND=
PKG_MANAGER=

if [ -n "$TERMUX_VERSION" ]; then
    PKG_MANAGER="pkg"
else
    SUDO_COMMAND="sudo"
    PKG_MANAGER="apt"
fi

yes | $SUDO_COMMAND $PKG_MANAGER update
yes | $SUDO_COMMAND $PKG_MANAGER install git

git clone https://github.com/HamletSargsyan/dotfiles.git
cd dotfiles
./builder.sh