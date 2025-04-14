#!/bin/bash

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

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "Installing fswatch..."
    brew install fswatch
fi

# Check if RAM disk is already mounted
if [ -d "$RAMDISK_PATH" ]; then
    echo "Error: RAM disk for this project is already mounted at $RAMDISK_PATH"
    echo "Please unmount it first or choose a different project directory"
    exit 1
fi

# Check if LaunchAgent is already running
if launchctl list | grep -q "com.local.ramdisksync.$PROJECT_NAME"; then
    echo "Error: Sync service for this project is already running"
    echo "Please stop it first or choose a different project directory"
    exit 1
fi

echo "Creating sync script: $SCRIPT_PATH"

cat <<EOF > "$SCRIPT_PATH"
#!/bin/bash

RAMDISK_SIZE_MB=$RAMDISK_SIZE_MB
PROJECT_NAME="$PROJECT_NAME"
SSD_PROJECT_PATH="$SSD_PROJECT_PATH"
RAMDISK_PATH="$RAMDISK_PATH"

# Create RAM disk
BLOCKS=\$((\$RAMDISK_SIZE_MB * 2048))
DEVICE=\$(hdiutil attach -nomount ram://\$BLOCKS)
diskutil erasevolume HFS+ "RAMDisk_\$PROJECT_NAME" \$DEVICE

# Initial sync
rsync -a --exclude='.git' "\$SSD_PROJECT_PATH/" "\$RAMDISK_PATH/"
if [ -d "\$SSD_PROJECT_PATH/.git" ]; then
    ln -s "\$SSD_PROJECT_PATH/.git" "\$RAMDISK_PATH/.git"
fi

# Start sync loop
fswatch -o "\$RAMDISK_PATH" | while read f; do
    rsync -a --delete "\$RAMDISK_PATH/" "\$SSD_PROJECT_PATH/"
done
EOF

chmod +x "$SCRIPT_PATH"

echo "Creating LaunchAgent: $PLIST_PATH"

cat <<EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
   "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.ramdisksync.$PROJECT_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

echo "Loading LaunchAgent..."
launchctl unload "$PLIST_PATH" &> /dev/null
launchctl load "$PLIST_PATH"

echo "DONE! Everything will start automatically on the next system login."
echo "RAM disk: $RAMDISK_PATH"
echo "SSD project: $SSD_PROJECT_PATH"
echo ""
echo "To stop this instance, run:"
echo "  launchctl unload $PLIST_PATH"
echo "  diskutil unmount $RAMDISK_PATH"