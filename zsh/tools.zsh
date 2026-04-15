# mise
eval "$(mise activate zsh)"

# zoxide
eval "$(zoxide init zsh)"

# fzf
source <(fzf --zsh)

# starship (keep at the end)
eval "$(starship init zsh)"
