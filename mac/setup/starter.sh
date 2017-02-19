#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Set global variables
PREF_FILES=()
AFFECTED_APPS=()

# Source lib tools
source 'lib/loginitem.sh'

# Add preference file followed by any number of affected applications
function set_prefs {
  PREF_FILES+=("apps/$1.sh")
  shift
  AFFECTED_APPS+=("$@")
}

# Sources all the preference files
function source_prefs {
  for file in "${PREF_FILES[@]}"; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
  done
}

# Check for open application
function get_open_affected_apps {
  open_apps=()

  # Store the open apps in an array
  for app in "${AFFECTED_APPS[@]}"; do
    (( $(osascript -e "tell app \"System Events\" to count processes whose name is \"${app}\"") > 0 )) \
    && open_apps+=("$app")
  done

  echo "The following open applications will be affected:"

  # Print the open apps in columns
  printf -- '%s\n' "${open_apps[@]}" | column -x

  echo "Would you like to quit these apps now? [Y/n] "
}

# Open Application
# open -a "SpeechSynthesisServer"

# Quit affected applications
function quit_apps {
  for app in "${AFFECTED_APPS[@]}"; do
    killall "$app" &>/dev/null
    # osascript -e "tell application \"${app}\" to quit"
  done
}

# Prompt if user wants to restart the machine
function prompt_restart {
  echo "Done. Note that some of these changes require a logout/restart to take effect."
  read -p "Would you like to restart the computer now? [Y/n] " -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      osascript -e 'tell app "System Events" to restart'
  fi
}

# System Prefrences
system_preferences=(
  general
  desktop-screen-saver
  dock
  mission-control
  language-region
  security-privacy
  spotlight
  displays
  keyboard
  # mouse
  trackpad
  printers-scanners
  icloud
  app-store
  bluetooth
  sharing
  users-groups
  siri
  date-time
  time-machine
  accessibility
)

for pane in "${system_preferences[@]}"; do
  PREF_FILES+=("system/${pane}.sh")
done

for pane in "cfprefsd" "SystemUIServer" "Dock" "SpeechSynthesisServer"; do
  AFFECTED_APPS+=("$pane")
done

# Default Apps
set_prefs activity-monitor "Activity Monitor"
set_prefs app-store "App Store"
set_prefs contacts "Contacts"
set_prefs disk-utility "Disk Utility"
set_prefs finder "Finder"
set_prefs iwork "Keynote" "Numbers" "Pages"
set_prefs safari "Safari" "WebKit"

# Third Party Apps
set_prefs dropbox "Dropbox"
set_prefs google-chrome "Google Chrome"
set_prefs qlcolorcode "Quick Look"
set_prefs transmission "Transmission"


# Run
get_open_affected_apps
source_prefs
quit_apps

prompt_restart

