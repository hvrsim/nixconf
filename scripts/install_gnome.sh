#!/usr/bin/env bash

# Gnomintosh install script, modified to my liking.
# - https://github.com/jothi-prasath/gnomintosh

user_name="$USER"

# Function to display usage.
usage() {
  echo "Usage: $0 [install|uninstall] [-light]"
  exit 1
}

# Function to uninstall the theme.
uninstall() {
  read -p "Are you sure you want to uninstall Gnomintosh theme? (y/N): " confirm
  if [[ "$confirm" != [yY] ]]; then
    echo "Uninstallation aborted."
    exit 0
  fi

  echo "Removing installed fonts..."
  for font in ~/.local/share/fonts/*; do
    if [[ $(basename "$font") == *"Gnomintosh"* ]]; then
      rm -f "$font"
    fi
  done

  echo "Removing wallpapers..."
  rm -f ~/Pictures/wallpapers/monterey.png
  rm -f ~/Pictures/wallpapers/smallsur.png
  rm -f ~/Pictures/wallpapers/bigsur.jpg
  rm -f ~/Pictures/wallpapers/ventura.jpg

  echo "Resetting desktop background..."
  gsettings reset org.gnome.desktop.background picture-uri
  gsettings reset org.gnome.desktop.background picture-uri-dark

  echo "Uninstall completed."
  exit 0
}

# Check for install/uninstall argument.
if [[ "$1" == "uninstall" ]]; then
  uninstall
elif [[ "$1" != "install" ]]; then
  usage
fi

# Wallpapers.
mkdir -p ~/Pictures/wallpapers/
cp -r wallpapers/* ~/Pictures/wallpapers/
gsettings set org.gnome.desktop.background picture-uri "file:///home/$user_name/Pictures/wallpapers/monterey.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$user_name/Pictures/wallpapers/monterey.png"

# Load settings using dconf.
dconf load / < assets/settings.dconf

# Load Fonts.
cp assets/* ~/.local/share/fonts/
