# Compatibilité et versions à valider

État au 3 novembre 2026. Une version observée pour l'analyse statique ne prouve
pas que les configurations ou le retour arrière fonctionnent avec cette version.
Aucune application de configuration ni restauration réelle n'a été effectuée.

Les ajouts ultérieurs d'historique, de complétion tolérante, d'aperçu Ctrl+T et
de raccourcis dans `.zshrc` et le modèle local n'ont pas été analysés ni testés,
à la demande de l'utilisateur. Les réussites syntaxiques ci-dessous concernent
leur état antérieur à ces ajouts.

La personnalisation Starship sur deux lignes est également préparée sans
contrôle TOML, exécution ni validation visuelle. Elle ne bénéficie d'aucun
résultat de validation antérieur.

Le paquet Bat, ses adaptations de sélection/diagnostic et l'exemple de pager
man sont également préparés sans vérification, exécution ni essai visuel.

Les raccourcis Yazi et l'extension du contrôle TOML à `keymap.toml` sont eux
aussi préparés sans analyse ni exécution. La version 26.9.1 sert uniquement
de référence documentaire pour ces nouveaux raccourcis.

L'apparence commune fzf/fzf-tab est préparée sans analyse syntaxique,
chargement ni essai de contraste en mode clair ou sombre.

Les vues Eza `ll`, `la` et `lt`, ainsi que leur exemple local, sont également
préparées sans analyse, chargement ni essai. La version compatible reste à établir.

L'évolution du catalogue, des dépendances, des chemins personnalisés, du Zsh
modulaire, des journaux avec états, des thèmes Mocha/Latte et des préférences
Ghostty reste **entièrement sans vérification**. Les chiffres et versions
observés antérieurement ne valident pas cet état de travail. Voir
[le guide d'organisation](organisation-configuration.md) pour les nouvelles règles.

| Composant | Cible du dépôt | Observation actuelle | Validation en fonctionnement |
| --- | --- | --- | --- |
| macOS | macOS ; plage de versions non certifiée | 26.7, build 25G229, arm64, inventaire en lecture seule | Non effectuée |
| Bash | 3.2 ou ultérieur, sans fonctionnalités Bash 4+ | `/bin/bash` 3.2.57 ; analyse syntaxique des scripts | Déploiement et annulation non exécutés |
| Zsh | Zsh fourni avec macOS | `/bin/zsh` 5.9 ; syntaxe de `.zshrc` et du modèle local | Démarrage, plugins et raccourcis non testés |
| GNU Stow | Options de simulation, adoption simulée et `--no-folding` utilisées dans les scripts | Absent du PATH de la session ; version minimale non établie | Conflits, liens et application non testés |
| `cksum` | Empreinte CRC du contenu des configurations à sauvegarder | Disponible ; requis par le déploiement et l'annulation | Gestion des sauvegardes non testée |
| Parseurs de configuration | Ruby pour YAML ; Python 3.11+ avec `tomllib` pour TOML | YAML analysé ; `tomllib` indisponible dans cette session | Syntaxe TOML non contrôlée ; aucun schéma applicatif validé |
| Ghostty | Options du fichier `ghostty/.config/ghostty/config` | Version cible non fixée | Chargement et rendu non testés |
| Herdr | Options du TOML fourni | Version cible non fixée | Chargement et rendu non testés |
| Starship | Deux variantes Mocha/Latte, choix explicite via le fichier amont | Version cible non fixée | Invite et rendu non testés |
| Bat | Thème intégré `ansi`, options de présentation et pagination ; thème externe facultatif | Version compatible non établie ; cache de thèmes non créé | Configuration, alias, aperçu fzf et pages man non testés |
| Eza | Vues détaillées et arborescence limitée à deux niveaux | Version installée non relevée | Alias, options et icônes non testés |
| Yazi | Présentation existante et raccourcis d'après 26.9.1 ; `yazi.toml` et `keymap.toml` | Version installée non relevée ; 26.9.1 est une référence documentaire | Ouvertures, navigation, presse-papiers et prévisualisations non testés |
| Lazygit | 0.66.2, référence documentaire du paquet | Version installée non relevée | Configuration et commandes non testées |
| Delta et GitHub CLI | Intégrations Lazygit ; `gh` facultatif | Versions cibles non fixées | Affichage et consultations non testés |
| fzf et Zoxide | Initialisations directes conditionnelles | Versions compatibles à relever dans la VM | Raccourcis, complétions et navigation non testés |
| Plugins Zsh | Projets et chemins indiqués dans le guide Zsh | Aucun commit ou tag de plugin validé | Chargement conjoint et fonctionnement sans plugins non testés |

La version de Lazygit est une **cible documentaire**, pas un résultat d'essai.
Les vérifications de syntaxe YAML/TOML ne valident pas les schémas applicatifs.
Les versions minimales manquantes restent à déterminer ; ne pas les déduire
de la seule présence d'une commande ou de la réussite d'une analyse statique.

## Relever les versions dans un macOS jetable

Suivre le [protocole](validation-avant-application.md). Pour chaque essai, noter :

- macOS et architecture, versions de Bash et Zsh, version de GNU Stow ;
- copie exacte du dépôt utilisée, y compris ses changements non commités ;
- version de chaque application testée et version des outils de prévisualisation ;
- tag ou commit précis de chaque plugin externe, notamment `zsh-completions`,
  `fzf-tab`, `zsh-autosuggestions` et `zsh-syntax-highlighting` ;
- scénario, résultat, code de sortie et preuves avant/après.

Mettre à jour une ligne comme « validée » uniquement après un essai réel avec
ces informations. Aucun tag ou commit externe n'est téléchargé ou figé par les
scripts. ShellCheck est reporté à la demande de l'utilisateur ; ce report ne
constitue pas une validation de l'analyse manquante.
