#!/usr/bin/env bash

main() {
    ask_for_sudo
    install_homebrew

    brew_install mas # mac app store command-line interface
    # Disabled automated login, as it doesn't work on Mojave
    # https://github.com/mas-cli/mas/issues/164
    # login_to_app_store

    clone_dotfiles_repo
    install_packages_with_brewfile
    change_shell_to_fish
    configure_git
    configure_iterm2
    setup_macOS_defaults
    update_login_items
    setup_symlinks
}

DOTFILES_REPO=~/dotfiles

function ask_for_sudo() {
    info "Prompting for sudo password..."
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; \
            sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
        success "Sudo credentials updated."
    else
        error "Obtaining sudo credentials failed."
        exit 1
    fi
}


function install_homebrew() {
    info "Installing Homebrew..."
    if hash brew 2>/dev/null; then
        success "Homebrew already exists."
    else
url=https://raw.githubusercontent.com/Sajjadhosn/dotfiles/master/installers/homebrew_installer
        if /usr/bin/ruby -e "$(curl -fsSL ${url})"; then
            success "Homebrew installation succeeded."
        else
            error "Homebrew installation failed."
            exit 1
        fi
    fi
}

function brew_install() {
    package_to_install="$1"
    info "brew install ${package_to_install}"
    if hash "$package_to_install" 2>/dev/null; then
        success "${package_to_install} already exists."
    else
        if brew install "$package_to_install"; then
            success "Package ${package_to_install} installation succeeded."
        else
            error "Package ${package_to_install} installation failed."
            exit 1
        fi
    fi
}

function login_to_app_store() {
    info "Logging into app store..."
    # if mas account >/dev/null; then
    #     success "Already logged in."
    # else
    #     open -a "/Applications/App Store.app"
    #     until (mas account > /dev/null);
    #     do
    #         sleep 3
    #     done
    #     success "Login to app store successful."
    # fi
}

function pull_latest() {
    info "Pulling latest changes in ${1} repository..."
    if git -C $1 pull origin master &> /dev/null; then
        success "Pull successful in ${1} repository."
    else
        error "Please pull the latest changes in ${1} repository manually."
    fi
}

function clone_dotfiles_repo() {
    info "Cloning dotfiles repository into ${DOTFILES_REPO} ..."
    if test -e $DOTFILES_REPO; then
        substep "${DOTFILES_REPO} already exists."
        pull_latest $DOTFILES_REPO
    else
        url=https://github.com/mavropalias/dotfiles.git
        if git clone "$url" $DOTFILES_REPO; then
            success "Cloned into ${DOTFILES_REPO}"
        else
            error "Cloning into ${DOTFILES_REPO} failed."
            exit 1
        fi
    fi
}


function install_packages_with_brewfile() {
    info "Installing packages within ${DOTFILES_REPO}/brew/Brewfile ..."
    if brew bundle --file=$DOTFILES_REPO/brew/Brewfile; then
        success "Brewfile installation succeeded."
    else
        error "Brewfile installation failed."
        exit 1
    fi
}

function change_shell_to_fish() {
    info "Fish shell setup..."
    if grep --quiet fish <<< "$SHELL"; then
        success "Fish shell already exists."
    else
        user=$(whoami)
        substep "Adding Fish executable to /etc/shells"
        if grep --fixed-strings --line-regexp --quiet \
            "/usr/local/bin/fish" /etc/shells; then
            substep "Fish executable already exists in /etc/shells"
        else
            if echo /usr/local/bin/fish | sudo tee -a /etc/shells > /dev/null;
            then
                substep "Fish executable successfully added to /etc/shells"
            else
                error "Failed to add Fish executable to /etc/shells"
                exit 1
            fi
        fi
        substep "Switching shell to Fish for \"${user}\""
        if sudo chsh -s /usr/local/bin/fish "$user"; then
            success "Fish shell successfully set for \"${user}\""
        else
            error "Please try setting the Fish shell again."
        fi
    fi
}

function configure_git() {
    username="Kostas Mavropalias"
    email="mavropalias@gmail.com"

    info "Configuring git..."
    if git config --global user.name "$username" && \
       git config --global user.email "$email"; then
        success "git configuration succeeded."
    else
        error "git configuration failed."
    fi
}

function configure_iterm2() {
    info "Configuring iTerm2..."
    if \
        defaults write com.googlecode.iterm2 \
            LoadPrefsFromCustomFolder -int 1 && \
        defaults write com.googlecode.iterm2 \
            PrefsCustomFolder -string "${DOTFILES_REPO}/configs/iTerm2";
    then
        success "iTerm2 configuration succeeded."
    else
        error "iTerm2 configuration failed."
        exit 1
    fi
    substep "Opening iTerm2"
    if osascript -e 'tell application "iTerm" to activate'; then
        substep "iTerm2 activation successful"
    else
        error "Failed to activate iTerm2"
        exit 1
    fi
}

function setup_macOS_defaults() {
    info "Updating macOS defaults..."

    current_dir=$(pwd)
    cd ${DOTFILES_REPO}/configs/macOS
    if bash defaults.sh; then
        cd $current_dir
        success "macOS defaults setup succeeded."
    else
        cd $current_dir
        error "macOS defaults setup failed."
        exit 1
    fi
}

function symlink() {
    application=$1
    point_to=$2
    destination=$3
    destination_dir=$(dirname "$destination")

    if test ! -e "$destination_dir"; then
        substep "Creating ${destination_dir}"
        mkdir -p "$destination_dir"
    fi
    if rm -rf "$destination" && ln -s "$point_to" "$destination"; then
        success "Symlinking ${application} done."
    else
        error "Symlinking ${application} failed."
        exit 1
    fi
}

function update_login_items() {
    info "Updating login items..."
    login_item /Applications/1Password.app
    login_item /Applications/Bartender\ 3.app
    login_item /Applications/Docker.app
    login_item /Applications/CheatSheet.app
    login_item /Applications/Fantastical.app
    login_item /Applications/iTerm.app
    login_item /Applications/Mail.app
    login_item /Applications/Messages.app
    login_item /Applications/Safari.app
    login_item /Applications/Spectacle.app
    success "Login items successfully updated."
}

function login_item() {
    path=$1
    hidden=${2:-true}
    name=$(basename "$path")

    # "¬" charachter tells osascript that the line continues
    if osascript &> /dev/null << EOM
tell application "System Events" to make login item with properties ¬
{name: "$name", path: "$path", hidden: "$hidden"}
EOM
then
    success "Login item ${name} successfully added."
else
    error "Adding login item ${name} failed."
    exit 1
fi
}

function setup_symlinks() {
    POWERLINE_ROOT_REPO=/usr/local/lib/python2.7/site-packages

    info "Setting up symlinks..."

    # vim
    symlink "vim" ${DOTFILES_REPO}/configs/vim/.vimrc ~/.vimrc

    # fish
    symlink "fish:functions" ${DOTFILES_REPO}/configs/fish/functions \
        ~/.config/fish/functions
    symlink "fish:config.fish" ${DOTFILES_REPO}/configs/fish/config.fish \
        ~/.config/fish/config.fish

    success "Symlinks successfully setup."
}

function coloredEcho() {
    local exp="$1";
    local color="$2";
    local arrow="$3";
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput bold;
    tput setaf "$color";
    echo "$arrow $exp";
    tput sgr0;
}

function info() {
    coloredEcho "$1" blue "========>"
}

function substep() {
    coloredEcho "$1" magenta "===="
}

function success() {
    coloredEcho "$1" green "========>"
}

function error() {
    coloredEcho "$1" red "========>"
}

main "$@"
