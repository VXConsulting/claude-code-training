# Module 7 : Les commandes personnalisées

## Objectifs

- Comprendre les commandes slash intégrées
- Créer des commandes personnalisées
- Comprendre la fusion commandes/skills

## Important : Fusion avec les Skills

**Les commandes personnalisées ont été fusionnées avec les skills.**

- Un fichier `.claude/commands/review.md` et un skill `.claude/skills/review/SKILL.md` créent tous deux `/review`
- Les fichiers `.claude/commands/` existants continuent de fonctionner
- **Recommandation** : Utilisez les skills (voir Module 5) pour les nouvelles créations

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
| `/agents` | Gère les agents |
| `/mcp` | Gère les serveurs MCP |
| `/context` | Affiche les skills chargés |

---

## Créer des commandes personnalisées

### Structure (ancienne méthode)

```
.claude/commands/
└── ma-commande.md
```

### Structure (méthode recommandée - skills)

```
.claude/skills/
└── ma-commande/
    └── SKILL.md
```

### Format

Les commandes utilisent le même frontmatter que les skills :

```markdown
---
name: test
description: Run tests for the project
allowed-tools: Bash
---

Run the test suite and report results.
```

### Champs du frontmatter

| Champ | Description |
|-------|-------------|
| `name` | Nom de la commande (sans /) |
| `description` | Description et quand utiliser |
| `disable-model-invocation` | Si `true`, invocation manuelle uniquement |
| `allowed-tools` | Outils autorisés |
| `context` | `fork` pour exécuter dans un subagent |

Voir le Module 5 (Skills) pour la liste complète des champs.

---

## Exemples

### Commande simple

```markdown
---
name: review
description: Review staged changes for quality and security
---

Review the staged changes:
1. Run `git diff --staged` to see changes
2. Analyze code quality
3. Check for security issues
4. Provide feedback
```

Usage :
```
/review
```

---

### Commande avec restriction d'invocation

```markdown
---
name: commit
description: Stage, review, and commit changes
disable-model-invocation: true
---

Commit workflow:
1. Review staged changes
2. If the review passes, create a commit
3. Use conventional commit format
4. Include Co-Authored-By trailer
```

Le `disable-model-invocation: true` empêche Claude d'invoquer automatiquement.

---

### Commande avec arguments

```markdown
---
name: feature
description: Full feature development workflow
argument-hint: [feature-description]
---

Implement the feature: $ARGUMENTS

1. **Planning** - Design the approach
2. **Implementation** - Code the feature
3. **Review** - Quality check
4. **Tests** - Ensure coverage
5. **Commit** - Proper commit
```

Usage :
```
/feature add user authentication
/feature fix login bug
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
└── skills/
    ├── test/
    │   └── SKILL.md
    ├── commit/
    │   └── SKILL.md
    └── deploy/
        └── SKILL.md
```

**Note :** Les plugins peuvent aussi avoir un dossier `commands/` pour compatibilité,
mais le format `skills/` est recommandé.

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

### 4. Utiliser le format skills

Préférez créer des skills dans `.claude/skills/` plutôt que des commandes.
Les skills offrent plus de fonctionnalités (fichiers de support, hooks, etc.).

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

1. Quelle est la différence entre commandes et skills ?
2. Où placer les skills dans un plugin ?
3. Comment passer des arguments à une commande ?
4. Quelle commande intégrée compacte le contexte ?

---

[← Module précédent](../06-agents/) | [Module suivant : MCP →](../08-mcp/)
