# mac_os_dotfiles

Configuration personnelle pour macOS : Ghostty, Herdr, Starship, Bat, Yazi, Zsh et Lazygit avec Delta.

Les fichiers sont organisés en **paquets [GNU Stow](https://www.gnu.org/software/stow/)** : chaque dossier de premier niveau reproduit l'arborescence du répertoire personnel.

Pour commencer, suivre [le guide de première utilisation](docs/premiere-utilisation.md) :
choix du parcours, diagnostic, simulation, application manuelle et annulation.
Le [catalogue des scripts](scripts/README.md#quel-script-utiliser) résume leurs options.
Le [guide d'organisation](docs/organisation-configuration.md) décrit le catalogue commun,
les préférences par machine, les thèmes et les états des journaux.

## Structure

```
.
├── ghostty/           # ~/.config/ghostty/config
├── herdr/             # ~/.config/herdr/config.toml
├── starship/          # ~/.config/starship.toml
├── bat/               # ~/.config/bat/config
├── yazi/              # ~/.config/yazi/yazi.toml
├── zsh/               # ~/.zshrc et ~/.config/zsh/*.zsh
├── lazygit/           # ~/Library/Application Support/lazygit/config.yml
├── scripts/           # scripts de liaison
├── config/            # modèles de configuration à préparer manuellement
├── docs/              # utilisation, annulation, validation et compatibilité
├── .githooks/         # contrôles avant commit, activation manuelle
└── .github/           # configuration GitHub
```

## Prérequis

Cible : macOS, avec Bash 3.2 ou ultérieur et GNU Stow déjà disponible dans le
`PATH`. Les options des applications peuvent varier selon leurs versions ;
leur compatibilité visuelle reste à vérifier sur la machine cible.

Les scripts ne téléchargent, n'installent et ne mettent à jour aucun logiciel.
Préparez les dépendances manuellement sur la machine cible ; voir
[scripts/README.md](scripts/README.md). Si un prérequis manque, le script
s'arrête avant toute sauvegarde ou création de lien, même en simulation.

## Application manuelle

Depuis la racine du dépôt, choisissez le parcours souhaité et commencez par
sa simulation. Il n'est pas nécessaire de lancer ces trois commandes :

```bash
bash scripts/stow_setup.sh --dry-run
bash scripts/terminal_setup.sh --dry-run
bash scripts/yazi_setup.sh --dry-run
```

- `stow_setup.sh` propose les paquets disponibles ; Entrée (`0`) ne crée aucun lien.
  Pour une sélection directe : `bash scripts/stow_setup.sh --dry-run --packages ghostty,zsh`.
- `terminal_setup.sh` lie le groupe Ghostty, Herdr, Starship et Zsh, ou un sous-ensemble
  avec `--packages`. Les compléments deviennent requis avec `--strict`.
- `yazi_setup.sh` exige Yazi et signale les compléments absents ; `--strict` les exige aussi.

Les parcours terminal et Yazi ne sont pas des étapes obligatoires après le
menu Stow. Le menu permet de choisir des paquets indépendamment, sans vérifier
tous leurs outils applicatifs ; Lazygit vérifie Lazygit et Delta, et Bat vérifie Bat.
Les scripts ne lancent pas les applications.

Le paquet facultatif [Bat](bat/README.md) prépare une présentation assortie au
terminal et une pagination automatique. Pour le sélectionner séparément :
`bash scripts/stow_setup.sh --dry-run --packages bat`.
Il ne fait pas partie du regroupement `terminal_setup.sh`.

Un lien Stow renvoie au fichier du clone : modifier son contenu via le chemin
lié peut donc modifier le dépôt. Déplacer le clone peut casser les liens.
Lire [les explications sur les liens](docs/premiere-utilisation.md#comprendre-les-liens-stow)
avant de personnaliser ou déplacer les configurations.

Le paquet [Lazygit avec Delta](lazygit/README.md) est facultatif et sélectionnable
dans le menu Stow. Il cible Lazygit 0.66.2, avec commandes personnalisées dans
le menu `?` et couleurs adaptées aux terminaux sombres ou clairs.
L'intégration facultative de [GitHub CLI (`gh`)](lazygit/README.md#github-cli-facultatif)
permet aussi de consulter les pull requests et leurs vérifications depuis ce menu.

La simulation vérifie désormais les conflits Stow sans modifier les fichiers.
Les liens vers d'autres emplacements et les options implicites `.stowrc` sont
refusés avant les sauvegardes. En cas d'échec de l'application, le script tente
de restaurer les fichiers déplacés ; voir [les limites et protections](scripts/README.md#sauvegardes-et-limites).

Après relecture, appliquez uniquement les configurations souhaitées en remplaçant
`--dry-run` par `--apply`. L'aide est accessible avec `--help`.
Les commandes utilisent `bash` : aucune permission d'exécution à ajouter.

Pour gérer uniquement les liens manuellement (sans sauvegarde automatique ni
les protections des scripts ; les options personnelles de Stow s'appliquent) :

```bash
stow --target="$HOME" --restow --no-folding ghostty herdr starship yazi zsh
```

Ajouter `lazygit` à cette commande si ce paquet est souhaité.

Pour les variables avant initialisation, Zsh accepte `~/.zshrc.local.pre`.
Pour les alias et touches après initialisation, il conserve `~/.zshrc.local`.
Ces deux fichiers sont facultatifs et préparés manuellement. Un modèle commenté et les
instructions de désactivation figurent dans [le guide Zsh](zsh/README.md#préférences-propres-à-chaque-mac).
Ce fichier personnel n'est pas géré par Stow.

## Vérifications et automatisation facultative

[Le guide de vérification](docs/verification.md) décrit les contrôles de syntaxe,
ShellCheck et un hook avant commit propre à ce dépôt. Aucun gestionnaire de
plugins ou de hooks supplémentaire n'est nécessaire. Le hook reste inactif tant
que l'utilisateur ne l'a pas activé manuellement ; il fonctionne aussi dans
Lazygit via les hooks natifs de Git.

Pour obtenir un bilan en lecture seule :

```bash
bash scripts/verifier-depot.sh --dry-run
```

Pour un diagnostic limité aux paquets souhaités :

```bash
bash scripts/verifier-depot.sh --dry-run --package ghostty
bash scripts/verifier-depot.sh --dry-run --packages ghostty,zsh
```

Les erreurs, contrôles incomplets et dépendances absentes sont comptés
séparément. Sans sélection, le bilan complet reste disponible.

Le [guide de validation avant application](docs/validation-avant-application.md)
décrit les essais manuels de déploiement, de conflit et de restauration dans
un macOS jetable. Le bilan statique ne les remplace pas.

La [matrice de compatibilité](docs/compatibilite.md) distingue les versions
ciblées, observées et réellement testées. La [revue de cohérence](docs/revue-coherence.md)
décrit les corrections et les limites du déploiement et de l'annulation.
Pour différer explicitement ShellCheck tout en poursuivant les autres contrôles :
`bash scripts/verifier-depot.sh --dry-run --sans-shellcheck`.
Le contrôle différé reste compté comme incomplet.

## Retour arrière

Voir [les instructions d'annulation](docs/retour-arriere.md) pour retirer les
liens et restaurer les fichiers sauvegardés. Retirer les liens ne restaure pas
automatiquement les anciennes configurations.

Les nouvelles applications enregistrent auparavant un journal local dans
`.deployments/`, ignoré par Git. Pour préparer une annulation guidée, utiliser
le chemin exact affiché pendant l'application :

```bash
bash scripts/annuler-deploiement.sh --dry-run --journal .deployments/IDENTIFIANT.tsv
```

Le journal est nécessaire ; les anciens déploiements restent annulables
manuellement. L'application de l'annulation exige `--apply` sur la machine cible.

Les sauvegardes sont conservées à côté des fichiers remplacés, sous la forme
`*.backup.HORODATAGE` (avec suffixe en cas de collision).

Les scripts sont destinés à être relus puis lancés manuellement sur la machine
cible. Ils n'ont pas été exécutés pendant la préparation de ces corrections.
