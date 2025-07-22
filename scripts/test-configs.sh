#!/usr/bin/env bash
# Test Configurations Script
# scripts/test-configs.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$REPO_DIR/packages"
TEST_DIR="/tmp/modern-cli-test-$$"

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

# Test configuration file syntax
test_config_syntax() {
    local config_file="$1"
    local config_type="$2"
    
    case "$config_type" in
        "toml")
            if command -v taplo &> /dev/null; then
                if taplo check "$config_file" &> /dev/null; then
                    return 0
                else
                    return 1
                fi
            else
                print_warning "taplo not installed, skipping TOML validation"
                return 0
            fi
            ;;
        "yaml"|"yml")
            if command -v yq &> /dev/null; then
                if yq eval . "$config_file" &> /dev/null; then
                    return 0
                else
                    return 1
                fi
            else
                print_warning "yq not installed, skipping YAML validation"
                return 0
            fi
            ;;
        "json")
            if command -v jq &> /dev/null; then
                if jq . "$config_file" &> /dev/null; then
                    return 0
                else
                    return 1
                fi
            else
                print_warning "jq not installed, skipping JSON validation"
                return 0
            fi
            ;;
        "lua")
            if command -v lua &> /dev/null; then
                if lua -e "dofile('$config_file')" &> /dev/null; then
                    return 0
                else
                    return 1
                fi
            else
                print_warning "lua not installed, skipping Lua validation"
                return 0
            fi
            ;;
        "fish")
            if command -v fish &> /dev/null; then
                if fish -n "$config_file" &> /dev/null; then
                    return 0
                else
                    return 1
                fi
            else
                print_warning "fish not installed, skipping Fish validation"
                return 0
            fi
            ;;
        "bash")
            if bash -n "$config_file" &> /dev/null; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            # For other types, just check if file is readable
            if [[ -r "$config_file" ]]; then
                return 0
            else
                return 1
            fi
            ;;
    esac
}

# Get file type from extension
get_file_type() {
    local file="$1"
    local extension="${file##*.}"
    
    case "$extension" in
        "toml") echo "toml" ;;
        "yml"|"yaml") echo "yaml" ;;
        "json") echo "json" ;;
        "lua") echo "lua" ;;
        "fish") echo "fish" ;;
        "bash"|"sh") echo "bash" ;;
        "kdl") echo "kdl" ;;
        "ron") echo "ron" ;;
        "rc") echo "bash" ;;
        "conf") echo "text" ;;
        *) echo "text" ;;
    esac
}

# Test single configuration file
test_single_config() {
    local config_file="$1"
    local config_name="$(basename "$config_file")"
    local file_type="$(get_file_type "$config_file")"
    
    printf "  %-30s " "$config_name"
    
    # Check if file exists and is readable
    if [[ ! -f "$config_file" ]]; then
        echo -e "${RED}✗ File not found${NC}"
        return 1
    fi
    
    if [[ ! -r "$config_file" ]]; then
        echo -e "${RED}✗ Not readable${NC}"
        return 1
    fi
    
    # Check file size (should not be empty)
    if [[ ! -s "$config_file" ]]; then
        echo -e "${RED}✗ Empty file${NC}"
        return 1
    fi
    
    # Test syntax
    if test_config_syntax "$config_file" "$file_type"; then
        echo -e "${GREEN}✓ Valid${NC}"
        return 0
    else
        echo -e "${RED}✗ Syntax error${NC}"
        return 1
    fi
}

# Test all configs in a package
test_package_configs() {
    local package_dir="$1"
    local package_name="$(basename "$package_dir")"
    local configs_dir="$package_dir/configs"
    
    print_status "Testing $package_name configurations..."
    
    if [[ ! -d "$configs_dir" ]]; then
        print_warning "No configs directory found in $package_name"
        return 0
    fi
    
    local total_configs=0
    local passed_configs=0
    
    for config_file in "$configs_dir"/*; do
        if [[ -f "$config_file" ]]; then
            ((total_configs++))
            if test_single_config "$config_file"; then
                ((passed_configs++))
            fi
        fi
    done
    
    echo
    if [[ $passed_configs -eq $total_configs ]]; then
        print_success "$package_name: All $total_configs configurations valid"
    else
        print_error "$package_name: $((total_configs - passed_configs))/$total_configs configurations failed"
    fi
    
    return $((total_configs - passed_configs))
}

# Test PKGBUILD syntax
test_pkgbuild() {
    local package_dir="$1"
    local package_name="$(basename "$package_dir")"
    local pkgbuild="$package_dir/PKGBUILD"
    
    printf "  %-30s " "PKGBUILD"
    
    if [[ ! -f "$pkgbuild" ]]; then
        echo -e "${RED}✗ Not found${NC}"
        return 1
    fi
    
    # Source PKGBUILD in subshell to check syntax
    if (source "$pkgbuild" &> /dev/null); then
        echo -e "${GREEN}✓ Valid${NC}"
        return 0
    else
        echo -e "${RED}✗ Syntax error${NC}"
        return 1
    fi
}

# Test package structure
test_package_structure() {
    local package_dir="$1"
    local package_name="$(basename "$package_dir")"
    
    print_status "Testing $package_name package structure..."
    
    local required_files=("PKGBUILD")
    local optional_dirs=("configs")
    
    local structure_valid=true
    
    # Check required files
    for file in "${required_files[@]}"; do
        printf "  %-30s " "$file"
        if [[ -f "$package_dir/$file" ]]; then
            echo -e "${GREEN}✓ Present${NC}"
        else
            echo -e "${RED}✗ Missing${NC}"
            structure_valid=false
        fi
    done
    
    # Check optional directories
    for dir in "${optional_dirs[@]}"; do
        printf "  %-30s " "$dir/"
        if [[ -d "$package_dir/$dir" ]]; then
            local config_count=$(find "$package_dir/$dir" -type f | wc -l)
            echo -e "${GREEN}✓ Present ($config_count files)${NC}"
        else
            echo -e "${YELLOW}! Optional (not present)${NC}"
        fi
    done
    
    echo
    
    if $structure_valid; then
        return 0
    else
        return 1
    fi
}

# Create test environment
setup_test_env() {
    print_status "Setting up test environment..."
    
    mkdir -p "$TEST_DIR"
    
    # Create minimal home directory structure
    export HOME="$TEST_DIR/home"
    mkdir -p "$HOME/.config"
    
    print_success "Test environment created at $TEST_DIR"
}

# Cleanup test environment
cleanup_test_env() {
    print_status "Cleaning up test environment..."
    rm -rf "$TEST_DIR"
    print_success "Test environment cleaned up"
}

# Test installation simulation
test_installation() {
    local package_dir="$1"
    local package_name="$(basename "$package_dir")"
    local configs_dir="$package_dir/configs"
    
    print_status "Testing installation simulation for $package_name..."
    
    if [[ ! -d "$configs_dir" ]]; then
        print_warning "No configs to test for $package_name"
        return 0
    fi
    
    local install_errors=0
    
    # Simulate config installation
    for config_file in "$configs_dir"/*; do
        if [[ -f "$config_file" ]]; then
            local config_name="$(basename "$config_file")"
            local target_path=""
            
            # Determine target path based on config name
            case "$config_name" in
                "zellij-config.kdl") target_path="$HOME/.config/zellij/config.kdl" ;;
                "starship-config.toml") target_path="$HOME/.config/starship.toml" ;;
                "neovim-init.lua") target_path="$HOME/.config/nvim/init.lua" ;;
                "helix-config.toml") target_path="$HOME/.config/helix/config.toml" ;;
                "fish-config.fish") target_path="$HOME/.config/fish/config.fish" ;;
                "gitconfig") target_path="$HOME/.gitconfig" ;;
                "taskwarrior-config.taskrc") target_path="$HOME/.taskrc" ;;
                *) target_path="$HOME/.config/$(basename "$config_name")" ;;
            esac
            
            printf "  %-30s " "$config_name"
            
            # Create target directory
            mkdir -p "$(dirname "$target_path")"
            
            # Copy config file
            if cp "$config_file" "$target_path" 2>/dev/null; then
                echo -e "${GREEN}✓ Installed${NC}"
            else
                echo -e "${RED}✗ Failed${NC}"
                ((install_errors++))
            fi
        fi
    done
    
    echo
    
    if [[ $install_errors -eq 0 ]]; then
        print_success "$package_name: Installation simulation passed"
        return 0
    else
        print_error "$package_name: $install_errors installation errors"
        return 1
    fi
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        "syntax")
            local package="${2:-all}"
            local total_errors=0
            
            print_status "Testing configuration syntax..."
            echo
            
            if [[ "$package" == "all" ]]; then
                for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                    if [[ -d "$package_dir" ]]; then
                        if ! test_package_configs "$package_dir"; then
                            ((total_errors++))
                        fi
                        echo
                    fi
                done
            else
                local package_dir="$PACKAGES_DIR/$package"
                if [[ -d "$package_dir" ]]; then
                    if ! test_package_configs "$package_dir"; then
                        ((total_errors++))
                    fi
                else
                    print_error "Package not found: $package"
                    exit 1
                fi
            fi
            
            if [[ $total_errors -eq 0 ]]; then
                print_success "All configuration syntax tests passed!"
            else
                print_error "$total_errors package(s) had syntax errors"
                exit 1
            fi
            ;;
            
        "structure")
            local package="${2:-all}"
            local total_errors=0
            
            print_status "Testing package structure..."
            echo
            
            if [[ "$package" == "all" ]]; then
                for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                    if [[ -d "$package_dir" ]]; then
                        if ! test_package_structure "$package_dir"; then
                            ((total_errors++))
                        fi
                        echo
                    fi
                done
            else
                local package_dir="$PACKAGES_DIR/$package"
                if [[ -d "$package_dir" ]]; then
                    if ! test_package_structure "$package_dir"; then
                        ((total_errors++))
                    fi
                else
                    print_error "Package not found: $package"
                    exit 1
                fi
            fi
            
            if [[ $total_errors -eq 0 ]]; then
                print_success "All package structure tests passed!"
            else
                print_error "$total_errors package(s) had structure errors"
                exit 1
            fi
            ;;
            
        "pkgbuild")
            local package="${2:-all}"
            local total_errors=0
            
            print_status "Testing PKGBUILD syntax..."
            echo
            
            if [[ "$package" == "all" ]]; then
                for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                    if [[ -d "$package_dir" ]]; then
                        print_status "Testing $(basename "$package_dir") PKGBUILD..."
                        if ! test_pkgbuild "$package_dir"; then
                            ((total_errors++))
                        fi
                        echo
                    fi
                done
            else
                local package_dir="$PACKAGES_DIR/$package"
                if [[ -d "$package_dir" ]]; then
                    print_status "Testing $package PKGBUILD..."
                    if ! test_pkgbuild "$package_dir"; then
                        ((total_errors++))
                    fi
                else
                    print_error "Package not found: $package"
                    exit 1
                fi
            fi
            
            if [[ $total_errors -eq 0 ]]; then
                print_success "All PKGBUILD tests passed!"
            else
                print_error "$total_errors PKGBUILD(s) had syntax errors"
                exit 1
            fi
            ;;
            
        "install")
            local package="${2:-all}"
            
            setup_test_env
            trap cleanup_test_env EXIT
            
            local total_errors=0
            
            print_status "Testing installation simulation..."
            echo
            
            if [[ "$package" == "all" ]]; then
                for package_dir in "$PACKAGES_DIR"/modern-cli-*; do
                    if [[ -d "$package_dir" ]]; then
                        if ! test_installation "$package_dir"; then
                            ((total_errors++))
                        fi
                        echo
                    fi
                done
            else
                local package_dir="$PACKAGES_DIR/$package"
                if [[ -d "$package_dir" ]]; then
                    if ! test_installation "$package_dir"; then
                        ((total_errors++))
                    fi
                else
                    print_error "Package not found: $package"
                    exit 1
                fi
            fi
            
            if [[ $total_errors -eq 0 ]]; then
                print_success "All installation tests passed!"
            else
                print_error "$total_errors package(s) had installation errors"
                exit 1
            fi
            ;;
            
        "all")
            local package="${2:-all}"
            
            print_status "Running all tests..."
            echo
            
            local test_commands=("structure" "pkgbuild" "syntax" "install")
            local failed_tests=()
            
            for test_cmd in "${test_commands[@]}"; do
                echo "=========================================="
                if ! "$0" "$test_cmd" "$package"; then
                    failed_tests+=("$test_cmd")
                fi
                echo
            done
            
            echo "=========================================="
            
            if [[ ${#failed_tests[@]} -eq 0 ]]; then
                print_success "All tests passed!"
            else
                print_error "Failed tests: ${failed_tests[*]}"
                exit 1
            fi
            ;;
            
        "help"|*)
            cat << EOF
Modern CLI Configuration Test Script

Usage: $0 <command> [package]

Commands:
  syntax [package]      Test configuration file syntax
  structure [package]   Test package directory structure
  pkgbuild [package]    Test PKGBUILD syntax
  install [package]     Test installation simulation
  all [package]         Run all tests
  help                  Show this help

Arguments:
  package              Package name (default: all)

Examples:
  $0 syntax                    # Test all config syntax
  $0 syntax modern-cli-core    # Test core config syntax
  $0 structure                 # Test all package structures
  $0 pkgbuild                  # Test all PKGBUILD files
  $0 install modern-cli-git    # Test git package installation
  $0 all                       # Run all tests

Dependencies:
  Optional: taplo (TOML), yq (YAML), jq (JSON), lua (Lua)

EOF
            ;;
    esac
}

main "$@"