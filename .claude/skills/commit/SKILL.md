---
name: commit
description: Analyze staged/unstaged changes and create commits following this dotfiles repo's convention (English imperative title, optional Korean body, conventional-commit type/scope). Use when the user asks to commit changes, split changes into commits, or apply this project's commit message style.
---

# Commit

변경 사항을 분석하고 이 프로젝트의 커밋 컨벤션에 맞게 커밋한다.

## Commit Message Rules

Format: `<type>: <English description>` or `<type>(<scope>): <English description>`

### Title
- English, lowercase imperative (e.g. "add", "fix", not "Add", "Fixed")
- Perspective: "what changed", not "what I did"

### Body (optional)
- Korean allowed
- Explain why the change was made or what it affects

### type
- feat: new feature
- fix: bug fix
- refactor: refactoring
- docs: documentation
- chore: config/build
- test: tests

### scope (optional)
Use when change is scoped to a specific module or area.

### Examples
```
feat(git): manage gitconfig via dotfiles with delta integration

diff 가독성 향상을 위해 delta pager 설정 추가.
```
```
fix(zsh): fix module source path resolution via readlink
```
```
chore: add bat/rg/fd aliases, D2Coding font, clean up configs
```

## Process

1. Check changes with `git status` and `git diff`
2. Split into single or multiple commits by logical scope
3. Show draft commit message to user and commit after confirmation
4. Warn if sensitive files (.env, credentials, etc.) are included
