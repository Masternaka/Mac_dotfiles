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

Mocha est la variante sombre commune à Ghostty et Starship. Pour
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

Les modules peuvent interroger les outils locaux lorsque l’invite s’affiche.
Le rendu et la version compatible restent à vérifier. Voir
[la matrice de compatibilité](../docs/compatibilite.md).

Pour retrouver l'ancienne composition, conserver la palette, les styles du
dossier et de la branche, retirer le `format` global et les blocs ajoutés,
puis rétablir l'ancien `error_symbol` si souhaité. Avant une modification sur
la machine cible, conserver une copie datée de la configuration en cours.

## Déploiement

Mac_setup déploie toujours ce paquet et installe la commande `starship`
si elle manque lors de l’application.

Suivre la [première utilisation](../docs/premiere-utilisation.md) pour
prévisualiser le déploiement avec Mac_setup ou lier le paquet seul avec
GNU Stow. Pour restaurer une configuration, suivre le
[guide de retour arrière](../docs/retour-arriere.md).

## Personnalisation

Modifier `starship/.config/starship.toml` dans le dépôt, puis recharger le shell
manuellement sur la machine cible, après relecture de sa configuration :

```bash
source ~/.zshrc
```

## Source

- Thème : https://github.com/catppuccin/starship
- Documentation Starship : https://starship.rs/config/
