# Module 9 : Projet pratique

## Objectif

Créer un **plugin Claude Code complet** qui intègre tous les concepts appris :
- Hooks de validation
- Skills réutilisables
- Agents spécialisés
- Commandes personnalisées

## Le projet : DevOps Assistant

Vous allez créer un plugin qui aide au développement quotidien avec :

1. **Hooks de sécurité** - Bloquer les actions dangereuses
2. **Skill de review** - Revue de code automatisée
3. **Agent de documentation** - Génère la doc automatiquement
4. **Commandes pratiques** - Raccourcis pour les tâches courantes

---

## Structure du projet

```
devops-assistant/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   ├── no-secrets.sh
│   ├── require-tests.sh
│   └── validate-commit.sh
├── skills/                    ← Format recommandé (skills = commandes)
│   ├── code-review/
│   │   └── SKILL.md
│   ├── documentation/
│   │   └── SKILL.md
│   └── release/
│       └── SKILL.md
├── agents/
│   └── doc-generator.md
├── commands/                  ← Optionnel (alias vers skills)
│   ├── review.md
│   ├── docs.md
│   └── release.md
├── tests/
│   └── hooks/
│       └── no-secrets.test.sh
└── README.md
```

**Note :** Les `commands/` et `skills/` sont fusionnés. Un skill crée automatiquement une commande `/nom-du-skill`. Le dossier `commands/` est optionnel si vous utilisez déjà `skills/`.

---

## Étape 1 : Initialisation

### 1.1 Créer le répertoire

```bash
mkdir -p devops-assistant/.claude-plugin
cd devops-assistant
```

### 1.2 Créer le manifest

**`.claude-plugin/plugin.json`**

```json
{
  "name": "devops-assistant",
  "version": "1.0.0",
  "description": "DevOps assistant for daily development tasks",
  "author": "Your Name",
  "repository": "https://github.com/you/devops-assistant"
}
```

### 1.3 Créer le README

```markdown
# DevOps Assistant

Plugin Claude Code pour assister le développement quotidien.

## Installation

```bash
claude plugin add /path/to/devops-assistant
```

## Fonctionnalités

- Hooks de sécurité (secrets, tests)
- Review de code automatisée
- Génération de documentation
- Workflow de release
```

---

## Étape 2 : Hooks

### 2.1 Hook anti-secrets

**`hooks/no-secrets.sh`**

```bash
#!/usr/bin/env bash
# Bloque l'écriture de secrets dans le code

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

if [[ "$tool_name" != "Write" && "$tool_name" != "Edit" ]]; then
    exit 0
fi

content=$(echo "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')

# Patterns de secrets
patterns=(
    'AKIA[0-9A-Z]{16}'
    'sk-[a-zA-Z0-9]{48}'
    'ghp_[a-zA-Z0-9]{36}'
    'password\s*[=:]\s*["\x27][^"\x27]{8,}'
)

for pattern in "${patterns[@]}"; do
    if echo "$content" | grep -qE "$pattern"; then
        jq -n '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": "Secret detected! Use environment variables instead."
            }
        }'
        exit 0
    fi
done

exit 0
```

### 2.2 Hook require-tests

**`hooks/require-tests.sh`**

```bash
#!/usr/bin/env bash
# Bloque le push si des fichiers source sont modifiés sans tests

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Seulement pour git push
if [[ "$tool_name" != "Bash" || "$command" != *"git push"* ]]; then
    exit 0
fi

# Vérifier les fichiers modifiés
src_files=$(git diff --cached --name-only | grep -E '\.(ts|js|py)$' | grep -v '\.test\.' | grep -v '__tests__')
test_files=$(git diff --cached --name-only | grep -E '\.test\.(ts|js|py)$|__tests__/')

if [[ -n "$src_files" && -z "$test_files" ]]; then
    jq -n '{
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": "Source files modified without tests. Are you sure?"
        }
    }'
    exit 0
fi

exit 0
```

### 2.3 Hook validate-commit

**`hooks/validate-commit.sh`**

```bash
#!/usr/bin/env bash
# Valide le format du message de commit

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [[ "$tool_name" != "Bash" || "$command" != *"git commit"* ]]; then
    exit 0
fi

# Extraire le message de commit
if [[ "$command" =~ -m[[:space:]]+[\"\']([^\"\']+)[\"\'] ]]; then
    message="${BASH_REMATCH[1]}"

    # Vérifier le format conventionnel
    if ! echo "$message" | grep -qE '^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+'; then
        jq -n '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": "Commit message must follow conventional commits: type(scope): description"
            }
        }'
        exit 0
    fi
fi

exit 0
```

---

## Étape 3 : Skills

### 3.1 Skill code-review

**`skills/code-review/SKILL.md`**

```markdown
---
name: code-review
description: Automated code review for staged changes
---

# Code Review

## Process

1. **Get changed files**
   ```bash
   git diff --staged --name-only
   ```

2. **Analyze each file**
   For each file, check:
   - [ ] Code readability
   - [ ] Error handling
   - [ ] Security vulnerabilities
   - [ ] Test coverage
   - [ ] Documentation

3. **Generate report**

## Output Format

```markdown
## Code Review Report

### Summary
- Files reviewed: X
- Issues found: Y

### Issues

#### [CRITICAL] filename.ts:42
Description of the issue
**Recommendation:** How to fix

#### [WARNING] filename.ts:100
Description
**Recommendation:** Fix suggestion

### Approved
- [x] No secrets detected
- [x] Error handling present
- [ ] Tests missing for new code

### Verdict
APPROVED / NEEDS CHANGES
```
```

### 3.2 Skill documentation

**`skills/documentation/SKILL.md`**

```markdown
---
name: documentation
description: Generate or update project documentation
---

# Documentation Generator

## Process

1. **Scan codebase**
   - Find public APIs
   - Identify exported functions
   - Locate README files

2. **Generate documentation**
   - API reference
   - Usage examples
   - Configuration options

3. **Update existing docs**
   - Check for outdated sections
   - Add new features
   - Fix broken links

## Output

Generate/update in `docs/` folder:
- `API.md` - API reference
- `CONFIGURATION.md` - Config options
- `EXAMPLES.md` - Usage examples
```

### 3.3 Skill release

**`skills/release/SKILL.md`**

```markdown
---
name: release
description: Prepare and publish a release
---

# Release Workflow

## Pre-release Checks

- [ ] All tests pass
- [ ] No uncommitted changes
- [ ] CHANGELOG.md updated
- [ ] Version bumped

## Process

1. **Determine version**
   - MAJOR: Breaking changes
   - MINOR: New features
   - PATCH: Bug fixes

2. **Update files**
   - package.json
   - CHANGELOG.md
   - README.md (if version mentioned)

3. **Create release**
   ```bash
   git tag v<version>
   git push origin v<version>
   gh release create v<version> --notes "<changelog>"
   ```

## Changelog Format

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature

### Changed
- Modified behavior

### Fixed
- Bug fix
```
```

---

## Étape 4 : Agent

### 4.1 Agent doc-generator

**`agents/doc-generator.md`**

```markdown
---
name: doc-generator
description: Agent specialized in generating documentation
model: haiku
tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Documentation Generator Agent

## Role

You are a documentation specialist. Your job is to:
1. Analyze source code
2. Extract public APIs and functions
3. Generate clear, useful documentation

## Guidelines

- Use JSDoc/TSDoc style for code documentation
- Include usage examples
- Document parameters and return types
- Add links between related functions

## Output Format

Generate markdown files with:
- Clear headings
- Code examples
- Parameter tables
- Return type descriptions
```

---

## Étape 5 : Commandes

### 5.1 Commande review

**Note :** Les commandes et skills ont été fusionnés. Vous pouvez soit :
- Créer une commande dans `commands/review.md`
- OU utiliser directement le skill `skills/code-review/SKILL.md` (recommandé)

**`commands/review.md`** (si vous voulez un alias simple)

```markdown
---
name: review
description: Review staged changes for quality and security
---

Run the code-review skill: analyze staged changes and provide feedback.

1. Get staged files with `git diff --staged --name-only`
2. For each file, check code quality and security
3. Generate a review report
```

### 5.2 Commande docs

**`commands/docs.md`**

```markdown
---
name: docs
description: Generate project documentation
---

Generate or update documentation for this project.

1. Scan the codebase for public APIs
2. Generate documentation in the `docs/` folder
3. After generating, offer to commit the changes
```

### 5.3 Commande release

**`commands/release.md`**

```markdown
---
name: release
description: Prepare a new release
argument-hint: [major|minor|patch]
---

Prepare and publish a release.

Arguments:
- `major` - Major version bump (breaking changes)
- `minor` - Minor version bump (new features)
- `patch` - Patch version bump (bug fixes)

Example: `/release minor`

Process:
1. Run all tests
2. Update version in package.json
3. Update CHANGELOG.md
4. Create git tag and push
```

---

## Étape 6 : Tests

### 6.1 Test du hook no-secrets

**`tests/hooks/no-secrets.test.sh`**

```bash
#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"
HOOK="$SCRIPT_DIR/../../hooks/no-secrets.sh"

# Test 1: Should block AWS key
test_blocks_aws_key() {
    local input='{"tool_name":"Write","tool_input":{"content":"const key = \"AKIAIOSFODNN7EXAMPLE\""}}'
    local output

    output=$(echo "$input" | bash "$HOOK")

    if echo "$output" | grep -q "deny"; then
        echo "✓ Test passed: blocks AWS key"
    else
        echo "✗ Test failed: should block AWS key"
        exit 1
    fi
}

# Test 2: Should allow safe content
test_allows_safe_content() {
    local input='{"tool_name":"Write","tool_input":{"content":"const message = \"Hello World\""}}'
    local output

    output=$(echo "$input" | bash "$HOOK")

    if [[ -z "$output" ]]; then
        echo "✓ Test passed: allows safe content"
    else
        echo "✗ Test failed: should allow safe content"
        exit 1
    fi
}

# Run tests
test_blocks_aws_key
test_allows_safe_content

echo "All tests passed!"
```

---

## Étape 7 : Configuration

### 7.1 Settings du plugin

Créez un fichier `.claude/settings.json` exemple :

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "./hooks/no-secrets.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "./hooks/require-tests.sh"
          },
          {
            "type": "command",
            "command": "./hooks/validate-commit.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Étape 8 : Installation et test

### 8.1 Rendre les hooks exécutables

```bash
chmod +x hooks/*.sh
chmod +x tests/hooks/*.sh
```

### 8.2 Lancer les tests

```bash
bash tests/hooks/no-secrets.test.sh
```

### 8.3 Installer le plugin

```bash
claude plugin add /path/to/devops-assistant
```

### 8.4 Tester les commandes

```
claude
> /review
> /docs
> /release patch
```

---

## Critères de validation

Votre projet est complet si :

- [ ] Les 3 hooks fonctionnent et ont des tests
- [ ] Les 3 skills sont bien documentés
- [ ] L'agent doc-generator est fonctionnel
- [ ] Les commandes `/review`, `/docs`, `/release` fonctionnent
- [ ] Le plugin s'installe sans erreur
- [ ] Le README explique l'installation et l'usage

---

## Pour aller plus loin

### Améliorations possibles

1. **Ajouter un serveur MCP** pour intégrer Slack/Discord
2. **Hook de performance** qui mesure le temps d'exécution
3. **Skill de migration** pour mettre à jour les dépendances
4. **Agent de test** qui génère des tests automatiquement

### Publier sur GitHub

1. Créez un repo GitHub
2. Ajoutez une CI avec les tests
3. Publiez une release
4. Partagez avec la communauté !

---

## Félicitations !

Vous avez terminé le cours Claude Code Training.

Vous maîtrisez maintenant :
- Les outils natifs de Claude Code
- La configuration et personnalisation
- Les hooks pour la validation et sécurité
- Les skills pour les workflows réutilisables
- Les agents pour les tâches spécialisées
- Les commandes pour les raccourcis
- L'intégration MCP

**Prochaine étape :** Créez vos propres plugins et partagez-les !

---

[← Module précédent](../08-mcp/) | [Retour au sommaire](../README.md)
