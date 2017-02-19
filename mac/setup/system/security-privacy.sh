#!/usr/bin/env bash

###############################################################################
# Security & Privacy                                                          #
###############################################################################

# Require password immediately after sleep or screen saver begins
sudo defaults write /Library/Preferences/com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPassword -bool true
# wait 1 minute
defaults write com.apple.screensaver askForPasswordDelay -int 2

# Disable automatic login
sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser &> /dev/null

# Activate logs
sudo defaults -currentHost write /Library/Preferences/com.apple.alf loggingenabled -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Allow applications downloaded from anywhere
# spctl --master-disable

# Turn on Firewall
defaults -currentHost write ~/Library/Preferences/com.apple.alf globalstate -bool true
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

# Allow signed apps
sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable captive control
sudo defaults -currentHost write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false

# Firewall logging
sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -bool false

# Stealth mode
sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true
defaults write ~/Library/Preferences/com.apple.alf stealthenabled -bool true

# Disable Infared Remote
sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false

# Disable encrypted swap (secure virtual memory)
#sudo defaults write /Library/Preferences/com.apple.virtualMemory DisableEncryptedSwap -boolean yes

# Disable Bonjour multicast ads
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES

# Prevent default auto-mounting in finder
duti -s com.apple.Safari afp
duti -s com.apple.Safari ftp
duti -s com.apple.Safari nfs
duti -s com.apple.Safari smb

# Disable filesharing
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist

# Disable internet sharing
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.nat NAT -dict-add Enabled -bool false

# No Wake on Net
sudo systemsetup -setwakeonnetworkaccess off

# Do not time automatically
sudo systemsetup setusingnetworktime off

# Disable IPV6
networksetup -listallnetworkservices | while read i; do SUPPORT=$(networksetup -getinfo "$i" | grep "IPv6: Automatic") && if [ -n "$SUPPORT" ]; then sudo networksetup -setv6off "$i"; fi; done;

# Set DNS Servers to Google
sudo networksetup -setdnsservers "Wi-Fi" 8.8.8.8 8.8.4.4


###############################################################################
# FileVault                                                                   #
###############################################################################

# Enable FileVault (if not already enabled)
# This requires a user password, and outputs a recovery key that should be
# copied to a secure location
#if [[ $(sudo fdesetup status | head -1) == "FileVault is Off." ]]; then
#  sudo fdesetup enable -user `whoami`
#fi

# Disable automatic login when FileVault is enabled
#sudo defaults write /Library/Preferences/com.apple.loginwindow DisableFDEAutoLogin -bool true
