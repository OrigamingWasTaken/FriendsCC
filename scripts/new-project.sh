#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

source "$SCRIPT_DIR/config.sh"

# --- Prompts ---

read -rp "Project name (kebab-case): " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
    echo "Error: project name required"
    exit 1
fi

if [[ -d "$ROOT_DIR/projects/$PROJECT_NAME" ]]; then
    echo "Error: projects/$PROJECT_NAME already exists"
    exit 1
fi

read -rp "Description: " DESCRIPTION

echo ""
echo "Select addons (y/n for each):"
read -rp "  CC:Sable? [y/N] " USE_SABLE
read -rp "  CC:C Bridge? [y/N] " USE_CCCBRIDGE
read -rp "  CC: Direct GPU? [y/N] " USE_DIRECTGPU
read -rp "  Basalt (UI)? [y/N] " USE_BASALT

echo ""
echo "Select shared libs (y/n for each):"
read -rp "  net.lua? [y/N] " USE_NET
read -rp "  event.lua? [y/N] " USE_EVENT
read -rp "  log.lua? [y/N] " USE_LOG

# --- Build references ---

ADDON_REFS=""
LIB_REFS=""
REQUIRES=""
FILE_LIST=""
WGET_COMMANDS=""
BASALT_RUN=""
BASALT_INSTALL=""

if [[ "${USE_SABLE,,}" == "y" ]]; then
    ADDON_REFS+=$'@types/cc-sable/aero.lua\n@types/cc-sable/sublevel.lua\n'
fi
if [[ "${USE_CCCBRIDGE,,}" == "y" ]]; then
    ADDON_REFS+=$'@types/ccc-bridge/source.lua\n@types/ccc-bridge/red-router.lua\n@types/ccc-bridge/animatronic.lua\n@types/ccc-bridge/scroller-pane.lua\n'
fi
if [[ "${USE_DIRECTGPU,,}" == "y" ]]; then
    ADDON_REFS+=$'@types/direct-gpu/gpu.lua\n@types/direct-gpu/map-reader.lua\n'
fi
if [[ "${USE_BASALT,,}" == "y" ]]; then
    ADDON_REFS+=$'@types/basalt/basalt.lua\n'
    REQUIRES+=$'local basalt = require("basalt")\n'
    BASALT_RUN=$'\nbasalt.run()'
    BASALT_INSTALL='if not fs.exists("/basalt.lua") and not fs.exists("/basalt") then
    print("Installing Basalt...")
    shell.run("wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -r")
end'
fi

if [[ "${USE_NET,,}" == "y" ]]; then
    LIB_REFS+=$'@lib/net.lua\n'
    REQUIRES+=$'local net = dofile("/lib/net.lua")\n'
    FILE_LIST+="    {remote = \"lib/net.lua\", path = \"/lib/net.lua\"},"$'\n'
    WGET_COMMANDS+="echo \"wget \$REPO_RAW/lib/net.lua /lib/net.lua\""$'\n'
fi
if [[ "${USE_EVENT,,}" == "y" ]]; then
    LIB_REFS+=$'@lib/event.lua\n'
    REQUIRES+=$'local event = dofile("/lib/event.lua")\n'
    FILE_LIST+="    {remote = \"lib/event.lua\", path = \"/lib/event.lua\"},"$'\n'
    WGET_COMMANDS+="echo \"wget \$REPO_RAW/lib/event.lua /lib/event.lua\""$'\n'
fi
if [[ "${USE_LOG,,}" == "y" ]]; then
    LIB_REFS+=$'@lib/log.lua\n'
    REQUIRES+=$'local log = dofile("/lib/log.lua")\n'
    FILE_LIST+="    {remote = \"lib/log.lua\", path = \"/lib/log.lua\"},"$'\n'
    WGET_COMMANDS+="echo \"wget \$REPO_RAW/lib/log.lua /lib/log.lua\""$'\n'
fi

# Add project files to deploy lists
FILE_LIST+="    {remote = \"projects/$PROJECT_NAME/startup.lua\", path = \"/startup.lua\"},"$'\n'
FILE_LIST+="    {remote = \"projects/$PROJECT_NAME/main.lua\", path = \"/main.lua\"},"$'\n'
WGET_COMMANDS+="echo \"wget \$REPO_RAW/projects/$PROJECT_NAME/startup.lua /startup.lua\""$'\n'
WGET_COMMANDS+="echo \"wget \$REPO_RAW/projects/$PROJECT_NAME/main.lua /main.lua\""$'\n'

if [[ "${USE_BASALT,,}" == "y" ]]; then
    WGET_COMMANDS+="echo \"wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -r\""$'\n'
fi

# --- Generate files ---

PROJECT_DIR="$ROOT_DIR/projects/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR"

# CLAUDE.md
sed -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{DESCRIPTION}}|$DESCRIPTION|g" \
    "$TEMPLATES_DIR/CLAUDE.md.template" > "$PROJECT_DIR/CLAUDE.md.tmp"

# Replace multiline placeholders
{
    while IFS= read -r line; do
        case "$line" in
            *"{{ADDON_REFS}}"*)
                printf "%s" "$ADDON_REFS"
                ;;
            *"{{LIB_REFS}}"*)
                printf "%s" "$LIB_REFS"
                ;;
            *)
                printf "%s\n" "$line"
                ;;
        esac
    done
} < "$PROJECT_DIR/CLAUDE.md.tmp" > "$PROJECT_DIR/CLAUDE.md"
rm "$PROJECT_DIR/CLAUDE.md.tmp"

# startup.lua
cp "$TEMPLATES_DIR/startup.lua.template" "$PROJECT_DIR/startup.lua"

# main.lua
{
    printf "%s" "$REQUIRES"
    printf "\n-- Your code here\n"
    if [[ -n "$BASALT_RUN" ]]; then
        printf "%s\n" "$BASALT_RUN"
    fi
} > "$PROJECT_DIR/main.lua"

# install.lua
sed -e "s|{{REPO_RAW}}|$REPO_RAW|g" \
    "$TEMPLATES_DIR/install.lua.template" > "$PROJECT_DIR/install.lua.tmp"
{
    while IFS= read -r line; do
        case "$line" in
            *"{{FILE_LIST}}"*)
                printf "%s" "$FILE_LIST"
                ;;
            *"{{BASALT_INSTALL}}"*)
                printf "%s\n" "$BASALT_INSTALL"
                ;;
            *)
                printf "%s\n" "$line"
                ;;
        esac
    done
} < "$PROJECT_DIR/install.lua.tmp" > "$PROJECT_DIR/install.lua"
rm "$PROJECT_DIR/install.lua.tmp"

# deploy.sh
{
    while IFS= read -r line; do
        case "$line" in
            *"{{WGET_COMMANDS}}"*)
                printf "%s" "$WGET_COMMANDS"
                ;;
            *)
                printf "%s\n" "$line"
                ;;
        esac
    done
} < "$TEMPLATES_DIR/deploy.sh.template" > "$PROJECT_DIR/deploy.sh"
chmod +x "$PROJECT_DIR/deploy.sh"

echo ""
echo "Created projects/$PROJECT_NAME/"
echo "  CLAUDE.md"
echo "  startup.lua"
echo "  main.lua"
echo "  install.lua"
echo "  deploy.sh"
echo ""
echo "Next: cd projects/$PROJECT_NAME and start coding!"
