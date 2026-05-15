# eza (ls replacement)
# LS_COLORS= prevents Oh My Zsh LS_COLORS from overriding eza theme.yml
alias ll="LS_COLORS= eza -l --git --icons"
alias la="LS_COLORS= eza -la --git --icons"
alias lt="LS_COLORS= eza --tree --level=2 --icons"
alias tree="LS_COLORS= eza --tree --icons"
alias llt="LS_COLORS= eza -l --git --icons --sort=modified --reverse"  # newest last (like ls -lart)

# bat (cat replacement)
alias cat="bat --paging=never"

# neovim
alias vim="nvim"
alias vi="nvim"

# Claude Code 한 줄 질문 — /btw 흉내: 일회성, 도구 없음, 디스크 저장 없음
# noglob: ?/* 같은 글로브 문자 그대로 통과
_ask() { claude -p --no-session-persistence --disable-slash-commands --tools "" -- "$*" }
alias ask='noglob _ask'

# ripgrep / fd
alias rg="rg --smart-case"
alias fd="fd --hidden --exclude .git"
