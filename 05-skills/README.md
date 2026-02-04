# Module 5 : Les skills

## Objectifs

- Comprendre ce qu'est un skill
- Créer des skills réutilisables
- Organiser une bibliothèque de skills
- Invoquer des skills dans vos workflows

## Qu'est-ce qu'un skill ?

Un skill est un **prompt structuré** qui guide Claude pour une tâche spécifique. C'est comme un template de comportement réutilisable.

```
┌─────────────────────────────────────────────────────┐
│                      Skill                           │
├─────────────────────────────────────────────────────┤
│  Métadonnées (frontmatter)                          │
│  - name: code-review                                │
│  - description: Review code changes                 │
│                                                     │
│  Instructions (markdown)                            │
│  - Étapes à suivre                                  │
│  - Critères de qualité                              │
│  - Format de sortie                                 │
└─────────────────────────────────────────────────────┘
```

## Structure d'un skill

### Emplacement

```
projet/
└── skills/
    └── mon-skill/
        └── SKILL.md
```

Ou dans un plugin :
```
mon-plugin/
└── skills/
    └── mon-skill/
        └── SKILL.md
```

### Format

```markdown
---
name: code-review
description: Review staged changes for quality and security
---

# Code Review

## Objectif

Analyser les changements stagés et fournir un feedback constructif.

## Étapes

1. **Lister les fichiers modifiés**
   ```bash
   git diff --staged --name-only
   ```

2. **Analyser chaque fichier**
   - Vérifier la lisibilité
   - Détecter les bugs potentiels
   - Vérifier la sécurité

3. **Produire le rapport**
   Format :
   ```
   ## Summary
   - X fichiers analysés
   - Y problèmes trouvés

   ## Issues
   - [CRITICAL] ...
   - [WARNING] ...
   - [INFO] ...

   ## Recommendations
   ...
   ```

## Critères

- [ ] Pas de secrets hardcodés
- [ ] Gestion des erreurs présente
- [ ] Tests inclus si nouveau code
- [ ] Pas de console.log oubliés
```

---

## Frontmatter (métadonnées)

| Champ | Obligatoire | Description |
|-------|-------------|-------------|
| `name` | Non | Identifiant unique (utilise le nom du dossier si absent) |
| `description` | Recommandé | Description et quand utiliser le skill |
| `argument-hint` | Non | Indice pour les arguments (ex: `[issue-number]`) |
| `disable-model-invocation` | Non | Si `true`, Claude ne peut pas invoquer automatiquement |
| `user-invocable` | Non | Si `false`, masqué du menu `/` |
| `allowed-tools` | Non | Outils autorisés sans demande de permission |
| `model` | Non | Modèle à utiliser |
| `context` | Non | `fork` pour exécuter dans un subagent isolé |
| `agent` | Non | Type de subagent si `context: fork` |
| `hooks` | Non | Hooks spécifiques au skill |

```yaml
---
name: tdd
description: Test-Driven Development workflow. Use when implementing new features.
disable-model-invocation: false
allowed-tools: Read, Bash
---
```

**Note :** Les commandes (`.claude/commands/`) ont été fusionnées avec les skills.
Les fichiers existants continuent de fonctionner, mais les skills sont recommandés.

---

## Invocation

### Via slash command

```
/code-review
```

### Via l'outil Skill

```
Skill { skill: "code-review" }
```

### Avec arguments

```
/code-review --strict
```

```
Skill { skill: "code-review", args: "--strict" }
```

### Variables de substitution

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | Tous les arguments passés au skill |
| `$ARGUMENTS[N]` | Argument par index (0-based) |
| `$0`, `$1`, etc. | Raccourcis pour `$ARGUMENTS[N]` |
| `${CLAUDE_SESSION_ID}` | ID de la session courante |

**Exemple :**
```yaml
---
name: fix-issue
description: Fix a GitHub issue by number
---

Fix GitHub issue #$ARGUMENTS following our coding standards.
```

Usage : `/fix-issue 123` → "Fix GitHub issue #123..."

---

### Exécution dans un subagent

Utilisez `context: fork` pour exécuter le skill dans un contexte isolé :

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly using Glob and Grep.
```

Le skill s'exécute dans un subagent `Explore` avec son propre contexte.

---

## Exemples de skills

### Skill : Debugging

```markdown
---
name: debugging
description: Systematic debugging workflow
---

# Debugging Workflow

## Étape 1 : Reproduire

1. Comprendre le bug rapporté
2. Identifier les étapes de reproduction
3. Confirmer le comportement attendu vs actuel

## Étape 2 : Isoler

1. Identifier le fichier/fonction concerné
2. Ajouter des logs stratégiques
3. Réduire le scope du problème

## Étape 3 : Analyser

1. Examiner le code suspect
2. Vérifier les hypothèses
3. Tracer le flux de données

## Étape 4 : Corriger

1. Implémenter le fix minimal
2. Vérifier que le fix résout le problème
3. S'assurer de ne pas créer de régression

## Étape 5 : Valider

1. Écrire un test pour le bug
2. Lancer la suite de tests
3. Documenter si nécessaire
```

---

### Skill : Refactoring

```markdown
---
name: refactoring
description: Safe code refactoring workflow
---

# Refactoring Workflow

## Règles d'or

1. **Jamais de refactoring sans tests**
2. **Petits commits atomiques**
3. **Un seul type de refactoring à la fois**

## Process

### Phase 1 : Préparation

- [ ] Vérifier que les tests passent
- [ ] Identifier le code à refactorer
- [ ] Définir l'objectif du refactoring

### Phase 2 : Exécution

Types de refactoring :
- Extract function/method
- Rename
- Move
- Inline
- Simplify conditionals

### Phase 3 : Validation

- [ ] Tests toujours verts
- [ ] Comportement identique
- [ ] Code plus lisible

## Red Flags

Arrêter si :
- Les tests cassent
- Le scope grandit
- Trop de fichiers impactés
```

---

### Skill : Git Workflow

```markdown
---
name: git-flow
description: Standard git workflow for features
---

# Git Feature Workflow

## Nouvelle feature

```bash
# 1. Créer la branche
git checkout main
git pull origin main
git checkout -b feature/<name>

# 2. Développer (commits atomiques)
git add <files>
git commit -m "feat(<scope>): <description>"

# 3. Pousser
git push -u origin feature/<name>

# 4. Créer PR
gh pr create --title "feat: <title>" --body "<description>"
```

## Conventions de commit

Format : `<type>(<scope>): <description>`

| Type | Usage |
|------|-------|
| feat | Nouvelle fonctionnalité |
| fix | Correction de bug |
| docs | Documentation |
| refactor | Refactoring |
| test | Tests |
| chore | Maintenance |

## Checklist PR

- [ ] Tests ajoutés/mis à jour
- [ ] Documentation mise à jour
- [ ] Pas de conflits
- [ ] CI passe
```

---

## Organisation des skills

### Par catégorie

```
skills/
├── workflow/
│   ├── tdd/
│   ├── code-review/
│   └── git-flow/
├── quality/
│   ├── security-audit/
│   └── refactoring/
└── debugging/
    ├── systematic/
    └── git-bisect/
```

### Dans un plugin

```
mon-plugin/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    ├── skill-1/
    │   └── SKILL.md
    └── skill-2/
        └── SKILL.md
```

---

## Bonnes pratiques

### 1. Un skill = Un objectif

```
❌ skill "development" qui fait tout

✅ skills séparés :
   - code-review
   - debugging
   - refactoring
```

### 2. Instructions claires

```markdown
❌ "Fais une review du code"

✅ "1. Liste les fichiers modifiés
    2. Pour chaque fichier, vérifie :
       - Lisibilité
       - Sécurité
       - Tests
    3. Produis un rapport structuré"
```

### 3. Formats de sortie définis

```markdown
## Format de sortie

```json
{
  "status": "success|warning|error",
  "issues": [...],
  "recommendations": [...]
}
```
```

### 4. Idempotence

Le skill doit pouvoir être relancé sans effets de bord.

---

## Exercices

### Exercice 1 : Skill simple

Créez un skill `hello-world` qui :
1. Affiche un message de bienvenue
2. Liste les fichiers du projet
3. Résume la structure

**Fichier** : `exercises/hello-world/SKILL.md`

### Exercice 2 : Skill avec étapes

Créez un skill `new-component` pour React qui :
1. Demande le nom du composant
2. Crée le fichier du composant
3. Crée le fichier de test
4. Crée le fichier de styles

**Fichier** : `exercises/new-component/SKILL.md`

### Exercice 3 : Skill de validation

Créez un skill `pre-commit-check` qui :
1. Vérifie les fichiers stagés
2. Lance les tests
3. Vérifie le format du message de commit
4. Produit un rapport go/no-go

**Fichier** : `exercises/pre-commit-check/SKILL.md`

---

## Quiz

1. Où placer les fichiers de skill ?
2. Quels champs sont obligatoires dans le frontmatter ?
3. Comment invoquer un skill avec des arguments ?
4. Pourquoi un skill doit-il être idempotent ?

---

[← Module précédent](../04-hooks/) | [Module suivant : Les agents →](../06-agents/)
