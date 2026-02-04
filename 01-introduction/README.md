# Module 1 : Introduction à Claude Code

## Objectifs

- Comprendre ce qu'est Claude Code et son positionnement
- Installer et configurer Claude Code
- Maîtriser les commandes de base
- Comprendre le flux de conversation

## Qu'est-ce que Claude Code ?

Claude Code est un **agent de programmation agentic** qui s'exécute dans votre terminal. Contrairement à un simple chatbot, Claude Code peut :

- Lire et écrire des fichiers
- Exécuter des commandes shell
- Naviguer dans votre codebase
- Effectuer des recherches web
- Orchestrer des sous-agents

```
┌─────────────────────────────────────────────────────┐
│                    Claude Code                       │
│                                                      │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌────────┐ │
│  │  Read   │  │  Write  │  │  Bash   │  │  Web   │ │
│  │  files  │  │  files  │  │ commands│  │ search │ │
│  └─────────┘  └─────────┘  └─────────┘  └────────┘ │
│                      │                              │
│                      ▼                              │
│              Votre codebase                         │
└─────────────────────────────────────────────────────┘
```

## Installation

### Prérequis

- Node.js 18+
- npm ou yarn
- Une clé API Anthropic

### Installation globale

```bash
npm install -g @anthropic-ai/claude-code
```

### Configuration de la clé API

```bash
# Option 1 : Variable d'environnement
export ANTHROPIC_API_KEY="sk-ant-..."

# Option 2 : Fichier de configuration
claude config set apiKey sk-ant-...
```

### Vérification

```bash
claude --version
```

## Premiers pas

### Lancer Claude Code

```bash
# Dans un projet existant
cd mon-projet
claude

# Ou avec une question directe
claude "Explique-moi la structure de ce projet"
```

### Interface de base

```
╭─────────────────────────────────────────────────────╮
│ claude                                              │
├─────────────────────────────────────────────────────┤
│ > Votre prompt ici...                               │
│                                                     │
│ Claude répond...                                    │
│                                                     │
│ [Enter] Envoyer  [Ctrl+C] Annuler  [/help] Aide    │
╰─────────────────────────────────────────────────────╯
```

### Commandes intégrées

| Commande | Description |
|----------|-------------|
| `/help` | Affiche l'aide |
| `/clear` | Efface la conversation |
| `/compact` | Compacte le contexte |
| `/exit` | Quitte Claude Code |
| `/config` | Affiche la configuration |

## Modes de permission

Claude Code demande votre autorisation avant certaines actions :

| Mode | Description |
|------|-------------|
| **default** | Demande permission pour actions sensibles |
| **plan** | Mode lecture seule, planification uniquement |
| **acceptEdits** | Auto-accepte les éditions de fichiers |
| **dontAsk** | Auto-accepte tout (à utiliser avec précaution) |

```bash
# Lancer en mode plan
claude --mode plan

# Lancer en mode auto-accept
claude --mode acceptEdits
```

## Anatomie d'une session

```
1. Démarrage
   └── SessionStart hooks s'exécutent
   └── Contexte projet chargé (CLAUDE.md)

2. Conversation
   └── Vous posez une question
   └── Claude analyse et planifie
   └── PreToolUse hooks vérifient
   └── Outils s'exécutent
   └── PostToolUse hooks valident
   └── Claude répond

3. Fin
   └── SessionEnd hooks s'exécutent
```

## Bonnes pratiques

### 1. Soyez précis dans vos demandes

```
❌ "Corrige le bug"
✅ "Il y a une erreur TypeError dans src/api/users.ts ligne 42.
    La fonction getUser retourne undefined au lieu d'un User."
```

### 2. Fournissez du contexte

```
❌ "Ajoute une fonction de login"
✅ "Ajoute une fonction de login dans src/auth/.
    On utilise JWT avec refresh tokens.
    Voir le pattern existant dans src/auth/register.ts"
```

### 3. Itérez par étapes

```
1. "Analyse la structure du projet"
2. "Propose un plan pour ajouter la feature X"
3. "Implémente l'étape 1 du plan"
4. "Écris les tests pour cette étape"
```

## Exercice pratique

1. Installez Claude Code si ce n'est pas déjà fait
2. Créez un nouveau dossier `training-sandbox`
3. Lancez Claude Code dedans
4. Demandez-lui de créer un fichier `hello.js` qui affiche "Hello, Claude Code!"
5. Demandez-lui d'exécuter le fichier

## Quiz

1. Quelle est la différence entre Claude Code et ChatGPT ?
2. Quels sont les 4 modes de permission ?
3. Comment effacer l'historique de conversation ?
4. Pourquoi est-il important d'être précis dans ses demandes ?

---

[Module suivant : Les outils natifs →](../02-native-tools/)
