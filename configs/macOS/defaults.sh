#!/usr/bin/env bash

main() {
    # configure_plist_apps # Configure all apps whose configurations are plists
    configure_finder
    configure_dock
    configure_chrome
    # to ensure the focus gets back to the terminal after the execution completes
    move_focus_back_to_iterm2
}

function configure_plist_apps() {
    quit "Transmission"
    import_plist "org.m0k.transmission" "Transmission.plist"
}

function configure_chrome() {
    # Disable the all too sensitive backswipe on trackpads
    defaults write com.google.Chrome \
        AppleEnableSwipeNavigateWithScrolls -bool false
    defaults write com.google.Chrome.canary \
        AppleEnableSwipeNavigateWithScrolls -bool false
}

function configure_dock() {
    quit "Dock"
    # Set the icon size of Dock items
    defaults write com.apple.dock tilesize -int 48
    # Disable the Launchpad gesture (pinch with thumb and three fingers)
    defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

    open "Dock"
}

function configure_finder() {
    # allow quitting via ⌘ + q; doing so will also hide desktop icons
    defaults write com.apple.finder QuitMenuItem -bool true
    # Set Downloads as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTarget -string "PfLo"
    defaults write com.apple.finder NewWindowTargetPath -string \
        "file://${HOME}/Downloads/"
    # disable status bar
    defaults write com.apple.finder ShowStatusBar -bool false
    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    # Disable disk image verification
    defaults write com.apple.frameworks.diskimages \
        skip-verify -bool true
    defaults write com.apple.frameworks.diskimages \
        skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages \
        skip-verify-remote -bool true
    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
}

function quit() {
    app=$1
    killall "$app" > /dev/null 2>&1
}

function open() {
    app=$1
    osascript << EOM
tell application "$app" to activate
EOM
}

function import_plist() {
    domain=$1
    filename=$2
    defaults delete "$domain" &> /dev/null
    defaults import "$domain" "$filename"
}

function move_focus_back_to_iterm2() {
    osascript << EOM
tell application "System Events" to tell process "iTerm2"
set frontmost to true
end tell
EOM
}

main "$@"
