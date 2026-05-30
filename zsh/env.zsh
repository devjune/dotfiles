# Environment Variables
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$PATH"
# mysql-client 는 keg-only — CLI(mysql/mysqldump 등)를 쓰려면 PATH 에 직접 추가
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export EZA_CONFIG_DIR="$HOME/.config/eza"
export EDITOR=nvim
export VISUAL=nvim
export BAT_THEME="Monokai Extended Origin"
export BAT_STYLE="numbers"

