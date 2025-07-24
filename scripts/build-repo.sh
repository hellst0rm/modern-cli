#!/usr/bin/env bash
# scripts/build-repo.sh - Repository management and update script with aurutils integration

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$REPO_DIR/x86_64"
REPO_NAME="modern-cli-repo"
AUR_REPO_NAME="modern-cli"

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

# Check if aurutils is available
check_aurutils() {
    if command -v aur &> /dev/null; then
        print_status "Using aurutils for repository management"
        return 0
    else
        print_warning "Aurutils not found, using traditional repo-add"
        return 1
    fi
}

# Check if repoctl is available
check_repoctl() {
    if command -v repoctl &> /dev/null; then
        print_status "Using repoctl for repository management"
        return 0
    else
        print_warning "Repoctl not found"
        return 1
    fi
}

# Initialize aurutils repository if available
init_aur_repo() {
    if check_aurutils; then
        local repo_dir="$HOME/.cache/aurutils/$AUR_REPO_NAME"
        
        if [[ ! -d "$repo_dir" ]]; then
            print_status "Initializing aurutils repository: $AUR_REPO_NAME"
            aur repo --init "$AUR_REPO_NAME"
            print_success "Aurutils repository initialized"
        else
            print_status "Aurutils repository already exists: $AUR_REPO_NAME"
        fi
    fi
}

# Add packages to repository database with aurutils integration
add_packages_to_repo() {
    print_status "Adding packages to repository..."
    
    cd "$BUILD_DIR"
    
    if [[ ! -f *.pkg.tar.* ]]; then
        print_error "No packages found in build directory: $BUILD_DIR"
        return 1
    fi
    
    # Try repoctl first if available
    if check_repoctl; then
        print_status "Using repoctl to add packages to repository"
        
        # Use repoctl to add packages
        if repoctl add *.pkg.tar.*; then
            print_success "Packages added to repository using repoctl"
            return 0
        else
            print_warning "Repoctl failed, trying aurutils..."
        fi
    fi
    
    # Try aurutils if available
    if check_aurutils; then
        print_status "Using aurutils to add packages to repository"
        
        # Initialize repository if needed
        init_aur_repo
        
        # Add packages using aurutils
        if aur repo --add "$AUR_REPO_NAME" *.pkg.tar.*; then
            print_success "Packages added to aurutils repository"
            
            # Also create traditional database for compatibility
            rm -f "${REPO_NAME}.db"* "${REPO_NAME}.files"*
            if repo-add "${REPO_NAME}.db.tar.xz" *.pkg.tar.*; then
                ln -sf "${REPO_NAME}.db.tar.xz" "${REPO_NAME}.db"
                ln -sf "${REPO_NAME}.files.tar.xz" "${REPO_NAME}.files"
                print_success "Traditional repository database also created"
            fi
            
            return 0
        else
            print_warning "Aurutils failed, falling back to traditional method"
        fi
    fi
    
    # Fallback to traditional method
    print_status "Using traditional repo-add method"
    
    # Remove old database files
    rm -f "${REPO_NAME}.db"* "${REPO_NAME}.files"*
    
    # Create new database with modern .tar.xz format
    if repo-add "${REPO_NAME}.db.tar.xz" *.pkg.tar.*; then
        # Create symlinks for pacman compatibility
        ln -sf "${REPO_NAME}.db.tar.xz" "${REPO_NAME}.db"
        ln -sf "${REPO_NAME}.files.tar.xz" "${REPO_NAME}.files"
        
        print_success "Repository database updated successfully"
        return 0
    else
        print_error "Failed to update repository database"
        return 1
    fi
}

# Show repository status and information
show_repo_status() {
    print_status "Repository status: $REPO_NAME"
    echo
    
    if [[ ! -d "$BUILD_DIR" ]]; then
        print_warning "Build directory not found: $BUILD_DIR"
        return 1
    fi
    
    cd "$BUILD_DIR"
    
    # Check if database exists
    if [[ -f "${REPO_NAME}.db" ]]; then
        print_success "Repository database exists"
        
        local db_size=$(stat -c%s "${REPO_NAME}.db" 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "unknown")
        local files_size=$(stat -c%s "${REPO_NAME}.files" 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "unknown")
        
        echo "  Database size: $db_size"
        echo "  Files size: $files_size"
        echo
    else
        print_warning "Repository database not found"
    fi
    
    # List packages
    local pkg_count=0
    local total_size=0
    
    print_status "Repository contents:"
    printf "%-40s %-15s %s\n" "Package" "Version" "Size"
    echo "$(printf '%*s' 70 '' | tr ' ' '-')"
    
    for pkg in *.pkg.tar.*; do
        if [[ -f "$pkg" ]]; then
            ((pkg_count++))
            
            # Extract package info
            local pkg_name=$(echo "$pkg" | sed -E 's/^([^-]+(-[^-]+)*)-[^-]+-[^-]+-[^.]+\.pkg\.tar\..*/\1/')
            local pkg_version=$(echo "$pkg" | sed -E 's/^[^-]+(-[^-]+)*-([^-]+)-[^-]+-[^.]+\.pkg\.tar\..*/\2/')
            local pkg_size=$(stat -c%s "$pkg" 2>/dev/null || echo "0")
            local pkg_size_human=$(echo "$pkg_size" | numfmt --to=iec 2>/dev/null || echo "unknown")
            
            total_size=$((total_size + pkg_size))
            
            printf "%-40s %-15s %s\n" "$pkg_name" "$pkg_version" "$pkg_size_human"
        fi
    done
    
    if [[ $pkg_count -eq 0 ]]; then
        echo "  No packages found"
    else
        echo "$(printf '%*s' 70 '' | tr ' ' '-')"
        local total_size_human=$(echo "$total_size" | numfmt --to=iec 2>/dev/null || echo "unknown")
        printf "%-40s %-15s %s\n" "Total: $pkg_count packages" "" "$total_size_human"
    fi
    echo
}

# Verify repository integrity
verify_repo() {
    print_status "Verifying repository integrity..."
    
    cd "$BUILD_DIR"
    
    local errors=0
    
    # Check if database files exist
    if [[ ! -f "${REPO_NAME}.db" ]]; then
        print_error "Repository database missing: ${REPO_NAME}.db"
        ((errors++))
    fi
    
    if [[ ! -f "${REPO_NAME}.files" ]]; then
        print_error "Repository files database missing: ${REPO_NAME}.files"
        ((errors++))
    fi
    
    # Check symlinks
    if [[ -L "${REPO_NAME}.db" ]]; then
        local target=$(readlink "${REPO_NAME}.db")
        if [[ ! -f "$target" ]]; then
            print_error "Broken symlink: ${REPO_NAME}.db -> $target"
            ((errors++))
        fi
    fi
    
    if [[ -L "${REPO_NAME}.files" ]]; then
        local target=$(readlink "${REPO_NAME}.files")
        if [[ ! -f "$target" ]]; then
            print_error "Broken symlink: ${REPO_NAME}.files -> $target"
            ((errors++))
        fi
    fi
    
    # Check for orphaned packages (packages without database entry)
    if [[ -f "${REPO_NAME}.db" ]] && command -v tar &> /dev/null; then
        print_status "Checking for package consistency..."
        
        local db_packages
        db_packages=$(tar -tf "${REPO_NAME}.db" 2>/dev/null | grep -E '^[^/]+/$' | sed 's|/$||' || true)
        
        for pkg in *.pkg.tar.*; do
            if [[ -f "$pkg" ]]; then
                local pkg_name=$(echo "$pkg" | sed -E 's/^([^-]+(-[^-]+)*)-[^-]+-[^-]+-[^.]+\.pkg\.tar\..*/\1/')
                
                if ! echo "$db_packages" | grep -q "^$pkg_name$"; then
                    print_warning "Package not in database: $pkg"
                fi
            fi
        done
    fi
    
    if [[ $errors -eq 0 ]]; then
        print_success "Repository integrity check passed"
        return 0
    else
        print_error "Repository has $errors error(s)"
        return 1
    fi
}

# Clean repository (remove old packages)
clean_repo() {
    print_status "Cleaning repository..."
    
    if [[ ! -d "$BUILD_DIR" ]]; then
        print_warning "Build directory not found: $BUILD_DIR"
        return 0
    fi
    
    cd "$BUILD_DIR"
    
    local removed_count=0
    
    # Remove package files
    for pkg in *.pkg.tar.*; do
        if [[ -f "$pkg" ]]; then
            rm -f "$pkg"
            ((removed_count++))
        fi
    done
    
    # Remove database files
    rm -f "${REPO_NAME}".db* "${REPO_NAME}".files*
    
    print_success "Removed $removed_count package files and database"
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        "add"|"update")
            # Create build directory if it doesn't exist
            mkdir -p "$BUILD_DIR"
            add_packages_to_repo
            ;;
            
        "status"|"info")
            show_repo_status
            ;;
            
        "verify"|"check")
            verify_repo
            ;;
            
        "clean")
            clean_repo
            ;;
            
        "init")
            # Initialize aurutils repository
            if check_aurutils; then
                init_aur_repo
            else
                print_error "Aurutils not available for repository initialization"
                exit 1
            fi
            ;;
            
        "help"|*)
            cat << EOF
Repository Management Script with Aurutils Integration

Usage: $0 <command>

Commands:
  add/update          Add packages to repository and update database
  status/info         Show repository status and package list
  verify/check        Verify repository integrity
  clean               Clean repository (remove all packages and database)
  init                Initialize aurutils repository
  help                Show this help

Examples:
  $0 add              # Add packages from build directory to repository
  $0 status           # Show repository information
  $0 verify           # Check repository integrity
  $0 clean            # Clean repository
  $0 init             # Initialize aurutils repository

Repository Details:
  - Name: $REPO_NAME (traditional), $AUR_REPO_NAME (aurutils)
  - Location: $BUILD_DIR
  - Format: Modern .tar.xz database format
  - Aurutils: $(command -v aur >/dev/null && echo "Available" || echo "Not available")
  
Features:
  - Automatic aurutils integration when available
  - Fallback to traditional repo-add method
  - Dual repository database creation for compatibility
  
Note: This script manages the repository database. Use scripts/update-packages.sh 
to build packages first.

EOF
            ;;
    esac
}

main "$@"
