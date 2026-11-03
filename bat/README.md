# Bat

Paquet Stow contenant `.config/bat/config`, destiné à `~/.config/bat/config`.
Il complète l'alias Zsh `cat='bat'` et l'aperçu Ctrl+T de fzf déjà préparés.

## Présentation préparée

- Thème intégré `ansi` : reprend les couleurs du terminal, donc sa palette
  Catppuccin lorsque Ghostty l'utilise. Le rendu dépend du terminal choisi.
- En-tête du fichier, numéros de ligne et marques de changements Git, sans grille.
- Pagination automatique ; `q` permet de quitter le pager habituel `less`.
- Couleurs et décorations automatiques, adaptées notamment aux sorties redirigées.

Les options explicites d'une commande peuvent remplacer ces réglages. L'aperçu
fzf conserve ainsi son style avec numéros de ligne, ses couleurs forcées et
sa pagination désactivée. L'alias `cat` peut ouvrir un pager pour un long fichier ;
utiliser `command cat` pour appeler la commande système, ou
`bat --paging=never` pour lire avec Bat sans pagination.

## Appliquer la configuration avec les scripts

Préparer manuellement Bat, Stow et `cksum` sur la machine cible. Vérifier le
chemin de configuration utilisé si `BAT_CONFIG_PATH` ou `XDG_CONFIG_HOME` est
personnalisé : ce paquet cible uniquement `~/.config/bat/config`.

Depuis la racine du clone, lorsque les essais seront possibles :

```bash
bash scripts/stow_setup.sh --dry-run --packages bat
```

Après validation dans un macOS jetable et relecture, remplacer `--dry-run` par
`--apply`, manuellement sur la machine cible. Le script sauvegarde le fichier
ordinaire existant, écrit son journal et crée le lien. Il n'installe ni ne
lance Bat. Le parcours `terminal_setup.sh` conserve ses quatre paquets actuels ;
sélectionner `bat` séparément pour ajouter sa configuration.

Une future commande de diagnostic ciblée est également disponible :

```bash
bash scripts/verifier-depot.sh --dry-run --sans-shellcheck --package bat
```

Elle inventorie les prérequis sans lancer Bat et ne valide pas son format de
configuration. Aucun de ces parcours n'a été exécuté pour préparer cet ajout.

## Thème Catppuccin dédié, facultatif

Le thème `ansi` fonctionne sans thème externe. Pour une coloration dédiée
Macchiato, suivre manuellement les instructions du
[projet Catppuccin pour Bat](https://github.com/catppuccin/bat) sur la machine
cible : conserver les fichiers existants, préparer le thème dans le dossier
de thèmes de Bat, puis reconstruire son cache selon ces instructions.
La commande `bat cache --build` écrit dans le cache ; elle n'est exécutée par
aucun script de ce dépôt. Choisir ensuite un thème réellement disponible, par
exemple `--theme="Catppuccin Macchiato"`, en remplaçant l'unique option active
`--theme` du fichier source. Ne pas activer deux lignes de thème simultanément.

Le thème externe et son cache ne sont pas fournis ni gérés par Stow. Leur
compatibilité et leur rendu restent à vérifier sur la machine cible.

## Pages man colorées, facultatif

Le modèle [Zsh local](../config/zshrc-local.example.zsh) contient un bloc
commenté pour `MANPAGER`, à reprendre manuellement dans `~/.zshrc.local` si
souhaité. Il requiert Bat et `col`, utilise une présentation sans en-tête ni
numéros, et prépare une pagination adaptée aux pages longues. Il ne requiert
pas `zsh-bat`. Examiner et conserver toute valeur personnelle de `MANPAGER`
avant de l'activer ; aucun réglage global du pager n'est imposé ici.

Pour désactiver cette option, retirer le bloc personnel ou rétablir l'ancienne
valeur, puis ouvrir un nouveau terminal. Sa compatibilité avec les pages man
du macOS cible n'a pas été testée.

## Retour arrière

Préparer l'annulation avec le journal exact affiché pendant l'application :

```bash
bash scripts/annuler-deploiement.sh --dry-run --journal .deployments/IDENTIFIANT.tsv
```

Suivre [le guide de retour arrière](../docs/retour-arriere.md) avant toute
application réelle. Le retrait du paquet ne désinstalle pas Bat et ne change
pas les préférences personnelles de `MANPAGER` ni un éventuel cache de thèmes.

Autre voie manuelle, sans sauvegarde, journal ni protections des scripts :

```bash
stow --target="$HOME" --restow --no-folding bat
```

Le retrait manuel `stow --target="$HOME" --delete bat` ne restaure pas à lui
seul le fichier antérieur.

Cette configuration est préparée **sans analyse, test ni validation visuelle**.
Voir [la première utilisation](../docs/premiere-utilisation.md),
[la compatibilité](../docs/compatibilite.md) et
[la documentation Bat](https://github.com/sharkdp/bat#customization).
