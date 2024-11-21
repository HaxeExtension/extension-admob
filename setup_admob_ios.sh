#!/bin/bash

# URLs and directories
URL="https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip"
OUTPUT_DIR="project/admob-ios/frameworks"
TEMP_DIR="temp_admob_sdk"
ZIP_FILE="googlemobileadssdkios.zip"

# Create necessary directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR"

# Download the zip file
echo "Downloading AdMob SDK..."
curl -o "$ZIP_FILE" "$URL"

# Unzip the file into the temporary directory
echo "Unzipping the file..."
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

# Navigate into the extracted folder
cd "$TEMP_DIR" || exit 1
EXTRACTED_DIR="GoogleMobileAdsSdkiOS-11.12.0"
cd "$EXTRACTED_DIR" || exit 1

# Process each .xcframework
for XCFRAMEWORK_DIR in *.xcframework; do
    if [ -d "$XCFRAMEWORK_DIR" ]; then
        echo "Processing $XCFRAMEWORK_DIR..."

        # Iterate over the architecture directories (ios-arm64, ios-arm64_x86_64-simulator, etc.)
        for ARCH_DIR in "$XCFRAMEWORK_DIR"/*; do
            if [[ "$ARCH_DIR" =~ ios-.* ]]; then
                echo "Found architecture directory: $ARCH_DIR"

                # Find the .framework directory inside the architecture directory
                FRAMEWORK_DIR=$(find "$ARCH_DIR" -type d -name "*.framework")
                if [ -d "$FRAMEWORK_DIR" ]; then
                    # Create destination directory based on architecture
                    ARCH_NAME=$(basename "$ARCH_DIR" | sed 's/^ios-//')
                    DEST_DIR="../../$OUTPUT_DIR/$ARCH_NAME"
                    mkdir -p "$DEST_DIR"
                    
                    # Now copy the .framework file to the destination
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

# Clean up by removing the temporary directory and zip file
echo "Cleaning up..."
cd ../../
rm -rf "$TEMP_DIR"
rm -f "$ZIP_FILE"

echo "Frameworks have been organized in $OUTPUT_DIR."
