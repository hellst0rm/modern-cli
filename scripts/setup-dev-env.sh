#!/usr/bin/env bash
# scripts/setup-dev-env.sh - Setup development environment with aurutils and paru

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

# Check if running on Arch Linux
check_arch_linux() {
    if ! command -v pacman &> /dev/null; then
        print_error "This script requires Arch Linux with pacman"
        print_status "For other distributions, please install equivalent packages manually"
        exit 1
    fi
    
    print_success "Arch Linux detected"
}

# Install base development tools
install_base_tools() {
    print_status "Installing base development tools..."
    
    local packages=(
        "base-devel"
        "devtools"
        "git"
        "namcap"
    )
    
    if sudo pacman -S --needed --noconfirm "${packages[@]}"; then
        print_success "Base development tools installed"
    else
        print_error "Failed to install base development tools"
        exit 1
    fi
}

# Install paru AUR helper
install_paru() {
    if command -v paru &> /dev/null; then
        print_success "Paru is already installed"
        return 0
    fi
    
    print_status "Installing paru AUR helper..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local original_dir=$(pwd)
    
    cd "$temp_dir"
    
    # Clone and build paru
    if git clone https://aur.archlinux.org/paru.git; then
        cd paru
        
        if makepkg -si --noconfirm; then
            print_success "Paru installed successfully"
        else
            print_error "Failed to build paru"
            cd "$original_dir"
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        print_error "Failed to clone paru repository"
        cd "$original_dir"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Cleanup
    cd "$original_dir"
    rm -rf "$temp_dir"
}

# Install aurutils
install_aurutils() {
    if command -v aur &> /dev/null; then
        print_success "Aurutils is already installed"
        return 0
    fi
    
    print_status "Installing aurutils..."
    
    if paru -S --noconfirm aurutils; then
        print_success "Aurutils installed successfully"
    else
        print_error "Failed to install aurutils"
        exit 1
    fi
}

# Install repoctl
install_repoctl() {
    if command -v repoctl &> /dev/null; then
        print_success "Repoctl is already installed"
        return 0
    fi
    
    print_status "Installing repoctl..."
    
    if paru -S --noconfirm repoctl; then
        print_success "Repoctl installed successfully"
    else
        print_error "Failed to install repoctl"
        exit 1
    fi
}

# Setup aurutils configuration
setup_aurutils_config() {
    print_status "Setting up aurutils configuration..."
    
    local config_dir="$HOME/.config/aurutils"
    local config_file="$config_dir/aurutils.conf"
    
    mkdir -p "$config_dir"
    
    # Create aurutils config if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << 'EOF'
# Aurutils configuration for modern-cli development

[modern-cli]
Server = file://$HOME/.cache/aurutils/modern-cli

[options]
# Enable color output
Color

# Use all cores for compilation
MAKEFLAGS = "-j$(nproc)"

# Additional options for clean builds
CleanBuild
EOF
        print_success "Created aurutils configuration at $config_file"
    else
        print_success "Aurutils configuration already exists"
    fi
}

# Initialize local repository
initialize_repository() {
    print_status "Initializing local repository..."
    
    cd "$REPO_DIR"
    
    # Initialize the repository using our script
    if ./scripts/build-repo.sh init; then
        print_success "Repository initialized successfully"
    else
        print_warning "Repository initialization may have failed or already exists"
    fi
}

# Add repository to pacman.conf
setup_pacman_config() {
    print_status "Configuring pacman for local repository..."
    
    local repo_entry="[modern-cli]"
    local repo_server="Server = file://$HOME/.cache/aurutils/modern-cli"
    
    if grep -q "$repo_entry" /etc/pacman.conf; then
        print_success "Repository already configured in pacman.conf"
        return 0
    fi
    
    print_status "Adding repository to pacman configuration..."
    
    # Create backup
    sudo cp /etc/pacman.conf /etc/pacman.conf.backup.$(date +%Y%m%d-%H%M%S)
    
    # Add repository configuration
    sudo tee -a /etc/pacman.conf << EOF

# Modern CLI local repository (added by setup script)
[modern-cli]
Server = file://$HOME/.cache/aurutils/modern-cli
EOF
    
    print_success "Repository added to pacman.conf"
    print_warning "Note: You may need to run 'sudo pacman -Sy' to refresh package databases"
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    local tools=(
        "paru:Paru AUR helper"
        "repoctl:Repoctl"
        "aur:Aurutils"
        "pkgctl:Devtools (pkgctl)"
        "namcap:Namcap"
        "makepkg:Makepkg"
    )
    
    local all_good=true
    
    echo
    print_status "Tool availability:"
    for tool_desc in "${tools[@]}"; do
        local tool="${tool_desc%%:*}"
        local desc="${tool_desc#*:}"
        
        if command -v "$tool" &> /dev/null; then
            printf "  %-20s %s\\n" "$desc:" "✓ Available"
        else
            printf "  %-20s %s\\n" "$desc:" "✗ Missing"
            all_good=false
        fi
    done
    
    echo
    print_status "Configuration files:"
    
    local config_files=(
        "$HOME/.config/aurutils/aurutils.conf:Aurutils config"
        "$HOME/.cache/aurutils/modern-cli:Repository cache"
    )
    
    for file_desc in "${config_files[@]}"; do
        local file="${file_desc%%:*}"
        local desc="${file_desc#*:}"
        
        if [[ -e "$file" ]]; then
            printf "  %-20s %s\\n" "$desc:" "✓ Exists"
        else
            printf "  %-20s %s\\n" "$desc:" "✗ Missing"
        fi
    done
    
    echo
    if $all_good; then
        print_success "All tools are available!"
    else
        print_warning "Some tools are missing, but the setup can still work"
    fi
}

# Show usage information
show_usage_info() {
    cat << EOF

${GREEN}Setup Complete!${NC}

${BLUE}Available commands:${NC}
  ./scripts/build-repo.sh      - Repository management
  ./scripts/test-pkgbuild.sh   - Test PKGBUILD files with paru support
  ./scripts/update-packages.sh - Build packages with aurutils and paru
  make setup                   - Re-run this setup (if Makefile exists)
  make help                    - Show Makefile help

${BLUE}Quick start:${NC}
  1. Test PKGBUILD files:      ./scripts/test-pkgbuild.sh all
  2. Build all packages:       ./scripts/update-packages.sh build
  3. Update repository:        ./scripts/build-repo.sh add
  4. Show repository status:   ./scripts/build-repo.sh status

${BLUE}Repository information:${NC}
  - Local repo: ~/.cache/aurutils/modern-cli
  - Config: ~/.config/aurutils/aurutils.conf
  - Build dir: $REPO_DIR/x86_64

${YELLOW}Next steps:${NC}
  - Run 'sudo pacman -Sy' to refresh package databases
  - Test the setup with './scripts/test-pkgbuild.sh all'

EOF
}

# Main function
main() {
    echo "Modern CLI Development Environment Setup"
    echo "========================================"
    echo
    
    print_status "Starting development environment setup..."
    
    # Check prerequisites
    check_arch_linux
    
    # Install tools
    install_base_tools
    install_paru
    install_repoctl
    install_aurutils
    
    # Configure environment
    setup_aurutils_config
    initialize_repository
    setup_pacman_config
    
    # Verify and show results
    verify_installation
    show_usage_info
    
    print_success "Development environment setup complete!"
}

# Handle command line arguments
case "${1:-setup}" in
    "setup"|"install")
        main
        ;;
    "verify"|"check")
        verify_installation
        ;;
    "help"|"--help"|"-h")
        cat << EOF
Development Environment Setup Script

Usage: $0 [command]

Commands:
  setup/install    Setup complete development environment (default)
  verify/check     Verify current installation
  help             Show this help

This script will:
- Install base development tools (base-devel, devtools, git, namcap)
- Install paru AUR helper
- Install aurutils for repository management
- Configure aurutils for the modern-cli project
- Initialize local repository
- Configure pacman to use the local repository

Requirements:
- Arch Linux with pacman
- Internet connection
- sudo privileges

EOF
        ;;
    *)
        print_error "Unknown command: $1"
        print_status "Use '$0 help' for usage information"
        exit 1
        ;;
esac
