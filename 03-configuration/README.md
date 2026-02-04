# Module 3 : Configuration et personnalisation

## Objectifs

- Comprendre la hiérarchie des fichiers de configuration
- Personnaliser Claude Code pour vos besoins
- Créer un CLAUDE.md efficace

## Hiérarchie de configuration

```
~/.claude/                          ← Configuration globale
├── settings.json                   ← Paramètres Claude Code
├── CLAUDE.md                       ← Instructions personnelles
└── keybindings.json               ← Raccourcis clavier

projet/                             ← Configuration projet
├── .claude/
│   ├── settings.json              ← Paramètres projet
│   └── rules/                     ← Règles spécifiques
│       ├── api.md
│       └── tests.md
├── CLAUDE.md                       ← Instructions projet
└── .dev-factory.yml               ← Config plugins (optionnel)
```

**Ordre de priorité :** Projet > Global

---

## settings.json

### Emplacement global

`~/.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test)",
      "Bash(git status)",
      "Bash(git diff)"
    ],
    "deny": [
      "Bash(rm -rf)",
      "Bash(sudo *)"
    ]
  },
  "hooks": {
    "PreToolUse": [],
    "PostToolUse": []
  }
}
```

### Emplacement projet

`projet/.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Bash(docker compose *)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "./hooks/dangerous-commands.sh"
      }
    ]
  }
}
```

---

## CLAUDE.md

Le fichier `CLAUDE.md` est automatiquement chargé au démarrage de Claude Code. C'est votre moyen principal de donner du contexte.

### CLAUDE.md global (~/.claude/CLAUDE.md)

Pour vos préférences personnelles :

```markdown
# Configuration Globale

## Identité
- Prénom : Alex
- Langue : Français pour les échanges

## Conventions Git
- Format : Conventional Commits avec Gitmoji
- Messages en anglais

## Code
- Commentaires en anglais
- Style : concis, pas de sur-ingénierie

## Sécurité
- Jamais de secrets en clair
- Jamais de force push sur main
```

### CLAUDE.md projet (projet/CLAUDE.md)

Pour le contexte spécifique au projet :

```markdown
# Projet : Mon Application

## Stack technique
- Frontend : React 18 + TypeScript
- Backend : Node.js + Express
- Base de données : PostgreSQL
- Tests : Vitest

## Architecture
```
src/
├── api/        # Routes Express
├── services/   # Logique métier
├── models/     # Types et schemas
└── utils/      # Helpers
```

## Conventions
- Fichiers en kebab-case
- Composants en PascalCase
- Tests colocalisés : `*.test.ts`

## Commandes utiles
- `npm run dev` - Démarre le serveur
- `npm test` - Lance les tests
- `npm run lint` - Vérifie le code

## À savoir
- L'auth utilise JWT avec refresh tokens
- Les migrations sont dans `db/migrations/`
- Variables d'environnement dans `.env.example`
```

---

## Rules (règles spécifiques)

Pour des règles qui s'appliquent à certains contextes, utilisez `.claude/rules/` :

### .claude/rules/api.md

```markdown
## Règles API

- Utiliser les codes HTTP appropriés
- Valider les entrées avec Zod
- Format d'erreur : `{ error: string, code?: string }`
- Toujours logger les erreurs
```

### .claude/rules/tests.md

```markdown
## Règles de tests

- Framework : Vitest
- Colocalisés dans `__tests__/`
- Mocker les dépendances externes
- Tester le comportement, pas l'implémentation
```

### .claude/rules/security.md

```markdown
## Règles de sécurité

- Jamais de mots de passe en clair
- Utiliser bcrypt pour le hashing
- Paramétrer les requêtes SQL
- Échapper les sorties HTML
```

---

## Raccourcis clavier

`~/.claude/keybindings.json`

```json
{
  "submit": "Enter",
  "newline": "Shift+Enter",
  "cancel": "Ctrl+C",
  "clear": "Ctrl+L",
  "history_prev": "Up",
  "history_next": "Down"
}
```

### Personnalisation

```json
{
  "submit": "Ctrl+Enter",
  "newline": "Enter",
  "custom": {
    "Ctrl+T": "/test",
    "Ctrl+R": "/review"
  }
}
```

---

## Variables d'environnement

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | Clé API Anthropic |
| `CLAUDE_MODEL` | Modèle par défaut |
| `CLAUDE_DEBUG` | Active le mode debug |
| `CLAUDE_CONFIG_DIR` | Répertoire de config alternatif |

```bash
# .bashrc ou .zshrc
export ANTHROPIC_API_KEY="sk-ant-..."
export CLAUDE_MODEL="claude-sonnet-4-20250514"
```

---

## Bonnes pratiques

### 1. CLAUDE.md concis

```markdown
❌ Mauvais : 500 lignes de documentation

✅ Bon : 50-100 lignes avec l'essentiel
- Stack technique
- Architecture clé
- Conventions importantes
- Commandes utiles
```

### 2. Règles organisées

```
.claude/rules/
├── api.md       # Règles API
├── tests.md     # Règles tests
├── security.md  # Règles sécurité
└── git.md       # Conventions git
```

### 3. Permissions explicites

```json
{
  "permissions": {
    "allow": [
      "Bash(npm *)",
      "Bash(git status)",
      "Bash(git diff)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(* --force)"
    ]
  }
}
```

---

## Exercices

### Exercice 1 : CLAUDE.md personnel

1. Créez `~/.claude/CLAUDE.md`
2. Ajoutez vos préférences personnelles
3. Testez avec une nouvelle session Claude

### Exercice 2 : Configuration projet

1. Créez un nouveau projet
2. Ajoutez un `CLAUDE.md` décrivant le projet
3. Ajoutez une règle dans `.claude/rules/`
4. Vérifiez que Claude respecte vos règles

### Exercice 3 : Permissions

1. Ajoutez une permission pour `npm run build`
2. Bloquez `npm publish`
3. Testez les deux commandes

---

## Quiz

1. Quel fichier a priorité : global ou projet ?
2. Où placer des règles spécifiques aux tests ?
3. Comment bloquer une commande dangereuse ?
4. Quelle variable d'environnement définit la clé API ?

---

[← Module précédent](../02-native-tools/) | [Module suivant : Les hooks →](../04-hooks/)
