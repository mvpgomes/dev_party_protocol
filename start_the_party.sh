#!/usr/bin/env bash
#
# Bootstrap script for setting up a new OSX machine
#
# This should be idempotent so it can be run multiple times.
#
# Notes:
#
# - If installing full Xcode, it's better to install that first from the app
#   store before running the bootstrap script. Otherwise, Homebrew can't access
#   the Xcode libraries as the agreement hasn't been accepted yet.
#
# Reading:
#
# - http://lapwinglabs.com/blog/hacker-guide-to-setting-up-your-mac
# - https://gist.github.com/MatthewMueller/e22d9840f9ea2fee4716
# - https://news.ycombinator.com/item?id=8402079
# - http://notes.jerzygangi.com/the-best-pgp-tutorial-for-mac-os-x-ever/

echo "Starting the party ... Yay!!!!!"

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/$USER/.zprofile
    eval $(/opt/homebrew/bin/brew shellenv)
fi

# Update homebrew recipes
brew update

echo "Installing GNU core utilities..."
# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils
brew install gnu-sed
brew install gnu-tar
brew install gnu-indent
brew install gnu-which
brew install grep
brew install findutils

# Install Font Source Code Pro
echo "Installing Font Source Code Pro..."
brew tap homebrew/cask-fonts
brew install --cask font-source-code-pro

PACKAGES=(
    asdf
    git
    ispell
    jq
    kubernetes-cli
    ripgrep
    tree
    vim
    zsh
    wget
)

echo "Installing base packages..."
brew install ${PACKAGES[@]}

CASKS=(
    1password
    alfred
    docker
    iterm2
    postman
    google-chrome
    slack
    spectacle
    spotify
    telegram
    visual-studio
)

echo "Installing cask apps..."
brew install --cask ${CASKS[@]}

echo "Exporting path..."
export PATH=/usr/local/bin:$PATH

echo "Adding ASDF to Zsh ..."
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ~/.zsh_profile

echo "Installing Oh My Zsh..."
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cp dotfiles/.zshrc ~/

echo "Installing Powerlevel10k required fonts..."
mkdir -p ~/.fonts
curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf --output ~/.fonts/'MesloLGS NF Regular.ttf'
curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf --output ~/.fonts/'MesloLGS NF Bold.ttf'
curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf --output ~/.fonts/'MesloLGS NF Italic.ttf'
curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf --output ~/.fonts/'MesloLGS NF Bold Italic.ttf'

echo "Installing Powelevel10k..."
sh -c "$(git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k)"

echo "Configuring Git..."
cp dotfiles/.gitconfig ~/

echo "Configuring OSX..."
# Set fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 0

# Require password as soon as screensaver or sleep mode starts
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Creating folder structure..."
[[ ! -d ~/Development ]] && mkdir ~/Development

# Install Emacs Plus
read -p "Install Emacs Plus [Y/N] (default N): " install_emacs
install_emacs=${install_emacs:-N}

if [[ "$install_emacs" == "Y" ]]; then
    echo "Installing Emacs Plus..."
    brew tap d12frosted/emacs-plus
    brew install emacs-plus
    ln -s /usr/local/Cellar/emacs-mac/*/Emacs.app/ /Applications

    # Install Spacemacs
    echo "Installing Spacemacs..."
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    cp dotfiles/.spacemacs ~/
fi

# Install Ruby
read -p "Install Ruby [Y/N] (default N): " install_ruby
install_ruby=${install_ruby:-N}

if [[ "$install_ruby" == "Y" ]]; then
    echo "Installing Asdf ruby plugin..."
    asdf plugin add ruby

    echo "Installing Ruby latest version..."
    asdf install ruby latest && asdf global ruby latest
fi

# Install Elixir
read -p "Install Elixir [Y/N] (default N): " install_elixir
install_elixir=${install_elixir:-N}

if [[ "$install_elixir" == "Y" ]]; then
    echo "Installing Asdf elixir plugin..."
    asdf plugin add elixir

    echo "Installing Elixir latest version..."
    asdf install elixir latest && asdf global elixir latest
fi

# Install Python
read -p "Install Python [Y/N] (default N): " install_python
install_python=${install_python:-N}

if [[ "$install_python" == "Y" ]]; then
    echo "Installing Asdf python plugin..."
    asdf plugin add python

    echo "Installing Python3 latest version..."
    asdf install python latest && asdf global python latest

    echo "Install Poetry..."
    brew install poetry
fi

# Install Golang
read -p "Install Go [Y/N] (default N): " install_go
install_go=${install_go:-N}

if [[ "$install_go" == "Y" ]]; then
    echo "Installing Asdf go plugin..."
    asdf plugin add golang

    echo "Installing Go latest version..."
    asdf install golang latest && asdf global golang latest

    echo "Setting GO_ROOT..."
    ~/.asdf/plugins/golang/set-env.zsh
fi

echo "Cleaning up..."
brew cleanup

echo "Reloading zsh config..."
source ~/.zshrc

echo "Party is over. Move around folks!!!"
