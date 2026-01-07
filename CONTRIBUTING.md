# Contributing to NixOS Omarchy Configuration

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Documentation](#documentation)

## 🤝 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn NixOS

## 🚀 Getting Started

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/yourusername/nix-omarchy.git
   cd nix-omarchy/nix
   ```

3. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make changes and test**
   ```bash
   # Test your changes
   sudo nixos-rebuild build --flake .#talos
   
   # If successful, switch
   sudo nixos-rebuild switch --flake .#talos
   ```

## 💡 How to Contribute

### Reporting Bugs

Create an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- System information
- Relevant logs

### Suggesting Enhancements

Create an issue with:
- Clear description of the enhancement
- Use case and motivation
- Proposed implementation (if any)
- Alternative solutions considered

### Adding Features

1. Check existing issues/PRs
2. Create an issue to discuss (for large changes)
3. Implement the feature
4. Add documentation
5. Test thoroughly
6. Submit pull request

## 📝 Style Guidelines

### Nix Code Style

```nix
# Good: Consistent indentation (2 spaces)
{
  services.example = {
    enable = true;
    setting = "value";
  };
}

# Good: Descriptive names
mkUserConfig = { name, uid }: { ... };

# Good: Comments for complex logic
# Calculate optimal buffer size based on RAM
bufferSize = ramSize / 1024;

# Good: Group related settings
services.pipewire = {
  enable = true;
  alsa.enable = true;
  pulse.enable = true;
};
```

### File Organization

- **One module per file**: Each file should have a single, clear purpose
- **Logical grouping**: Group related configurations together
- **Default.nix**: Use for module aggregation
- **Naming**: Use kebab-case for files (e.g., `display-manager.nix`)

### Module Structure

```nix
{ config, pkgs, lib, ... }:

{
  # Imports (if any)
  imports = [ ];
  
  # Options (if defining new options)
  options = { };
  
  # Configuration
  config = {
    # Your configuration here
  };
}
```

### Comments

```nix
# Good: Explain WHY, not WHAT
# Use powersave on battery to extend battery life
CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

# Bad: Obvious comment
# Set CPU governor to powersave
CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
```

## 📋 Commit Messages

Follow conventional commits format:

```
type(scope): subject

body (optional)

footer (optional)
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples

```bash
# Good
feat(audio): add equalizer support with EasyEffects
fix(power): correct TLP battery threshold values
docs(readme): update installation instructions
refactor(hyprland): simplify keybinding configuration

# With body
feat(bluetooth): add auto-connect for trusted devices

Add configuration to automatically connect to previously
paired and trusted Bluetooth devices on boot.

Closes #123
```

## 🔀 Pull Request Process

1. **Update documentation**
   - Update relevant markdown files in `docs/`
   - Add docstrings to complex functions
   - Update CHANGELOG.md

2. **Test thoroughly**
   ```bash
   # Build test
   sudo nixos-rebuild build --flake .#talos
   
   # Syntax check
   nix flake check
   
   # Test in VM (if possible)
   nixos-rebuild build-vm --flake .#talos
   ```

3. **Update CHANGELOG.md**
   ```markdown
   ## [Unreleased]
   
   ### Added
   - New feature description
   ```

4. **Create Pull Request**
   - Clear title following commit message format
   - Description of changes
   - Reference related issues
   - Screenshots (if UI changes)

5. **Code Review**
   - Respond to feedback
   - Make requested changes
   - Keep PR focused and small

6. **Merging**
   - Maintainer will merge after approval
   - Delete branch after merge

## 📚 Documentation

### Documentation Standards

- **Obsidian-compatible markdown**: Use frontmatter, tags, links
- **Cross-references**: Link related documents with `[[Document-Name]]`
- **Code blocks**: Use appropriate language tags
- **Examples**: Provide practical examples
- **Screenshots**: Include for UI changes (optional)

### Frontmatter Template

```markdown
---
title: Document Title
tags: [tag1, tag2, tag3]
created: YYYY-MM-DD
related: [[Related-Doc]], [[Another-Doc]]
---
```

### Documentation Structure

```markdown
# Title

Brief introduction

## Section 1

Content with examples

## Section 2

Content with examples

## Related Documentation

- [[Doc1]] - Description
- [[Doc2]] - Description

---

**Last Updated**: YYYY-MM-DD
```

## 🧪 Testing Guidelines

### Before Submitting

- [ ] Code builds without errors
- [ ] `nix flake check` passes
- [ ] Changes tested on actual hardware (if possible)
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No merge conflicts

### Testing Commands

```bash
# Flake syntax check
nix flake check

# Build test (no switch)
sudo nixos-rebuild build --flake .#talos

# Test with trace for debugging
sudo nixos-rebuild build --flake .#talos --show-trace

# Build VM (if supported)
nixos-rebuild build-vm --flake .#talos
```

## 🎯 Areas for Contribution

### High Priority

- Additional hardware configurations
- Theme variations
- Performance optimizations
- Bug fixes
- Documentation improvements

### Medium Priority

- Additional applications
- Alternative desktop environments
- Development environment templates
- Automation scripts

### Low Priority

- Code cleanup
- Comment improvements
- Example configurations

## 💬 Communication

### Where to Ask Questions

- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: General questions, ideas
- **NixOS Discourse**: General NixOS questions
- **Pull Requests**: Implementation discussions

### Getting Help

If you need help:
1. Check existing documentation
2. Search closed issues/PRs
3. Ask in GitHub Discussions
4. Ping maintainers in PR/issue

## 🏆 Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Mentioned in relevant documentation
- Credited in commit messages

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Thank You!

Every contribution, no matter how small, is valuable and appreciated!

---

**Happy Contributing!** 🎉
