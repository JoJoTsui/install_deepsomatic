#!/bin/bash

# --- Configuration ---
# 1. Set your base source and destination paths
SRC_BASE="models/deepsomatic/1.9.0/savedmodels"
DEST_BASE="/opt/models/deepsomatic"

# 2. Define the prefix and suffix to remove
PREFIX="deepsomatic."
SUFFIX=".savedmodel"
# ---------------------

# Ensure the main destination directory exists
mkdir -p "$DEST_BASE"

# Loop through all directories in the source folder
# We use -d */ to select only directories
echo "Starting rsync dry-run..."
echo "--------------------------"

for src_path in "$SRC_BASE"/*/; do

    # Check if the path is actually a directory
    if [ -d "$src_path" ]; then

        # Get just the directory name (e.g., "deepsomatic.wes.savedmodel")
        # Note: basename works on the path *with* the trailing slash,
        # so we remove it first with ${src_path%/}
        src_name=$(basename "${src_path%/}")

        # --- Calculate the new name ---

        # 1. Remove the prefix "deepsomatic."
        tmp_name="${src_name#$PREFIX}"

        # 2. Remove the suffix ".savedmodel"
        dest_name="${tmp_name%$SUFFIX}"

        # -------------------------------

        # Construct the full destination path
        dest_path="$DEST_BASE/$dest_name"

        # Run rsync
        # -a: archive mode (recursive, preserves permissions, links, etc.)
        # -v: verbose (shows files being copied)
        # -n: --dry-run (IMPORTANT: shows what would happen. Remove for actual copy)
        #
        # CRITICAL: Note the trailing slash on "$src_path"/
        # This tells rsync to copy the *contents* of the source directory
        # into the destination directory, not the source directory itself.

        echo "Syncing: $src_path -> $dest_path"
        rsync -avPn "$src_path"/ "$dest_path"
        echo # Add a blank line for readability
    fi
done

echo "--------------------------"
echo "✅ Dry-run complete."
echo "To perform the actual copy, remove the '-n' from the rsync command."

