# System Detection
IS_MACOS := $(shell [ "$$(uname -s)" = "Darwin" ] && echo "true")
IS_ARM64 := $(shell [ "$$(uname -m)" = "arm64" ] && echo "true")

# Paths
BREW_PATH := /opt/homebrew/bin/brew
ASDF_PATH := $(shell $(BREW_PATH) --prefix asdf)/libexec/asdf.sh
HOME_DIR := $(HOME)
OH_MY_ZSH_PATH := $(HOME_DIR)/.oh-my-zsh
ZSH_CUSTOM := $(OH_MY_ZSH_PATH)/custom
DOTFILES_DIR := $(shell pwd)


# Languages
LANGUAGES := java:temurin-21.0.7+6.0.LTS nodejs:latest:24 python:latest:3

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
	@if [ -e $(2) ] && [ ! -L $(2) ]; then \
		cp $(2) $(2).bak.$$(date +%Y%m%d); \
		echo "📦 Backed up $(2)"; \
	fi
	@ln -sf $(1) $(2)
	@echo "🔗 $(2) → $(1)"
endef

# ===== Main Targets =====
.PHONY: all install terminal clean help check-system homebrew tools omz languages dump
.DEFAULT_GOAL := help

all: check-system install terminal languages
	$(call PRINT_SUCCESS,Complete development environment ready!)

install: homebrew tools omz

terminal:
	$(call PRINT_HEADER,Terminal Configuration)
	@mkdir -p ~/.config/ghostty
	$(call BACKUP_AND_LINK,$(DOTFILES_DIR)/ghostty/config,$(HOME)/.config/ghostty/config)
	$(call BACKUP_AND_LINK,$(DOTFILES_DIR)/starship/starship.toml,$(HOME)/.config/starship.toml)
	$(call BACKUP_AND_LINK,$(DOTFILES_DIR)/zshrc,$(HOME)/.zshrc)
	@touch ~/.hushlogin
	$(call PRINT_SUCCESS,Terminal configs linked)

clean:
	@echo "🧹 Cleaning up all installed components..."
	@rm -rf ~/.oh-my-zsh
	@rm -rf ~/.asdf
	@rm -f ~/.tool-versions
	@rm -f ~/.hushlogin
	@for f in ~/.zshrc ~/.config/ghostty/config ~/.config/starship.toml; do \
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
	@echo "  languages  - Install programming languages via asdf"
	@echo "  dump       - Update Brewfile from current system"
	@echo "  clean      - Remove all installed components and restore backups"
	@echo "  help       - Show this help message"

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
	@if [ ! -d "$(ZSH_CUSTOM)/plugins/zsh-autosuggestions" ]; then \
		git clone https://github.com/zsh-users/zsh-autosuggestions $(ZSH_CUSTOM)/plugins/zsh-autosuggestions; \
	fi
	@if [ ! -d "$(ZSH_CUSTOM)/plugins/zsh-syntax-highlighting" ]; then \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $(ZSH_CUSTOM)/plugins/zsh-syntax-highlighting; \
	fi
	$(call PRINT_SUCCESS,Oh My Zsh ready)

dump:
	$(call PRINT_HEADER,Updating Brewfile)
	@$(BREW_PATH) bundle dump --file=$(DOTFILES_DIR)/Brewfile --force
	$(call PRINT_SUCCESS,Brewfile updated)

languages: install
	$(call PRINT_HEADER,Installing programming languages)
	@. "$(ASDF_PATH)" && \
	for lang_ver in $(LANGUAGES); do \
		lang=$${lang_ver%%:*} && \
		version=$${lang_ver#*:} && \
		echo "Adding $$lang plugin..." && \
		asdf plugin add $$lang && \
		asdf install $$lang $$version && \
		asdf set $$lang $$version; \
	done && \
	echo "Installed versions:" && \
	asdf list
	$(call PRINT_SUCCESS,All programming languages installed)
