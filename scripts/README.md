# Utiliser les scripts du dépôt

Les scripts vérifient les dépendances déjà présentes, sauvegardent les fichiers
existants puis créent des liens GNU Stow. Aucun téléchargement, installation,
clonage ou mise à jour n'est effectué.

Cible : macOS avec Bash 3.2 ou ultérieur. Exécuter depuis la racine du dépôt avec
`bash` ; aucune permission d'exécution n'est nécessaire.

Pour un parcours guidé, commencer par [la première utilisation](../docs/premiere-utilisation.md).

## Quel script utiliser

| Fichier | Rôle et configurations concernées | Options disponibles |
| --- | --- | --- |
| `verifier-depot.sh` | Diagnostic en lecture seule ; tous les parcours ou paquets ciblés | `--dry-run`, `--package NOM`, `--packages LISTE`, `--sans-shellcheck`, `-h` / `--help` ; aucun `--apply` |
| `stow_setup.sh` | Menu ou sélection directe de paquets ; sauvegardes, journal et liens correspondants | `--dry-run` par défaut, `--apply`, `--packages LISTE`, `-h` / `--help` |
| `terminal_setup.sh` | Groupe terminal complet ou sous-ensemble choisi ; compléments facultatifs par défaut | `--dry-run` par défaut, `--apply`, `--packages LISTE`, `--strict`, `-h` / `--help` |
| `yazi_setup.sh` | Yazi requis, outils de prévisualisation complémentaires ; liaison du seul paquet `yazi` | `--dry-run` par défaut, `--apply`, `--strict`, `-h` / `--help` |
| `annuler-deploiement.sh` | Lecture d'un journal de ce clone ; retrait de nouveaux liens et restauration des sauvegardes en application réelle | `--journal FICHIER` requis, `--dry-run` par défaut, `--apply`, `-h` / `--help` |
| `lister-deploiements.sh` | Consultation des journaux, paquets et états enregistrés ; lecture seule | `--dry-run`, `-h` / `--help` ; aucun `--apply` |
| `lib.sh` | Bibliothèque partagée de journalisation, préparation, sauvegarde et retour automatique | Aucune interface utilisateur ; ne pas lancer directement |
| `../.githooks/pre-commit` | Contrôles avant commit, facultatifs et activés manuellement ; aucun commit créé | `--dry-run`, `--apply` avec les mêmes contrôles en lecture seule, `-h` / `--help` |

Les trois scripts de déploiement sont des choix de parcours, pas une suite
d'étapes obligatoire. `--packages` est accepté par le menu Stow, le diagnostic et le parcours terminal
(pour un sous-ensemble de son groupe). Il ne s'applique ni à Yazi ni à l'annulation.
Le diagnostic accepte aussi les formes `--package=NOM` et `--packages=LISTE`.
Le script Stow accepte `--packages=LISTE`. Une liste utilise des virgules sans espaces.
Pour `--journal`, employer la forme avec un espace montrée dans les exemples.
Les options de sélection du diagnostic peuvent être répétées ; les doublons
sont ignorés. Éviter de mélanger `--dry-run` et `--apply` : dans les scripts de
déploiement et d'annulation, la dernière de ces deux options détermine le mode.

Pour consulter l'aide d'un script, par exemple :

```bash
bash scripts/stow_setup.sh --help
```

### Destinations des paquets

| Paquet | Fichier source dans le dépôt | Destination liée |
| --- | --- | --- |
| `ghostty` | `ghostty/.config/ghostty/config` | `~/.config/ghostty/config` |
| `herdr` | `herdr/.config/herdr/config.toml` | `~/.config/herdr/config.toml` |
| `starship` | `starship/.config/starship.toml` et `starship-latte.toml` | `~/.config/starship.toml` et `~/.config/starship-latte.toml` |
| `bat` | `bat/.config/bat/config` | `~/.config/bat/config` |
| `yazi` | `yazi/.config/yazi/yazi.toml` et `keymap.toml` dans le même dossier | `~/.config/yazi/yazi.toml` et `~/.config/yazi/keymap.toml` |
| `zsh` | `zsh/.zshrc` et les fragments `zsh/.config/zsh/*.zsh` | `~/.zshrc` et `~/.config/zsh/*.zsh` |
| `lazygit` | `lazygit/Library/Application Support/lazygit/config.yml` | `~/Library/Application Support/lazygit/config.yml` |

`~` désigne le dossier personnel de l'utilisateur qui lance le script. Les
scripts n'ont pas d'option pour cibler un autre compte. Ils ne créent pas le
fichier personnel `~/.zshrc.local` ni `~/.zshrc.local.pre` et n'installent pas les plugins externes.
Les sauvegardes sont placées à côté des fichiers remplacés, et les journaux
dans `.deployments/` du clone. Ne pas déplacer le clone après liaison sans
préparer le retour arrière ; voir [le fonctionnement des liens](../docs/premiere-utilisation.md#comprendre-les-liens-stow).

## Vérification sans application

```bash
bash scripts/verifier-depot.sh --dry-run
```

`verifier-depot.sh` lit les fichiers, vérifie les syntaxes disponibles et
inventorie les outils. Il ne lance aucun script de liaison ni application,
n'utilise pas Stow, ne contacte pas GitHub et n'installe rien. `--apply` n'est
pas accepté car il n'a aucun changement à appliquer. L'aide est disponible
avec `--help`.

Pour reporter explicitement ShellCheck, utiliser `--sans-shellcheck`. Les
autres contrôles continuent, mais le bilan reste incomplet (code `2` en
l'absence d'échec). Le hook avant commit ne propose pas ce report.

Les contrôles supplémentaires utilisent uniquement les outils déjà présents :
ShellCheck pour Bash, Ruby pour YAML, Python avec `tomllib` pour TOML. Les outils
absents sont signalés et les autres contrôles continuent. Les codes de sortie
sont `0` pour un bilan statique terminé, `1` en cas d'échec, `2` si le bilan
est incomplet ou si une option est invalide. Même un code `0` ne valide ni
l'application des configurations ni leur restauration.

Pour Yazi, les contrôles TOML prévus couvrent à la fois `yazi.toml` et
`keymap.toml`, sans valider leur schéma applicatif ni lancer les raccourcis.

Pour limiter les configurations et dépendances vérifiées :

```bash
bash scripts/verifier-depot.sh --dry-run --package ghostty
bash scripts/verifier-depot.sh --dry-run --packages ghostty,zsh
```

Sans sélection, le bilan complet est conservé. Les contrôles Bash communs et
Git restent effectués dans tous les cas ; YAML, TOML et Zsh sont filtrés selon
les paquets choisis. Une erreur détectée renvoie `1`. Un contrôle indisponible
ou une dépendance requise absente renvoie `2`, avec des compteurs distincts.
Les compléments facultatifs absents ne rendent pas le bilan incomplet.
Pour Zsh, les outils et plugins conditionnels sont facultatifs ; le parcours
terminal les exige seulement avec `--strict`. Le diagnostic reste un inventaire
normal, sans option stricte. Pour Lazygit
ciblé, Lazygit et Delta sont requis, tandis que `gh` reste facultatif.
Les plugins sont seulement contrôlés comme fichiers lisibles, jamais sourcés.
Un paquet absent du catalogue ou un catalogue invalide est refusé avec le code `2`.

Voir [le guide complet de validation](../docs/validation-avant-application.md)
pour les essais manuels dans un environnement jetable.

## Prérequis à préparer manuellement

Les exécutables doivent être disponibles dans le `PATH` du terminal cible.
Si nécessaire, initialisez vous-même votre environnement Homebrew avant de
lancer un script. Les scripts ne requièrent pas Homebrew lui-même.

| Script | Commandes requises |
| --- | --- |
| `stow_setup.sh` | `stow`, `cksum` ; `lazygit` et `delta` pour leur paquet ; `bat` pour le paquet Bat |
| `terminal_setup.sh` | `stow`, `cksum`, commandes des paquets sélectionnés ; groupe complet : `ghostty`, `herdr`, `starship`, `zsh` |
| `yazi_setup.sh` | `stow`, `cksum`, `yazi` ; outils de recherche/prévisualisation facultatifs, requis avec `--strict` |
| `annuler-deploiement.sh` | `cksum`, journal complet et sauvegardes correspondantes ; Stow non requis |

Si le paquet `lazygit` est sélectionné dans le menu Stow ou par `--packages`, `lazygit` et `delta`
doivent également être présents avant toute sauvegarde. Le menu lit les
paquets déclarés dans `config/paquets.tsv`. Le paquet Lazygit utilise
le chemin natif macOS, décrit dans [son guide](../lazygit/README.md).

Le paquet `bat` exige lui aussi sa commande `bat` avant toute sauvegarde.
Il reste sélectionnable séparément ; `terminal_setup.sh` ne le lie pas
automatiquement. Son [guide](../bat/README.md) décrit les thèmes et l'option
personnelle de coloration des pages man. Le diagnostic ciblé `--package bat`
inventorie ses prérequis sans valider son fichier de configuration ni lancer Bat.

ShellCheck est utilisé uniquement pour les [vérifications](../docs/verification.md),
pas comme dépendance des scripts de liaison.
GitHub CLI (`gh`) est également facultatif : il sert aux commandes de consultation
GitHub du menu Lazygit, après [préparation manuelle](../lazygit/README.md#github-cli-facultatif).

Avec `terminal_setup.sh --strict` et le paquet Zsh sélectionné, les deux fichiers
suivants doivent aussi être lisibles (facultatifs en mode normal) :

- `~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh`
- `~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`

Préparez les plugins manuellement à partir des projets `zsh-users/zsh-autosuggestions`
et `zsh-users/zsh-syntax-highlighting`. La configuration Ghostty utilise la police
JetBrainsMono Nerd Font : préparez-la également pour obtenir le rendu prévu.
`pdftoppm` est fourni par Poppler, `rg` par ripgrep, `magick` par ImageMagick et
`7zz` par SevenZip. La présence des commandes ne garantit pas la compatibilité
de toutes leurs versions.

Les compléments `zsh-completions` et `fzf-tab` restent facultatifs, y compris
avec `terminal_setup.sh --strict`. Leurs chemins et leur ordre de chargement sont décrits dans
[le guide Zsh](../zsh/README.md#complétions-supplémentaires-facultatives).
Le diagnostic signale leur présence sans les exécuter ni les installer.

Toute dépendance requise manquante arrête le script de déploiement avant les changements, y compris en
simulation. Pour lier seulement Zsh sans ces outils, utilisez le menu Stow :
les fonctionnalités absentes sont simplement omises par `.zshrc`.

## Utilisation

Choisir la commande qui correspond au besoin, sans lancer systématiquement
les trois parcours :

```bash
bash scripts/stow_setup.sh --dry-run
bash scripts/terminal_setup.sh --dry-run
bash scripts/yazi_setup.sh --dry-run
```

Sans option, la simulation est également activée. `--help` affiche l'aide.
Après relecture sur la machine cible, remplacez `--dry-run` par `--apply` pour
sauvegarder les fichiers existants et créer les liens.

`stow_setup.sh` propose un menu de paquets. Entrée (`0`) ou une entrée non
interactive ne crée aucun lien, sauf sélection explicite avec `--packages` :

```bash
bash scripts/stow_setup.sh --dry-run --packages ghostty,zsh
```

La sélection directe conserve les contrôles de sécurité, les sauvegardes et le
mode simulation par défaut. `--packages=ghostty,zsh` est également accepté.
L'option peut être répétée ; les doublons sont ignorés. Les noms sont séparés
par des virgules sans espaces. Une liste vide, un nom inconnu ou un chemin est
refusé avant toute application. Sans cette option, le menu reste inchangé.

`terminal_setup.sh` lie `ghostty`, `herdr`,
`starship` et `zsh` par défaut ; `--packages ghostty,zsh` limite ce groupe.
`yazi_setup.sh` lie uniquement `yazi`. `--strict` rétablit l'exigence de tous
les compléments du parcours choisi.

Les [règles d'organisation](../docs/organisation-configuration.md) détaillent
le catalogue, les chemins personnalisés, l'ordre des fragments Zsh et les états
des journaux. Un chemin d'environnement incompatible bloque le déploiement
avant toute sauvegarde ; le script ne change pas silencieusement de destination.

## Sauvegardes et limites

`lib.sh` fournit la journalisation, `run`, les contrôles de dépendances et les
sauvegardes. Il doit être sourcé par les scripts, pas lancé directement.

Les déploiements requièrent aussi `cksum`, normalement fourni avec macOS.
Après les contrôles préalables et avant les déplacements, ils enregistrent un
journal `.deployments/IDENTIFIANT.tsv` dans le clone. La simulation affiche
cette étape sans créer de dossier ni de journal. Une création impossible
arrête le déploiement avant toute modification des destinations.

Le fichier voisin `.events` garde les transitions horodatées et peut être
consulté via `bash scripts/lister-deploiements.sh --dry-run`.

Ce journal privé contient le clone, la destination, les états initiaux, les
chemins de sauvegarde et une empreinte CRC des fichiers remplacés. Il ne
contient pas leur contenu et n'est jamais exécuté comme du code. Les chemins
contenant des tabulations ou retours à la ligne sont refusés. Le journal reste
présent après un échec ; un journal incomplet est refusé par l'annulation.
Ne pas modifier ni publier `.deployments/`, qui est ignoré par Git.

Pour préparer un retour arrière avec le chemin exact affiché :

```bash
bash scripts/annuler-deploiement.sh --dry-run --journal .deployments/IDENTIFIANT.tsv
```

Ce script ne requiert pas Stow. Voir [le guide d'annulation](../docs/retour-arriere.md)
pour les protections, les conditions d'application et les limites.

La procédure commune prépare toutes les destinations avant toute écriture :

1. Vérifier chaque dossier parent. Un dossier symbolique n'est accepté que s'il
   pointe exactement vers le dossier correspondant du paquet de ce clone.
   Les liens vers un ancien clone, un autre dossier ou une cible cassée sont
   refusés. Les liens de fichiers vers une autre cible sont également refusés.
2. Refuser les options implicites de `.stowrc` dans le dossier personnel ou à
   la racine du dépôt. Elles pourraient, par exemple, activer une adoption
   réelle des fichiers. Les fichiers `.stowrc` existants ne sont pas modifiés.
3. Lancer réellement **la simulation en lecture seule de Stow**, même lorsque
   le script est lui-même en mode simulation. Les conflits de structure ou
   entre paquets arrêtent la procédure avant toute sauvegarde.
4. En mode `--apply` seulement, déplacer les fichiers ordinaires existants vers
   des sauvegardes horodatées sans écrasement, puis créer les liens. Les liens
   déjà corrects sont conservés. Une vérification finale contrôle les cibles.

Le contrôle préalable utilise `--simulate --adopt` pour permettre de planifier
le remplacement des fichiers ordinaires qui seront sauvegardés. **L'option
`--adopt` n'est jamais utilisée pendant l'application réelle** : aucune
configuration personnelle n'est importée dans les sources du dépôt.

L'application utilise `--stow --no-folding`, plutôt que `--restow`, afin de ne
pas retirer d'abord les liens déjà fonctionnels. Les liens devenus obsolètes
après suppression d'un fichier source ne sont donc pas nettoyés automatiquement.
Les noms de paquet et les types de fichiers sources sont contrôlés ; les liens
symboliques dans les sources sont refusés. Les fichiers de configuration des
paquets restent sous `.config/`, `Library/` ou dans `.zshrc`.

En cas d'échec après le début des sauvegardes, ou d'interruption par `Ctrl+C`
ou `TERM`, le script tente automatiquement de retirer uniquement ses nouveaux
liens et de remettre les fichiers sauvegardés à leur emplacement initial.
Une destination occupée ou un parent devenu symbolique n'est jamais remplacé :
le script conserve la sauvegarde et affiche le chemin à restaurer manuellement.
Les répertoires vides éventuellement créés par Stow sont laissés en place.

Il ne s'agit pas d'une transaction atomique du système de fichiers. Une coupure
électrique ou un arrêt forcé `KILL` ne permet pas au gestionnaire d'interruption
de s'exécuter : utiliser alors les sauvegardes et le guide ci-dessous. Ne pas
lancer plusieurs applications en parallèle ni modifier les destinations pendant
l'opération. Les parcours de déploiement et de restauration n'ont pas été
exécutés pendant la préparation de cette correction.

Voir [le retour arrière](../docs/retour-arriere.md).
