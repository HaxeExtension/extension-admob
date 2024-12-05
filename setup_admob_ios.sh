#!/bin/bash

URL="https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip"
OUTPUT_DIR="project/admob-ios/frameworks"
TEMP_DIR="temp_admob_sdk"
ZIP_FILE="googlemobileadssdkios.zip"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR"

echo "Downloading AdMob SDK..."

curl -o "$ZIP_FILE" "$URL"

echo "Unzipping the file..."

unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

EXTRACTED_DIR=$(find "$TEMP_DIR" -type d -name "GoogleMobileAdsSdkiOS*" -print -quit)

if [ -z "$EXTRACTED_DIR" ]; then
    echo "Error: Extracted directory not found in $TEMP_DIR."
    exit 1
fi

echo "Extracted directory found: $EXTRACTED_DIR"

cd "$EXTRACTED_DIR" || exit 1

for XCFRAMEWORK_DIR in *.xcframework; do
    if [ -d "$XCFRAMEWORK_DIR" ]; then
        echo "Processing $XCFRAMEWORK_DIR..."

        for ARCH_DIR in "$XCFRAMEWORK_DIR"/*; do
            if [[ "$ARCH_DIR" =~ ios-.* ]]; then
                echo "Found architecture directory: $ARCH_DIR"

                FRAMEWORK_DIR=$(find "$ARCH_DIR" -type d -name "*.framework")
                if [ -d "$FRAMEWORK_DIR" ]; then
                    ARCH_NAME=$(basename "$ARCH_DIR" | sed 's/^ios-//')
                    DEST_DIR="../../$OUTPUT_DIR/$ARCH_NAME"
                    mkdir -p "$DEST_DIR"
                    FRAMEWORK_NAME=$(basename "$FRAMEWORK_DIR")
                    echo "Copying $FRAMEWORK_NAME to $DEST_DIR."
                    cp -R "$FRAMEWORK_DIR" "$DEST_DIR"
                else
                    echo "No .framework file found in $ARCH_DIR"
                fi
            fi
        done
    fi
done

echo "Cleaning up..."

cd ../../
rm -rf "$TEMP_DIR"
rm -f "$ZIP_FILE"

echo "Frameworks have been organized in $OUTPUT_DIR."
