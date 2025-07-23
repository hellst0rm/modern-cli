#!/bin/bash
# build-repo.sh - Build custom Arch repository

set -euo pipefail

REPO_NAME="modern-cli-repo"
REPO_DIR="$(pwd)"
PKG_DIR="$REPO_DIR/x86_64"

echo "🔨 Building custom Arch repository: $REPO_NAME"

# Create directory structure
mkdir -p "$PKG_DIR"

# Build package (run this in the PKGBUILD directory)
echo "📦 Building package..."
makepkg -sf --sign

# Copy package to repository
echo "📋 Adding package to repository..."
cp *.pkg.tar.zst "$PKG_DIR/"
cp *.pkg.tar.zst.sig "$PKG_DIR/" 2>/dev/null || echo "No signatures found"

# Update repository database
echo "🗄️  Updating repository database..."
cd "$PKG_DIR"
repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst

# Create symlinks (required by pacman)
ln -sf "$REPO_NAME.db.tar.gz" "$REPO_NAME.db"
ln -sf "$REPO_NAME.files.tar.gz" "$REPO_NAME.files"

echo "✅ Repository built successfully!"
echo "📤 Commit and push to GitHub to update the repository"