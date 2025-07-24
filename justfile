# Modern CLI Repository Justfile
# Integrated repoctl, aurutils and paru workflow

# Configuration
repo_name := "modern-cli"
build_dir := "x86_64"
script_dir := "scripts"
packages_dir := "packages"

# Default recipe (help)
default:
    @echo "{{BLUE}}Modern CLI Repository - Justfile with Repoctl, Aurutils & Paru Integration{{NORMAL}}"
    @echo ""
    @echo "{{BLUE}}Setup Commands:{{NORMAL}}"
    @echo "  just setup           Setup development environment (installs paru, repoctl & aurutils)"
    @echo "  just check-env       Check if required tools are available"
    @echo "  just install-deps    Install development dependencies"
    @echo ""
    @echo "{{BLUE}}Development Commands:{{NORMAL}}"
    @echo "  just test            Test all PKGBUILD files with paru support"
    @echo "  just build           Build all packages using repoctl/aurutils/paru/pkgctl"
    @echo "  just update          Update package versions and dependencies"
    @echo "  just clean           Clean build artifacts"
    @echo ""
    @echo "{{BLUE}}Repository Commands:{{NORMAL}}"
    @echo "  just repo-init       Initialize aurutils repository"
    @echo "  just repo-add        Add packages to repository database"
    @echo "  just repo-status     Show repository status"
    @echo "  just repo-verify     Verify repository integrity"
    @echo ""
    @echo "{{BLUE}}Package Commands:{{NORMAL}}"
    @echo "  just list            List available packages"
    @echo "  just deps            Show package dependencies and build order"
    @echo "  just install-local   Install packages from local repository"
    @echo ""
    @echo "{{BLUE}}Environment Variables:{{NORMAL}}"
    @echo "  repo_name    Repository name (default: {{repo_name}})"
    @echo "  build_dir    Build directory (default: {{build_dir}})"

# Check if required tools are available
check-env:
    @echo "{{BLUE}}Checking development environment...{{NORMAL}}"
    @echo ""
    @printf "%-15s " "Pacman:"
    @if command -v pacman >/dev/null 2>&1; then echo "{{GREEN}}✓ Available{{NORMAL}}"; else echo "{{RED}}✗ Missing{{NORMAL}}"; fi
    @printf "%-15s " "Paru:"
    @if command -v paru >/dev/null 2>&1; then echo "{{GREEN}}✓ Available{{NORMAL}}"; else echo "{{YELLOW}}⚠ Optional{{NORMAL}}"; fi
    @printf "%-15s " "Repoctl:"
    @if command -v repoctl >/dev/null 2>&1; then echo "{{GREEN}}✓ Available{{NORMAL}}"; else echo "{{YELLOW}}⚠ Optional{{NORMAL}}"; fi
    @printf "%-15s " "Aurutils:"
    @if command -v aur >/dev/null 2>&1; then echo "{{GREEN}}✓ Available{{NORMAL}}"; else echo "{{YELLOW}}⚠ Optional{{NORMAL}}"; fi
    @printf "%-15s " "Pkgctl:"
    @if command -v pkgctl >/dev/null 2>&1; then echo "{{GREEN}}✓ Available{{NORMAL}}"; else echo "{{YELLOW}}⚠ Optional{{NORMAL}}"; fi
    @printf "%-15s " "Namcap:"
    @if command -v namcap >/dev/null 2>&1; then echo "{{GREEN}}✓ Available{{NORMAL}}"; else echo "{{YELLOW}}⚠ Optional{{NORMAL}}"; fi
    @printf "%-15s " "Makepkg:"
    @if command -v makepkg >/dev/null 2>&1; then echo "{{GREEN}}✓ Available{{NORMAL}}"; else echo "{{RED}}✗ Missing{{NORMAL}}"; fi
    @printf "%-15s " "Just:"
    @if command -v just >/dev/null 2>&1; then echo "{{GREEN}}✓ Available{{NORMAL}}"; else echo "{{YELLOW}}⚠ Consider installing{{NORMAL}}"; fi
    @echo ""
    @if ! command -v pacman >/dev/null 2>&1; then echo "{{RED}}Error: This requires Arch Linux with pacman{{NORMAL}}"; exit 1; fi
    @echo "{{GREEN}}Environment check complete{{NORMAL}}"

# Setup development environment
setup: check-env
    @echo "{{BLUE}}Setting up development environment with repoctl, aurutils and paru...{{NORMAL}}"
    @{{script_dir}}/setup-dev-env.sh setup
    @echo "{{GREEN}}Setup complete! Run 'just check-env' to verify{{NORMAL}}"

# Install development dependencies
install-deps: check-env
    @echo "{{BLUE}}Installing base development dependencies...{{NORMAL}}"
    @if command -v paru >/dev/null 2>&1; then paru -S --needed --noconfirm base-devel devtools git namcap just; else sudo pacman -S --needed --noconfirm base-devel devtools git namcap; fi
    @echo "{{GREEN}}Dependencies installed{{NORMAL}}"

# Test all PKGBUILD files
test: check-env
    @echo "{{BLUE}}Testing PKGBUILD files with paru integration...{{NORMAL}}"
    @{{script_dir}}/test-pkgbuild.sh all

# Test specific package
test-package package: check-env
    @echo "{{BLUE}}Testing specific package: {{package}}{{NORMAL}}"
    @{{script_dir}}/test-pkgbuild.sh {{package}}

# Build all packages
build: check-env test
    @echo "{{BLUE}}Building all packages with repoctl/aurutils/paru/pkgctl...{{NORMAL}}"
    @{{script_dir}}/update-packages.sh build
    @{{script_dir}}/build-repo.sh add
    @echo "{{GREEN}}Build complete{{NORMAL}}"

# Build specific package
build-package package: check-env
    @echo "{{BLUE}}Building specific package: {{package}}{{NORMAL}}"
    @{{script_dir}}/test-pkgbuild.sh {{package}}
    @{{script_dir}}/update-packages.sh build {{package}}
    @{{script_dir}}/build-repo.sh add

# Update package versions and dependencies
update: check-env
    @echo "{{BLUE}}Updating package versions...{{NORMAL}}"
    @{{script_dir}}/update-packages.sh version-all `date +%Y%m%d`
    @echo "{{GREEN}}Versions updated{{NORMAL}}"

# Clean build artifacts
clean:
    @echo "{{BLUE}}Cleaning build artifacts...{{NORMAL}}"
    @{{script_dir}}/update-packages.sh clean
    @{{script_dir}}/build-repo.sh clean
    @echo "{{GREEN}}Clean complete{{NORMAL}}"

# Repository management commands
repo-init: check-env
    @echo "{{BLUE}}Initializing aurutils repository...{{NORMAL}}"
    @{{script_dir}}/build-repo.sh init

repo-add: check-env
    @echo "{{BLUE}}Adding packages to repository...{{NORMAL}}"
    @{{script_dir}}/build-repo.sh add

repo-status:
    @echo "{{BLUE}}Repository status:{{NORMAL}}"
    @{{script_dir}}/build-repo.sh status

repo-verify:
    @echo "{{BLUE}}Verifying repository integrity...{{NORMAL}}"
    @{{script_dir}}/build-repo.sh verify

# Package information commands
list:
    @echo "{{BLUE}}Available packages:{{NORMAL}}"
    @{{script_dir}}/update-packages.sh list

deps:
    @echo "{{BLUE}}Package dependencies and build order:{{NORMAL}}"
    @{{script_dir}}/update-packages.sh deps

# Development workflow recipes
dev-test: test
    @echo "{{GREEN}}Development test complete{{NORMAL}}"

dev-build: test build
    @echo "{{GREEN}}Development build complete{{NORMAL}}"

dev-full: clean test build repo-verify
    @echo "{{GREEN}}Full development cycle complete{{NORMAL}}"

# Install packages locally
install-local: build
    @echo "{{BLUE}}Installing packages from local repository...{{NORMAL}}"
    @sudo pacman -Sy
    @if sudo pacman -S --noconfirm modern-cli-meta; then echo "{{GREEN}}Local packages installed{{NORMAL}}"; else echo "{{YELLOW}}Installation may have failed or packages already installed{{NORMAL}}"; fi

# Uninstall local packages
uninstall-local:
    @echo "{{BLUE}}Uninstalling modern-cli packages...{{NORMAL}}"
    @sudo pacman -Rs modern-cli-meta || echo "{{YELLOW}}Packages may not be installed{{NORMAL}}"

# CI/CD recipes
ci-setup: install-deps
    @echo "{{BLUE}}CI environment setup{{NORMAL}}"
    @if command -v paru >/dev/null 2>&1 && command -v aur >/dev/null 2>&1 && command -v repoctl >/dev/null 2>&1; then echo "{{GREEN}}Enhanced tools available{{NORMAL}}"; else echo "{{YELLOW}}Using basic tools only{{NORMAL}}"; fi

ci-test: ci-setup test
    @echo "{{GREEN}}CI test complete{{NORMAL}}"

ci-build: ci-setup build
    @echo "{{GREEN}}CI build complete{{NORMAL}}"

# Show comprehensive status
status:
    @echo "{{BLUE}}Modern CLI Repository Status{{NORMAL}}"
    @echo "============================"
    @echo ""
    @echo "{{BLUE}}Environment:{{NORMAL}}"
    @printf "  %-20s %s\n" "Repository:" "{{repo_name}}"
    @printf "  %-20s %s\n" "Build directory:" "{{build_dir}}"
    @printf "  %-20s %s\n" "Packages directory:" "{{packages_dir}}"
    @echo ""
    @just check-env
    @echo ""
    @if [ -d "{{build_dir}}" ]; then \
        echo "{{BLUE}}Built packages:{{NORMAL}}"; \
        if ls {{build_dir}}/*.pkg.tar.* 1> /dev/null 2>&1; then \
            for pkg in {{build_dir}}/*.pkg.tar.*; do \
                if [ -f "$pkg" ]; then \
                    pkg_name=$$(basename "$pkg"); \
                    pkg_size=$$(stat -c%s "$pkg" | numfmt --to=iec 2>/dev/null || echo "unknown"); \
                    printf "  %-40s %s\n" "$pkg_name" "$pkg_size"; \
                fi \
            done; \
        else \
            echo "  No packages found"; \
        fi; \
    else \
        echo "{{YELLOW}}No build directory found{{NORMAL}}"; \
    fi
    @echo ""
    @if [ -d "$$HOME/.cache/aurutils/{{repo_name}}" ]; then \
        echo "{{BLUE}}Aurutils repository:{{NORMAL}}"; \
        printf "  %-20s %s\n" "Location:" "$$HOME/.cache/aurutils/{{repo_name}}"; \
        printf "  %-20s %s\n" "Status:" "{{GREEN}}Initialized{{NORMAL}}"; \
    else \
        echo "{{YELLOW}}Aurutils repository not initialized{{NORMAL}}"; \
    fi

# Information about the project
info:
    @echo "{{BLUE}}Modern CLI Repository Information{{NORMAL}}"
    @echo "================================"
    @echo ""
    @echo "This repository contains modern CLI tool packages built with:"
    @echo "  - {{GREEN}}Repoctl{{NORMAL}}: Advanced repository management (primary)"
    @echo "  - {{GREEN}}Aurutils{{NORMAL}}: AUR-aware repository management"
    @echo "  - {{GREEN}}Paru{{NORMAL}}: AUR helper for dependency resolution"
    @echo "  - {{GREEN}}Pkgctl{{NORMAL}}: Reproducible chroot builds"
    @echo "  - {{GREEN}}Makepkg{{NORMAL}}: Traditional package building"
    @echo "  - {{GREEN}}Just{{NORMAL}}: Modern command runner"
    @echo ""
    @echo "{{BLUE}}Build Process:{{NORMAL}}"
    @echo "  1. Dependencies resolved with paru"
    @echo "  2. Packages built with aurutils (preferred) or pkgctl"
    @echo "  3. Repository managed with repoctl (primary) or aurutils"
    @echo "  4. Traditional pacman compatibility maintained"
    @echo ""
    @echo "{{BLUE}}Quick Start:{{NORMAL}}"
    @echo "  just setup      # Setup development environment"
    @echo "  just test       # Test all packages"
    @echo "  just build      # Build all packages"
    @echo "  just status     # Show current status"

# Show detailed help for advanced usage
help-advanced:
    @echo "{{BLUE}}Advanced Usage{{NORMAL}}"
    @echo "=============="
    @echo ""
    @echo "{{BLUE}}Package-specific recipes:{{NORMAL}}"
    @echo "  just test-package modern-cli-core   # Test specific package"
    @echo "  just build-package modern-cli-core  # Build specific package"
    @echo ""
    @echo "{{BLUE}}Development workflows:{{NORMAL}}"
    @echo "  just dev-test      # Quick test cycle"
    @echo "  just dev-build     # Test + build cycle"
    @echo "  just dev-full      # Clean + test + build + verify"
    @echo ""
    @echo "{{BLUE}}CI/CD recipes:{{NORMAL}}"
    @echo "  just ci-setup      # Setup CI environment"
    @echo "  just ci-test       # CI test workflow"
    @echo "  just ci-build      # CI build workflow"
    @echo ""
    @echo "{{BLUE}}Repository management:{{NORMAL}}"
    @echo "  just repo-init     # Initialize aurutils repo"
    @echo "  just repo-add      # Add packages to database"
    @echo "  just repo-status   # Show repo status"
    @echo "  just repo-verify   # Verify repo integrity"
    @echo ""
    @echo "{{BLUE}}Local installation:{{NORMAL}}"
    @echo "  just install-local   # Install built packages"
    @echo "  just uninstall-local # Remove installed packages"

# Watch for changes and rebuild
watch:
    @echo "{{BLUE}}Watching for changes...{{NORMAL}}"
    @while inotifywait -r -e modify,create,delete {{packages_dir}}; do \
        echo "{{YELLOW}}Changes detected, rebuilding...{{NORMAL}}"; \
        just build; \
    done

# Interactive package selection
interactive:
    #!/usr/bin/env bash
    @echo "{{BLUE}}Interactive Package Management{{NORMAL}}"
    @echo "Available packages:"
    @select pkg in $(ls {{packages_dir}} | grep modern-cli-); do
        if [ -n "$pkg" ]; then
            echo "Selected package: $pkg"
            echo "What would you like to do?"
            select action in "test" "build" "info" "quit"; do
                case $action in
                    test) just test-package $pkg; break;;
                    build) just build-package $pkg; break;;
                    info) echo "Package: $pkg"; ls -la {{packages_dir}}/$pkg/; break;;
                    quit) exit;;
                esac
            done
            break
        fi
    done

# Generate documentation
docs:
    @echo "{{BLUE}}Generating documentation...{{NORMAL}}"
    @mkdir -p docs/generated
    @just --list > docs/generated/justfile-help.txt
    @{{script_dir}}/build-repo.sh help > docs/generated/build-repo-help.txt
    @{{script_dir}}/test-pkgbuild.sh help > docs/generated/test-pkgbuild-help.txt
    @{{script_dir}}/update-packages.sh help > docs/generated/update-packages-help.txt
    @echo "{{GREEN}}Documentation generated in docs/generated/{{NORMAL}}"

# Validate justfile syntax
validate:
    @echo "{{BLUE}}Validating justfile syntax...{{NORMAL}}"
    @just --evaluate > /dev/null
    @echo "{{GREEN}}Justfile syntax is valid{{NORMAL}}"

# Test colors
test-colors:
    @echo "{{BLUE}}Testing colors:{{NORMAL}}"
    @echo "{{RED}}  Red text{{NORMAL}}"
    @echo "{{GREEN}}  Green text{{NORMAL}}" 
    @echo "{{YELLOW}}  Yellow text{{NORMAL}}"
    @echo "{{BLUE}}  Blue text{{NORMAL}}"
    @echo "Colors are working properly!"

# Show recipe dependencies
graph:
    @echo "{{BLUE}}Recipe dependency graph:{{NORMAL}}"
    @just --list --unsorted | grep -E '^[[:space:]]*[^[:space:]]+:' | sort

# Quick development cycle
quick: test build repo-add
    @echo "{{GREEN}}Quick development cycle complete{{NORMAL}}"

# Full release cycle
release: clean test build repo-verify install-local
    @echo "{{GREEN}}Full release cycle complete{{NORMAL}}"
