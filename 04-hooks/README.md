# Module 4 : Les hooks

## Objectifs

- Comprendre le système de hooks de Claude Code
- Créer des hooks pour valider, bloquer ou enrichir
- Maîtriser les différents événements
- Tester et debugger vos hooks

## Qu'est-ce qu'un hook ?

Un hook est un script qui s'exécute à des moments clés de Claude Code :

```
┌─────────────────────────────────────────────────────┐
│                   Claude Code                        │
│                                                      │
│  SessionStart ──► UserPromptSubmit                   │
│                          │                           │
│                          ▼                           │
│                   ┌─────────────┐                    │
│                   │   Claude    │                    │
│                   └──────┬──────┘                    │
│                          │                           │
│                    PreToolUse ◄── Peut bloquer       │
│                          │                           │
│                   [Exécution]                        │
│                          │                           │
│              ┌───────────┴───────────┐               │
│              ▼                       ▼               │
│        PostToolUse           PostToolUseFailure      │
│                                                      │
│                       Stop                           │
│                        │                             │
│                   SessionEnd                         │
└─────────────────────────────────────────────────────┘
```

## Configuration

Les hooks sont déclarés dans `.claude/settings.json` :

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "./hooks/check-command.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "./hooks/validate-syntax.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "./hooks/inject-context.sh"
          }
        ]
      }
    ]
  }
}
```

**Note :** Chaque hook a maintenant un tableau `hooks` contenant des objets avec `type` et `command`.
```

## Le champ matcher

Le matcher est une **expression régulière** :

| Pattern | Correspond à |
|---------|--------------|
| `"Bash"` | Outil Bash uniquement |
| `"Edit\|Write"` | Edit OU Write |
| `"mcp__.*"` | Tous les outils MCP |
| Absent | Tous les événements |

---

## Les événements

### Vue d'ensemble

| Événement | Déclencheur | Peut bloquer |
|-----------|-------------|--------------|
| `SessionStart` | Démarrage session | Non |
| `SessionEnd` | Fin session | Non |
| `UserPromptSubmit` | Prompt soumis | Oui |
| `PreToolUse` | Avant outil | Oui |
| `PermissionRequest` | Dialogue de permission affiché | Oui |
| `PostToolUse` | Après outil (succès) | Non* |
| `PostToolUseFailure` | Après outil (échec) | Non |
| `SubagentStart` | Lancement sous-agent | Non |
| `SubagentStop` | Fin sous-agent | Oui |
| `Stop` | Claude termine | Oui |
| `PreCompact` | Avant compaction | Non |
| `Notification` | Notification envoyée | Non |

*PostToolUse peut fournir du feedback à Claude mais ne bloque pas l'action (déjà exécutée).

---

### SessionStart

**Quand** : Au démarrage de la session
**Matchers** : `startup`, `resume`, `clear`, `compact`

```bash
#!/usr/bin/env bash
# hooks/session-start.sh

input=$(cat)
source=$(echo "$input" | jq -r '.source')

if [[ "$source" == "startup" ]]; then
    # Injecter du contexte au démarrage
    context="Rappel: Toujours écrire les tests avant le code."

    jq -n --arg ctx "$context" '{
        "additionalContext": $ctx
    }'
fi

exit 0
```

---

### PreToolUse

**Quand** : Avant l'exécution d'un outil
**Matchers** : Noms d'outils (`Bash`, `Edit`, `Write`, etc.)

**Entrée** :
```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /tmp/test"
  },
  "session_id": "abc123"
}
```

**Sorties possibles** :

```bash
# Bloquer (deny)
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Commande dangereuse"
  }
}'

# Autoriser (allow)
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow"
  }
}'

# Demander confirmation (ask)
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "Êtes-vous sûr ?"
  }
}'

# Modifier les paramètres avant exécution
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "updatedInput": {
      "command": "rm -rf /tmp/test --interactive"
    }
  }
}'
```

**Important :** `hookSpecificOutput` doit inclure `hookEventName: "PreToolUse"`.
Les valeurs de `permissionDecision` sont : `allow`, `deny`, `ask`.

---

### PermissionRequest

**Quand** : Quand un dialogue de permission est affiché à l'utilisateur
**Matchers** : Noms d'outils (comme PreToolUse)

**Entrée** :
```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf node_modules"
  },
  "permission_suggestions": [
    { "type": "toolAlwaysAllow", "tool": "Bash" }
  ]
}
```

**Sortie pour autoriser** :
```bash
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow"
    }
  }
}'
```

**Sortie pour refuser** :
```bash
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "deny",
      "message": "Cette opération n est pas autorisée"
    }
  }
}'
```

---

### PostToolUse

**Quand** : Après exécution réussie d'un outil
**Matchers** : Noms d'outils

**Entrée** :
```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/home/user/test.json",
    "content": "{\"key\": \"value\"}"
  },
  "tool_response": "File written successfully"
}
```

**Sortie pour bloquer** :
```bash
jq -n '{
  "decision": "block",
  "reason": "Le JSON écrit est invalide"
}'
```

**Sortie pour informer** :
```bash
jq -n '{
  "additionalContext": "Note: fichier créé avec succès"
}'
```

---

### Stop

**Quand** : Claude termine sa réponse
**Important** : Vérifier `stop_hook_active` pour éviter les boucles infinies !

```bash
#!/usr/bin/env bash
# hooks/verify-complete.sh

input=$(cat)
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active')

# IMPORTANT: éviter la boucle infinie
if [[ "$stop_hook_active" == "true" ]]; then
    exit 0
fi

# Vérifier que les tests passent
if ! npm test --silent 2>/dev/null; then
    jq -n '{
        "decision": "block",
        "reason": "Les tests échouent. Veuillez corriger avant de terminer."
    }'
    exit 0
fi

exit 0
```

---

## Exemples pratiques

### Bloquer les commandes dangereuses

```bash
#!/usr/bin/env bash
# hooks/dangerous-commands.sh

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

if [[ "$tool_name" != "Bash" ]]; then
    exit 0
fi

command=$(echo "$input" | jq -r '.tool_input.command')

# Patterns dangereux
dangerous=(
    "rm -rf /"
    "rm -rf ~"
    "mkfs"
    ":(){:|:&};:"
    "dd if=/dev/zero"
    "chmod -R 777 /"
)

for pattern in "${dangerous[@]}"; do
    if [[ "$command" == *"$pattern"* ]]; then
        jq -n --arg cmd "$pattern" '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": ("Commande dangereuse bloquée: " + $cmd)
            }
        }'
        exit 0
    fi
done

exit 0
```

---

### Bloquer les secrets

```bash
#!/usr/bin/env bash
# hooks/no-secrets.sh

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

if [[ "$tool_name" != "Write" && "$tool_name" != "Edit" ]]; then
    exit 0
fi

content=$(echo "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')

# Patterns de secrets
patterns=(
    'AKIA[0-9A-Z]{16}'           # AWS Key
    'sk-[a-zA-Z0-9]{48}'         # OpenAI Key
    'ghp_[a-zA-Z0-9]{36}'        # GitHub Token
)

for pattern in "${patterns[@]}"; do
    if echo "$content" | grep -qE "$pattern"; then
        jq -n '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": "Secret détecté ! Utilisez des variables d environnement."
            }
        }'
        exit 0
    fi
done

exit 0
```

---

### Valider la syntaxe

```bash
#!/usr/bin/env bash
# hooks/syntax-validation.sh

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

if [[ "$tool_name" != "Write" && "$tool_name" != "Edit" ]]; then
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path')
extension="${file_path##*.}"

case "$extension" in
    json)
        if ! jq empty "$file_path" 2>/dev/null; then
            jq -n '{
                "decision": "block",
                "reason": "Syntaxe JSON invalide"
            }'
        fi
        ;;
    sh|bash)
        if ! bash -n "$file_path" 2>/dev/null; then
            jq -n '{
                "decision": "block",
                "reason": "Syntaxe shell invalide"
            }'
        fi
        ;;
esac

exit 0
```

---

## Codes de sortie

| Code | Signification |
|------|---------------|
| `0` | Succès - stdout JSON parsé |
| `2` | Erreur bloquante - stderr affiché |
| Autre | Erreur non-bloquante - loggé en verbose |

---

## Debugging

### Test manuel

```bash
# Simuler un appel PreToolUse
echo '{
  "tool_name": "Bash",
  "tool_input": {"command": "rm -rf /"},
  "session_id": "test"
}' | bash hooks/dangerous-commands.sh

# Vérifier le code de sortie
echo $?
```

### Mode verbose

```bash
export CLAUDE_DEBUG=1
claude
```

### Logs dans le hook

```bash
# Écrire sur stderr (ne perturbe pas le JSON)
echo "DEBUG: tool_name=$tool_name" >&2
```

---

## Exercices

### Exercice 1 : Hook basique

Créez un hook qui bloque `git push --force`.

**Fichier** : `exercises/block-force-push.sh`

### Exercice 2 : Validation de fichier

Créez un hook PostToolUse qui vérifie que les fichiers `.env` ne sont jamais créés.

**Fichier** : `exercises/no-env-files.sh`

### Exercice 3 : Injection de contexte

Créez un hook SessionStart qui injecte la date du jour dans le contexte.

**Fichier** : `exercises/inject-date.sh`

---

## Quiz

1. Quelle est la différence entre PreToolUse et PostToolUse ?
2. Comment éviter une boucle infinie dans un hook Stop ?
3. Quel code de sortie indique une erreur bloquante ?
4. Comment un hook peut-il modifier les paramètres d'un outil ?

---

[← Module précédent](../03-configuration/) | [Module suivant : Les skills →](../05-skills/)
