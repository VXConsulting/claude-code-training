# Module 3 : Configuration et personnalisation

## Objectifs

- Comprendre la hiérarchie des fichiers de configuration
- Personnaliser Claude Code pour vos besoins
- Créer un CLAUDE.md efficace

## Hiérarchie de configuration

```
/etc/claude/                        ← Settings gérés (entreprise)
└── settings.json                   ← Priorité maximale

~/.claude/                          ← Configuration utilisateur
├── settings.json                   ← Paramètres globaux
├── CLAUDE.md                       ← Instructions personnelles
└── keybindings.json               ← Raccourcis clavier

projet/                             ← Configuration projet
├── .claude/
│   ├── settings.json              ← Paramètres projet (partagé git)
│   ├── settings.local.json        ← Paramètres locaux (non commités)
│   └── rules/                     ← Règles spécifiques
│       ├── api.md
│       └── tests.md
├── .claude.json                    ← Ancienne config (obsolète)
└── CLAUDE.md                       ← Instructions projet
```

**Ordre de priorité (du plus au moins prioritaire) :**
1. **Managed** (`/etc/claude/settings.json`) - Pour les entreprises
2. **CLI flags** - Options en ligne de commande
3. **Local** (`.claude/settings.local.json`) - Non commité, pour dev local
4. **Project** (`.claude/settings.json`) - Partagé via git
5. **User** (`~/.claude/settings.json`) - Préférences personnelles

---

## settings.json

### Paramètres disponibles

| Paramètre | Type | Description |
|-----------|------|-------------|
| `permissions` | object | Règles allow/deny pour les outils |
| `hooks` | object | Hooks par événement |
| `env` | object | Variables d'environnement |
| `defaultModel` | string | Modèle par défaut |
| `contextFiles` | array | Fichiers de contexte additionnels |
| `disableContextFiles` | boolean | Désactive les fichiers de contexte |
| `enableCompact` | boolean | Active la compaction automatique |
| `sandbox` | object | Configuration du sandbox |

### Emplacement utilisateur

`~/.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test)",
      "Bash(git status)",
      "Bash(git diff:*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/global-check.sh"
          }
        ]
      }
    ]
  },
  "env": {
    "NODE_ENV": "development"
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
        "hooks": [
          {
            "type": "command",
            "command": "./hooks/dangerous-commands.sh"
          }
        ]
      }
    ]
  }
}
```

### Emplacement local (non commité)

`projet/.claude/settings.local.json`

```json
{
  "env": {
    "DEBUG": "true",
    "DATABASE_URL": "postgresql://localhost/mydb_dev"
  },
  "permissions": {
    "allow": [
      "Bash(npm run dev:debug)"
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
| `ANTHROPIC_API_KEY` | Clé API (uniquement si compte Console) |
| `CLAUDE_CODE_API_KEY` | Alias pour ANTHROPIC_API_KEY |
| `CLAUDE_CODE_SKIP_LOGIN` | Ignore l'authentification OAuth |
| `CLAUDE_CODE_USE_BEDROCK` | Utilise Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Utilise Google Vertex AI |
| `CLAUDE_CONFIG_DIR` | Répertoire de config alternatif |
| `CLAUDE_LOG_LEVEL` | Niveau de log (debug, info, warn, error) |
| `CLAUDE_DISABLE_TELEMETRY` | Désactive la télémétrie |
| `BASH_DEFAULT_TIMEOUT_MS` | Timeout des commandes Bash (défaut: 120000) |

**Note :** Pour les abonnements Claude Pro/Max/Teams/Enterprise, l'authentification se fait via `/login` (OAuth). La clé API n'est nécessaire que pour les comptes Claude Console.

```bash
# .bashrc ou .zshrc (uniquement si compte Console)
export ANTHROPIC_API_KEY="sk-ant-..."

# Ou pour les providers cloud
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION="us-east-1"
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
      "Bash(git diff:*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(* --force)"
    ]
  }
}
```

---

## Syntaxe des règles de permission

### Format général

```
ToolName(pattern)
```

### Patterns supportés

| Pattern | Signification |
|---------|---------------|
| `*` | Wildcard (tout caractère) |
| `**` | Wildcard récursif (chemins) |
| `:*` | Tous les arguments |
| `Read(src/**)` | Lire tout dans src/ |
| `Bash(npm:*)` | npm avec tout argument |
| `Write(*.test.ts)` | Écrire fichiers de test |

### Exemples

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(npm test:*)",
      "Bash(git:status|diff|log)",
      "Write(src/**/*.ts)",
      "Edit(src/**)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(*:--force)",
      "Write(.env*)",
      "Edit(node_modules/**)"
    ]
  }
}
```

---

## Configuration Sandbox

Le sandbox isole l'exécution des commandes pour plus de sécurité.

```json
{
  "sandbox": {
    "enabled": true,
    "allowedPaths": [
      "/home/user/projects",
      "/tmp"
    ],
    "deniedPaths": [
      "/etc",
      "/var"
    ],
    "networkAccess": false
  }
}
```

**Modes de sandbox :**
- `enabled: true` - Active le sandbox (recommandé)
- `enabled: false` - Désactive le sandbox
- Via CLI : `--dangerously-skip-sandbox`

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

1. Quel est l'ordre de priorité des fichiers settings.json ?
2. Où placer des règles spécifiques aux tests ?
3. Comment bloquer une commande dangereuse ?
4. Quelle est la différence entre `settings.json` et `settings.local.json` ?
5. Comment utiliser des wildcards dans les règles de permission ?

---

[← Module précédent](../02-native-tools/) | [Module suivant : Les hooks →](../04-hooks/)
