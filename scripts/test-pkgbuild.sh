#!/usr/bin/env bash
# scripts/test-pkgbuild.sh - PKGBUILD testing and validation script

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$REPO_DIR/packages"

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

# Check if paru is available for dependency validation
check_paru() {
    if command -v paru &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Validate dependencies with paru
validate_dependencies() {
    local package_dir="$1"
    local pkgbuild="$package_dir/PKGBUILD"
    
    if ! check_paru; then
        print_warning "Paru not available, skipping dependency validation"
        return 0
    fi
    
    print_status "Validating dependencies with paru..."
    
    # Extract and check dependencies
    local all_deps=()
    
    # Source PKGBUILD to get dependency arrays
    (
        cd "$package_dir"
        source "$pkgbuild" 2>/dev/null
        
        # Combine all dependency types
        local all_deps=()
        all_deps+=("${depends[@]:-}" "${makedepends[@]:-}" "${checkdepends[@]:-}")

        # Check each dependency
        local missing_deps=()
        local aur_deps=()
        
        for dep in "${all_deps[@]}"; do
            [[ -z "$dep" ]] && continue
            
            # Remove version constraints for checking
            dep_name=$(echo "$dep" | sed 's/[>=<].*//')
            
            # Skip modern-cli-* dependencies (internal)
            if [[ "$dep_name" == modern-cli-* ]]; then
                continue
            fi
            
            print_status "Checking dependency: $dep_name"
            
            # Check in official repositories first
            if pacman -Si "$dep_name" &>/dev/null; then
                print_success "Found in official repos: $dep_name"
            # Check in AUR with paru
            elif paru -Si "$dep_name" &>/dev/null; then
                aur_deps+=("$dep_name")
                print_warning "Found in AUR: $dep_name"
            else
                missing_deps+=("$dep_name")
                print_error "Not found: $dep_name"
            fi
        done
        
        # Report results
        if [[ ${#aur_deps[@]} -gt 0 ]]; then
            print_warning "AUR dependencies found: ${aur_deps[*]}"
        fi
        
        if [[ ${#missing_deps[@]} -gt 0 ]]; then
            print_error "Missing dependencies: ${missing_deps[*]}"
            exit 1
        else
            print_success "All dependencies are available"
        fi
    )
    
    return $?
}

# Test PKGBUILD syntax and required variables
test_pkgbuild_syntax() {
    local package_dir="$1"
    local pkgbuild="$package_dir/PKGBUILD"
    local package_name="$(basename "$package_dir")"
    
    print_status "Testing PKGBUILD: $package_name"
    
    if [[ ! -f "$pkgbuild" ]]; then
        print_error "PKGBUILD not found in $package_dir"
        return 1
    fi
    
    # Test PKGBUILD syntax by sourcing it in a subshell
    local errors=()
    
    if ! (
        cd "$package_dir"
        set +e  # Don't exit on errors in subshell
        source "$pkgbuild" &>/dev/null
        exit_code=$?
        set -e
        
        if [[ $exit_code -ne 0 ]]; then
            echo "PKGBUILD syntax error"
            exit 1
        fi
        
        # Check required variables
        [[ -n "${pkgname:-}" ]] || { echo "pkgname not set"; exit 1; }
        [[ -n "${pkgver:-}" ]] || { echo "pkgver not set"; exit 1; }
        [[ -n "${pkgrel:-}" ]] || { echo "pkgrel not set"; exit 1; }
        [[ -n "${arch:-}" ]] || { echo "arch not set"; exit 1; }
        
        # Check if package function exists
        if ! declare -f package &>/dev/null; then
            echo "package() function not defined"
            exit 1
        fi
        
        # Additional checks for specific package types
        if [[ "$package_name" == "modern-cli-meta" ]]; then
            [[ -n "${depends:-}" ]] || { echo "meta package must have depends"; exit 1; }
        fi
        
    ) 2>&1; then
        local error_output
        error_output=$(
            cd "$package_dir"
            source "$pkgbuild" 2>&1 || echo "Failed to source PKGBUILD"
        )
        print_error "PKGBUILD validation failed: $error_output"
        return 1
    fi
    
    # Validate dependencies with paru if available
    if ! validate_dependencies "$package_dir"; then
        print_error "Dependency validation failed for $package_name"
        return 1
    fi
    
    # Run namcap if available
    if command -v namcap &>/dev/null; then
        print_status "Running namcap analysis..."
        if namcap "$pkgbuild" 2>/dev/null; then
            print_success "namcap analysis passed"
        else
            print_warning "namcap found issues (warnings may be acceptable)"
        fi
    fi
    
    print_success "PKGBUILD validation passed: $package_name"
    return 0
}

# Test all packages or a specific package
main() {
    local target="${1:-all}"
    
    case "$target" in
        "all")
            print_status "Testing all PKGBUILD files..."
            
            local failed_packages=()
            local passed_packages=()
            local total_packages=0
            
            for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                if [[ -d "$package_dir" ]]; then
                    ((total_packages++))
                    local pkg_name="$(basename "$package_dir")"
                    
                    if test_pkgbuild_syntax "$package_dir"; then
                        passed_packages+=("$pkg_name")
                    else
                        failed_packages+=("$pkg_name")
                    fi
                    echo  # Add spacing between tests
                fi
            done
            
            # Summary
            echo "$(printf '%*s' 60 '' | tr ' ' '=')"
            print_status "Test Results Summary:"
            print_success "Passed: ${#passed_packages[@]}/$total_packages packages"
            
            if [[ ${#passed_packages[@]} -gt 0 ]]; then
                echo "  ✓ ${passed_packages[*]}"
            fi
            
            if [[ ${#failed_packages[@]} -gt 0 ]]; then
                print_error "Failed: ${#failed_packages[@]}/$total_packages packages"
                echo "  ✗ ${failed_packages[*]}"
                exit 1
            else
                print_success "All PKGBUILD tests passed!"
            fi
            ;;
            
        "help"|"--help"|"-h")
            cat << EOF
PKGBUILD Testing Script with Paru Integration

Usage: $0 [target]

Arguments:
  all                   Test all PKGBUILD files (default)
  <package-name>        Test specific package PKGBUILD
  help                  Show this help

Examples:
  $0                              # Test all packages
  $0 all                          # Test all packages  
  $0 modern-cli-core              # Test specific package

This script validates:
- PKGBUILD syntax
- Required variables (pkgname, pkgver, pkgrel, arch)
- Required functions (package)
- Package-specific requirements
- Dependency availability (with paru if available)
- namcap analysis (if available)

Features:
- Paru integration for dependency validation
- AUR package detection
- Official repository checking
- Missing dependency reporting

Tools used:
- Paru: $(command -v paru >/dev/null && echo "Available" || echo "Not available")
- Namcap: $(command -v namcap >/dev/null && echo "Available" || echo "Not available")

No root privileges required - this only tests syntax and structure.
EOF
            ;;
            
        *)
            # Test specific package
            local package_dir="$PACKAGES_DIR/$target"
            
            if [[ ! -d "$package_dir" ]]; then
                print_error "Package directory not found: $package_dir"
                print_status "Available packages:"
                for pkg_dir in "$PACKAGES_DIR"/modern-cli-*; do
                    if [[ -d "$pkg_dir" ]]; then
                        echo "  - $(basename "$pkg_dir")"
                    fi
                done
                exit 1
            fi
            
            if test_pkgbuild_syntax "$package_dir"; then
                print_success "PKGBUILD test passed for $target"
            else
                print_error "PKGBUILD test failed for $target"
                exit 1
            fi
            ;;
    esac
}

main "$@"
