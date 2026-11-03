# Starship — Catppuccin Mocha

Configuration [Starship](https://starship.rs) basée sur le thème Catppuccin Mocha officiel.

## Contenu

- `.config/starship.toml` : configuration principale, destinée à `~/.config/starship.toml`.
- `.config/starship-latte.toml` : variante claire, destinée à `~/.config/starship-latte.toml`.

## Détails

- Palette `catppuccin_mocha` avec les couleurs officielles Catppuccin.
- Invite sur deux lignes, avec un espace visuel entre deux commandes.
- Première ligne : dossier, branche et état Git, langages détectés, durée utile.
- Deuxième ligne : code d'échec éventuel puis symbole de saisie.
- Le symbole du prompt utilise une icône Nerd Font, fournie par `font-jetbrains-mono-nerd-font`.

## Lire l'invite

Mocha est la variante sombre commune à Ghostty, Starship et Lazygit. Pour
choisir Latte dans Zsh, définir `DOTFILES_APPARENCE=clair` dans le fichier
personnel amont `~/.zshrc.local.pre`. Le choix est explicite et ne suit pas
automatiquement les changements macOS. Une valeur personnelle de
`STARSHIP_CONFIG`, même héritée d'un autre shell, reste prioritaire.
Le [guide d'organisation](../docs/organisation-configuration.md#apparence-commune-et-préférences-ghostty)
explique le choix et ses limites. Les deux variantes partagent la même structure ;
reporter les changements de modules dans les deux fichiers lors d'une personnalisation.

Exemple illustratif, pas une capture du rendu :

```text
~/Projets/exemple  main ~2?1 Node vXX.Y.Z durée 3s
󰄛 ❯
```

| Indication | Sens |
| --- | --- |
| `~2`, `+1`, `?1` | Fichiers modifiés, changements indexés, fichiers non suivis |
| `!`, `*`, `-`, `»` suivis d'un nombre | Conflits, entrées de stash, suppressions, renommages |
| `↑` / `↓` | Avance / retard par rapport à la branche de suivi connue localement |
| `durée …` | Affichée à partir du seuil de 2 secondes |
| `code …` et symbole rouge | Échec rapporté par le shell pour la commande précédente |

L'état Git repose sur les informations locales, sans fetch automatique.
Node.js, Python et Swift gardent leur détection native de projet ; un
environnement Python actif peut aussi apparaître. Les modules utilisateur et
machine conservent leur affichage conditionnel natif, notamment en SSH.

Les autres modules Starship sont exclus du format explicite. Pour ajouter un
langage, ajouter son module dans `format` puis ses réglages éventuels.

## État de préparation

Cette personnalisation n'a fait l'objet d'aucun contrôle TOML, lancement de
Starship ni essai visuel, conformément au report des vérifications. Les modules
peuvent interroger les outils locaux lors de l'utilisation future de l'invite.
Aucun outil n'a été installé ni lancé pour appliquer cette configuration.
La version compatible reste à établir dans [la matrice](../docs/compatibilite.md).

Pour retrouver l'ancienne composition, conserver la palette, les styles du
dossier et de la branche, retirer le `format` global et les blocs ajoutés,
puis rétablir l'ancien `error_symbol` si souhaité. Avant une modification sur
la machine cible, conserver une copie datée de la configuration en cours.

## Appliquer la configuration avec les scripts

Depuis la racine du dépôt, commencer par une simulation :

```bash
bash scripts/stow_setup.sh --dry-run --packages starship
```

Ce parcours sélectionne uniquement ce paquet. L'application doit être préparée
manuellement pour utiliser sa configuration.
Après validation dans un macOS jetable et relecture du résultat, remplacer
`--dry-run` par `--apply`, manuellement sur la machine cible. Le script
sauvegarde les fichiers existants, enregistre un journal local et crée les
liens ; il n'installe ni ne lance l'application.

Voir [la première utilisation](../docs/premiere-utilisation.md) et
[les prérequis des scripts](../scripts/README.md#prérequis-à-préparer-manuellement).
Pour préparer une annulation, utiliser le journal exact affiché :

```bash
bash scripts/annuler-deploiement.sh --dry-run --journal .deployments/IDENTIFIANT.tsv
```

Suivre [le guide de retour arrière](../docs/retour-arriere.md) avant toute
annulation réelle. Le comportement applicatif reste à valider sur la machine cible.

## Autre voie : Stow manuel

Ces commandes sont à lancer soi-même sur la machine cible. Elles n'utilisent
ni les sauvegardes automatiques, ni le journal, ni les protections des scripts.
Examiner les fichiers et les options Stow personnels avant de les employer.

```bash
stow --target="$HOME" --restow --no-folding starship
```

Pour retirer uniquement les liens du paquet :

```bash
stow --target="$HOME" --delete starship
```

Ce retrait ne restaure pas les anciennes configurations ; voir
[le retour arrière manuel](../docs/retour-arriere.md#annulation-manuelle-sans-journal).

## Personnalisation

Modifier `starship/.config/starship.toml` dans le dépôt, puis recharger le shell
manuellement sur la machine cible, après relecture de sa configuration :

```bash
source ~/.zshrc
```

## Source

- Thème : https://github.com/catppuccin/starship
- Documentation Starship : https://starship.rs/config/
