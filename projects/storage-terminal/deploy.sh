#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/config.sh"

echo "-- Paste these commands into the CC:Tweaked computer:"
echo ""
echo "wget $REPO_RAW/lib/log.lua /lib/log.lua"
echo "wget $REPO_RAW/projects/storage-terminal/startup.lua /startup.lua"
echo "wget $REPO_RAW/projects/storage-terminal/main.lua /main.lua"
echo "wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -r"
echo ""
echo "-- Then reboot the computer."
