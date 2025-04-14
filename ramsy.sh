#!/bin/bash

# Common ignored directories and files
COMMON_IGNORES=(
    # Version Control
    ".git"
    ".svn"
    ".hg"
    
    # Dependencies and Build
    "node_modules"
    "bower_components"
    "vendor"
    "dist"
    "build"
    "__pycache__"
    "*.egg-info"
    ".pytest_cache"
    ".next"
    ".nuxt"
    
    # IDE and Editor
    ".idea"
    ".vscode"
    ".vs"
    "*.swp"
    "*.swo"
    
    # OS specific
    ".DS_Store"
    ".Trashes"
    ".Spotlight-V100"
    ".fseventsd"
    "Thumbs.db"
    "Desktop.ini"
    
    # Logs and Temporary
    "*.log"
    "log/"
    "logs/"
    "tmp/"
    "temp/"
    ".cache"
)

# Convert ignore array to rsync exclude parameters
RSYNC_EXCLUDES=""
for item in "${COMMON_IGNORES[@]}"; do
    RSYNC_EXCLUDES="$RSYNC_EXCLUDES --exclude='$item'"
done

# Exit on error, but allow us to handle it
set -e
trap 'handle_error $? $LINENO' ERR

# Error handling function
handle_error() {
    local exit_code=$1
    local line_number=$2
    echo "Error occurred in script at line $line_number with exit code $exit_code"
    cleanup
    exit $exit_code
}

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    if [ -d "$RAMDISK_PATH" ]; then
        echo "Syncing final changes..."
        eval "rsync -a --delete $RSYNC_EXCLUDES \"\$RAMDISK_PATH/\" \"\$SSD_PROJECT_PATH/\"" 2>/dev/null || true
        echo "Unmounting RAM disk..."
        diskutil unmount "$RAMDISK_PATH" > /dev/null 2>&1 || true
    fi
    if [ -f "$SCRIPT_PATH" ]; then
        echo "Removing sync script..."
        rm -f "$SCRIPT_PATH"
    fi
    echo "Cleanup complete"
}

echo "_____________________  ___               "
echo "___  __ \__    |__   |/  /___________  __"
echo "__  /_/ /_  /| |_  /|_/ /__  ___/_  / / /"
echo "_  _, _/_  ___ |  /  / / _(__  )_  /_/ / "
echo "/_/ |_| /_/  |_/_/  /_/  /____/ _\__, /  "
echo "Let's boost your project in RAM!/____/   "
echo ""

# === SETTINGS ===
SSD_PROJECT_PATH="$(pwd)"
PROJECT_NAME="$(basename "$SSD_PROJECT_PATH")"
RAMDISK_PATH="/Volumes/RAMDisk_$PROJECT_NAME"
RAMDISK_SIZE_MB=4096

USERNAME=$(whoami)
SCRIPT_PATH="$HOME/ramdisk-sync_$PROJECT_NAME.sh"
PLIST_PATH="$HOME/Library/LaunchAgents/com.local.ramdisksync.$PROJECT_NAME.plist"

# Set up trap for script termination
trap cleanup EXIT INT TERM

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed."
    echo "Please install Homebrew first by running:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    echo "After installation, run this script again."
    exit 1
fi

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "Installing fswatch..."
    brew install fswatch || {
        echo "Error: Failed to install fswatch"
        exit 1
    }
fi

# Check if RAM disk is already mounted
if [ -d "$RAMDISK_PATH" ]; then
    echo "Error: RAM disk for this project is already mounted at $RAMDISK_PATH"
    echo "Please unmount it first or choose a different project directory"
    exit 1
fi

# Check if LaunchAgent is already running
# if launchctl list | grep -q "com.local.ramdisksync.$PROJECT_NAME"; then
#     echo "Error: Sync service for this project is already running"
#     echo "Please stop it first or choose a different project directory"
#     exit 1
# fi

echo "Creating sync script: $SCRIPT_PATH"

cat <<EOF > "$SCRIPT_PATH"
#!/bin/bash

# Configuration
RAMDISK_SIZE_MB=$RAMDISK_SIZE_MB
PROJECT_NAME="$PROJECT_NAME"
SSD_PROJECT_PATH="$SSD_PROJECT_PATH"
RAMDISK_PATH="$RAMDISK_PATH"
LOG_FILE="\$HOME/ramsy_\$PROJECT_NAME.log"

# Logging function
log() {
    echo "\$(date '+%Y-%m-%d %H:%M:%S') - \$1" | tee -a "\$LOG_FILE"
}

# Error handling
set -e
trap 'log "Error occurred in sync script. Exiting..."; exit 1' ERR

log "Starting RAM disk setup for \$PROJECT_NAME"

# Create RAM disk
log "Creating RAM disk..."
BLOCKS=\$((\$RAMDISK_SIZE_MB * 2048))
DEVICE=\$(hdiutil attach -nomount ram://\$BLOCKS)
diskutil erasevolume HFS+ "RAMDisk_\$PROJECT_NAME" \$DEVICE > /dev/null 2>&1

# Initial sync
log "Performing initial sync..."
eval "rsync -a $RSYNC_EXCLUDES \"\$SSD_PROJECT_PATH/\" \"\$RAMDISK_PATH/\""
if [ -d "\$SSD_PROJECT_PATH/.git" ]; then
    log "Creating .git symlink..."
    ln -s "\$SSD_PROJECT_PATH/.git" "\$RAMDISK_PATH/.git"
fi

# Start sync loop with better error handling
log "Starting file monitoring..."
(
    while true; do
        fswatch -o "\$RAMDISK_PATH" | while read f; do
            log "Changes detected, syncing..."
            eval "rsync -a --delete $RSYNC_EXCLUDES \"\$RAMDISK_PATH/\" \"\$SSD_PROJECT_PATH/\"" 2>/dev/null || true
            log "Sync complete"
        done
        log "fswatch stopped, restarting in 5 seconds..."
        sleep 5
    done
) &
FSWATCH_PID=$!

# Set up trap to kill fswatch on script exit
trap 'kill $FSWATCH_PID 2>/dev/null || true; exit 0' EXIT INT TERM

# Wait for fswatch to exit
wait $FSWATCH_PID
EOF

chmod +x "$SCRIPT_PATH"

# echo "Creating LaunchAgent: $PLIST_PATH"
# 
# cat <<EOF > "$PLIST_PATH"
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
#    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
#     <key>Label</key>
#     <string>com.local.ramdisksync.$PROJECT_NAME</string>
#     <key>ProgramArguments</key>
#     <array>
#         <string>/bin/bash</string>
#         <string>$SCRIPT_PATH</string>
#     </array>
#     <key>RunAtLoad</key>
#     <true/>
#     <key>KeepAlive</key>
#     <true/>
# </dict>
# </plist>
# EOF
# 
# echo "Loading LaunchAgent..."
# launchctl unload "$PLIST_PATH" &> /dev/null
# launchctl load "$PLIST_PATH"

# Run the sync script directly instead of using LaunchAgent
echo "Starting RAM disk and sync..."
"$SCRIPT_PATH" &
SYNC_PID=$!

echo "DONE! RAM disk is mounted and sync is running (PID: $SYNC_PID)."
echo "RAM disk: $RAMDISK_PATH"
echo "SSD project: $SSD_PROJECT_PATH"
echo "Log file: $HOME/ramsy_$PROJECT_NAME.log"
echo ""
echo "To stop, press Ctrl+C"

# Set up trap to kill the background process
trap 'kill $SYNC_PID; cleanup; exit 0' INT TERM

# Keep the script running until interrupted
while kill -0 $SYNC_PID 2>/dev/null; do
    sleep 1
done

# If we get here, the sync script died unexpectedly
echo "Sync script died unexpectedly. Cleaning up..."
cleanup
exit 1
