#!/usr/bin/env bash
# scripts/update-packages.sh - Modern package building with pkgctl and dependency resolution

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

# Check required dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for devtools (provides pkgctl)
    if ! command -v pkgctl &> /dev/null; then
        missing_deps+=("devtools")
    fi
    
    # Check for base-devel
    if ! pacman -Qi base-devel &> /dev/null; then
        missing_deps+=("base-devel") 
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Install with: sudo pacman -S ${missing_deps[*]}"
        exit 1
    fi
    
    print_success "All dependencies available"
}

# Get package dependencies from PKGBUILD
get_package_dependencies() {
    local package_dir="$1"
    local pkgbuild="$package_dir/PKGBUILD"
    local deps=()
    
    if [[ -f "$pkgbuild" ]]; then
        # Source PKGBUILD and extract modern-cli-* dependencies
        while IFS= read -r dep; do
            if [[ "$dep" =~ ^modern-cli- ]]; then
                deps+=("$dep")
            fi
        done < <(
            cd "$package_dir"
            source "$pkgbuild" 2>/dev/null
            printf '%s\n' "${depends[@]}" 2>/dev/null || true
        )
    fi
    
    printf '%s\n' "${deps[@]}"
}

# Topological sort for build order based on dependencies
get_build_order() {
    local -A deps_map
    local -A in_degree
    local available_packages=()
    
    # Initialize available packages and dependency map
    for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
        if [[ -d "$package_dir" ]]; then
            local pkg_name=$(basename "$package_dir")
            available_packages+=("$pkg_name")
            in_degree["$pkg_name"]=0
            deps_map["$pkg_name"]=""
        fi
    done
    
    # Build dependency map and calculate in-degrees
    for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
        if [[ -d "$package_dir" ]]; then
            local pkg_name=$(basename "$package_dir")
            local pkg_deps
            pkg_deps=($(get_package_dependencies "$package_dir"))
            
            for dep in "${pkg_deps[@]}"; do
                if [[ -n "$dep" ]] && printf '%s\n' "${available_packages[@]}" | grep -q "^$dep$"; then
                    deps_map["$pkg_name"]+="$dep "
                    ((in_degree["$pkg_name"]++)
                fi
            done
        fi
    done
    
    # Topological sort using Kahn's algorithm
    local queue=()
    local result=()
    
    # Find packages with no dependencies
    for pkg in "${available_packages[@]}"; do
        if [[ ${in_degree["$pkg"]} -eq 0 ]]; then
            queue+=("$pkg")
        fi
    done
    
    # Process packages in dependency order
    while [[ ${#queue[@]} -gt 0 ]]; do
        local current="${queue[0]}"
        queue=("${queue[@]:1}")  # Remove first element
        result+=("$current")
        
        # Update in-degrees for packages that depend on current
        for pkg in "${available_packages[@]}"; do
            if [[ "${deps_map["$pkg"]}" == *"$current "* ]]; then
                ((in_degree["$pkg"]--))
                if [[ ${in_degree["$pkg"]} -eq 0 ]]; then
                    queue+=("$pkg")
                fi
            fi
        done
    done
    
    # Check for circular dependencies
    if [[ ${#result[@]} -ne ${#available_packages[@]} ]]; then
        print_warning "Circular dependencies detected, using fallback order"
        # Fallback to original order with core first
        result=(
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
    fi
    
    printf '%s\n' "${result[@]}"
}

# Build single package using pkgctl
build_package() {
    local package_dir="$1"
    local package_name="$(basename "$package_dir")"
    
    print_status "Building package with pkgctl: $package_name"
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    
    # Copy package to temporary build directory
    local temp_build_dir=$(mktemp -d)
    cp -r "$package_dir"/* "$temp_build_dir/"
    
    cd "$temp_build_dir"
    
    # Clean any existing packages
    rm -f *.pkg.tar.* 
    
    # Build with pkgctl in clean chroot
    if pkgctl build --clean; then
        print_success "Built $package_name successfully with pkgctl"
        
        # Move built packages to build directory
        if ls *.pkg.tar.* 1> /dev/null 2>&1; then
            mv *.pkg.tar.* "$BUILD_DIR/"
            print_success "Moved packages to $BUILD_DIR"
        else
            print_warning "No packages found after build"
        fi
        
        # Cleanup temp directory
        rm -rf "$temp_build_dir"
        return 0
    else
        print_warning "pkgctl build failed, trying fallback makepkg..."
        
        # Fallback to makepkg
        if makepkg -sf; then
            print_success "Built $package_name with makepkg fallback"
            
            if ls *.pkg.tar.* 1> /dev/null 2>&1; then
                mv *.pkg.tar.* "$BUILD_DIR/"
            fi
            
            rm -rf "$temp_build_dir"
            return 0
        else
            print_error "Failed to build $package_name with both pkgctl and makepkg"
            rm -rf "$temp_build_dir"
            return 1
        fi
    fi
}

# Update repository database using modern format
update_repository() {
    print_status "Updating repository database..."
    
    cd "$BUILD_DIR"
    
    if [[ ! -f *.pkg.tar.* ]]; then
        print_error "No packages found in build directory"
        return 1
    fi
    
    # Remove old database files
    rm -f modern-cli-repo.db* modern-cli-repo.files*
    
    # Create new database with .tar.xz format
    if repo-add modern-cli-repo.db.tar.xz *.pkg.tar.*; then
        # Create symlinks for pacman compatibility
        ln -sf modern-cli-repo.db.tar.xz modern-cli-repo.db
        ln -sf modern-cli-repo.files.tar.xz modern-cli-repo.files
        
        print_success "Repository database updated with modern format"
        
        # Show repository info
        print_status "Repository contents:"
        printf "%-30s %s\n" "Package" "Version"
        echo "$(printf '%*s' 50 '' | tr ' ' '-')"
        
        for pkg in *.pkg.tar.*; do
            if [[ -f "$pkg" ]]; then
                local pkg_info=$(echo "$pkg" | sed 's/\.pkg\.tar\..*//')
                printf "%-30s %s\n" "$pkg_info" "$(stat -c%s "$pkg" | numfmt --to=iec)"
            fi
        done
        
        return 0
    else
        print_error "Failed to update repository database"
        return 1
    fi
}

# Get current version from PKGBUILD
get_package_version() {
    local package_dir="$1"
    local pkgbuild="$package_dir/PKGBUILD"
    
    if [[ -f "$pkgbuild" ]]; then
        grep "^pkgver=" "$pkgbuild" | cut -d'=' -f2 | tr -d '"'
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
        sed -i "s/^pkgver=.*/pkgver=\"$new_version\"/" "$pkgbuild"
        sed -i "s/^pkgrel=.*/pkgrel=\"1\"/" "$pkgbuild"
        print_success "Updated $(basename "$package_dir") to version $new_version"
    else
        print_error "PKGBUILD not found in $package_dir"
        return 1
    fi
}

# Show package information
show_package_info() {
    local package_dir="$1"
    local package_name="$(basename "$package_dir")"
    local version="$(get_package_version "$package_dir")"
    local deps=($(get_package_dependencies "$package_dir"))
    
    printf "%-25s %-10s %s\n" "$package_name" "$version" "${deps[*]}"
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        "build")
            check_dependencies
            local target="${2:-all}"
            
            if [[ "$target" == "all" ]]; then
                print_status "Building all packages with dependency-aware ordering..."
                
                local build_order
                build_order=($(get_build_order))
                
                print_status "Build order: ${build_order[*]}"
                echo
                
                local failed_packages=()
                
                for pkg in "${build_order[@]}"; do
                    if [[ -d "$PACKAGES_DIR/$pkg" ]]; then
                        if ! build_package "$PACKAGES_DIR/$pkg"; then
                            failed_packages+=("$pkg")
                        fi
                        echo  # Add spacing between builds
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
                local package_dir="$PACKAGES_DIR/$target"
                if [[ -d "$package_dir" ]]; then
                    build_package "$package_dir"
                    update_repository
                else
                    print_error "Package not found: $target"
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
            
        "deps")
            print_status "Package dependency analysis:"
            echo
            printf "%-25s %-10s %s\n" "Package" "Version" "Dependencies"
            echo "$(printf '%*s' 60 '' | tr ' ' '-')"
            
            for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                if [[ -d "$package_dir" ]]; then
                    show_package_info "$package_dir"
                fi
            done
            echo
            
            print_status "Recommended build order:"
            local build_order
            build_order=($(get_build_order))
            for i in "${!build_order[@]}"; do
                printf "%2d. %s\n" $((i+1)) "${build_order[$i]}"
            done
            ;;
            
        "list")
            print_status "Available packages:"
            echo
            printf "%-25s %s\n" "Package" "Version"
            echo "$(printf '%*s' 40 '' | tr ' ' '-')"
            
            for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                if [[ -d "$package_dir" ]]; then
                    local package_name="$(basename "$package_dir")"
                    local version="$(get_package_version "$package_dir")"
                    printf "%-25s %s\n" "$package_name" "$version"
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
                    rm -f *.pkg.tar.* *.src.tar.*
                    print_success "Cleaned $(basename "$package_dir")"
                fi
            done
            
            # Clean build directory
            if [[ -d "$BUILD_DIR" ]]; then
                rm -rf "$BUILD_DIR"
                print_success "Cleaned build directory"
            fi
            
            # Clean any temp directories
            rm -rf /tmp/modern-cli-build-*
            ;;
            
        "help"|*)
            cat << EOF
Modern CLI Package Build Script

Usage: $0 <command> [options]

Commands:
  build [package]           Build package(s) using pkgctl with dependency resolution
  deps                      Show package dependencies and build order
  version <pkg> <ver>       Update package version
  version-all <version>     Update all packages to version
  list                      List packages and versions
  clean                     Clean build artifacts
  help                      Show this help

Examples:
  $0 build                          # Build all packages in dependency order
  $0 build modern-cli-core          # Build specific package
  $0 deps                           # Show dependencies and build order
  $0 version modern-cli-core 1.1.0  # Update core to v1.1.0
  $0 version-all 1.1.0              # Update all to v1.1.0
  $0 list                           # Show package versions
  $0 clean                          # Clean build files

Features:
- Uses pkgctl build for reproducible chroot builds
- Automatic dependency resolution and build ordering
- Fallback to makepkg if pkgctl fails
- Modern repository database format (.tar.xz)

Requirements:
- devtools package (for pkgctl)
- base-devel package group

EOF
            ;;
    esac
}

main "$@"
