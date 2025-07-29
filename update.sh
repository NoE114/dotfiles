#!/bin/bash

# Script to update dotfiles from current system configuration
# Use this to sync changes back to your repository

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Updating dotfiles from current system...${NC}"

# Config directories to sync
CONFIG_DIRS=("hypr" "waybar" "kitty" "wofi" "dunst" "swaylock" "rofi")

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$HOME/.config/$dir" ]; then
        echo -e "${GREEN}Updating $dir configuration...${NC}"
        cp -r "$HOME/.config/$dir" ./
    fi
done

# Copy home directory dotfiles
for file in ~/.bashrc ~/.zshrc ~/.profile ~/.xinitrc; do
    if [ -f "$file" ]; then
        cp "$file" ./
    fi
done

echo -e "${GREEN}Dotfiles updated!${NC}"
echo "Don't forget to commit and push your changes:"
echo "  git add ."
echo "  git commit -m 'Update dotfiles'"
echo "  git push"
