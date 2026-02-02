#!/bin/bash
set -e

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="ansi2irc"
LINK_NAME="irc2ansi"

# Ensure ~/.local/bin exists
mkdir -p "$INSTALL_DIR"

# Copy the script
echo "Installing $SCRIPT_NAME to $INSTALL_DIR..."
cp "$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Create symlink
echo "Creating symlink $LINK_NAME -> $SCRIPT_NAME..."
ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$LINK_NAME"

echo "Success!"
echo "Ensure '$INSTALL_DIR' is in your \$PATH to use '$SCRIPT_NAME' and '$LINK_NAME'."
