# Modern CLI Tools Repository

A curated collection of modern command-line tools and configurations for Arch Linux, packaged for easy installation and management.

## 🚀 Quick Start

```bash
# Add repository
echo '[modern-cli-repo]
Server = https://yourusername.github.io/modern-cli-repo/$arch' | sudo tee -a /etc/pacman.conf

# Install and configure
sudo pacman -Sy modern-cli-meta
modern-cli install
```

## 🎯 What You Get

### **Modern CLI Experience**
- **Fish Shell** - Intelligent autocompletions and syntax highlighting
- **Helix Editor** - Modal editing with built-in LSP support
- **Yazi File Manager** - Fast terminal file manager with image preview
- **Zellij Multiplexer** - Modern tmux alternative with better defaults
- **Starship Prompt** - Cross-shell prompt with Git integration

### **Enhanced Core Tools**
- **bat** → Enhanced `cat` with syntax highlighting
- **fd** → Faster, user-friendly `find` alternative
- **ripgrep** → Lightning-fast `grep` replacement
- **eza** → Modern `ls` with Git integration and icons
- **zoxide** → Smart `cd` with frecency algorithm
- **delta** → Beautiful Git diffs with syntax highlighting

### **System Monitoring**
- **bottom** → Cross-platform system monitor (htop alternative)
- **procs** → Modern `ps` replacement with colors and tree view
- **dust** → Intuitive `du` replacement
- **duf** → Better `df` with colors and usage bars
- **bandwhich** → Network utilization monitor by process

### **Development Tools**
- **gitui** → Fast terminal Git UI
- **lazygit** → Simple terminal UI for Git commands
- **just** → Command runner and build tool
- **hyperfine** → Command-line benchmarking tool
- **tokei** → Code statistics and line counting

## 📦 Modular Packages

Choose what you need:

### **Core Package** (Required)
```bash
sudo pacman -S modern-cli-core
```
Essential CLI tools: fish, helix, yazi, zellij, starship, bat, fd, ripgrep, eza, fzf, gitui

### **System Monitoring**
```bash
sudo pacman -S modern-cli-system
```
Tools: bottom, procs, dust, duf, bandwhich, hyperfine, tokei

### **Git Workflow**
```bash
sudo pacman -S modern-cli-git
```
Tools: lazygit, git-interactive-rebase-tool, git-lfs, github-cli

### **Music & Media**
```bash
sudo pacman -S modern-cli-music
```
Tools: cmus, ncmpcpp, mpd, mpv, playerctl, beets, yt-dlp, aria2

### **Productivity**
```bash
sudo pacman -S modern-cli-productivity
```
Tools: taskwarrior, timewarrior, vit, calcurse, remind, ledger

### **Communication**
```bash
sudo pacman -S modern-cli-communication
```
Tools: aerc, neomutt, newsboat, w3m, lynx, isync, msmtp, notmuch

### **Network Tools**
```bash
sudo pacman -S modern-cli-network
```
Tools: dog, xh, ouch, curl, wget, bandwhich, nmap, wireshark-cli

### **Development**
```bash
sudo pacman -S modern-cli-development
```
Tools: rust-analyzer, typescript-language-server, python-lsp-server, gopls, nil, just, watchexec

### **Everything**
```bash
sudo pacman -S modern-cli-meta
```
All packages above

## 🔧 Smart Configuration Management

The `modern-cli` tool automatically detects installed packages and only configures relevant tools:

```bash
# View installed packages
modern-cli packages

# Install configurations for installed packages only
modern-cli install

# Check what's configured
modern-cli status

# List available configurations
modern-cli list

# Create backup before changes
modern-cli backup
```

## 🎨 Features

### **Consistent Theme**
- **Catppuccin Mocha** color scheme across all tools
- **Unified visual experience** with consistent colors and styling
- **Dark theme** optimized for terminal usage

### **Intelligent Defaults**
- **Pre-configured integrations** between tools
- **Optimized settings** for productivity
- **Modern keybindings** and workflows

### **Safe Installation**
- **Automatic backups** before configuration changes
- **Package-aware** - only configures tools you have installed
- **Incremental updates** - add packages anytime
- **Easy rollback** with timestamped backups

## 🛠️ Installation Scenarios

### **Developer Workstation**
```bash
sudo pacman -S modern-cli-core modern-cli-development modern-cli-git
modern-cli install
```
Perfect for software development with LSP support, Git tools, and modern editing.

### **System Administrator**
```bash
sudo pacman -S modern-cli-core modern-cli-system modern-cli-network
modern-cli install
```
Essential tools for system monitoring, network troubleshooting, and administration.

### **Content Creator**
```bash
sudo pacman -S modern-cli-core modern-cli-music modern-cli-communication
modern-cli install
```
Media tools, music players, email clients, and RSS readers.

### **Minimalist Setup**
```bash
sudo pacman -S modern-cli-core
modern-cli install
```
Just the essential modern CLI tools without extras.

## 📚 Documentation

- **[Installation Guide](docs/installation.md)** - Detailed installation instructions
- **[Usage Guide](docs/usage.md)** - How to use the tools effectively
- **[Configuration Reference](docs/configuration.md)** - Customize your setup
- **[Package Details](docs/packages.md)** - Complete package documentation

## 🔄 Tool Replacements

| Traditional | Modern Alternative | Improvements |
|-------------|-------------------|--------------|
| `ls` | `eza` | Git integration, icons, colors |
| `cat` | `bat` | Syntax highlighting, line numbers |
| `find` | `fd` | Faster, simpler syntax, colors |
| `grep` | `ripgrep` | Faster, better defaults, colors |
| `cd` | `zoxide` | Frecency algorithm, smart jumping |
| `ps` | `procs` | Colors, tree view, modern output |
| `du` | `dust` | Visual tree, intuitive display |
| `df` | `duf` | Colors, usage bars, clean layout |
| `top`/`htop` | `bottom` | Better visuals, cross-platform |
| `tmux` | `zellij` | Better defaults, easier config |
| `vim`/`nano` | `helix` | Modal editing, built-in LSP |
| `bash`/`zsh` | `fish` | Smart completions, better syntax |

## 🚀 Key Integrations

### **Shell Experience**
- **Fish** with intelligent autocompletions
- **Starship** prompt with Git status and language detection
- **FZF** integration for fuzzy finding
- **McFly** for neural network-powered history search
- **Zoxide** for smart directory navigation

### **Development Workflow**
- **Helix** with LSP support for multiple languages
- **GitUI/LazyGit** for interactive Git operations
- **Delta** for beautiful Git diffs
- **Just** for project task automation
- **Language servers** for Rust, TypeScript, Python, Go, Nix

### **System Administration**
- **Bottom** for system monitoring with customizable widgets
- **Procs** for process management with tree view
- **Bandwhich** for network monitoring by process
- **Dog** for modern DNS queries
- **XH** for API testing and HTTP requests

## 🎯 Why Modern CLI Tools?

### **Performance**
- **Rust-based tools** - Most tools are written in Rust for speed and safety
- **Parallel processing** - Many tools leverage multiple CPU cores
- **Smart defaults** - Optimized configurations out of the box

### **User Experience**
- **Colors and icons** - Visual improvements over traditional tools
- **Better error messages** - More helpful and actionable feedback
- **Intuitive interfaces** - Modern UX principles applied to CLI

### **Integration**
- **Consistent keybindings** - Similar shortcuts across tools
- **Shared configurations** - Tools work well together
- **Modern formats** - Support for Git, Unicode, and modern file types

## 🔧 Customization

All configurations are installed to standard locations and can be easily customized:

```bash
# Shell configuration
hx ~/.config/fish/config.fish

# Editor settings
hx ~/.config/helix/config.toml

# Prompt customization
hx ~/.config/starship.toml

# Git configuration
hx ~/.gitconfig

# File manager settings
hx ~/.config/yazi/yazi.toml
```

## 🆕 Updates

```bash
# Update packages
sudo pacman -Sy && sudo pacman -Su

# Update configurations (optional)
modern-cli install
```

The package system integrates with Arch Linux's package manager, so updates are handled through the standard `pacman` workflow.

## 🤝 Contributing

We welcome contributions! Here's how you can help:

- **Report bugs** - Open issues for any problems you encounter
- **Suggest tools** - Propose new modern CLI tools to include
- **Improve configs** - Submit better default configurations
- **Documentation** - Help improve guides and documentation
- **Testing** - Test on different systems and report compatibility

### **Development Setup**
```bash
# Clone repository
git clone https://github.com/yourusername/modern-cli-repo.git
cd modern-cli-repo

# Test configurations
./scripts/test-configs.sh all

# Build packages
./scripts/update-packages.sh build
```

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

This project builds upon the excellent work of many open-source developers:

- **Fish Shell** team for the friendly interactive shell
- **Helix** developers for the modern modal editor
- **Rust community** for many of the fast, safe CLI tools
- **Catppuccin** team for the beautiful color scheme
- **Arch Linux** community for the packaging system

## 📞 Support

- **GitHub Issues** - [Report bugs and request features](https://github.com/yourusername/modern-cli-repo/issues)
- **Discussions** - [Community discussions and questions](https://github.com/yourusername/modern-cli-repo/discussions)
- **Wiki** - [Detailed documentation and guides](https://github.com/yourusername/modern-cli-repo/wiki)

---

**Transform your command-line experience with modern, fast, and beautiful tools! 🚀**
-