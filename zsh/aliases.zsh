# eza (ls replacement)
# LS_COLORS= prevents Oh My Zsh LS_COLORS from overriding eza theme.yml
alias ll="LS_COLORS= eza -l --git --icons"
alias la="LS_COLORS= eza -la --git --icons"
alias lt="LS_COLORS= eza --tree --level=2 --icons"
alias llt="LS_COLORS= eza -l --git --icons --sort=modified --reverse"  # newest last (like ls -lart)

# bat (cat replacement)
alias cat="bat --paging=never"

# ripgrep / fd
alias rg="rg --smart-case"
alias fd="fd --hidden --exclude .git"
