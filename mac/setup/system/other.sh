#!/usr/bin/env bash

###############################################################################
# Other                                                                       #
###############################################################################

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Opening and closing speed of Quick Look windows
defaults write NSGlobalDomain QLPanelAnimationDuration -float 0

# Opening and closing window animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Disable animated focus ring
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# Display ASCII control characters using caret notation in standard text views
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Disable Resume system-wide
#defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Rubber-band scrolling (doesn't affect web views)
# defaults write NSGlobalDomain NSScrollViewRubberbanding -bool false

# Disable App Nap (not recomended)
# defaults write NSGlobalDomain NSAppSleepDisabled -bool true

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Set Help Viewer windows to non-floating mode
defaults write com.apple.helpviewer DevMode -bool true

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Screenshot location
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Include date in screenshots
defaults write com.apple.screencapture include-date -bool false

# Base name of screenshots
defaults write com.apple.screencapture name -string "screen"

# Link hidden Applications
hidden_apps=(
  'Archive Utility'
  'Directory Utility'
  'Screen Sharing'
  'Network Utility'
  'Wireless Diagnostics'
  'Feedback Assistant'
  'RAID Utility'
  'System Image Utility'
)

for app in "${hidden_apps[@]}"; do
  sudo ln -s "/System/Library/CoreServices/Applications/${app}.app" \
             "/Applications/Utilities/${app}.app"
done

hidden_apps=(
  'Ticket Viewer'
  'Network Diagnostics'
)

for app in "${hidden_apps[@]}"; do
  sudo ln -s "/System/Library/CoreServices/${app}.app" \
             "/Applications/Utilities/${app}.app"
done

 # Link hidden prefPanes
sudo ln -s '/System/Library/CoreServices/Applications/Archive Utility.app/Contents/Resources/Archives.prefPane' \
           '/Library/PreferencePanes/Archives.prefPane'

# Enable Folder Actions
defaults write com.apple.FolderActionsDispatcher folderActionsEnabled -bool false
