# Organisation des configurations

Cette évolution est préparée dans le dépôt, sans exécution, analyse syntaxique,
ShellCheck ni essai visuel. Elle remplace certaines descriptions antérieures
des prérequis : les règles actuelles sont résumées ci-dessous.

## Catalogue commun des paquets

`config/paquets.tsv` est lu comme des données par les scripts ; il n'est jamais
sourcé ni évalué. Chaque ligne contient huit champs séparés par une tabulation :
nom, libellé, commandes requises, commandes facultatives, groupe, format,
source principale relative au paquet et exigence des commandes dans le menu.
`-` indique une liste ou un groupe vide. Les commandes sont séparées par des
espaces. Un nom de commande ne peut pas être une commande shell composée.

Le menu présente les paquets du catalogue. Le diagnostic s'en sert pour les
formats, les sources principales et les dépendances. Les parcours regroupés
utilisent les mêmes listes. Ajouter un dossier ne suffit donc plus pour le
faire apparaître : il faut une ligne de catalogue correspondante.

La source principale peut être un dossier : le diagnostic TOML prévoit alors
de lire les TOML qu'il contient. Le déploiement continue d'examiner l'ensemble
du paquet avec ses protections, indépendamment de cette source principale.
Les chemins, formats et groupes non pris en charge sont refusés. Aucun champ
ne déclenche une installation.

## Parcours partiels et prérequis

Le menu Stow conserve son rôle de liaison : il exige Stow et `cksum`, puis les
commandes applicatives lorsque le catalogue l'impose (`bat`, `lazygit` et
`delta` actuellement). Pour les autres paquets, une application absente est
signalée sans empêcher la liaison seule.

Le parcours terminal conserve par défaut Ghostty, Herdr, Starship et Zsh. Il
permet désormais de choisir un sous-ensemble explicite, par exemple :

```bash
bash scripts/terminal_setup.sh --dry-run --packages ghostty,zsh
```

Seuls les paquets du groupe terminal sont acceptés. Herdr n'est donc pas imposé
pour cette sélection. Les commandes des applications choisies sont requises ;
Neovim, fzf, Zoxide, Eza, Bat et les plugins Zsh sont des compléments. Leur
absence est annoncée et les fonctions correspondantes restent omises par Zsh.

Yazi exige sa commande, Stow et `cksum`. Ses outils de prévisualisation et de
recherche sont complémentaires : leur absence limite les fonctions concernées.
Pour exiger tous les compléments du parcours et retrouver cette politique :

```bash
bash scripts/terminal_setup.sh --dry-run --strict
bash scripts/yazi_setup.sh --dry-run --strict
```

Les ajouts `zsh-completions` et `fzf-tab` restent facultatifs même avec `--strict`.
La simulation reste le mode par défaut. Ces exemples n'ont pas été exécutés.

## Ordre de chargement Zsh

Le paquet doit être déployé en entier : `.zshrc` devient un chargeur des
fragments de `~/.config/zsh/`. Un fragment absent arrête ce chargement avec un
message plutôt que laisser croire à une configuration complète.

| Ordre | Contenu |
| --- | --- |
| `~/.zshrc.local.pre`, facultatif | Variables personnelles avant les valeurs par défaut et initialisations |
| `10-environnement.zsh` | Homebrew et valeurs de repli pour `LANG` et `EDITOR` |
| `20-historique.zsh` | Capacités et options d'historique |
| `30-completion.zsh` | Définitions et initialisation de la complétion |
| `40-outils.zsh` | Choix Starship, initialisation Starship et Zoxide |
| `50-recherche.zsh` | fzf, apparence, aperçu et fzf-tab |
| `60-edition.zsh` | Touches d'édition et zsh-autosuggestions |
| `70-alias.zsh` | Alias Eza, Bat et Git |
| `~/.zshrc.local`, facultatif et conservé | Surcharges finales d'alias, de touches et d'options |
| Plugin de coloration | Chargé en dernier |

Les fragments sont des configurations sourcées, pas des scripts indépendants.
Ils ne modifient pas les options globales du shell via `set -euo pipefail`.
`LANG` et `EDITOR` ne sont définis par défaut que si la variable est absente ;
une valeur existante, même vide, est respectée. Une préférence d'éditeur fixée
dans le fichier amont est donc disponible pour toutes les intégrations.

Les deux modèles locaux dans `config/` ne sont ni copiés ni liés par Stow.
Conserver toute version personnelle avant de la modifier. Ne pas déplacer le
fichier local actuel vers l'amont sans examiner ses commandes : un réglage de
widget peut nécessiter le chargement préalable du plugin correspondant.

## Chemins personnalisés

Les scripts ciblent toujours le dossier personnel réel. Avant les sauvegardes,
ils signalent et refusent les redirections connues incompatibles : `ZDOTDIR`,
`XDG_CONFIG_HOME`, `BAT_CONFIG_PATH` et `STARSHIP_CONFIG` selon les paquets.
Les chemins Starship sombre et Latte livrés ici sont tous deux reconnus.
Les chemins relatifs ou alternatifs ne sont pas interprétés comme une
autorisation de changer de cible. Les liens parents suspects restent refusés.

Ce contrôle lit l'environnement du processus qui lance le script. Il ne
source aucun fichier personnel : une variable définie seulement dans un
futur fichier de démarrage peut donc ne pas être visible. Les options de
lancement des applications ne sont pas toutes détectables. Examiner le
message avant de changer quoi que ce soit ; ne pas effacer une préférence
personnelle uniquement pour contourner le refus.

## Apparence commune et préférences Ghostty

Ghostty, Starship sombre et Lazygit sombre utilisent désormais Mocha ; les
variantes claires utilisent Latte. Herdr conserve sa paire native
`catppuccin` / `catppuccin-latte` : aucun nom de thème Macchiato non documenté
n'est introduit. Bat et fzf continuent de reprendre la palette du terminal.
L'apparence effective reste à vérifier avec les versions installées.

Le paquet Starship fournit deux fichiers : `starship.toml` et
`starship-latte.toml`. Définir `DOTFILES_APPARENCE=clair` dans le fichier Zsh
amont sélectionne Latte si aucun `STARSHIP_CONFIG` personnel n'est défini.
Le choix est explicite, sans interrogation de macOS et sans bascule automatique
en cours de session. Pour changer de variante, repartir d'un nouveau terminal
sans ancienne valeur `STARSHIP_CONFIG` héritée, ou définir explicitement le
chemin souhaité dans le fichier amont. Une valeur personnalisée prévaut.

Ghostty charge facultativement `~/.config/ghostty-local.conf`, après le fichier
commun. Le modèle `config/ghostty-local.example.conf` propose des réglages de
police, de taille et d'opacité, tous commentés. Préparer le fichier personnel
manuellement en s'assurant que son dossier parent est réel, pas un lien vers
le clone. Ni ce fichier ni les fichiers locaux Zsh ne sont gérés par le journal
Stow. Pour les désactiver, renommer leur fichier personnel vers un nom libre
après sauvegarde puis recharger soi-même l'application concernée.

## Lecture des journaux

Le journal TSV v1 reste le plan de restauration. Un fichier voisin `.events`
enregistre désormais les transitions horodatées, sans contenu des configurations.
Son dernier état est informatif : il ne prouve pas l'état actuel des fichiers.
Les anciens journaux sans métadonnées restent lisibles comme « inconnu ».

```bash
bash scripts/lister-deploiements.sh --dry-run
```

La liste présente le nom du journal, les paquets, la date du dernier événement
et son état : `prepare`, `application`, `applique`, `echec`, `retour-automatique`,
`restauration-incomplete`, `annulation`, `annule` ou `annulation-incomplete`.
Elle ne valide pas le journal TSV, les sauvegardes ou les liens et ne supprime rien.
Une interruption brutale peut laisser un état intermédiaire. Si un état final
n'a pas pu être enregistré, un avertissement est affiché.

Une annulation voit un état `annule` ou `retour-automatique` comme déjà terminé
et n'effectue pas de nouveau retrait. Cette protection ne remplace pas l'ordre
du plus récent au plus ancien : un vieux journal encore marqué `applique`
peut concerner des chemins réutilisés depuis. Ne pas le rejouer aveuglément.
Conserver ensemble TSV, événements et sauvegardes ; ne pas modifier les
métadonnées pour forcer une action. Aucun verrouillage concurrent n'est ajouté.

## Retour à l'organisation précédente

Conserver une copie complète du dépôt avant toute application. Restaurer le
chargeur Zsh et ses fragments ensemble, et annuler depuis le clone qui a
produit le journal avant de retirer des fichiers sources. Une restauration
des liens ne modifie pas les préférences locales personnelles. Pour revenir
à l'ancien thème, rétablir les configurations sauvegardées ; les fichiers
Latte ne doivent pas être supprimés tant qu'un lien les vise.

Les anciens résultats de contrôle ne couvrent pas cette évolution. Les essais
restent différés selon [la matrice](compatibilite.md).
