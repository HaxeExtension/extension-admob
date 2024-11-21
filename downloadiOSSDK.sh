#!/bin/bash

URL="https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip"
OUTPUT_DIR="project/admob-ios/frameworks"
TEMP_DIR="temp_admob_sdk"
ZIP_FILE="googlemobileadssdkios.zip"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR"

echo "Downloading Google Mobile Ads SDK..."
curl -o "$ZIP_FILE" "$URL"

echo "Unzipping the SDK..."
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

cd "$TEMP_DIR" || exit 1

echo "Organizing .framework files..."
for ARCH_DIR in *.xcframework/*; do
    if [ -d "$ARCH_DIR" ]; then
        ARCH=$(basename "$ARCH_DIR")
        FRAMEWORK_SRC="$ARCH_DIR/*.framework"
        FRAMEWORK_DEST="../../$OUTPUT_DIR/$ARCH"

        mkdir -p "$FRAMEWORK_DEST"
        cp -R $FRAMEWORK_SRC "$FRAMEWORK_DEST" 2>/dev/null
        echo "Moved frameworks for $ARCH to $FRAMEWORK_DEST."
    fi
done

cd ..
rm -rf "$TEMP_DIR"
rm -f "$ZIP_FILE"

echo "Frameworks are organized in $OUTPUT_DIR."
