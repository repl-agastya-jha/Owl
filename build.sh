#!/bin/bash

APP_NAME="Owl"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_DIR="$DIR/$APP_NAME.app"
MAC_OS_DIR="$APP_DIR/Contents/MacOS"
RESOURCES_DIR="$APP_DIR/Contents/Resources"

echo "Building $APP_NAME..."

mkdir -p "$MAC_OS_DIR"
mkdir -p "$RESOURCES_DIR"

# Create Info.plist
cat <<EOF > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.agastya.Owl</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Compile Swift files
swiftc $DIR/Sources/*.swift -o "$MAC_OS_DIR/$APP_NAME"

if [ $? -eq 0 ]; then
    echo "Build successful! Your app is at $APP_DIR"
    echo "To setup passwordless sudo for pmset, run the following command once:"
    echo 'echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/pmset" | sudo tee /etc/sudoers.d/pmset-nopasswd > /dev/null'
else
    echo "Build failed."
fi
