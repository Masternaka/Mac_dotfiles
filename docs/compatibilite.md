# Compatibilité et versions à valider

Les versions ci-dessous servent de références pour les configurations. La
validation en fonctionnement se fait sur le Mac cible ou avec le
[protocole sur un macOS jetable](validation-avant-application.md).

| Composant | Cible du dépôt | Validation en fonctionnement |
| --- | --- | --- |
| macOS | Apple Silicon et Intel | Plage de versions à établir |
| Zsh | Zsh fourni avec macOS | Démarrage, plugins et raccourcis non testés |
| GNU Stow | Simulation et liens par fichier avec `--no-folding` | Conflits, liens et application non testés |
| [Ghostty](../ghostty/README.md#compatibilité) | Ghostty 1.3 ou ultérieur pour les notifications et la barre de défilement, macOS 26 ou ultérieur pour Liquid Glass | Chargement et rendu non testés |
| Starship | Variantes Mocha et Latte, choix via le fichier Zsh chargé en amont | Invite et rendu non testés |
| Bat | Thème intégré `ansi`, options de présentation et pagination ; thème externe facultatif | Configuration, alias, aperçu fzf et pages man non testés |
| Eza | Vues détaillées et arborescence limitée à deux niveaux | Alias, options et icônes non testés |
| Yazi | Présentation existante et raccourcis d'après 26.9.1 ; `yazi.toml` et `keymap.toml` | Ouvertures, navigation, presse-papiers et prévisualisations non testés |
| fzf et Zoxide | Initialisations directes conditionnelles | Raccourcis, complétions et navigation non testés |
| Plugins Zsh | Projets et chemins indiqués dans le guide Zsh | Chargement conjoint et fonctionnement sans plugins non testés |

Le [contrôle TOML](verification.md#toml) couvre la syntaxe. Pour un essai en
fonctionnement,
relever macOS et son architecture, les versions de Zsh, GNU Stow, des
applications et des outils facultatifs, ainsi que le tag ou le commit des
plugins Zsh utilisés. Consigner aussi les révisions de Mac_dotfiles et Mac_setup.
