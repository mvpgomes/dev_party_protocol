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
fi

# Update homebrew recipes
brew update

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils
brew install gnu-sed
brew install gnu-tar
brew install gnu-indent
brew install gnu-which
brew install grep --with-default-names

# Install Emacs Plus
echo "Installing Emacs Plus..."
brew tap d12frosted/emacs-plus
brew install emacs-plus@28 --with-spacemacs-icon
brew link emacs-plus

# Install Font Source Code Pro
echo "Installing Font Source Code Pro..."
brew tap homebrew/cask-fonts
brew install --cask font-source-code-pro

# Install Spacemacs
echo "Installing Spacemacs..."
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    cp dotfiles/.spacemacs ~/

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

PACKAGES=(
    awscli
    elixir
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

echo "Installing packages..."
brew install ${PACKAGES[@]}

echo "Cleaning up..."
brew cleanup

CASKS=(
    1password
    alfred
    iterm2
    postman
    spectacle
    spotify
)

echo "Installing cask apps..."
brew install --cask ${CASKS[@]}

echo "Installing Ruby gems"
RUBY_GEMS=(
    bundler
    pry
    pry-byebug
    rbenv
    ruby-build
)
sudo gem install ${RUBY_GEMS[@]}

echo "Installing Oh My Zsh..."
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cp dotfiles/.zshrc ~/

echo "Configuring Git..."
cp dotfiles/.gitconfig ~/

echo "Reloading terminal environment..."
source ~/.zshrc

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

echo "Party is over. Move around folks!!!"
