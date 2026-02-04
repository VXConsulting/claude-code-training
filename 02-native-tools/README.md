# Module 2 : Les outils natifs

## Objectifs

- Connaître tous les outils disponibles dans Claude Code
- Comprendre quand chaque outil est utilisé
- Savoir comment les outils interagissent

## Vue d'ensemble

Claude Code dispose de nombreux **outils natifs** :

```
┌─────────────────────────────────────────────────────────────┐
│                     Outils Claude Code                       │
├─────────────────────────────────────────────────────────────┤
│  Fichiers        │  Recherche       │  Exécution            │
│  ────────────    │  ──────────      │  ──────────           │
│  Read            │  Glob            │  Bash                 │
│  Write           │  Grep            │  Task                 │
│  Edit            │  LS              │                       │
│  MultiEdit       │                  │                       │
├─────────────────────────────────────────────────────────────┤
│  Web             │  Notebook        │  Tâches               │
│  ────────────    │  ──────────      │  ──────────           │
│  WebFetch        │  NotebookRead    │  TodoRead             │
│  WebSearch       │  NotebookEdit    │  TodoWrite            │
├─────────────────────────────────────────────────────────────┤
│  MCP                                                        │
│  ──────────                                                 │
│  mcp__*                                                     │
└─────────────────────────────────────────────────────────────┘
```

## Outils de fichiers

### Read

Lit le contenu d'un fichier.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `file_path` | string | Chemin absolu du fichier |
| `offset` | number | Ligne de départ (optionnel) |
| `limit` | number | Nombre de lignes (optionnel) |

**Exemple d'utilisation par Claude :**
```
"Je vais lire le fichier src/index.ts"
→ Read { file_path: "/home/user/project/src/index.ts" }
```

**Capacités spéciales :**
- Peut lire des images (PNG, JPG, etc.)
- Peut lire des PDFs (paramètre `pages`)
- Peut lire des notebooks Jupyter (.ipynb)

---

### Write

Crée ou écrase un fichier.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `file_path` | string | Chemin absolu du fichier |
| `content` | string | Contenu à écrire |

**Exemple :**
```
"Je vais créer le fichier config.json"
→ Write {
    file_path: "/home/user/project/config.json",
    content: "{\n  \"version\": 1\n}"
  }
```

**Note :** Claude doit avoir lu un fichier avant de pouvoir l'écraser.

---

### Edit

Modifie un fichier existant par remplacement de chaîne.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `file_path` | string | Chemin absolu du fichier |
| `old_string` | string | Texte à remplacer |
| `new_string` | string | Nouveau texte |
| `replace_all` | boolean | Remplacer toutes les occurrences |

**Exemple :**
```
"Je vais corriger le typo dans utils.ts"
→ Edit {
    file_path: "/home/user/project/utils.ts",
    old_string: "cosnt",
    new_string: "const"
  }
```

**Important :** `old_string` doit être unique dans le fichier, sinon l'édition échoue.

---

### MultiEdit

Applique plusieurs modifications à un fichier en une seule opération.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `file_path` | string | Chemin absolu du fichier |
| `edits` | array | Liste des éditions à appliquer |

Chaque édition dans le tableau contient `old_string` et `new_string`.

**Exemple :**
```
→ MultiEdit {
    file_path: "/home/user/project/utils.ts",
    edits: [
      { old_string: "const", new_string: "let" },
      { old_string: "var x", new_string: "const x" }
    ]
  }
```

---

## Outils de recherche

### Glob

Trouve des fichiers par pattern.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `pattern` | string | Pattern glob (ex: `**/*.ts`) |
| `path` | string | Répertoire de recherche (optionnel) |

**Exemples de patterns :**
```
**/*.ts          → Tous les fichiers TypeScript
src/**/*.test.js → Tests dans src/
**/index.*       → Tous les fichiers index
```

---

### Grep

Recherche dans le contenu des fichiers.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `pattern` | string | Expression régulière |
| `path` | string | Répertoire de recherche |
| `glob` | string | Filtrer par pattern de fichiers |
| `output_mode` | string | `files_with_matches`, `content`, `count` |

**Exemple :**
```
"Où est définie la fonction handleLogin ?"
→ Grep {
    pattern: "function handleLogin|const handleLogin",
    path: "/home/user/project/src"
  }
```

---

### LS

Liste le contenu d'un répertoire.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `path` | string | Chemin du répertoire à lister |

**Exemple :**
```
→ LS { path: "/home/user/project/src" }
```

---

## Outil d'exécution

### Bash

Exécute des commandes shell.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `command` | string | Commande à exécuter |
| `timeout` | number | Timeout en ms (max 600000) |

**Exemples :**
```bash
# Tests
npm test

# Git
git status
git diff

# Build
npm run build
```

**Restrictions :**
- Pas de commandes interactives (`vim`, `git rebase -i`)
- Timeout par défaut : 2 minutes
- Output tronqué à 30000 caractères

---

### Task

Lance un sous-agent spécialisé.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `prompt` | string | Instructions pour l'agent |
| `subagent_type` | string | Type d'agent |
| `model` | string | Modèle à utiliser (optionnel) |

**Types d'agents natifs :**
| Type | Usage |
|------|-------|
| `Bash` | Spécialiste commandes shell |
| `Explore` | Exploration de codebase |
| `Plan` | Planification d'implémentation |
| `general-purpose` | Agent généraliste |

**Exemple :**
```
→ Task {
    prompt: "Explore le codebase et trouve comment l'auth est implémentée",
    subagent_type: "Explore"
  }
```

---

## Outils Web

### WebFetch

Récupère et analyse du contenu web.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `url` | string | URL à récupérer |
| `prompt` | string | Question sur le contenu |

**Exemple :**
```
→ WebFetch {
    url: "https://docs.example.com/api",
    prompt: "Quels sont les endpoints disponibles ?"
  }
```

**Limitations :**
- Ne fonctionne pas avec les pages authentifiées
- Redirige automatiquement HTTP → HTTPS

---

### WebSearch

Recherche sur le web.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `query` | string | Requête de recherche |
| `allowed_domains` | array | Domaines autorisés (optionnel) |
| `blocked_domains` | array | Domaines bloqués (optionnel) |

**Exemple :**
```
→ WebSearch {
    query: "React 19 new features 2026",
    allowed_domains: ["react.dev", "github.com"]
  }
```

---

## Notebook

### NotebookRead

Lit le contenu d'un notebook Jupyter.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `notebook_path` | string | Chemin absolu du notebook |

---

### NotebookEdit

Modifie une cellule d'un notebook Jupyter.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `notebook_path` | string | Chemin absolu du notebook |
| `cell_id` | string | ID de la cellule à modifier |
| `new_source` | string | Nouveau contenu de la cellule |
| `cell_type` | string | Type : `code` ou `markdown` |
| `edit_mode` | string | Mode : `replace`, `insert`, `delete` |

---

## Outils de tâches

### TodoRead

Lit la liste des tâches de la session courante.

---

### TodoWrite

Crée ou met à jour des tâches pour suivre le travail en cours.

**Paramètres :**
| Param | Type | Description |
|-------|------|-------------|
| `todos` | array | Liste des tâches à créer/modifier |

Chaque tâche contient `id`, `content`, `status` (pending/in_progress/completed).

---

## Outils MCP

### mcp__*

Les outils MCP sont fournis par des serveurs externes.

**Format du nom :** `mcp__<serveur>__<outil>`

**Exemples :**
```
mcp__memory__store        → Stocker en mémoire
mcp__github__create_issue → Créer une issue GitHub
mcp__slack__send_message  → Envoyer un message Slack
```

Ces outils sont détaillés dans le [Module 8 : MCP](../08-mcp/).

---

## Flux typique d'utilisation

```
Demande utilisateur : "Ajoute une validation email dans le formulaire"

1. Glob → Trouve les fichiers de formulaire
   pattern: "**/form*.{ts,tsx}"

2. Read → Lit le fichier trouvé
   file_path: "src/components/ContactForm.tsx"

3. Grep → Cherche les validations existantes
   pattern: "validate|yup|zod"

4. Edit → Ajoute la validation
   old_string: "const schema = z.object({"
   new_string: "const schema = z.object({\n  email: z.string().email(),"

5. Bash → Lance les tests
   command: "npm test ContactForm"
```

---

## Exercices

### Exercice 1 : Explorer un projet

1. Créez un projet avec quelques fichiers TypeScript
2. Demandez à Claude de lister tous les fichiers `.ts`
3. Observez quel outil il utilise

### Exercice 2 : Recherche ciblée

1. Demandez à Claude de trouver toutes les fonctions `async`
2. Observez la différence entre Glob et Grep

### Exercice 3 : Édition précise

1. Créez un fichier avec une faute de frappe intentionnelle
2. Demandez à Claude de la corriger
3. Observez comment Edit fonctionne

---

## Quiz

1. Quelle est la différence entre Glob et Grep ?
2. Pourquoi Claude doit-il lire un fichier avant de le Write ?
3. Quel outil utiliser pour exécuter `npm test` ?
4. Comment Task diffère-t-il de Bash ?

---

[← Module précédent](../01-introduction/) | [Module suivant : Configuration →](../03-configuration/)
