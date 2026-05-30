# mise
eval "$(mise activate zsh)"

# zoxide
eval "$(zoxide init zsh)"

# fzf
# 기본 외관 + fd 소스 (gitignore 존중) + 프리뷰 스크롤 키
export FZF_DEFAULT_OPTS="--height=60% --layout=reverse --border --info=inline \
  --bind=ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"
export FZF_DEFAULT_COMMAND="fd --type=f --hidden --exclude=.git"
# Ctrl-T (파일): bat 프리뷰
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview='bat --color=always --style=numbers --line-range=:500 {}'"
# Alt-C (cd): eza tree 프리뷰
export FZF_ALT_C_COMMAND="fd --type=d --hidden --exclude=.git"
export FZF_ALT_C_OPTS="--preview='eza --tree --icons --color=always --level=3 {}'"
# Ctrl-R (히스토리): 긴 명령 줄바꿈
export FZF_CTRL_R_OPTS="--preview='echo {}' --preview-window=down:3:wrap"
# key-bindings 만 로드 (Ctrl-T/R, Alt-C). completion 은 일부러 제외 —
# TAB 완성은 fzf-tab 이 담당하는데, fzf 의 completion 을 같이 켜면 TAB(^I)을
# fzf-completion 이 가로채서 fzf-tab 이 죽어버림.
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

# starship (keep at the end)
eval "$(starship init zsh)"
