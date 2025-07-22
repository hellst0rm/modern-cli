# Modern CLI Tools Usage Guide

This guide covers how to effectively use the modern CLI tools after installation.

## 🎯 Core Tools Workflow

### Fish Shell (Interactive Shell)

Fish is your primary shell with modern features and intelligent defaults.

#### Key Features:
```bash
# Auto-suggestions (type and press →)
git checkout main

# Auto-completion (press Tab)
git <Tab>

# Command history (press ↑)
# Previous commands appear automatically

# Directory abbreviations
cd /very/long/path/to/project
abbr proj 'cd /very/long/path/to/project'
proj  # Now this works
```

#### Built-in Abbreviations:
```bash
# Git shortcuts
g        # git
gc       # git commit
ga       # git add
gp       # git push
gpl      # git pull --rebase --autostash
gs       # git status --short

# Navigation
ll       # eza -la --icons --git
la       # eza -la --icons --git
tree     # eza --tree --icons

# Modern tools
cat      # bat
find     # fd
grep     # rg
ps       # procs
top      # btm
```

### Helix Editor (Modal Editor)

Modern modal editor with built-in LSP support.

#### Basic Usage:
```bash
# Open file
hx file.txt

# Multiple files
hx file1.txt file2.txt

# Directory (file picker)
hx .
```

#### Key Bindings:
```
# Normal mode
i         # Insert mode
a         # Append mode
o         # Open line below
O         # Open line above
v         # Visual mode
:         # Command mode
Space     # Leader key

# Navigation
h j k l   # Left, down, up, right
w e b     # Word navigation
gg G      # Top, bottom
f F       # Find character
/ n N     # Search

# Editing
d         # Delete
c         # Change
y         # Yank (copy)
p         # Paste
u         # Undo
U         # Redo

# Leader commands
Space f f # File picker
Space f r # Recent files
Space g g # Go to definition
Space l a # Code actions
Space l r # Rename symbol
```

### Yazi File Manager

Terminal file manager with image preview and modern UI.

#### Basic Navigation:
```bash
# Open current directory
yazi

# Open specific directory
yazi ~/Documents

# Key bindings (vim-like)
h j k l   # Navigate
Enter     # Enter directory/open file
q         # Quit
/         # Search
n N       # Next/previous search result
```

#### File Operations:
```
d         # Cut
y         # Copy
p         # Paste
D         # Delete
r         # Rename
c         # Create file/directory
Space     # Select file
a         # Select all
v         # Toggle visual mode
```

### Zellij Terminal Multiplexer

Modern alternative to tmux with better defaults.

#### Basic Usage:
```bash
# Start session
zellij

# Start named session
zellij -s work

# Attach to session
zellij attach work
```

#### Key Bindings (Alt-based):
```
Alt + n   # New tab
Alt + h/l # Navigate tabs
Alt + j/k # Navigate panes
Alt + -   # Split horizontal
Alt + |   # Split vertical
Alt + x   # Close pane
Alt + q   # Quit
```

### Starship Prompt

Cross-shell prompt with Git integration and language detection.

#### Features:
- **Git status**: Shows branch, dirty files, ahead/behind
- **Language versions**: Automatically detects and shows versions
- **Directory**: Smart path truncation
- **Command duration**: Shows execution time for slow commands
- **Exit codes**: Shows non-zero exit codes

## 🛠️ System Monitoring Workflow

### Bottom System Monitor

Modern replacement for htop with better visualization.

```bash
# Start bottom
btm

# Key bindings
Tab       # Switch between widgets
e         # Toggle processes/expanded
s         # Sort processes
f         # Filter processes
/         # Search
q         # Quit
```

### Process Management

```bash
# View processes (modern ps)
procs

# Search processes
procs firefox

# View process tree
procs --tree

# Kill process by name
procs firefox | head -1 | awk '{print $1}' | xargs kill
```

### Disk Usage

```bash
# Modern du replacement
dust

# Specific directory
dust ~/Downloads

# Show top 10 largest
dust -n 10

# Modern df replacement
duf

# Network monitoring
bandwhich
```

## 📁 File Operations Workflow

### Finding Files

```bash
# Modern find replacement
fd pattern

# Find by type
fd -t f pattern        # Files only
fd -t d pattern        # Directories only

# Include hidden files
fd -H pattern

# Search in specific directory
fd pattern ~/Documents
```

### Text Search

```bash
# Modern grep replacement
rg pattern

# Search specific file types
rg pattern -t rust     # Rust files
rg pattern -t js       # JavaScript files

# Case insensitive
rg -i pattern

# Show context
rg -C 3 pattern        # 3 lines before/after
```

### File Listing

```bash
# Modern ls replacement
eza

# Long format with git status
eza -la --git

# Tree view
eza --tree

# Sort by size
eza -la --sort=size

# Show icons
eza --icons
```

## 🔍 Search and Navigation

### FZF Fuzzy Finder

Integrated with Fish for enhanced searching.

#### Key Bindings:
```
Ctrl + T  # File search
Ctrl + R  # Command history
Alt + C   # Directory change
```

#### Usage Examples:
```bash
# Search files and open in editor
hx $(fd | fzf)

# Search and kill process
kill $(procs | fzf | awk '{print $1}')

# Search git branches
git checkout $(git branch | fzf)
```

### Zoxide Smart Directory Navigation

```bash
# Jump to frecent directory
z project

# Interactive selection
zi

# Add current directory
z -a .

# Remove directory
z -r old_path
```

### McFly Enhanced History

Neural network-powered command history.

```bash
# Search history (automatic in Fish)
# Type and press ↑ to search

# Manual search
mcfly search pattern
```

## 📝 Text Processing

### Bat Enhanced Cat

```bash
# View file with syntax highlighting
bat file.py

# Show line numbers
bat -n file.py

# Show only specific lines
bat -r 10:20 file.py

# Multiple files
bat file1.py file2.js
```

### SD Modern Sed

```bash
# Replace text
sd 'old' 'new' file.txt

# Regex replacement
sd '\d+' 'NUMBER' file.txt

# In-place editing
sd 'old' 'new' -i file.txt
```

## 🏗️ Development Workflow

### Git Integration

#### GitUI (Interactive Git)
```bash
# Open in current repo
gitui

# Key bindings
Tab       # Switch sections
Enter     # Drill down
Esc       # Go back
c         # Commit
p         # Push
f         # Fetch
```

#### LazyGit (Alternative Git UI)
```bash
# Open in current repo
lazygit

# Key bindings similar to GitUI
# More vim-like navigation
```

#### Git with Delta Diff Viewer
```bash
# Configured automatically
git diff    # Shows enhanced diff with syntax highlighting
git log -p  # Shows commits with enhanced diffs
```

### Language Server Integration (Helix)

Automatic language support for:

#### Rust
```bash
# LSP: rust-analyzer (auto-installed)
# Features: completion, go-to-definition, diagnostics
hx main.rs
```

#### JavaScript/TypeScript
```bash
# LSP: typescript-language-server
hx app.js
hx component.tsx
```

#### Python
```bash
# LSP: python-lsp-server
hx script.py
```

#### Go
```bash
# LSP: gopls
hx main.go
```

### Just Command Runner

```bash
# Show available tasks
just

# Run specific task
just build
just test
just deploy

# List with descriptions
just --list
```

## 📊 Productivity Workflow

### Task Management (Taskwarrior)

```bash
# Add task
task add "Complete project documentation"

# List tasks
task list

# Mark complete
task 1 done

# Add project and priority
task add project:work priority:H "Important task"

# Filter by project
task project:work list

# Visual interface
vit
```

### Time Tracking (Timewarrior)

```bash
# Start tracking
timew start "Working on documentation"

# Stop tracking
timew stop

# Show summary
timew summary

# Continue previous task
timew continue
```

### Calendar (Calcurse)

```bash
# Open calendar
calcurse

# Key bindings
Tab       # Switch views
a         # Add appointment
d         # Delete
e         # Edit
q         # Quit
```

## 🎵 Music Workflow

### Cmus Music Player

```bash
# Start cmus
cmus

# Basic controls
x         # Play/pause
c         # Pause
b         # Next track
z         # Previous track
v         # Stop
```

### MPD + ncmpcpp

```bash
# Start MPD
mpd

# Control with ncmpcpp
ncmpcpp

# Or use mpc command line
mpc play
mpc next
mpc prev
mpc toggle
```

### Media Control

```bash
# Control any media player
playerctl play-pause
playerctl next
playerctl previous
playerctl status
```

## 📧 Communication Workflow

### Aerc Email Client

```bash
# Start aerc
aerc

# Key bindings
Tab       # Switch panels
Enter     # Open email
c         # Compose
r         # Reply
q         # Quit
```

### Newsboat RSS Reader

```bash
# Start newsboat
newsboat

# Key bindings
j k       # Navigate
Enter     # Open article
r         # Reload feeds
q         # Quit
```

### W3M Web Browser

```bash
# Browse website
w3m example.com

# Local file
w3m file.html

# Key bindings
j k       # Navigate
Enter     # Follow link
B         # Back
q         # Quit
```

## 🌐 Network Tools

### HTTP Requests

```bash
# Modern curl alternative
xh GET api.example.com/users
xh POST api.example.com/users name=John
xh PUT api.example.com/users/1 name=Jane

# Traditional curl (enhanced config)
curl -s api.example.com/users | bat -l json
```

### DNS Lookup

```bash
# Modern dig alternative
dog example.com
dog @1.1.1.1 example.com
dog example.com MX
```

### Network Monitoring

```bash
# Real-time network usage
bandwhich

# Network scanner
nmap -sn 192.168.1.0/24
```

## 💡 Pro Tips

### Combining Tools

```bash
# Find large files and delete interactively
fd -t f -S +100M | fzf -m | xargs rm -i

# Search code and edit results
rg -l "TODO" | fzf | xargs hx

# Find processes and kill
procs | fzf | awk '{print $1}' | xargs kill

# Git commit with fuzzy file selection
git add $(git status --porcelain | fzf -m | awk '{print $2}')
```

### Aliases and Abbreviations

Add to `~/.config/fish/config.fish`:

```fish
# Custom abbreviations
abbr -a ll 'eza -la --icons --git'
abbr -a tree 'eza --tree --icons'
abbr -a cat bat
abbr -a ping 'ping -c 5'
abbr -a myip 'curl ifconfig.me'

# Git workflow
abbr -a gst 'git status'
abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gaa 'git add --all'
abbr -a gcm 'git commit -m'
abbr -a gp 'git push'
abbr -a gpl 'git pull'
```

### Shell Functions

```fish
# Quick project switcher
function proj
    set project_dir (fd -t d . ~/Projects | fzf)
    if test -n "$project_dir"
        cd "$project_dir"
    end
end

# Enhanced search and replace
function replace-in-files
    set pattern $argv[1]
    set replacement $argv[2]
    rg -l "$pattern" | xargs sd "$pattern" "$replacement"
end

# Quick HTTP server
function serve
    set port (test -n "$argv[1]"; and echo $argv[1]; or echo 8000)
    python -m http.server $port
end
```

This workflow leverages the power of modern CLI tools to create an efficient, integrated development and system administration environment.