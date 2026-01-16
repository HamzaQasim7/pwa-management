#!/bin/bash
set -e

echo "🚀 Starting Flutter web build for Vercel..."

# Get the project root directory
# Vercel uses PWD as the project root
PROJECT_ROOT="${PWD}"
echo "📂 Project root: $PROJECT_ROOT"
echo "📂 Current working directory: $(pwd)"

# List directory to debug
echo "📋 Root directory contents:"
ls -la "$PROJECT_ROOT" | head -10 || true

# Check for lib directory
if [ ! -d "$PROJECT_ROOT/lib" ]; then
  echo "❌ Error: lib directory not found"
  echo "📋 Searching for lib directory..."
  find "$PROJECT_ROOT" -type d -name "lib" 2>/dev/null | head -5 || true
  exit 1
fi

# Verify we're in the right place
if [ ! -f "$PROJECT_ROOT/lib/main.dart" ]; then
  echo "❌ Error: lib/main.dart not found in $PROJECT_ROOT"
  echo "📋 lib directory contents:"
  ls -la "$PROJECT_ROOT/lib" | head -10 || true
  exit 1
fi

echo "✅ Found lib/main.dart"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter not found. Installing Flutter SDK..."
  
  # Install Flutter SDK
  FLUTTER_SDK_PATH="/tmp/flutter"
  
  if [ ! -d "$FLUTTER_SDK_PATH" ]; then
    echo "📥 Cloning Flutter SDK (stable branch)..."
    git clone --branch stable --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_SDK_PATH" 2>&1 | grep -v "^Cloning" || true
  else
    echo "🔄 Updating Flutter SDK..."
    cd "$FLUTTER_SDK_PATH"
    git pull origin stable 2>&1 | grep -v "^Already" || true
    cd "$PROJECT_ROOT"
  fi
  
  export PATH="$FLUTTER_SDK_PATH/bin:$PATH"
  echo "✅ Flutter SDK installed at: $FLUTTER_SDK_PATH"
  echo "📂 PATH updated, back in project root: $(pwd)"
fi

# Ensure we're back in project root
cd "$PROJECT_ROOT"
echo "📂 Confirmed in project root: $(pwd)"

# Verify Flutter is available
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter command still not found after installation"
  exit 1
fi

echo "🔍 Flutter version:"
flutter --version || true

# Double-check we're in the right place before pub get
if [ ! -f "lib/main.dart" ]; then
  echo "❌ Error: lib/main.dart not found in current directory"
  echo "📂 Current directory: $(pwd)"
  exit 1
fi

echo "📦 Getting Flutter dependencies..."
flutter pub get

# Verify again before build
cd "$PROJECT_ROOT"
if [ ! -f "lib/main.dart" ]; then
  echo "❌ Error: lib/main.dart not found before build"
  exit 1
fi

echo "🔨 Building Flutter web app..."
echo "📂 Building from: $(pwd)"
flutter build web --release --base-href /

# Verify build output exists
if [ ! -d "$PROJECT_ROOT/build/web" ]; then
  echo "❌ Error: build/web directory not found after build"
  echo "📋 Build directory contents:"
  ls -la "$PROJECT_ROOT/build" || true
  exit 1
fi

echo "✅ Build completed successfully!"
echo "📁 Output directory: $PROJECT_ROOT/build/web"
echo "📋 Build output contents:"
ls -la "$PROJECT_ROOT/build/web" | head -20 || true

