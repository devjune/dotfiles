# Dotfiles

macOS (Apple Silicon) development environment — minimal, modern, and built to be worked on alongside an AI agent.

## Setup

```bash
git clone git@github.com:devjune/dotfiles.git ~/git/dotfiles
cd ~/git/dotfiles
make all        # Homebrew + tools + terminal configs + symlinks
make languages  # Programming languages via mise (optional)
```

After setup, fill in machine-specific values:

- `~/.gitconfig.local` — git user name and email
- `~/.zshrc.local` — machine-specific aliases, env vars, AWS profiles

Both files are auto-created from `.example` versions on first `make terminal` and are gitignored.

## Make targets

| Target | Description |
|---|---|
| `make all` | Full setup (system check + install + terminal + languages) |
| `make install` | Homebrew + Brewfile + Oh My Zsh + plugins + Claude Code |
| `make terminal` | Symlink configs to `~/` and `~/.config/` + install tmux plugins |
| `make languages` | Install Java / Node / Python via mise |
| `make check` | Verify symlinks and key dependencies |
| `make clean` | Remove installed components and restore backups |
| `make brew-check` | Compare Brewfile vs installed brews |
| `make brew-dump` | Dump current brews into Brewfile |
| `make help` | List targets |

## Structure

```
dotfiles/
├── .claude/              # AI-agent rules, skills, permissions
├── Brewfile              # Homebrew packages (declarative)
├── Makefile              # Install / link / check / clean
├── ghostty/config        # Terminal emulator
├── git/gitconfig         # Universal git config (includes .local)
├── git/gitconfig.local   # Identity / LFS (gitignored)
├── nvim/                 # Neovim — lightweight quick editor (no LSP by design)
├── starship/starship.toml
├── tmux/tmux.conf
├── zsh/                  # Modular zsh: env / aliases / history / tools
└── zsh/zshrc.local       # Machine-specific aliases / functions (gitignored)
```

## Tracked vs local

Universal improvements that every machine wants → tracked. Machine-specific values (identity, AWS profiles, infra IDs, secrets) → `.local`. See `.claude/rules/preferences.md` for full rationale.

## Design notes

- **`nvim/lazy-lock.json` is tracked** — reproducibility first: a fresh `make all` should resolve identical plugin versions on every machine, not whatever is newest that day. This matters most for `nvim-treesitter`, which rides its volatile `main` branch where a bad commit can break startup. To bump, run `:Lazy update` and commit the lockfile.
- **Claude Code installs via the official script, not Homebrew** — `make install` runs `curl -fsSL https://claude.ai/install.sh | bash` because the Homebrew cask lags behind the latest releases. The installer self-updates and lives in `~/.local/bin` (kept ahead of `brew` paths in `zsh/env.zsh`).
- **tmux and starship share one color palette by hand** — `tmux/tmux.conf` (`@c_bg`/`@c_mode`/`@c_sync`) and `starship/starship.toml` (`[palettes.tmux]`) each hard-code the same hex values; there is no shared file. Change a color in one and you must mirror it in the other, or the status bar and prompt drift out of sync.
- **Session state restoration is intentional** — Ghostty (`window-save-state = always`) and tmux (`@continuum-restore 'on'`, which also autosaves every ~15 min) both bring back the previous layout on launch. If you ever want a clean start, that is the pair to disable.

## Verification

```bash
make check        # Symlinks + oh-my-zsh + homebrew + mise health
make brew-check   # Brewfile drift vs installed
```

## Troubleshooting

- **Symlink missing or broken** → `make terminal` (idempotent, backs up real files)
- **Brewfile says missing packages** → `make tools`
- **Nuke and reinstall** → `make clean` then `make all`
