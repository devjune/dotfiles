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

# Tools & Plugins
BREW_TOOLS := asdf git curl zsh tree wget jq fzf starship
BREW_CASKS := font-jetbrains-mono-nerd-font
OMZ_PLUGINS := git z sudo copypath copyfile extract docker docker-compose npm node python brew zsh-autosuggestions zsh-syntax-highlighting

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

define BACKUP_ZSHRC
	@if [ ! -f ~/.zshrc.backup-* ]; then \
		echo "Backing up .zshrc..."; \
		cp ~/.zshrc ~/.zshrc.backup-$$(date +%Y-%m-%d_%H-%M-%S); \
		echo "✅ .zshrc backed up"; \
	fi
endef

define INSTALL_OH_MY_ZSH
	@if [ ! -d ~/.oh-my-zsh ]; then \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
		echo "✅ Oh My Zsh installed"; \
	else \
		echo "✅ Oh My Zsh is already installed"; \
	fi
endef

define INSTALL_EXTERNAL_PLUGINS
	@echo "Installing external plugins..."
	@if [ ! -d "$(ZSH_CUSTOM)/plugins/zsh-autosuggestions" ]; then \
		git clone https://github.com/zsh-users/zsh-autosuggestions $(ZSH_CUSTOM)/plugins/zsh-autosuggestions; \
	fi
	@if [ ! -d "$(ZSH_CUSTOM)/plugins/zsh-syntax-highlighting" ]; then \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $(ZSH_CUSTOM)/plugins/zsh-syntax-highlighting; \
	fi
	@echo "✅ External plugins installed"
endef

define ENABLE_PLUGINS
	@echo "Enabling Oh My Zsh plugins..."
	@sed -i '' 's/plugins=(git)/plugins=($(OMZ_PLUGINS))/' ~/.zshrc
	@echo "✅ Oh My Zsh plugins enabled"
endef

# ===== Main Targets =====
.PHONY: all install terminal clean help
.DEFAULT_GOAL := help

all: check-system install terminal languages
	$(call PRINT_SUCCESS,Complete development environment ready!)

install: homebrew tools asdf-setup
	$(call PRINT_HEADER,Installing Oh My Zsh and plugins)
	$(call BACKUP_ZSHRC)
	$(call INSTALL_OH_MY_ZSH)
	@if ! grep -q 'asdf.sh' ~/.zshrc 2>/dev/null; then \
		echo '\n# asdf version manager' >> ~/.zshrc; \
		echo '. "$(ASDF_PATH)"' >> ~/.zshrc; \
	fi
	$(call INSTALL_EXTERNAL_PLUGINS)
	$(call ENABLE_PLUGINS)
	$(call PRINT_SUCCESS,Oh My Zsh setup complete)

clean:
	@echo "🧹 Cleaning up all installed components..."
	@echo "Removing Oh My Zsh..."
	@rm -rf ~/.oh-my-zsh
	@echo "Removing asdf..."
	@rm -rf ~/.asdf
	@rm -f ~/.tool-versions
	@echo "Restoring original .zshrc..."
	@if ls ~/.zshrc.backup-* 1> /dev/null 2>&1; then \
		latest_backup=$$(ls -t ~/.zshrc.backup-* | head -n1); \
		mv "$$latest_backup" ~/.zshrc; \
		echo "✅ .zshrc restored from $$latest_backup"; \
	fi
	@echo "✅ Cleanup completed"

help:
	@echo "Available targets:"
	@echo "  all        - Install all components (default)"
	@echo "  homebrew   - Install Homebrew"
	@echo "  tools      - Install base tools"
	@echo "  asdf-setup - Setup asdf version manager"
	@echo "  install    - Install all components"
	@echo "  terminal   - Link terminal configs (Ghostty, Starship, zshrc)"
	@echo "  clean      - Remove all installed components"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "After installation:"
	@echo "  - Start a new terminal session"
	@echo "  - Or run 'source ~/.zshrc' to apply changes immediately"

# ===== Sub Targets =====
check-system:
	$(call PRINT_HEADER,System Compatibility Check)
	@echo "OS: $$(uname -s)"
	@echo "Architecture: $$(uname -m)"
	@echo "Shell: $$(basename $$SHELL)"
	@if [ "$(IS_MACOS)" != "true" ]; then \
		$(call PRINT_ERROR,This setup requires macOS); exit 1; \
	fi
	@if [ "$(IS_ARM64)" != "true" ]; then \
		$(call PRINT_ERROR,This setup requires Apple Silicon (ARM64)); exit 1; \
	fi
	$(call PRINT_SUCCESS,System compatibility verified)

homebrew:
	$(call PRINT_HEADER,Homebrew Installation)
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		echo 'eval "$$($(BREW_PATH) shellenv)"' >> $(HOME_DIR)/.zshrc; \
		eval "$$($(BREW_PATH) shellenv)"; \
	else \
		echo "Homebrew already installed"; \
	fi
	$(call PRINT_SUCCESS,Homebrew ready)

tools: homebrew
	$(call PRINT_HEADER,Development Tools Installation)
	@$(BREW_PATH) install $(BREW_TOOLS) || { \
		$(call PRINT_ERROR,Failed to install development tools); exit 1; \
	}
	@$(BREW_PATH) install --cask $(BREW_CASKS) || true
	$(call PRINT_SUCCESS,Development tools installed)

asdf-setup:
	@echo "🔵 ==> asdf Configuration"
	@if ! grep -q 'asdf.sh' ~/.zshrc 2>/dev/null; then \
		echo '\n# asdf version manager' >> ~/.zshrc; \
		echo '. "$(ASDF_PATH)"' >> ~/.zshrc; \
	fi
	@echo "✅ asdf configured."

terminal: tools
	$(call PRINT_HEADER,Terminal Configuration)
	@mkdir -p ~/.config/ghostty
	@mkdir -p ~/.config
	@ln -sf $(DOTFILES_DIR)/ghostty/config ~/.config/ghostty/config
	@ln -sf $(DOTFILES_DIR)/starship/starship.toml ~/.config/starship.toml
	@ln -sf $(DOTFILES_DIR)/zshrc ~/.zshrc
	@touch ~/.hushlogin
	$(call PRINT_SUCCESS,Terminal configs linked)

languages: install
	$(call PRINT_HEADER,Installing programming languages)
	@echo "Setting up asdf plugins and languages..."
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
	@echo "🔄 Starting new shell session..."
	@exec zsh -l
