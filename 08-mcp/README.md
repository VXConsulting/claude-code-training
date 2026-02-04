# Module 8 : MCP - Model Context Protocol

## Objectifs

- Comprendre le protocole MCP
- Configurer des serveurs MCP
- Utiliser des outils MCP dans Claude Code
- Créer un serveur MCP simple

## Qu'est-ce que MCP ?

MCP (Model Context Protocol) est un **protocole ouvert** qui permet à Claude de communiquer avec des services externes.

```
┌─────────────────────────────────────────────────────┐
│                   Claude Code                        │
│                                                      │
│  Outils natifs    │    Outils MCP                   │
│  ─────────────    │    ──────────                   │
│  Read, Write...   │    mcp__github__*               │
│                   │    mcp__slack__*                │
│                   │    mcp__memory__*               │
│                   │                                 │
│                   ▼                                 │
│            ┌─────────────┐                          │
│            │  MCP Client │                          │
│            └──────┬──────┘                          │
│                   │                                 │
└───────────────────┼─────────────────────────────────┘
                    │ JSON-RPC
        ┌───────────┼───────────┐
        ▼           ▼           ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ GitHub  │ │  Slack  │ │ Memory  │
   │ Server  │ │ Server  │ │ Server  │
   └─────────┘ └─────────┘ └─────────┘
```

## Configuration

### Méthode recommandée : CLI

```bash
# Ajouter un serveur HTTP distant
claude mcp add --transport http <nom> <url>

# Ajouter un serveur stdio local
claude mcp add --transport stdio <nom> -- <commande> [args...]

# Avec variables d'environnement
claude mcp add --transport stdio --env API_KEY=xxx myserver -- npx server

# Lister les serveurs
claude mcp list

# Supprimer un serveur
claude mcp remove <nom>
```

### Scopes

| Scope | Stockage | Disponibilité |
|-------|----------|---------------|
| `local` | `~/.claude.json` (défaut) | Projet courant, privé |
| `project` | `.mcp.json` à la racine | Partagé via git |
| `user` | `~/.claude.json` | Tous vos projets |

```bash
# Ajouter au scope projet (partagé)
claude mcp add --scope project --transport http api https://api.example.com/mcp

# Ajouter au scope user (personnel, tous projets)
claude mcp add --scope user --transport http myapi https://myapi.com/mcp
```

### Format JSON

Vous pouvez aussi configurer manuellement dans les fichiers de settings :

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"]
    }
  }
}
```

### Authentification OAuth

Pour les serveurs distants nécessitant OAuth :

1. Ajoutez le serveur : `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp`
2. Dans Claude Code, tapez `/mcp`
3. Suivez le flow d'authentification dans le navigateur

---

## Serveurs MCP populaires

### GitHub

```json
{
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_TOKEN": "${GITHUB_TOKEN}"
    }
  }
}
```

**Outils disponibles :**
- `mcp__github__create_issue`
- `mcp__github__list_issues`
- `mcp__github__create_pull_request`
- `mcp__github__get_file_contents`

### Memory

```json
{
  "memory": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"]
  }
}
```

**Outils disponibles :**
- `mcp__memory__store`
- `mcp__memory__retrieve`
- `mcp__memory__list`

### Filesystem

```json
{
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/allowed/path"]
  }
}
```

**Outils disponibles :**
- `mcp__filesystem__read_file`
- `mcp__filesystem__write_file`
- `mcp__filesystem__list_directory`

### Slack

```json
{
  "slack": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-slack"],
    "env": {
      "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}"
    }
  }
}
```

### PostgreSQL

```json
{
  "postgres": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-postgres"],
    "env": {
      "DATABASE_URL": "${DATABASE_URL}"
    }
  }
}
```

---

## Utilisation dans Claude Code

### Nommage des outils

Format : `mcp__<serveur>__<outil>`

Exemples :
```
mcp__github__create_issue
mcp__memory__store
mcp__slack__send_message
```

### Exemple d'utilisation

```
Claude : "Je vais créer une issue GitHub pour ce bug"

→ mcp__github__create_issue {
    "repo": "owner/repo",
    "title": "Bug: Login fails on mobile",
    "body": "Description...",
    "labels": ["bug", "mobile"]
  }
```

---

## Ressources MCP

Les serveurs MCP peuvent exposer des **ressources** accessibles via `@` :

```
> Analyse @github:issue://123 et suggère un fix
> Compare @postgres:schema://users avec la doc
```

Tapez `@` pour voir les ressources disponibles de tous les serveurs connectés.

---

## Prompts MCP

Les serveurs peuvent exposer des **prompts** qui deviennent des commandes :

```
> /mcp__github__list_prs
> /mcp__jira__create_issue "Bug title" high
```

Format : `/mcp__<serveur>__<prompt>`

---

## Hooks pour MCP

### Intercepter les outils MCP

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__github__.*",
        "hooks": [
          {
            "type": "command",
            "command": "./hooks/github-guard.sh"
          }
        ]
      }
    ]
  }
}
```

### Exemple : Valider les issues

```bash
#!/usr/bin/env bash
# hooks/github-guard.sh

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

# Bloquer la création d'issues sans labels
if [[ "$tool_name" == "mcp__github__create_issue" ]]; then
    labels=$(echo "$input" | jq -r '.tool_input.labels // empty')

    if [[ -z "$labels" || "$labels" == "null" ]]; then
        jq -n '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": "Les issues doivent avoir au moins un label"
            }
        }'
        exit 0
    fi
fi

exit 0
```

---

## Créer un serveur MCP

### Structure minimale

```
mon-serveur-mcp/
├── package.json
├── src/
│   └── index.ts
└── tsconfig.json
```

### package.json

```json
{
  "name": "my-mcp-server",
  "version": "1.0.0",
  "type": "module",
  "main": "dist/index.js",
  "bin": {
    "my-mcp-server": "dist/index.js"
  },
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
```

### src/index.ts

```typescript
#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server(
  {
    name: 'my-mcp-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Définir un outil
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'greet',
      description: 'Greet someone by name',
      inputSchema: {
        type: 'object',
        properties: {
          name: {
            type: 'string',
            description: 'Name to greet',
          },
        },
        required: ['name'],
      },
    },
  ],
}));

// Implémenter l'outil
server.setRequestHandler('tools/call', async (request) => {
  if (request.params.name === 'greet') {
    const name = request.params.arguments?.name;
    return {
      content: [
        {
          type: 'text',
          text: `Hello, ${name}!`,
        },
      ],
    };
  }
  throw new Error('Unknown tool');
});

// Démarrer le serveur
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Configuration

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/path/to/my-mcp-server/dist/index.js"]
    }
  }
}
```

---

## Bonnes pratiques

### 1. Sécuriser les tokens

```json
{
  "env": {
    "GITHUB_TOKEN": "${GITHUB_TOKEN}"
  }
}
```

Ne jamais hardcoder les tokens dans la configuration.

### 2. Limiter les permissions

```json
{
  "filesystem": {
    "args": ["server-filesystem", "/specific/allowed/path"]
  }
}
```

### 3. Valider avec des hooks

```bash
# Toujours valider les opérations sensibles
"matcher": "mcp__.*__delete.*|mcp__.*__write.*"
```

### 4. Documenter les outils disponibles

Créez un fichier listant les outils MCP configurés :

```markdown
## MCP Tools Available

### GitHub
- `create_issue` - Create GitHub issue
- `list_issues` - List issues

### Memory
- `store` - Store key-value
- `retrieve` - Retrieve value
```

---

## Exercices

### Exercice 1 : Configurer GitHub MCP

1. Obtenez un token GitHub
2. Configurez le serveur MCP GitHub
3. Testez la création d'une issue

### Exercice 2 : Serveur MCP simple

Créez un serveur MCP qui :
1. Expose un outil `timestamp` qui retourne la date/heure
2. Expose un outil `random` qui retourne un nombre aléatoire

### Exercice 3 : Hook de validation

Créez un hook qui :
1. Intercepte `mcp__github__create_pull_request`
2. Vérifie que le titre commence par un type (feat:, fix:, etc.)
3. Bloque si le format est incorrect

---

## Quiz

1. Quel est le format de nommage des outils MCP ?
2. Comment sécuriser un token dans la config MCP ?
3. Quelle est la différence entre les outils natifs et MCP ?
4. Comment créer un serveur MCP minimal ?

---

[← Module précédent](../07-commands/) | [Module suivant : Projet pratique →](../09-project/)
