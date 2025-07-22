# Fish Shell Configuration
# ~/.config/fish/config.fish

# Initialize modern shell tools
starship init fish | source
zoxide init fish | source
mcfly init fish | source

# FZF integration
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --margin=1 --padding=1'

# Vivid for LS_COLORS
set -gx LS_COLORS (vivid generate catppuccin-mocha)

# Environment variables
set -gx EDITOR hx
set -gx VISUAL hx
set -gx PAGER "bat --paging=always"
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx BAT_THEME "Catppuccin-mocha"
set -gx DELTA_FEATURES "+side-by-side"

# McFly settings
set -gx MCFLY_KEY_SCHEME vim
set -gx MCFLY_FUZZY 2
set -gx MCFLY_RESULTS 25
set -gx MCFLY_INTERFACE_VIEW TOP

# Zoxide configuration
set -gx _ZO_ECHO 1
set -gx _ZO_RESOLVE_SYMLINKS 1

# Modern tool aliases
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias tree='eza --tree --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias ps='procs'
alias du='dust'
alias df='duf'
alias top='btm'
alias htop='btm'
alias curl='xh'
alias dig='dog'
alias help='tldr'

# Email and communication aliases
alias mail='aerc'
alias email='neomutt'
alias rss='newsboat'

# Web browsing
alias web='w3m'
alias browse='lynx'

# Music and media
alias music='cmus'
alias play='mpv'
alias ncmp='ncmpcpp'

# Task management
alias task='task'
alias todo='task'
alias time='timew'
alias cal='calcurse'

# Downloads
alias dl='yt-dlp'
alias download='aria2c'

# Archive handling
alias extract='ouch decompress'
alias compress='ouch compress'

# System info
alias benchmark='hyperfine'
alias cloc='tokei'
alias netstat='bandwhich'

# Git aliases
alias gd='git diff'
alias gl='git log --oneline --graph'
alias gg='gitui'
alias lg='lazygit'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gm='git merge'
alias gr='git rebase'
alias gri='git rebase -i'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

# Git abbreviations with modern defaults
abbr -a g git
abbr -a gc 'git commit'
abbr -a gca 'git commit --amend'
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gap 'git add --patch'
abbr -a gp 'git push'
abbr -a gpf 'git push --force-with-lease'
abbr -a gpl 'git pull --rebase --autostash'
abbr -a gs 'git status --short'
abbr -a gss 'git status'
abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gb 'git branch'
abbr -a gba 'git branch --all'
abbr -a gbd 'git branch --delete'
abbr -a gm 'git merge'
abbr -a gr 'git rebase --autostash'
abbr -a gri 'git rebase --interactive --autostash'
abbr -a grc 'git rebase --continue'
abbr -a gra 'git rebase --abort'
abbr -a grs 'git rebase --skip'
abbr -a gst 'git stash'
abbr -a gstp 'git stash pop'
abbr -a gstl 'git stash list'
abbr -a gsta 'git stash --include-untracked'
abbr -a gd 'git diff'
abbr -a gdc 'git diff --cached'
abbr -a gdh 'git diff HEAD'
abbr -a gl 'git log --oneline --graph --decorate'
abbr -a gla 'git log --oneline --graph --decorate --all'
abbr -a glp 'git log --patch'
abbr -a gf 'git fetch --prune --prune-tags'
abbr -a gfa 'git fetch --all --prune --prune-tags'

# Navigation with zoxide
abbr -a cd z
abbr -a .. 'z ..'
abbr -a ... 'z ../..'
abbr -a .... 'z ../../..'

# System shortcuts
abbr -a ll 'eza -la --icons --git'
abbr -a la 'eza -la --icons --git'
abbr -a lt 'eza --tree --icons'
abbr -a l1 'eza -1 --icons'

# Process and system monitoring
abbr -a ps procs
abbr -a psg 'procs | grep'
abbr -a top btm
abbr -a htop btm
abbr -a du dust
abbr -a df duf

# Network tools
abbr -a curl xh
abbr -a wget xh
abbr -a ping 'ping -c 5'
abbr -a dig dog
abbr -a netmon bandwhich

# Archive operations
abbr -a extract 'ouch decompress'
abbr -a compress 'ouch compress'
abbr -a unzip 'ouch decompress'
abbr -a untar 'ouch decompress'

# Text processing
abbr -a cat bat
abbr -a less bat
abbr -a grep rg
abbr -a find fd
abbr -a locate fd
abbr -a sed sd

# Documentation
abbr -a help tldr
abbr -a man tldr
abbr -a tldr 'tldr --color always'

# Benchmarking and analysis
abbr -a time hyperfine
abbr -a bench hyperfine
abbr -a lines tokei
abbr -a cloc tokei

# Email and communication abbreviations
abbr -a mail aerc
abbr -a nm neomutt
abbr -a rss newsboat
abbr -a news newsboat

# Web browsing
abbr -a web w3m
abbr -a www w3m
abbr -a browse lynx

# Music and media
abbr -a music cmus
abbr -a cmus cmus
abbr -a ncmp ncmpcpp
abbr -a play mpv
abbr -a mp mpv

# Task management
abbr -a task task
abbr -a todo 'task list'
abbr -a t task
abbr -a tl 'task list'
abbr -a ta 'task add'
abbr -a td 'task done'
abbr -a time timew
abbr -a tt 'timew start'
abbr -a ts 'timew stop'
abbr -a cal calcurse

# Downloads
abbr -a dl yt-dlp
abbr -a yt yt-dlp
abbr -a download aria2c

# Media control
abbr -a pause 'playerctl pause'
abbr -a resume 'playerctl play'
abbr -a next 'playerctl next'
abbr -a prev 'playerctl previous'
abbr -a vol 'playerctl volume'

# Quick email
abbr -a compose aerc
abbr -a inbox aerc

# Yazi integration with directory change
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if test -f "$tmp"
        set cwd (cat "$tmp")
        if test -n "$cwd" -a "$cwd" != "$PWD"
            cd "$cwd"
        end
    end
    rm -f "$tmp"
end

# Enhanced git status with suggestions
function gs
    git status --porcelain | read -l status_output
    
    if test -z "$status_output"
        echo "✅ Working tree clean"
        git log --oneline -5
    else
        echo "📋 Repository status:"
        git status
        echo ""
        echo "💡 Quick actions:"
        echo "  ga .     - Stage all changes"
        echo "  gc -m '' - Commit with message"
        echo "  gp       - Push changes"
        echo "  gitui    - Open GitUI"
    end
end

# System dashboard
function dashboard
    clear
    echo "🖥️  System Dashboard - "(date)
    echo "════════════════════════════════════════"
    echo ""
    
    echo "💾 Disk Usage:"
    duf
    echo ""
    
    echo "🧠 Top Processes:"
    procs | head -10
    echo ""
    
    echo "📊 System Load:"
    uptime
end

# Weather function
function weather
    if test (count $argv) -eq 0
        curl -s "wttr.in/Barcelona?format=3"
    else
        curl -s "wttr.in/$argv[1]?format=3"
    end
end

# System info
function sysinfo
    echo "📊 System Information"
    echo "===================="
    echo "🖥️  Hostname: "(hostname)
    echo "👤 User: "$USER
    echo "🐧 OS: "(uname -o)
    echo "🔧 Kernel: "(uname -r)
    echo "🏠 Shell: "$SHELL
    echo "📅 Date: "(date)
    echo "⏰ Uptime: "(uptime | sed 's/.*up //' | sed 's/,.*//')
    echo ""
    echo "💾 Disk Usage:"
    duf
    echo ""
    echo "🧠 Memory Usage:"
    free -h
end

# FZF file browser with bat preview
function fzf_bat_preview
    fd --type f --hidden --follow --exclude .git |
    fzf --preview 'bat --color=always --style=header,grid --line-range :300 {}'
end

# FZF directory changer
function fzf_cd
    set dir (fd --type d --hidden --follow --exclude .git | fzf --preview 'eza --tree --color=always {} | head -200')
    if test -n "$dir"
        cd "$dir"
    end
end

# FZF git branch switcher
function fzf_git_branch
    git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf --ansi --multi --tac --preview-window right:70% \
        --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
    sed 's/^..//' | cut -d' ' -f1 |
    sed 's#^remotes/[^/]*/##' |
    xargs git checkout
end

# FZF git log browser
function fzf_git_log
    git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}"); [ $# -eq 0 ] || git show --color=always $1; }; f {}'
end

# FZF process manager
function fzf_processes
    procs | fzf | awk '{print $1}' | xargs kill
end

# FZF history search
function fzf_history
    history | fzf --tac --no-sort | read -l result
    and commandline -- $result
end

# FZF key bindings
function fish_user_key_bindings
    # File and directory navigation
    bind \ct fzf_bat_preview      # Ctrl+T for file search with preview
    bind \cr fzf_history          # Ctrl+R for history search
    bind \ec fzf_cd               # Alt+C for directory change
    
    # Git operations
    bind \cg\cb fzf_git_branch    # Ctrl+G, Ctrl+B for git branch
    bind \cg\cl fzf_git_log       # Ctrl+G, Ctrl+L for git log
    
    # System management
    bind \cp fzf_processes        # Ctrl+P for process selection
    
    # Quick access
    bind \ep 'dashboard; commandline -f repaint'  # Alt+P for dashboard
end