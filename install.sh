#!/bin/bash

# Hyprland Dotfiles Installation Script
# Repository: NoE114/dotfiles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Hyprland Miku Dotfiles Installation  ${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    print_error "This script is designed for Arch Linux systems with pacman"
    exit 1
fi

print_status "Detected Arch Linux system"

# Backup existing configs
backup_configs() {
    print_status "Creating backup of existing configurations..."
    
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # List of config directories to backup
    CONFIG_DIRS=("hypr" "waybar" "kitty" "wofi" "dunst" "swaylock" "rofi")
    
    for dir in "${CONFIG_DIRS[@]}"; do
        if [ -d "$HOME/.config/$dir" ]; then
            print_status "Backing up ~/.config/$dir"
            cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
        fi
    done
    
    print_status "Backup created at: $BACKUP_DIR"
}

# Install required packages
install_packages() {
    print_status "Installing required packages..."
    
    # Core Hyprland packages
    PACKAGES=(
        "hyprland"
        "waybar"
        "wofi"
        "kitty"
        "dunst"
        "swaylock-effects"
        "grim"
        "slurp" 
        "wl-clipboard"
        "pipewire"
        "pipewire-pulse"
        "pipewire-alsa"
        "xdg-desktop-portal-hyprland"
        "polkit-kde-agent"
        "qt5-wayland"
        "qt6-wayland"
        "noto-fonts"
        "noto-fonts-emoji"
        "ttf-jetbrains-mono"
    )
    
    # Optional packages
    OPTIONAL_PACKAGES=(
        "firefox"
        "thunar"
        "pavucontrol"
        "blueman"
        "network-manager-applet"
        "brightnessctl"
        "playerctl"
        "neofetch"
    )
    
    print_status "Installing core packages..."
    sudo pacman -S --needed "${PACKAGES[@]}"
    
    echo
    read -p "Do you want to install optional packages? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installing optional packages..."
        sudo pacman -S --needed "${OPTIONAL_PACKAGES[@]}"
    fi
}

# Install dotfiles
install_dotfiles() {
    print_status "Installing dotfiles..."
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Copy all config directories from the repo
    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != ".git/" ]; then
            dir_name=${dir%/}  # Remove trailing slash
            print_status "Installing $dir_name configuration..."
            cp -r "$dir" "$HOME/.config/"
        fi
    done
    
    # Copy any home directory files (files starting with dot)
    if ls .??* 1> /dev/null 2>&1; then
        print_status "Installing home directory files..."
        cp .??* "$HOME/" 2>/dev/null || true
    fi
    
    # Make scripts executable
    if [ -d "$HOME/.config/hypr/scripts" ]; then
        print_status "Making Hyprland scripts executable..."
        chmod +x "$HOME/.config/hypr/scripts/"*
    fi
    
    # Set up wallpapers directory
    if [ -d "wallpapers" ]; then
        print_status "Setting up wallpapers..."
        mkdir -p "$HOME/Pictures/wallpapers"
        cp -r wallpapers/* "$HOME/Pictures/wallpapers/" 2>/dev/null || true
    fi
}

# Enable services
enable_services() {
    print_status "Enabling system services..."
    
    # Enable Bluetooth if installed
    if systemctl list-unit-files | grep -q bluetooth.service; then
        sudo systemctl enable bluetooth.service
        print_status "Bluetooth service enabled"
    fi
    
    # Enable NetworkManager if installed
    if systemctl list-unit-files | grep -q NetworkManager.service; then
        sudo systemctl enable NetworkManager.service
        print_status "NetworkManager service enabled"
    fi
}

# Final setup
final_setup() {
    print_status "Performing final setup..."
    
    # Set Hyprland as default session (optional)
    echo
    read -p "Do you want to set Hyprland as your default session? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "exec Hyprland" > "$HOME/.xinitrc"
        print_status "Hyprland set as default session"
    fi
    
    print_status "Installation completed!"
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}          Installation Complete!        ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Reboot your system or log out and back in"
    echo "2. Select Hyprland from your display manager"
    echo "3. Or run 'Hyprland' from a TTY"
    echo
    echo -e "${YELLOW}Useful commands:${NC}"
    echo "• Super + Return: Open terminal"
    echo "• Super + D: Open application launcher"
    echo "• Super + Q: Close window"
    echo "• Super + M: Exit Hyprland"
    echo
    echo -e "${BLUE}Enjoy your Hyprland Miku setup! 🎌${NC}"
}

# Main installation process
main() {
    echo "This script will install Hyprland dotfiles and required packages."
    echo "Your existing configurations will be backed up."
    echo
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Installation cancelled by user"
        exit 0
    fi
    
    backup_configs
    install_packages
    install_dotfiles
    enable_services
    final_setup
}

# Run main function
main "$@"
