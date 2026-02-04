# Module 6 : Les agents et subagents

## Objectifs

- Comprendre le concept d'agent dans Claude Code
- Utiliser les agents natifs efficacement
- Créer des agents personnalisés
- Orchestrer plusieurs agents

## Qu'est-ce qu'un agent ?

Un agent est une instance de Claude spécialisée pour une tâche. Il fonctionne de manière **autonome** avec son propre contexte.

```
┌─────────────────────────────────────────────────────┐
│                   Claude Principal                   │
│                                                      │
│  "J'ai besoin d'explorer le codebase"               │
│              │                                       │
│              ▼                                       │
│       ┌─────────────┐                               │
│       │    Task     │                               │
│       │   (outil)   │                               │
│       └──────┬──────┘                               │
│              │                                       │
│              ▼                                       │
│  ┌───────────────────────┐                          │
│  │   Agent "Explore"     │ ◄── Contexte isolé       │
│  │                       │                          │
│  │  - Glob               │                          │
│  │  - Grep               │                          │
│  │  - Read               │                          │
│  └───────────┬───────────┘                          │
│              │                                       │
│              ▼                                       │
│       Résultat retourné                             │
└─────────────────────────────────────────────────────┘
```

## Agents natifs

Claude Code fournit plusieurs agents intégrés :

| Agent | Usage | Outils disponibles |
|-------|-------|-------------------|
| `Bash` | Commandes shell | Bash uniquement |
| `Explore` | Explorer le codebase | Glob, Grep, Read |
| `Plan` | Planifier une implémentation | Tous sauf édition |
| `general-purpose` | Tâches complexes | Tous les outils |

### Utilisation

```
Task {
  prompt: "Explore comment l'authentification est implémentée",
  subagent_type: "Explore"
}
```

---

## L'outil Task

### Paramètres

| Param | Type | Description |
|-------|------|-------------|
| `prompt` | string | Instructions pour l'agent |
| `subagent_type` | string | Type d'agent |
| `model` | string | Modèle (optionnel) |
| `run_in_background` | boolean | Exécution en arrière-plan |

### Exemple : Exploration

```
Task {
  prompt: "Trouve tous les endpoints API et liste-les avec leur méthode HTTP",
  subagent_type: "Explore"
}
```

### Exemple : Planification

```
Task {
  prompt: "Conçois un plan pour ajouter l'authentification OAuth2",
  subagent_type: "Plan"
}
```

### Exemple : Exécution parallèle

```
// Lancer plusieurs agents en parallèle
Task { prompt: "Analyse la sécurité", subagent_type: "general-purpose" }
Task { prompt: "Analyse la performance", subagent_type: "general-purpose" }
```

---

## Créer des agents personnalisés

### Structure

```
agents/
└── mon-agent.md
```

### Format

```markdown
---
name: security-reviewer
description: Specialized agent for security code review
model: haiku
tools:
  - Read
  - Grep
  - Glob
---

# Security Reviewer Agent

## Role

You are a security specialist reviewing code for vulnerabilities.

## Focus Areas

1. **Injection vulnerabilities**
   - SQL injection
   - Command injection
   - XSS

2. **Authentication issues**
   - Weak passwords
   - Session management
   - Token handling

3. **Data exposure**
   - Sensitive data in logs
   - Hardcoded secrets
   - Insecure storage

## Output Format

```json
{
  "findings": [
    {
      "severity": "critical|high|medium|low",
      "type": "injection|auth|exposure|...",
      "file": "path/to/file",
      "line": 42,
      "description": "...",
      "recommendation": "..."
    }
  ],
  "summary": {
    "critical": 0,
    "high": 0,
    "medium": 0,
    "low": 0
  }
}
```
```

### Utilisation

```
Task {
  prompt: "Review les changements pour des failles de sécurité",
  subagent_type: "security-reviewer"
}
```

---

## Choix du modèle

| Modèle | Usage | Coût |
|--------|-------|------|
| `opus` | Tâches complexes, architecture | $$$ |
| `sonnet` | Usage général | $$ |
| `haiku` | Tâches simples, rapides | $ |

### Dans la définition

```markdown
---
name: quick-linter
model: haiku
---
```

### À l'invocation

```
Task {
  prompt: "...",
  subagent_type: "general-purpose",
  model: "haiku"
}
```

---

## Patterns d'orchestration

### Pattern : Architect + Coder

```
1. Task(architect) → Plan détaillé
2. Validation humaine
3. Task(coder) pour chaque étape → Implémentation
4. Task(reviewer) → Validation
```

```markdown
## Workflow

1. **Architect** (Opus)
   - Analyse les requirements
   - Conçoit l'architecture
   - Découpe en tâches

2. **Coder** (Sonnet)
   - Implémente chaque tâche
   - Écrit les tests

3. **Reviewer** (Haiku)
   - Vérifie la qualité
   - Valide les tests
```

### Pattern : Parallel Review

```
┌─────────────────────────────────────────┐
│            Code à reviewer               │
│                   │                      │
│     ┌─────────────┼─────────────┐       │
│     ▼             ▼             ▼       │
│ Security      Quality       Performance │
│ Reviewer      Checker       Analyzer    │
│     │             │             │       │
│     └─────────────┼─────────────┘       │
│                   ▼                      │
│           Rapport consolidé             │
└─────────────────────────────────────────┘
```

### Pattern : Background Agent

```
Task {
  prompt: "Surveille les logs et alerte en cas d'erreur",
  subagent_type: "log-watcher",
  run_in_background: true
}
```

---

## Hooks pour agents

### SubagentStart

Injecter du contexte au démarrage :

```bash
#!/usr/bin/env bash
# hooks/agent-context.sh

input=$(cat)
agent_type=$(echo "$input" | jq -r '.agent_type')

if [[ "$agent_type" == "security-reviewer" ]]; then
    jq -n '{
        "hookSpecificOutput": {
            "additionalContext": "Focus on OWASP Top 10 vulnerabilities."
        }
    }'
fi

exit 0
```

### SubagentStop

Valider le travail de l'agent :

```bash
#!/usr/bin/env bash
# hooks/agent-validate.sh

input=$(cat)
agent_type=$(echo "$input" | jq -r '.agent_type')

if [[ "$agent_type" == "coder" ]]; then
    # Vérifier que des tests ont été écrits
    if ! git diff --staged --name-only | grep -q "\.test\."; then
        jq -n '{
            "decision": "block",
            "reason": "L agent coder doit inclure des tests"
        }'
    fi
fi

exit 0
```

---

## Communication entre agents

Les agents ne communiquent pas directement. L'orchestration se fait via l'agent principal :

```
Principal
   │
   ├── Task(architect) → Plan
   │         │
   │         ▼
   │   Résultat stocké
   │         │
   ├── Task(coder, contexte=Plan) → Code
   │         │
   │         ▼
   │   Résultat stocké
   │         │
   └── Task(reviewer, contexte=Code) → Review
```

---

## Exercices

### Exercice 1 : Agent simple

Créez un agent `doc-generator` qui :
1. Lit les fichiers source
2. Extrait les fonctions publiques
3. Génère de la documentation

**Fichier** : `exercises/doc-generator.md`

### Exercice 2 : Orchestration

Créez un workflow qui utilise :
1. Un agent pour analyser un bug
2. Un agent pour proposer un fix
3. Un agent pour écrire le test

### Exercice 3 : Agent avec hook

1. Créez un agent `strict-coder`
2. Ajoutez un hook SubagentStop qui vérifie la présence de tests
3. Testez le workflow

---

## Quiz

1. Quelle est la différence entre un skill et un agent ?
2. Quel agent utiliser pour explorer un codebase ?
3. Comment faire tourner un agent en arrière-plan ?
4. Comment injecter du contexte dans un agent ?

---

[← Module précédent](../05-skills/) | [Module suivant : Les commandes →](../07-commands/)
