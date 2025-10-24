#!/usr/bin/env bash
# SecureWork Quick Tools - Public Version
# Author: Open Source Community
# Description: Creates a set of clickable .command shortcuts on macOS Desktop
#              for managing encrypted APFS sparseimages securely.
# License: MIT

set -e
DESKTOP="$HOME/Desktop/SecureWork-Commands"
mkdir -p "$DESKTOP"

make_command() {
  local name="$1"; shift
  local body="$@"
  local path="$DESKTOP/${name}.command"
  cat > "$path" <<EOF
#!/bin/bash
# ${name} - generated shortcut
clear
printf "\n== SecureWork: ${name} ==\n\n"
${body}

echo "\n\nOperation complete. Press any key to exit."
read -n1 -r _
exec bash   # keeps Terminal open after keypress
EOF
  chmod +x "$path"
}

make_command "Mount-SecureWork" 'IMAGE=~/SecureWork.sparseimage
if [ ! -f "$IMAGE" ]; then
  echo "Image not found: $IMAGE"
  read -p "Enter path manually: " IMAGE
fi
hdiutil attach "$IMAGE" || echo "Mount failed."'

make_command "Detach-SecureWork" 'VOL=/Volumes/SecureWork
if [ ! -d "$VOL" ]; then
  read -p "Enter volume path (e.g., /Volumes/SecureWork): " VOL
fi
hdiutil detach "$VOL" || echo "Detach failed. Try Force-Detach if needed."'

make_command "Force-Detach" 'VOL=/Volumes/SecureWork
if [ ! -d "$VOL" ]; then
  read -p "Enter volume path (e.g., /Volumes/SecureWork): " VOL
fi
sudo hdiutil detach -force "$VOL"'

make_command "Who-Uses" 'VOL=/Volumes/SecureWork
if [ ! -d "$VOL" ]; then
  read -p "Enter volume path (e.g., /Volumes/SecureWork): " VOL
fi
echo "Processes using $VOL:\n"
lsof | grep "$VOL" || echo "No open handles found."'

make_command "Create-SparseImage" 'IMG=~/SecureWork.sparseimage
read -p "Image path [default: ~/SecureWork.sparseimage]: " path
IMG=${path:-$IMG}
read -p "Size (e.g., 200m or 1g): " SIZE
[ -z "$SIZE" ] && SIZE=200m
echo "Creating encrypted sparseimage..."
read -s -p "Password: " PW; echo
printf "%s" "$PW" | hdiutil create -size "$SIZE" -fs APFS -type SPARSE -volname SecureWork -encryption -stdinpass "$IMG"
echo "Created: $IMG"'

make_command "Open-Volume" 'VOL=/Volumes/SecureWork
[ ! -d "$VOL" ] && read -p "Enter volume path (e.g., /Volumes/SecureWork): " VOL
open "$VOL" || echo "Volume not found: $VOL"'

cat > "$DESKTOP/README.txt" <<DOC
SecureWork Quick Tools
=======================

Usage:
1. Double-click any .command file on your Desktop (macOS will open Terminal).
2. Use Mount/Detach/Force/Who-Uses/Create/Open as needed.
3. Keep your .sparseimage file outside iCloud (e.g. ~/SecureWork.sparseimage).

Installation:
-------------
1. Save this script as SecureWork-desktop-quick.command
2. Run: chmod +x SecureWork-desktop-quick.command
3. Double-click it once to create all tools.

License: MIT (free to use, modify, share)
DOC

open "$DESKTOP"
echo "✅ SecureWork Quick Tools ready on your Desktop: $DESKTOP"
