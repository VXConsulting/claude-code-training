# Module 7 : Les commandes personnalisées

## Objectifs

- Comprendre les commandes slash intégrées
- Créer des commandes personnalisées
- Lier commandes et skills

## Commandes intégrées

Claude Code fournit des commandes slash par défaut :

| Commande | Description |
|----------|-------------|
| `/help` | Affiche l'aide |
| `/clear` | Efface la conversation |
| `/compact` | Compacte le contexte |
| `/exit` | Quitte Claude Code |
| `/config` | Affiche la configuration |
| `/model` | Change le modèle |
| `/permissions` | Gère les permissions |

---

## Créer des commandes personnalisées

### Structure

```
commands/
└── ma-commande.md
```

Ou dans un plugin :
```
mon-plugin/
└── commands/
    └── ma-commande.md
```

### Format

```markdown
---
name: test
description: Run tests for the project
invokes: quick-test
---
```

### Champs du frontmatter

| Champ | Description |
|-------|-------------|
| `name` | Nom de la commande (sans /) |
| `description` | Description affichée dans l'aide |
| `invokes` | Skill à invoquer (optionnel) |

---

## Exemples

### Commande simple → Skill

```markdown
---
name: review
description: Review staged changes
invokes: code-review
---
```

Usage :
```
/review
```

---

### Commande avec instructions

```markdown
---
name: commit
description: Stage, review, and commit changes
invokes: code-review
---

After invoking the code-review skill:

1. If the review passes, proceed to commit
2. Use conventional commit format
3. Include Co-Authored-By trailer
```

---

### Commande complexe

```markdown
---
name: feature
description: Full feature development workflow
invokes: workflow
---

## Feature Workflow

This command triggers the full development workflow:

1. **Planning** - Use architect agent to design
2. **Implementation** - Code the feature
3. **Review** - Quality check
4. **Tests** - Ensure coverage
5. **Commit** - Proper commit with changelog

Arguments:
- `--skip-tests` : Skip test execution
- `--quick` : Minimal review
```

Usage :
```
/feature add user authentication
/feature --quick fix login bug
```

---

### Commande de déploiement

```markdown
---
name: deploy
description: Deploy to staging or production
---

## Deploy Command

### Usage

```
/deploy staging
/deploy production
```

### Process

1. **Pre-checks**
   - Verify all tests pass
   - Check for uncommitted changes
   - Verify branch is up to date

2. **Build**
   ```bash
   npm run build
   ```

3. **Deploy**
   - staging: `npm run deploy:staging`
   - production: `npm run deploy:prod`

4. **Verify**
   - Run smoke tests
   - Check health endpoints

### Safety

- Production requires explicit confirmation
- Rollback instructions provided on failure
```

---

## Organisation

### Dans un plugin

```
mon-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── test.md
│   ├── commit.md
│   └── deploy.md
└── skills/
    ├── code-review/
    └── workflow/
```

### Mapping commandes → skills

| Commande | Skill invoqué |
|----------|---------------|
| `/test` | quick-test |
| `/commit` | code-review |
| `/feature` | workflow |
| `/review` | code-review |

---

## Arguments et options

### Passer des arguments

```
/deploy production
```

Le skill reçoit `production` comme argument.

### Avec options

```
/feature --skip-tests --verbose
```

Documentez les options dans la commande :

```markdown
## Options

| Option | Description |
|--------|-------------|
| `--skip-tests` | Ne pas exécuter les tests |
| `--verbose` | Affichage détaillé |
| `--dry-run` | Simulation sans effet |
```

---

## Bonnes pratiques

### 1. Noms courts et mémorables

```
✅ /test, /commit, /deploy
❌ /run-all-tests-and-check, /commit-with-review
```

### 2. Description claire

```markdown
---
name: hotfix
description: Quick bug fix workflow (bypasses planning)
---
```

### 3. Documenter les arguments

```markdown
## Usage

/hotfix <bug-description>

## Examples

/hotfix Fix null pointer in login
/hotfix --critical Payment processing failure
```

### 4. Associer à un skill

```markdown
---
invokes: quick-fix
---
```

Cela garantit un comportement cohérent.

---

## Exercices

### Exercice 1 : Commande simple

Créez une commande `/hello` qui affiche "Hello, Claude Code!".

**Fichier** : `exercises/hello.md`

### Exercice 2 : Commande avec skill

1. Créez un skill `format-code`
2. Créez une commande `/format` qui l'invoque

### Exercice 3 : Commande avec arguments

Créez une commande `/new` qui crée différents fichiers selon l'argument :
- `/new component` → composant React
- `/new api` → endpoint API
- `/new test` → fichier de test

---

## Quiz

1. Comment lier une commande à un skill ?
2. Où placer les fichiers de commande dans un plugin ?
3. Comment passer des arguments à une commande ?
4. Quelle commande intégrée compacte le contexte ?

---

[← Module précédent](../06-agents/) | [Module suivant : MCP →](../08-mcp/)
