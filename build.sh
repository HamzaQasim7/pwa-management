#!/bin/bash
set -e

echo "🚀 Starting Flutter web build for Vercel..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter not found. Installing Flutter SDK..."
  
  # Install Flutter SDK
  FLUTTER_VERSION="3.24.0"
  FLUTTER_SDK_PATH="/tmp/flutter"
  
  if [ ! -d "$FLUTTER_SDK_PATH" ]; then
    git clone --branch stable --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_SDK_PATH" 2>&1 | grep -v "^Cloning"
    cd "$FLUTTER_SDK_PATH"
    git checkout $FLUTTER_VERSION 2>&1 | grep -v "^HEAD" || true
  fi
  
  export PATH="$FLUTTER_SDK_PATH/bin:$PATH"
  flutter doctor --android-licenses || true
fi

# Navigate to project root
PROJECT_ROOT="${VERCEL_SOURCE_DIR:-$(pwd)}"
cd "$PROJECT_ROOT"

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🔨 Building Flutter web app..."
flutter build web --release --base-href /

echo "✅ Build completed successfully!"
echo "📁 Output directory: build/web"

