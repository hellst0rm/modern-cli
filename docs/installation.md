# Modern CLI Tools Installation Guide

Welcome to the Modern CLI Tools repository! This guide will help you install and configure a complete modern command-line environment on Arch Linux.

## 🚀 Quick Start

### 1. Add Custom Repository

Edit your pacman configuration:

```bash
sudo vim /etc/pacman.conf
```

Add the following at the end of the file:

```ini
[modern-cli-repo]
Server = https://hellst0rm.github.io/modern-cli/$arch
```

### 2. Update Package Database

```bash
sudo pacman -Sy
```

### 3. Choose Your Installation

#### Option A: Complete Installation (Recommended)
```bash
# Install everything
sudo pacman -S modern-cli-meta

# Configure all tools
modern-cli install
```

#### Option B: Minimal Installation
```bash
# Install just the essentials
sudo pacman -S modern-cli-core

# Configure core tools
modern-cli install
```

#### Option C: Custom Installation
```bash
# Install specific packages
sudo pacman -S modern-cli-core modern-cli-git modern-cli-development

# Configure selected tools
modern-cli install
```

## 📦 Available Packages

### **modern-cli-core** (Required Base)
Essential modern CLI tools and configurations.

**Tools Included:**
- `fish` - Friendly interactive shell
- `helix` - Modal text editor
- `neovim` - Extensible text editor
- `yazi` - Terminal file manager
- `zellij` - Terminal multiplexer
- `starship` - Cross-shell prompt
- `bat` - Cat clone with syntax highlighting
- `fd` - Find alternative
- `ripgrep` - Grep alternative
- `eza` - ls alternative
- `zoxide` - cd alternative
- `fzf` - Fuzzy finder
- `mcfly` - Shell history search
- `tealdeer` - TLDR client
- `gitui` - Terminal Git UI
- `git-delta` - Git diff viewer

**Size:** ~50MB

### **modern-cli-system**
System monitoring and management tools.

**Tools Included:**
- `procs` - ps alternative
- `dust` - du alternative
- `bottom` - htop alternative
- `duf` - df alternative
- `bandwhich` - Network monitor
- `hyperfine` - Benchmarking tool
- `tokei` - Code statistics
- `broot` - Tree view and navigation

**Size:** ~15MB

### **modern-cli-git**
Advanced Git tools and workflows.

**Tools Included:**
- `lazygit` - Terminal Git UI
- `git-interactive-rebase-tool` - Interactive rebase
- `git-lfs` - Large file storage
- `github-cli` - GitHub CLI

**Size:** ~25MB

### **modern-cli-music**
Music and media management tools.

**Tools Included:**
- `cmus` - Terminal music player
- `ncmpcpp` - MPD client
- `mpd` - Music player daemon
- `mpv` - Media player
- `playerctl` - Media control
- `beets` - Music library manager
- `yt-dlp` - Video/audio downloader
- `aria2` - Download manager

**Size:** ~40MB

### **modern-cli-productivity**
Task management and productivity tools.

**Tools Included:**
- `taskwarrior` - Task management
- `timewarrior` - Time tracking
- `vit` - Visual task interface
- `calcurse` - Calendar application
- `remind` - Calendar and alarm
- `ledger` - Plain text accounting

**Size:** ~20MB

### **modern-cli-communication**
Email, RSS, and web browsing tools.

**Tools Included:**
- `aerc` - Terminal email client
- `neomutt` - Email client
- `isync` - Email synchronization
- `msmtp` - SMTP client
- `notmuch` - Email indexer
- `newsboat` - RSS reader
- `w3m` - Terminal web browser
- `lynx` - Text web browser

**Size:** ~30MB

### **modern-cli-network**
Network tools and utilities.

**Tools Included:**
- `dog` - DNS lookup
- `xh` - HTTP client
- `ouch` - Archive tool
- `curl` - Data transfer tool
- `wget` - File downloader
- `bandwhich` - Network monitor
- `nmap` - Network scanner
- `wireshark-cli` - Network analyzer

**Size:** ~25MB

### **modern-cli-development**
Development tools and language servers.

**Tools Included:**
- `rust-analyzer` - Rust language server
- `typescript-language-server` - TypeScript/JavaScript LSP
- `python-lsp-server` - Python language server
- `gopls` - Go language server
- `nil` - Nix language server
- `just` - Command runner
- `watchexec` - File watcher
- `entr` - File watcher alternative

**Size:** ~100MB

### **modern-cli-meta**
Meta package that installs all other packages.

**Dependencies:** All packages listed above

**Total Size:** ~300MB

## 🔧 Configuration Management

After installing packages, use the `modern-cli` tool to manage configurations:

### View Installed Packages
```bash
modern-cli packages
```

### List Available Configurations
```bash
modern-cli list
```

### Install Configurations
```bash
# Install all configurations for installed packages
modern-cli install

# Check installation status
modern-cli status
```

### Backup Current Configurations
```bash
modern-cli backup
```

### Get Help
```bash
modern-cli help
```

## 🎯 Usage Scenarios

### Scenario 1: New Developer Setup
```bash
# Install core tools + development + git
sudo pacman -S modern-cli-core modern-cli-development modern-cli-git

# Configure everything
modern-cli install

# Start using modern tools
exec fish
```

### Scenario 2: System Administrator
```bash
# Install core + system monitoring + network tools
sudo pacman -S modern-cli-core modern-cli-system modern-cli-network

# Configure tools
modern-cli install
```

### Scenario 3: Content Creator
```bash
# Install core + music + communication
sudo pacman -S modern-cli-core modern-cli-music modern-cli-communication

# Configure media tools
modern-cli install
```

### Scenario 4: Minimalist Setup
```bash
# Just the essentials
sudo pacman -S modern-cli-core

# Configure core tools only
modern-cli install
```

## 🛠️ Post-Installation Setup

### 1. Configure Personal Information
```bash
# Set your Git identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 2. Update Documentation Database
```bash
# Update TLDR database
tldr --update
```

### 3. Configure Email (if communication package installed)
```bash
# Edit email configurations
hx ~/.config/aerc/aerc.conf
hx ~/.config/neomutt/neomuttrc
```

### 4. Add RSS Feeds (if communication package installed)
```bash
# Add your favorite RSS feeds
echo "https://example.com/rss.xml" >> ~/.config/newsboat/urls
```

### 5. Set Music Directory (if music package installed)
```bash
# Configure music directory
echo 'music_directory "~/Music"' >> ~/.config/mpd/mpd.conf
```

## 🔍 Verification

Check that everything is working correctly:

```bash
# Check package installation
modern-cli packages

# Verify configurations
modern-cli status

# Test core tools
fish --version
hx --version
yazi --version
zellij --version
```

## 🆕 Adding More Packages Later

You can add packages at any time:

```bash
# Add system monitoring tools
sudo pacman -S modern-cli-system

# Install new configurations
modern-cli install

# Only new configs will be added, existing ones preserved
```

## 🔧 Customization

### Override Default Configurations
All configurations are installed to standard locations and can be customized:

```bash
# Edit Fish shell configuration
hx ~/.config/fish/config.fish

# Customize Helix editor
hx ~/.config/helix/config.toml

# Modify Starship prompt
hx ~/.config/starship.toml
```

### Add Custom Aliases
```bash
# Add to Fish config
echo "alias mycommand='echo Hello World'" >> ~/.config/fish/config.fish

# Reload shell
exec fish
```

## 🔄 Updates

### Update Packages
```bash
# Update repository database
sudo pacman -Sy

# Update packages
sudo pacman -Su

# Update configurations (optional)
modern-cli install
```

### Update Individual Package
```bash
# Update specific package
sudo pacman -S modern-cli-core

# Apply updated configurations
modern-cli install
```

## 🆘 Troubleshooting

### Repository Access Issues
```bash
# Test repository access
curl -I https://hellst0rm.github.io/modern-cli/x86_64/modern-cli-repo.db

# Refresh package database
sudo pacman -Syy
```

### Missing Dependencies
```bash
# Check for missing tools
modern-cli status

# Install missing dependencies
yay -S missing-tool-name
```

### Configuration Issues
```bash
# Check if configs are properly installed
modern-cli list

# Reinstall configurations
modern-cli install

# Check file permissions
ls -la ~/.config/fish/config.fish
```

### Shell Integration
```bash
# Reload shell after installation
exec fish

# Verify tools are in PATH
which hx yazi zellij

# Check Fish configuration
fish -c "echo $PATH"
```

## 🗑️ Uninstallation

### Remove Packages
```bash
# Remove specific package
sudo pacman -R modern-cli-core

# Remove all packages
sudo pacman -R modern-cli-meta

# Remove with dependencies
sudo pacman -Rs modern-cli-meta
```

### Remove Configurations
```bash
# Create backup first
modern-cli backup

# Manual removal (be careful!)
rm -rf ~/.config/fish/
rm -rf ~/.config/helix/
rm ~/.gitconfig
# ... etc for other configs
```

### Remove Repository
```bash
# Edit /etc/pacman.conf and remove:
[modern-cli-repo]
Server = https://hellst0rm.github.io/modern-cli/$arch

# Refresh database
sudo pacman -Sy
```

## 📞 Support

- **Documentation**: [GitHub Repository](https://github.com/yourusername/modern-cli-repo)
- **Issues**: [Report Issues](https://github.com/yourusername/modern-cli-repo/issues)
- **Wiki**: [Detailed Wiki](https://github.com/yourusername/modern-cli-repo/wiki)

## 📄 License

MIT License - Feel free to modify and distribute.