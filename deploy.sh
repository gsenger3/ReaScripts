#!/bin/bash

# Files to be deployed
FILES=(
    "Primo-Monitors FX Toggle.lua"
    "Primo-Headphones FX Toggle.lua"
    "Primo-Prepare Mastering Session.lua"
)

# Define destination path
DEST_DIR="$HOME/Library/Application Support/REAPER/Scripts/Primo Studios"
ROOT_SCRIPTS_DIR="$HOME/Library/Application Support/REAPER/Scripts"

# Create the directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy the Lua scripts
EXIT_STATUS=0
for FILE in "${FILES[@]}"; do
    if cp "$FILE" "$DEST_DIR/"; then
        echo "Successfully deployed $FILE to: $DEST_DIR"
    else
        echo "Error: Failed to deploy $FILE to $DEST_DIR" >&2
        EXIT_STATUS=1
    fi
done

# Copy the startup script to the root Scripts directory
if [ -f "__startup.lua" ]; then
    if cp "__startup.lua" "$ROOT_SCRIPTS_DIR/"; then
        echo "Successfully deployed __startup.lua to: $ROOT_SCRIPTS_DIR"
    else
        echo "Error: Failed to deploy __startup.lua to $ROOT_SCRIPTS_DIR" >&2
        EXIT_STATUS=1
    fi
fi

exit $EXIT_STATUS
