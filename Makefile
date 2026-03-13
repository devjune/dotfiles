# System Detection
IS_MACOS := $(shell [ "$$(uname -s)" = "Darwin" ] && echo "true")
IS_ARM64 := $(shell [ "$$(uname -m)" = "arm64" ] && echo "true")

# Paths
BREW_PATH := /opt/homebrew/bin/brew
DOTFILES_DIR := $(shell pwd)

# Terminal config targets (clean 타겟에서도 참조)
TERMINAL_TARGETS := \
	$(HOME)/.config/ghostty/config \
	$(HOME)/.config/starship.toml \
	$(HOME)/.zshrc \
	$(HOME)/.tmux.conf \
	$(HOME)/.gitconfig

# Languages
LANGUAGES := java:temurin-25 nodejs:latest python:latest

# ===== Utility Functions =====
define PRINT_HEADER
	@echo "🔵 ==> $(1)"
endef

define PRINT_SUCCESS
	@echo "✅ $(1)"
endef

define PRINT_ERROR
	@echo "❌ $(1)"
endef

define BACKUP_AND_LINK
	@if [ -e "$(2)" ] && [ ! -L "$(2)" ]; then \
		cp "$(2)" "$(2).bak.$$(date +%Y%m%d_%H%M%S)"; \
		echo "📦 Backed up $(2)"; \
	fi
	@ln -sf "$(1)" "$(2)"
	@echo "🔗 $(2) → $(1)"
endef

# ===== Main Targets =====
.PHONY: all install terminal clean help check check-system homebrew tools omz languages brew-dump brew-check
.DEFAULT_GOAL := help

all: check-system install terminal
	$(call PRINT_SUCCESS,Complete development environment ready!)

install: homebrew tools omz

terminal:
	$(call PRINT_HEADER,Terminal Configuration)
	@mkdir -p ~/.config/ghostty
	$(call BACKUP_AND_LINK,$(DOTFILES_DIR)/ghostty/config,$(HOME)/.config/ghostty/config)
	$(call BACKUP_AND_LINK,$(DOTFILES_DIR)/starship/starship.toml,$(HOME)/.config/starship.toml)
	$(call BACKUP_AND_LINK,$(DOTFILES_DIR)/zsh/zshrc,$(HOME)/.zshrc)
	$(call BACKUP_AND_LINK,$(DOTFILES_DIR)/tmux/tmux.conf,$(HOME)/.tmux.conf)
	$(call BACKUP_AND_LINK,$(DOTFILES_DIR)/git/gitconfig,$(HOME)/.gitconfig)
	@if [ ! -f $(HOME)/.gitconfig.local ]; then cp $(DOTFILES_DIR)/git/gitconfig.local.example $(HOME)/.gitconfig.local; echo "📝 Created ~/.gitconfig.local — edit with your name/email"; fi
	@touch ~/.hushlogin
	$(call PRINT_SUCCESS,Terminal configs linked)

clean:
	@echo "🧹 Cleaning up all installed components..."
	@rm -rf ~/.oh-my-zsh
	@rm -rf ~/.local/share/mise
	@rm -rf ~/.config/mise
	@rm -f ~/.hushlogin
	@for f in $(TERMINAL_TARGETS); do \
		if [ -L "$$f" ]; then rm "$$f"; echo "🔗 Removed symlink $$f"; fi; \
		latest=$$(ls -t "$$f".bak.* 2>/dev/null | head -n1); \
		if [ -n "$$latest" ]; then mv "$$latest" "$$f"; echo "📦 Restored $$f from $$latest"; fi; \
	done
	@echo "✅ Cleanup completed"

help:
	@echo "Available targets:"
	@echo "  all        - Install everything"
	@echo "  install    - Homebrew + tools + Oh My Zsh"
	@echo "  terminal   - Link terminal configs (Ghostty, Starship, zshrc)"
	@echo "  languages  - Install programming languages via mise"
	@echo "  check      - Verify symlinks and dependencies"
	@echo "  brew-check - Check Brewfile sync status"
	@echo "  brew-dump  - Update Brewfile from current system"
	@echo "  clean      - Remove all installed components and restore backups"
	@echo "  help       - Show this help message"

check:
	$(call PRINT_HEADER,Environment Check)
	@ok=true; \
	for f in $(TERMINAL_TARGETS); do \
		if [ -L "$$f" ]; then \
			target=$$(readlink "$$f"); \
			if [ -e "$$target" ]; then \
				echo "✅ $$f → $$target"; \
			else \
				echo "❌ $$f → $$target (broken)"; ok=false; \
			fi; \
		elif [ -e "$$f" ]; then \
			echo "⚠️  $$f (not a symlink)"; ok=false; \
		else \
			echo "❌ $$f (missing)"; ok=false; \
		fi; \
	done; \
	if [ -d ~/.oh-my-zsh ]; then echo "✅ oh-my-zsh"; else echo "❌ oh-my-zsh (missing)"; ok=false; fi; \
	if command -v brew >/dev/null 2>&1; then echo "✅ homebrew"; else echo "❌ homebrew (missing)"; ok=false; fi; \
	if command -v mise >/dev/null 2>&1; then echo "✅ mise"; else echo "❌ mise (missing)"; ok=false; fi; \
	if [ "$$ok" = "true" ]; then \
		echo ""; echo "✅ All good"; \
	else \
		echo ""; echo "⚠️  Issues found. Run 'make all' to fix"; \
	fi

# ===== Sub Targets =====
check-system:
	$(call PRINT_HEADER,System Compatibility Check)
	@echo "OS: $$(uname -s) / Arch: $$(uname -m)"
	@if [ "$(IS_MACOS)" != "true" ]; then \
		$(call PRINT_ERROR,This setup requires macOS); exit 1; \
	fi
	@if [ "$(IS_ARM64)" != "true" ]; then \
		$(call PRINT_ERROR,This setup requires Apple Silicon); exit 1; \
	fi
	$(call PRINT_SUCCESS,System compatibility verified)

homebrew:
	$(call PRINT_HEADER,Homebrew Installation)
	@if ! command -v brew >/dev/null 2>&1; then \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		eval "$$($(BREW_PATH) shellenv)"; \
	else \
		echo "Homebrew already installed"; \
	fi
	$(call PRINT_SUCCESS,Homebrew ready)

tools: homebrew
	$(call PRINT_HEADER,Development Tools Installation)
	@$(BREW_PATH) bundle --file=$(DOTFILES_DIR)/Brewfile
	$(call PRINT_SUCCESS,Development tools installed)

omz:
	$(call PRINT_HEADER,Oh My Zsh Installation)
	@if [ ! -d ~/.oh-my-zsh ]; then \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
	else \
		echo "Oh My Zsh already installed"; \
	fi
	$(call PRINT_SUCCESS,Oh My Zsh ready)

brew-check:
	$(call PRINT_HEADER,Brew Sync Check)
	@untracked=$$($(BREW_PATH) bundle cleanup --file=$(DOTFILES_DIR)/Brewfile 2>/dev/null); \
	missing=$$($(BREW_PATH) bundle check --file=$(DOTFILES_DIR)/Brewfile 2>&1 || true); \
	synced=true; \
	if [ -n "$$untracked" ]; then \
		echo "⚠️  Brewfile에 없는 패키지:"; \
		echo "$$untracked"; \
		echo ""; \
		echo "→ make brew-dump 으로 Brewfile 업데이트 필요"; \
		synced=false; \
	fi; \
	if echo "$$missing" | grep -q "needs to be installed"; then \
		echo "⚠️  설치 안 된 패키지:"; \
		echo "$$missing"; \
		echo ""; \
		echo "→ make tools 로 설치 필요"; \
		synced=false; \
	fi; \
	if [ "$$synced" = "true" ]; then \
		echo "✅ Brewfile과 시스템이 동기화 상태"; \
	fi

brew-dump:
	$(call PRINT_HEADER,Updating Brewfile)
	@$(BREW_PATH) bundle dump --file=$(DOTFILES_DIR)/Brewfile --force
	$(call PRINT_SUCCESS,Brewfile updated)

languages:
	$(call PRINT_HEADER,Installing programming languages)
	@if ! command -v mise >/dev/null 2>&1; then \
		echo "❌ mise not installed. Run 'make install' first"; exit 1; \
	fi; \
	for lang_ver in $(LANGUAGES); do \
		lang=$${lang_ver%%:*}; \
		version=$${lang_ver#*:}; \
		echo "Installing $$lang@$$version..."; \
		mise use -g $$lang@$$version; \
	done && \
	echo "Installed versions:" && \
	mise ls
	$(call PRINT_SUCCESS,All programming languages installed)
