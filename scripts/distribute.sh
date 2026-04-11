#!/bin/bash

# Clanship Distribution Script
# This script automates the build and upload process to Firebase App Distribution.
# Requirements: 
# 1. Firebase CLI installed (npm install -g firebase-tools)
# 2. Authenticated with 'firebase login'
# 3. Google Services configuration files present (managed by flutterfire configure)

# Exit immediately if a command exits with a non-zero status.
set -e

PLATFORM=$1

# Firebase App IDs (From flutterfire configure output)
ANDROID_APP_ID="1:955997354464:android:402058c88c1b89a479d385"
IOS_APP_ID="1:955997354464:ios:bd5551c03530b7f179d385"

if [ "$PLATFORM" == "android" ]; then
    echo "🚀 Building Clanship Android APK (Release)..."
    flutter build apk --release
    
    echo "📦 Uploading to Firebase App Distribution via Gradle..."
    # This uses the plugin configured in android/app/build.gradle.kts
    cd android
    ./gradlew app:appDistributionUploadRelease
    cd ..
    
    echo "✅ Android Distribution Complete!"

elif [ "$PLATFORM" == "ios" ]; then
    echo "🚀 Building Clanship iOS IPA (Release)..."
    # Note: Requires a valid distribution certificate and provisioning profile.
    flutter build ipa --release
    
    echo "📦 Uploading to Firebase App Distribution via CLI..."
    # Note: Ensure the group 'internal-testers' exists in Firebase Console
    firebase appdistribution:distribute build/ios/ipa/*.ipa \
        --app "$IOS_APP_ID" \
        --groups "internal-testers" \
        --release-notes "New internal beta version of Clanship Cliente."
        
    echo "✅ iOS Distribution Complete!"

else
    echo "❌ Error: Invalid platform."
    echo "Usage: ./scripts/distribute.sh [android|ios]"
    exit 1
fi
