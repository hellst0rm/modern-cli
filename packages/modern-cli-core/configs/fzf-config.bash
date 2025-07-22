# FZF Configuration
# ~/.config/fzf/fzf.bash (for bash) or add to ~/.config/fish/config.fish

# Default command and options
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Default options
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --margin=1
  --padding=1
  --info=inline
  --prompt="❯ "
  --pointer="❯"
  --marker="❯"
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8
  --color=fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8
  --color=info:#cba6f7,prompt:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,spinner:#f5e0dc,header:#f38ba8
  --bind="ctrl-u:preview-page-up,ctrl-d:preview-page-down"
  --bind="ctrl-f:preview-page-down,ctrl-b:preview-page-up"
  --bind="ctrl-a:select-all,ctrl-n:deselect-all"
  --bind="ctrl-t:toggle-preview"
'

# Preview options
export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=header,grid --line-range :300 {}'
  --preview-window 'right:60%:wrap'
"

export FZF_ALT_C_OPTS="
  --preview 'eza --tree --color=always {} | head -200'
  --preview-window 'right:60%:wrap'
"

# Completion options
export FZF_COMPLETION_OPTS='--border --info=inline'

# Use fd for path completion
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}