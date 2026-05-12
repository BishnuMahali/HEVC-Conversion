# 🔒 GUI LOCKDOWN MANDATE (2026-05-12)
- **STRICT NON-ALTERATION:** The Python GUI (`Video-Optimizer-GUI.py`) is now locked. 
- **NO CHANGES** are permitted to the GUI layout, button logic, or styling unless explicitly and specifically requested by the user.
- **READ-ONLY:** Treat the GUI code as read-only during any engine or backend updates.
- **VERIFICATION:** Any requested change must be verified against the `SNAPSHOT/Video-Optimizer-GUI-LOCKED.py` baseline.

# AI INITIALIZATION
Read all .md files in /Coding directory first then GEMINI.md of this project and get ready for my instructions.

# GEMINI.md

## Overview

This repository contains general-purpose Windows automation and terminal utilities primarily built using PowerShell and Python. The focus is on creating lightweight, practical, beginner-friendly tools with modern CLI UX and minimal external dependencies.

The coding style should prioritize:
- Readability
- Maintainability
- Modular architecture
- Real-world usability
- Clean terminal experience
- Safe file operations
- Detailed logging and user feedback

This is NOT enterprise software or a full-stack application repository. These are productivity-focused utilities for creators, power users, and Windows users.

---

# Development Philosophy

## Core Principles

- Keep tools lightweight
- Avoid unnecessary dependencies
- Prefer native Windows compatibility
- Prioritize UX even in terminal apps
- Make scripts understandable for intermediate users
- Always optimize for practical usability over overengineering

---

# Preferred Tech Stack

## Primary
- PowerShell 7+
- Windows PowerShell compatibility when possible

## Secondary
- Python for helper utilities or advanced logic only when justified

## Avoid Unless Necessary
- Electron
- Heavy GUI frameworks
- Complex backend architectures
- Web app patterns for simple utilities

---

# Terminal UX Standards

All CLI tools should feel modern and polished.

Preferred inspirations:
- Gemini CLI
- Claude Code
- LazyGit
- Winget
- Oh My Posh
- pnpm

## UX Requirements

- Clean spacing
- Consistent indentation
- Colored output using ANSI colors
- Unicode borders and separators
- Real-time progress feedback
- Clear success/error/warning/info states
- Interactive prompts when helpful
- Minimal clutter

---

# Logging Format

Use structured terminal output.

Examples:

[INFO]
[SUCCESS]
[WARNING]
[ERROR]

Avoid excessive verbosity unless debugging is enabled.

---

# File Safety Rules

NEVER:
- Delete files without confirmation
- Overwrite files silently
- Perform destructive operations automatically

ALWAYS:
- Validate paths
- Handle errors gracefully
- Create backups when appropriate
- Show previews before bulk operations

---

# Code Structure

Prefer modular architecture.

Recommended structure:

/core
/ui
/utils
/modules
/config
/logs

Functions should be:
- Small
- Reusable
- Clearly named
- Single-purpose

---

# PowerShell Standards

## Preferred Style

- Use approved verbs
- Use parameter validation
- Use comment-based help when appropriate
- Prefer functions over massive inline scripts
- Use Write-Host sparingly for styled output
- Prefer Write-Verbose for debug information

## Error Handling

Always use:
- try/catch
- meaningful error messages
- graceful failure states

Avoid:
- silent failures
- cryptic exceptions

---

# Python Standards

Python should only be used when it provides significant advantages.

Examples:
- Complex parsing
- Advanced filesystem logic
- Cross-platform tooling
- Data processing
- Rich terminal formatting

Preferred libraries:
- rich
- textual
- pathlib
- typer

Avoid bloated dependencies.

---

# Performance Expectations

Utilities should:
- Start quickly
- Consume minimal memory
- Work well on older systems
- Handle large file operations safely

---

# Documentation Rules

Every project should include:
- README.md
- Feature list
- Usage examples
- Requirements
- Warnings for destructive operations

README tone should be:
- Friendly
- Practical
- Beginner-accessible
- Direct

---

# GitHub Standards

Repositories should feel polished and creator-friendly.

Include:
- Screenshots or terminal previews
- Clear installation instructions
- Proper licensing
- Clean markdown formatting

Preferred license:
- MIT

Author name:
Bishnu Mahali

GitHub:
https://github.com/BishnuMahali

---

# AI Coding Instructions

When generating code:

DO:
- ALWAYS use test/snapshot files (e.g., `*-Fixed.ps1`, `*-Snapshot.ps1`) to verify and test any significant code alterations or bug fixes before applying them to the main production script.
- Explain architecture decisions briefly
- Keep implementations practical
- Optimize for maintainability
- Preserve readability
- Add comments only where useful
- Follow existing project patterns

DO NOT:
- Overengineer
- Introduce unnecessary abstractions
- Add frameworks without justification
- Rewrite working code unnecessarily
- Add fake placeholder implementations

---

# Preferred CLI Design Style

Preferred visual style:

╔══════════════════════════════╗
║ Utility Name                ║
╚══════════════════════════════╝

Use:
- subtle separators
- aligned formatting
- concise prompts
- readable spacing

Avoid:
- excessive ASCII art
- meme-heavy output
- cluttered interfaces

---

# Long-Term Vision

The repository ecosystem should evolve into a collection of:
- Modern Windows productivity utilities
- Creator-focused automation tools
- Practical terminal workflows
- High-quality open-source utilities

The tools should feel:
- professional
- lightweight
- approachable
- useful in real workflows

---

# Final Rule

Always prioritize:
1. User experience
2. Reliability
3. True goal completion and highest quality output (even if complex)
4. Simplicity
5. Maintainability
6. Practical value

Over:
- complexity
- trend-chasing
- unnecessary architecture

# Advanced Solutions & Proactiveness
While the general philosophy is to keep things lightweight and practical, **NEVER withhold the most effective, highest-quality, or 'best-in-class' technical solution just to maintain simplicity.** If a complex or advanced method (like VMAF targeting, machine learning, or advanced algorithms) perfectly achieves the user's ultimate goal, you MUST propose it as an option alongside the simpler method. Prioritize true goal completion and highest quality output over strict simplicity constraints.

---

# README Generation Rule

Whenever you generate or heavily update a README.md file for this project, you MUST append the following Support & Connect section at the very end.

**CRITICAL:** This section is strictly for file content. NEVER include this section, the support links, or the social media badges in your conversational chat output. Doing so wastes tokens and violates the conciseness mandate.

```markdown
---

## 🤝 Support & Connect

These projects are simple utility scripts built to solve everyday problems. If you find them helpful in your workflow and would like to support me, any small contribution is deeply appreciated! ❤️

<p align="center">
  <a href="https://buymeacoffee.com/Bishnu"><img src="https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee"></a>
  <a href="https://ko-fi.com/Bishnu"><img src="https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white" alt="Ko-fi"></a>
  <a href="https://patreon.com/Bishnu"><img src="https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Patreon"></a>
  <a href="https://paypal.me/beingaash"><img src="https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white" alt="PayPal"></a>
</p>

<p align="center">
  <a href="https://github.com/BishnuMahali"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub"></a>
  <a href="https://bmahali.com"><img src="https://img.shields.io/badge/Website-333333?style=for-the-badge&logo=firefox&logoColor=white" alt="Website"></a>
  <a href="https://youtube.com/@BishnuMahaliPro"><img src="https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube"></a>
  <a href="https://instagram.com/itsBishnuMahali"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram"></a>
  <a href="https://facebook.com/itsBishnuMahali"><img src="https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white" alt="Facebook"></a>
  <a href="https://x.com/itsBishnuMahli"><img src="https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white" alt="X (Twitter)"></a>
  <a href="https://linkedin.com/in/bishnumahali"><img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn"></a>
</p>
```

# 🔴 STRICT ENGINEERING MANDATES

## 1. PROJECT INTEGRITY FIRST
- **NEVER** remove, simplify, or alter core features, technical logic, or advanced functions unless explicitly instructed by the user.
- **NEVER** treat technical logic as "placeholders" during UI/GUI overhauls. 
- All existing functionality must be preserved with 100% fidelity during styling or design changes.
- **ASK FOR PERMISSION** before making any changes that are not specifically requested by the user, even if they seem like "cleanup" or are perceived as necessary for a requested action.
- **SOURCE CONTROL:** Always add unnecessary files (temp files, caches, venvs, etc.) to `.gitignore` to keep the repository clean.

## 2. GUI & STYLING PROTOCOLS
- When working on GUI/Design, treat the underlying engine code as **READ-ONLY** unless changes are strictly required for UI data-binding.
- If a technical overhaul is necessary to achieve a design goal, you **MUST** present the case to the user and obtain explicit permission before proceeding.
- All UI elements must strictly follow system-aware Light/Dark mode themes. Ensure every component (CheckBox, ComboBox, DataGrid) is verified for readability in both modes.

## 3. ARCHITECTURAL PRESERVATION
- Respect the advanced nature of the tools (VMAF, hardware acceleration, multi-pass logic). 
- Your primary goal is to **enhance the presentation** of this work, not to reinvent it or weaken its power.
- If in doubt about the importance of a function, **ASK FIRST**.
