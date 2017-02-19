#!/usr/bin/env bash

###############################################################################
# Dock                                                                        #
###############################################################################

# Dark dock
defaults write NSGlobalDomain AppleInterfaceStyle Dark

# Icon size of Dock items
defaults write com.apple.dock tilesize -int 32

# Lock the Dock size
defaults write com.apple.dock size-immutable -bool true

# Dock magnification
defaults write com.apple.dock magnification -bool false

# Minimization effect: 'genie', 'scale', 'suck'
defaults write com.apple.dock mineffect -string 'scale'

# Prefer tabs when opening documents: 'always', 'fullscreen', 'manual'
# defaults write NSGlobalDomain AppleWindowTabbingMode -string 'always'

# Dock orientation: 'left', 'bottom', 'right'
# defaults write com.apple.dock 'orientation' -string 'bottom'


# Double-click a window's title bar to:
# None
# Mimimize
# Maximize (zoom)
defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Maximize"

# Minimize to application
defaults write com.apple.dock minimize-to-application -bool true

# Animate opening applications
defaults write com.apple.dock launchanim -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Auto-hide delay
defaults write com.apple.dock autohide-delay -float 0

# Auto-hide animation duration
# defaults write com.apple.dock autohide-time-modifier -float 0

# Spring loaded Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications
defaults write com.apple.dock show-process-indicators -bool true

# Highlight hover effect for the grid view of a stack
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Remove all (default) app icons from the Dock
defaults write com.apple.dock persistent-apps -array
