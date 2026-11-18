# Organisation des configurations

Chaque répertoire de paquet reproduit les chemins relatifs au dossier
personnel. Les fichiers `.stow-local-ignore` excluent du déploiement la
documentation du paquet et les fichiers locaux indiqués. Les modèles dans
`config/` sont à recopier manuellement selon les besoins.

## Ordre de chargement Zsh

Le paquet doit être déployé en entier : `.zshrc` devient un chargeur des
fragments de `~/.config/zsh/`. Un fragment absent arrête ce chargement avec un
message plutôt que laisser croire à une configuration complète.

| Ordre | Contenu |
| --- | --- |
| `~/.zshrc.local.pre`, facultatif | Variables personnelles avant les valeurs par défaut et initialisations |
| `10-environnement.zsh` | Homebrew et valeur de repli pour `LANG` |
| `20-historique.zsh` | Capacités et options d'historique |
| `30-completion.zsh` | Définitions et initialisation de la complétion |
| `40-outils.zsh` | Choix Starship, initialisation Starship et Zoxide |
| `50-recherche.zsh` | fzf, apparence, aperçu et fzf-tab |
| `60-edition.zsh` | Touches d'édition et zsh-autosuggestions |
| `70-alias.zsh` | Alias Eza, Bat, Git et Finder, puis navigation avec Yazi |
| `~/.zshrc.local`, facultatif et conservé | Surcharges finales d'alias, de touches et d'options |
| Plugin de coloration | Chargé après les préférences locales |
| `zsh-history-substring-search`, facultatif | Chargé après la coloration s’il est disponible via Homebrew. Associe ↑ et ↓ à la recherche d’historique |

Le fragment d’environnement définit `LANG` lorsque la variable est absente.
Pour choisir un éditeur, définir `VISUAL` ou `EDITOR` dans le fichier local
adapté. Le [guide Zsh](../zsh/README.md#préférences-propres-à-chaque-mac)
décrit le moment de chargement des deux modèles locaux.

## Chemins personnalisés

Le paquet Zsh vise `~/.zshrc` et `~/.config/zsh/`. Vérifier `ZDOTDIR` et
`XDG_CONFIG_HOME` avant de lancer le déploiement Mac_setup. Pour les autres
applications, vérifier aussi les chemins personnalisés, notamment
`YAZI_CONFIG_HOME`, `BAT_CONFIG_PATH` et `STARSHIP_CONFIG`. Un fichier
personnel choisi par l’application peut prendre le dessus sur le fichier lié.

## Apparence commune et préférences Ghostty

Ghostty et Starship utilisent Mocha pour l’apparence sombre et Latte pour
l’apparence claire. Bat et fzf reprennent la palette du terminal.
L’apparence effective reste à vérifier avec les versions installées.

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
manuellement dans un dossier parent réel. Pour désactiver une préférence
locale, renommer le fichier personnel vers un nom libre après sauvegarde,
puis recharger l’application concernée.
