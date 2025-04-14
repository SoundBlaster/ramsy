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
SCRIPT_PATH="$HOME/ramdisk-sync.sh"
PLIST_PATH="$HOME/Library/LaunchAgents/com.local.ramdisksync.plist"

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "Installing fswatch..."
    brew install fswatch
fi

echo "Creating sync script: $SCRIPT_PATH"

cat <<EOF > "$SCRIPT_PATH"
#!/bin/bash

RAMDISK_SIZE_MB=$RAMDISK_SIZE_MB
PROJECT_NAME="$PROJECT_NAME"
SSD_PROJECT_PATH="$SSD_PROJECT_PATH"
RAMDISK_PATH="$RAMDISK_PATH"

BLOCKS=\$((\$RAMDISK_SIZE_MB * 2048))
DEVICE=\$(hdiutil attach -nomount ram://\$BLOCKS)
diskutil erasevolume HFS+ "RAMDisk_\$PROJECT_NAME" \$DEVICE

rsync -a --exclude='.git' "\$SSD_PROJECT_PATH/" "\$RAMDISK_PATH/"
ln -s "\$SSD_PROJECT_PATH/.git" "\$RAMDISK_PATH/.git"

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
    <string>com.local.ramdisksync</string>
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