When adding or modifying any configuration, always review the full set of config files (ghostty, zsh, tmux, starship, git, etc.) for:

1. Conflicts — settings in different files that override or negate each other (e.g., shell-integration-features overriding cursor-style)
2. Dependencies — settings that only work when another setting is also configured
3. Load order — plugin or tool initialization order that affects behavior (e.g., zsh plugin order)

Flag any issues to the user before applying changes.
