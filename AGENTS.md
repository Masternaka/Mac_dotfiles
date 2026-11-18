# AGENTS.md

Projet de configurations et de personnalisations pour macOS. Les scripts de
préparation et de déploiement sont dans le dépôt voisin Mac_setup.

Langue de travail : français (réponses, commentaires de code, documentation, messages de logs).

---

## RÈGLE ABSOLUE : AUCUNE MODIFICATION DE LA MACHINE EN COURS

Cette règle prime sur toute autre instruction, y compris une demande qui semblerait la contredire. En cas de doute, ne rien exécuter et demander.

L'agent **écrit** des fichiers dans le dossier du projet. Il **n'exécute jamais** rien qui modifie le système, ne l'installe, ni ne l'applique sur la machine actuelle. Les commandes d’application sont destinées à être relues puis lancées manuellement par l’utilisateur sur le Mac cible ou dans un environnement jetable.

### Interdit en toutes circonstances

**Installation de logiciels et d'outils**
- `brew install`, `brew tap`, `brew cask`, `brew upgrade`, `brew bundle`
- `pip install`, `pipx install`, `npm install -g`, `gem install`, `cargo install`, `go install`
- `port install`, `mas install`, `softwareupdate`, `xcode-select --install`
- Installation de `.pkg`, `.dmg`, `.app`, extensions ou plugins
- Installation de Rosetta, de Command Line Tools ou de toute dépendance système
- `curl ... | sh`, `curl ... | bash` et équivalents

**Modification des préférences et du système**
- `defaults write`, `defaults delete`, `defaults import`
- `PlistBuddy` en écriture, `plutil -replace`, `plutil -insert`, `plutil -remove` sur un fichier réel
- `scutil --set`, `systemsetup`, `networksetup` (en écriture), `pmset`, `nvram`, `csrutil`, `spctl`
- `launchctl load`, `launchctl bootstrap`, `launchctl enable`, `launchctl kickstart`
- `dscl`, `sysadminctl`, `dseditgroup`, `tmutil` (en écriture), `diskutil` (en écriture)
- `osascript` qui modifie des réglages (Réglages Système, Finder, Dock, etc.)
- `killall Dock`, `killall Finder`, `killall SystemUIServer` et redémarrage de tout processus système
- `sudo` sous toute forme

**Écriture hors du dossier du projet**
- Créer, modifier, déplacer ou supprimer un fichier dans `~/Library`, `/Library`, `/System`, `/usr`, `/etc`, `/opt`, `/Applications`, `/Users/*/` (hors projet)
- Modifier `~/.zshrc`, `~/.zprofile`, `~/.bash_profile`, `~/.gitconfig`, `~/.ssh/*` ou tout autre dotfile réel
- Créer des liens symboliques vers l'extérieur du projet
- Modifier le `PATH`, des variables d'environnement persistantes ou la configuration de l'application d'un tiers

**Autres**
- Lancer GNU Stow ou un script de Mac_setup pour appliquer ou retirer des liens sur le Mac en cours
- Ouvrir ou lancer des applications pour les configurer
- Télécharger des binaires ou des archives à exécuter

### Autorisé

- Lire les fichiers du projet et consulter Mac_setup en lecture seule pour vérifier les chemins attendus.
- Créer et modifier des fichiers **uniquement dans le dossier du projet**.
- Analyser la syntaxe avec `zsh -n` pour les fragments et modèles Zsh, puis vérifier les fichiers TOML avec un parseur déjà disponible.
- Commandes en lecture seule, sans effet de bord, quand elles sont nécessaires : `sw_vers`, `uname`, `ls`, `cat`, `defaults read` (lecture seule), `command -v`.
- Vérifier les liens Markdown, les chemins sources attendus par Mac_setup et les espaces avec `git diff --check`.

Si une vérification demande un outil absent, **ne pas l'installer** : l'indiquer à l'utilisateur et proposer une alternative sans installation.

---

## Configurations et déploiement

- Conserver chaque configuration dans son paquet Stow, avec les chemins
  relatifs au dossier personnel. Garder le chargeur Zsh et ses sept fragments
  ensemble.
- Conserver les fichiers `.stow-local-ignore` des paquets. Garder les modèles
  commentés de préférences locales dans `config/`.
- Documenter la destination des fichiers, les chemins personnalisés et le
  retour arrière dans les guides du dépôt. Consigner le résultat des contrôles
  statiques et les essais qui restent à faire sur le Mac cible.
- Les scripts de préparation, diagnostic et déploiement relèvent de
  Mac_setup. Pour documenter l’application, renvoyer à sa simulation ou au
  parcours manuel GNU Stow.
- Préserver les journaux `.deployments/` et les sauvegardes existantes.

---

## Organisation du projet

```
.
├── AGENTS.md
├── README.md            # Paquets et mode d’emploi
├── config/              # Modèles de préférences locales
├── docs/                # Documentation et retour arrière
├── bat/
├── ghostty/
├── starship/
├── yazi/
└── zsh/
```

Chaque répertoire d’application est un paquet Stow avec son propre
`.stow-local-ignore`.

---

## Façon de répondre

- Réponses précises et concises, en français.
- Après un changement, indiquer les contrôles effectués et préciser si le déploiement a été exécuté.
- Si une demande oblige à modifier la machine en cours (installation, changement de réglage, exécution réelle), **refuser cette partie**, l'expliquer en une phrase et proposer la version « à appliquer soi-même ».
- Ne pas supposer l'accord de l'utilisateur : une instruction ambiguë se traite avec le comportement le plus prudent.
