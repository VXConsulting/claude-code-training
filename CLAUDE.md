# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **training course** for mastering Claude Code, from basic usage to advanced plugin development. The course is written in French and consists of 9 progressive modules.

## Course Structure

```
01-introduction/    # Claude Code basics, installation, first steps
02-native-tools/    # 11 native tools (Read, Write, Edit, Glob, Grep, Bash, Task, WebFetch, WebSearch, Notebook, MCP)
03-configuration/   # settings.json, CLAUDE.md hierarchy, rules, permissions
04-hooks/           # PreToolUse, PostToolUse, SessionStart/End, Stop hooks
05-skills/          # SKILL.md format, reusable prompts with frontmatter
06-agents/          # Task tool, native agents (Bash, Explore, Plan), custom agents
07-commands/        # Slash commands, linking commands to skills
08-mcp/             # Model Context Protocol servers configuration and creation
09-project/         # Practical project: building a complete Claude Code plugin
```

## Content Guidelines

- Each module contains a `README.md` with theory, examples, exercises, and a quiz
- Documentation language: French for explanations, English for code/technical terms
- Exercises are hands-on with provided solutions
- Code examples demonstrate Claude Code concepts (hooks in bash, skills in markdown, MCP servers in TypeScript)

## Key Technical Concepts Covered

- **Hooks**: Shell scripts that intercept tool calls (PreToolUse for blocking, PostToolUse for validation)
- **Skills**: Markdown files with YAML frontmatter (`name`, `description`) containing structured prompts
- **Agents**: Specialized Claude instances launched via the Task tool with isolated contexts
- **MCP Servers**: External services exposing tools via JSON-RPC (`mcp__<server>__<tool>` naming)

## Module Dependencies

Modules should be followed in order as they build upon each other. Module 09 (project) consolidates all previous concepts into a complete "DevOps Assistant" plugin.
