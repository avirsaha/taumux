#!/bin/bash

# Exit on any error
set -e

# Log file for actions
LOG_FILE="bootstrap_tmux.log"

# Error codes
E_TMUX_NOT_INSTALLED=1
E_CONFIG_MISSING=2
E_SYMLINK_FAILED=3
E_TPM_INSTALL_FAILED=4
E_TMUX_SESSION_FAILED=5
E_INVALID_OPTION=6
E_DIR_CREATION_FAILED=7
E_FILE_NOT_FOUND=8
E_SHELL_DETECTION_FAILED=9
E_PREFIX_UPDATE_FAILED=10
E_RESTORE_FAILED=11
E_BACKUP_FAILED=12
E_SYMLINK_EXISTS=13
E_UNKNOWN_ERROR=14

# Function to display help
show_help() {
    echo "Usage: ./bootstrap_tmux.sh [OPTIONS]"
    echo
    echo "This script sets up tmux configuration files by creating symlinks"
    echo "and backing up existing configurations."
    echo
    echo "Options:"
    echo "  -h, --help           Show this help message and exit."
    echo "  -b, --backup         Back up existing tmux config files."
    echo "  -n, --no-install     Do not install Tmux Plugin Manager."
    echo "  -d, --debug          Enable debug mode for more verbose output."
    echo "  -p, --prefix KEY     Set a custom tmux prefix key (default: C-Space)."
    echo "  -a, --auto-consent   Automatically confirm all prompts."
    echo
    echo "Ensure that you have git installed before running this script."
    echo "Run the script from the directory containing your tmux config."
}

# Parse command-line options
BACKUP=false
INSTALL_TPM=true
DEBUG=false
PREFIX_KEY="C-Space"
AUTO_CONSENT=false

while [[ "$1" != "" ]]; do
    case $1 in
        -h | --help )
            show_help
            exit 0
            ;;
        -b | --backup )
            BACKUP=true
            ;;
        -n | --no-install )
            INSTALL_TPM=false
            ;;
        -d | --debug )
            DEBUG=true
            ;;
        -p | --prefix )
            shift
            PREFIX_KEY="$1"
            ;;
        -a | --auto-consent )
            AUTO_CONSENT=true
            ;;
        * )
            echo "Invalid option: $1"
            echo "Error code: $E_INVALID_OPTION"
            exit $E_INVALID_OPTION
            ;;
    esac
    shift
done

# Function for logging
log() {
    echo "[LOG] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function for debug messages
debug() {
    if $DEBUG; then
        echo "[DEBUG] $1"
    fi
}

# Check for Tmux installation
if ! command -v tmux &> /dev/null; then
    echo "Tmux is not installed. Please install Tmux to proceed."
    log "Tmux is not installed."
    exit $E_TMUX_NOT_INSTALLED
fi

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"

# Validate configuration files
validate_config() {
    if [ ! -f "$CONFIG_DIR/.tmux.conf" ]; then
        echo "Configuration file .tmux.conf is missing."
        log "Configuration file .tmux.conf is missing."
        return 1
    fi
    return 0
}

# Backup and symlink function
backup_and_symlink() {
    local src_file="$1"
    local dest_file="$2"

    if [ -f "$dest_file" ]; then
        if $BACKUP; then
            echo "Backing up existing $(basename "$dest_file") to $(basename "$dest_file").bak"
            mv "$dest_file" "$dest_file.bak" || { echo "Failed to back up $(basename "$dest_file")."; exit $E_BACKUP_FAILED; }
            echo "Backup created."
            log "Backup created for $(basename "$dest_file")."
        else
            echo "Warning: Existing $(basename "$dest_file") found."
            if $AUTO_CONSENT || (read -p "Do you want to back it up? (y/n): " confirm && [[ "$confirm" == "y" ]]); then
                echo "Backing up existing $(basename "$dest_file") to $(basename "$dest_file").bak"
                mv "$dest_file" "$dest_file.bak" || { echo "Failed to back up $(basename "$dest_file")."; exit $E_BACKUP_FAILED; }
                echo "Backup created."
                log "Backup created for $(basename "$dest_file")."
            else
                echo "Continuing without backup."
            fi
        fi
    fi

    echo "Creating symlink for $(basename "$src_file")..."
    if ln -sf "$src_file" "$dest_file"; then
        echo "Symlink created for $(basename "$dest_file")."
        log "Symlink created for $(basename "$dest_file")."
    else
        echo "Failed to create symlink for $(basename "$dest_file")."
        log "Failed to create symlink for $(basename "$dest_file")."
        exit $E_SYMLINK_FAILED
    fi
}

# Backup existing configuration for restoration
backup_existing_config() {
    if [ -f "$HOME/.tmux.conf" ]; then
        mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak" || return 1
    fi
    if [ -d "$HOME/.tmux" ]; then
        mv "$HOME/.tmux" "$HOME/.tmux.bak" || return 1
    fi
    return 0
}

# Restore original configuration
restore_original_config() {
    if [ -f "$HOME/.tmux.conf.bak" ]; then
        mv "$HOME/.tmux.conf.bak" "$HOME/.tmux.conf" || return 1
    fi
    if [ -d "$HOME/.tmux.bak" ]; then
        mv "$HOME/.tmux.bak" "$HOME/.tmux" || return 1
    fi
    return 0
}

# Validate configurations
if ! validate_config; then
    echo "Configuration validation failed. Exiting."
    exit $E_CONFIG_MISSING
fi

# Backup existing configuration for restoration on error
if ! backup_existing_config; then
    echo "Failed to backup existing tmux configuration. Exiting."
    exit $E_BACKUP_FAILED
fi

# Backup and symlink .tmux.conf
backup_and_symlink "$CONFIG_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Backup and symlink additional config files (if present)
if [ -d "$CONFIG_DIR/.tmux" ]; then
    mkdir -p "$HOME/.tmux" || { echo "Failed to create .tmux directory."; exit $E_DIR_CREATION_FAILED; }
    echo "Processing additional tmux configuration files..."
    for file in "$CONFIG_DIR/.tmux/"*; do
        backup_and_symlink "$file" "$HOME/.tmux/$(basename "$file")"
    done
fi

# Prepare to update prefix key in .tmux.conf
echo "Updating prefix key in .tmux.conf to $PREFIX_KEY..."
if sed -i.bak "s/^set -g prefix .*/set -g prefix $PREFIX_KEY/" "$HOME/.tmux.conf"; then
    log "Prefix key updated to $PREFIX_KEY in .tmux.conf."
else
    echo "Failed to update prefix key in .tmux.conf."
    restore_original_config
    exit $E_PREFIX_UPDATE_FAILED
fi

# Install TPM (Tmux Plugin Manager) if not already installed
if [ ! -d "$HOME/.tmux/plugins/tpm" ] && $INSTALL_TPM; then
    echo "Installing Tmux Plugin Manager..."
    if git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; then
        echo "Tmux Plugin Manager has been installed."
        log "Tmux Plugin Manager installed."
    else
        echo "Failed to install Tmux Plugin Manager. Exiting."
        restore_original_config
        exit $E_TPM_INSTALL_FAILED
    fi
fi

# Optional: Start tmux and install plugins
if $INSTALL_TPM; then
    echo "Starting tmux and installing plugins..."
    if tmux new-session -d -s bootstrap 'bash -c "tmux source-file ~/.tmux.conf; sleep 1; tmux send-keys C-Space I"'; then
        echo "Tmux has been started in a new session named 'bootstrap', and plugins are being installed."
        log "Tmux session 'bootstrap' started for plugin installation."
    else
        echo "Failed to start tmux session. Exiting."
        restore_original_config
        exit $E_TMUX_SESSION_FAILED
    fi
fi

echo "Tmux configuration has been set up successfully!"
echo "To start tmux, run: tmux"

# Cleanup mechanism on error
trap 'restore_original_config; exit $E_UNKNOWN_ERROR' ERR
