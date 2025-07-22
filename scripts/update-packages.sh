#!/usr/bin/env bash
# Update Packages Script
# scripts/update-packages.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$REPO_DIR/packages"
BUILD_DIR="$REPO_DIR/x86_64"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get current version from PKGBUILD
get_package_version() {
    local package_dir="$1"
    local pkgbuild="$package_dir/PKGBUILD"
    
    if [[ -f "$pkgbuild" ]]; then
        grep "^pkgver=" "$pkgbuild" | cut -d'=' -f2
    else
        echo "unknown"
    fi
}

# Update version in PKGBUILD
update_package_version() {
    local package_dir="$1"
    local new_version="$2"
    local pkgbuild="$package_dir/PKGBUILD"
    
    if [[ -f "$pkgbuild" ]]; then
        sed -i "s/^pkgver=.*/pkgver=$new_version/" "$pkgbuild"
        sed -i "s/^pkgrel=.*/pkgrel=1/" "$pkgbuild"
        print_success "Updated $(basename "$package_dir") to version $new_version"
    else
        print_error "PKGBUILD not found in $package_dir"
        return 1
    fi
}

# Build single package
build_package() {
    local package_dir="$1"
    local package_name="$(basename "$package_dir")"
    
    print_status "Building package: $package_name"
    
    cd "$package_dir"
    
    # Clean previous builds
    rm -f *.pkg.tar.zst *.pkg.tar.zst.sig
    
    # Build package
    if makepkg -sf --sign; then
        print_success "Built $package_name successfully"
        
        # Move package to build directory
        mkdir -p "$BUILD_DIR"
        mv *.pkg.tar.zst "$BUILD_DIR/"
        [[ -f *.pkg.tar.zst.sig ]] && mv *.pkg.tar.zst.sig "$BUILD_DIR/"
        
        return 0
    else
        print_error "Failed to build $package_name"
        return 1
    fi
}

# Update repository database
update_repository() {
    print_status "Updating repository database..."
    
    cd "$BUILD_DIR"
    
    # Remove old database files
    rm -f modern-cli-repo.db* modern-cli-repo.files*
    
    # Create new database
    if repo-add modern-cli-repo.db.tar.gz *.pkg.tar.zst; then
        # Create symlinks
        ln -sf modern-cli-repo.db.tar.gz modern-cli-repo.db
        ln -sf modern-cli-repo.files.tar.gz modern-cli-repo.files
        
        print_success "Repository database updated"
        return 0
    else
        print_error "Failed to update repository database"
        return 1
    fi
}

# Show package information
show_package_info() {
    local package_dir="$1"
    local package_name="$(basename "$package_dir")"
    local version="$(get_package_version "$package_dir")"
    
    printf "%-25s %s\n" "$package_name" "$version"
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        "build")
            local package="${2:-all}"
            
            if [[ "$package" == "all" ]]; then
                print_status "Building all packages..."
                
                # Build order (core first, then others)
                local build_order=(
                    "modern-cli-core"
                    "modern-cli-system"
                    "modern-cli-git"
                    "modern-cli-music"
                    "modern-cli-productivity"
                    "modern-cli-communication"
                    "modern-cli-network"
                    "modern-cli-development"
                    "modern-cli-meta"
                )
                
                local failed_packages=()
                
                for pkg in "${build_order[@]}"; do
                    if [[ -d "$PACKAGES_DIR/$pkg" ]]; then
                        if ! build_package "$PACKAGES_DIR/$pkg"; then
                            failed_packages+=("$pkg")
                        fi
                    else
                        print_warning "Package directory not found: $pkg"
                    fi
                done
                
                if [[ ${#failed_packages[@]} -eq 0 ]]; then
                    update_repository
                    print_success "All packages built successfully!"
                else
                    print_error "Failed to build packages: ${failed_packages[*]}"
                    exit 1
                fi
            else
                # Build specific package
                local package_dir="$PACKAGES_DIR/$package"
                if [[ -d "$package_dir" ]]; then
                    build_package "$package_dir"
                    update_repository
                else
                    print_error "Package not found: $package"
                    exit 1
                fi
            fi
            ;;
            
        "version")
            local package="${2:-}"
            local new_version="${3:-}"
            
            if [[ -z "$package" || -z "$new_version" ]]; then
                print_error "Usage: $0 version <package> <new_version>"
                exit 1
            fi
            
            local package_dir="$PACKAGES_DIR/$package"
            if [[ -d "$package_dir" ]]; then
                update_package_version "$package_dir" "$new_version"
            else
                print_error "Package not found: $package"
                exit 1
            fi
            ;;
            
        "version-all")
            local new_version="${2:-}"
            
            if [[ -z "$new_version" ]]; then
                print_error "Usage: $0 version-all <new_version>"
                exit 1
            fi
            
            print_status "Updating all packages to version $new_version"
            
            for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                if [[ -d "$package_dir" ]]; then
                    update_package_version "$package_dir" "$new_version"
                fi
            done
            ;;
            
        "list")
            print_status "Available packages:"
            echo
            printf "%-25s %s\n" "Package" "Version"
            echo "$(printf '%*s' 40 '' | tr ' ' '-')"
            
            for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                if [[ -d "$package_dir" ]]; then
                    show_package_info "$package_dir"
                fi
            done
            echo
            ;;
            
        "clean")
            print_status "Cleaning build artifacts..."
            
            # Clean package directories
            for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                if [[ -d "$package_dir" ]]; then
                    cd "$package_dir"
                    rm -f *.pkg.tar.zst *.pkg.tar.zst.sig
                    print_success "Cleaned $(basename "$package_dir")"
                fi
            done
            
            # Clean build directory
            rm -rf "$BUILD_DIR"
            print_success "Cleaned build directory"
            ;;
            
        "help"|*)
            cat << EOF
Modern CLI Package Update Script

Usage: $0 <command> [options]

Commands:
  build [package]           Build package(s) (default: all)
  version <pkg> <ver>       Update package version
  version-all <version>     Update all packages to version
  list                      List packages and versions
  clean                     Clean build artifacts
  help                      Show this help

Examples:
  $0 build                          # Build all packages
  $0 build modern-cli-core          # Build specific package
  $0 version modern-cli-core 1.1.0  # Update core to v1.1.0
  $0 version-all 1.1.0              # Update all to v1.1.0
  $0 list                           # Show package versions
  $0 clean                          # Clean build files

EOF
            ;;
    esac
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in makepkg repo-add; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_error "Install with: sudo pacman -S base-devel"
        exit 1
    fi
}

# Initialize
check_dependencies
main "$@"