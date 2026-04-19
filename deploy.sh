#!/bin/bash

# Files to be deployed
FILES=(
    "Primo-Monitors FX Toggle.lua"
    "Primo-Headphones FX Toggle.lua"
)

# Define destination path
DEST_DIR="$HOME/Library/Application Support/REAPER/Scripts/Primo Studios"

# Create the directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy the JSFX files
EXIT_STATUS=0
for FILE in "${FILES[@]}"; do
    if cp "$FILE" "$DEST_DIR/"; then
        echo "Successfully deployed $FILE to: $DEST_DIR"
    else
        echo "Error: Failed to deploy $FILE to $DEST_DIR" >&2
        EXIT_STATUS=1
    fi
done

exit $EXIT_STATUS

