# Zsh

Configuration du shell Zsh, gérée par GNU Stow.

## Contenu

- `.zshrc` : chargeur principal, destiné à `~/.zshrc`.
- `.config/zsh/*.zsh` : sept fragments, destinés à `~/.config/zsh/`.

Le chargeur et les fragments doivent être déployés ensemble. Ne pas copier
seulement `.zshrc` : il signalerait des fragments absents. Les réglages de
langue et d'éditeur existants sont respectés ; les valeurs de repli ne sont
appliquées que si les variables correspondantes ne sont pas définies.
Voir [l'organisation détaillée](../docs/organisation-configuration.md#ordre-de-chargement-zsh).

## Réglages

- Initialisation de Homebrew pour Apple Silicon (`/opt/homebrew`) et Intel (`/usr/local`).
- Historique persistant, capacité augmentée et filtres de doublons natifs Zsh.
- Complétion Zsh via `compinit`.
- Complétion exacte puis tolérante aux majuscules/minuscules.
- Aperçu Bat des fichiers dans Ctrl+T de fzf, sans remplacer les options personnelles.
- Raccourcis pour éditer la ligne et l'ouvrir dans un éditeur.
- Définitions supplémentaires via `zsh-completions`, si disponible.
- Sélection des complétions avec `fzf-tab`, si le plugin et fzf sont disponibles.
- Présentation fzf/fzf-tab assortie aux couleurs du terminal, avec options séparées.
- Plugin `zsh-autosuggestions`.
- Starship, Zoxide (`cd` intelligent) et fzf.
- `zsh-syntax-highlighting` chargé en dernier.
- Alias modernes pour `ls`, `ll`, `la`, `lt` et `cat`.
- Chargement facultatif de `~/.zshrc.local` pour les préférences de cette machine.

## Vues Eza pour les fichiers

Lorsque `eza` est disponible dans le PATH, la configuration prépare ces vues :

| Commande | Vue |
| --- | --- |
| `ls` | Vue habituelle Eza avec icônes et dossiers en premier, conservée |
| `ll` | Liste détaillée avec en-têtes, une entrée par ligne, sans grille |
| `la` | Même liste détaillée, avec les fichiers cachés |
| `lt` | Arborescence limitée à deux niveaux, sans les fichiers cachés par défaut |

`ll`, `la` et `lt` placent les dossiers en premier et affichent leurs icônes
automatiquement lorsque la sortie est un terminal. Une police Nerd Font est
nécessaire au rendu prévu des icônes. L'ancienne vue `ll` utilisait une grille :
ce réglage est retiré pour garder une ligne par entrée.

Ces alias acceptent les chemins et options ajoutés à la commande. Exemples
à utiliser soi-même sur la machine cible après chargement de la configuration :

```bash
ll "$HOME/Documents"
la
lt "$HOME/Projets"
```

Adapter le dernier chemin à un dossier existant. Aucune installation, création
de dossier ou lecture de ces exemples n'a été exécutée pour préparer cet ajout.
Le niveau de l'arbre limite la profondeur, pas le nombre total de fichiers
affichés. Aucune exclusion de dossiers ni option Git supplémentaire n'est imposée.

Si Eza est absent, ce bloc ne définit pas ces alias : la commande système `ls`
et les éventuelles définitions antérieures restent disponibles. Pour l'appeler
explicitement même avec Eza présent, utiliser `command ls`.

Les préférences dans `~/.zshrc.local` peuvent redéfinir les alias ; le modèle
local propose un exemple commenté pour afficher aussi les fichiers cachés
dans l'arbre. Pour retrouver l'ancienne vue, y définir
`alias ll='eza -lh --icons --grid'` uniquement si Eza est disponible.
Retirer `la` et `lt` de la source pour ne plus les définir au prochain démarrage,
ou rétablir les anciennes préférences personnelles si ces noms étaient déjà utilisés.

Ces vues restent **sans analyse syntaxique, chargement ou essai visuel**.
Référence : [options Eza](https://github.com/eza-community/eza/blob/main/man/eza.1.md).

## Complétion et confort d'édition

Ces ajouts sont préparés dans le dépôt, **sans chargement, analyse syntaxique
ni test interactif pour le moment**, conformément au report des vérifications.

### Complétion tolérante aux majuscules

Tab essaie d'abord une correspondance avec la casse saisie. S'il n'y a aucun
résultat, Zsh essaie une correspondance insensible aux majuscules/minuscules
ASCII. Par exemple, `doc` peut proposer `Documents` lorsque la première recherche
ne trouve rien. Ce réglage ne corrige pas les fautes de frappe, ne modifie pas
une commande déjà saisie et ne rend pas les accents interchangeables.

Le style `matcher-list` s'applique au système de complétion Zsh, utilisé aussi
par fzf-tab. Pour revenir à la casse exacte, ajouter dans le fichier personnel
`~/.zshrc.local` : `zstyle ':completion:*' matcher-list ''`.

### Aperçu des fichiers avec Ctrl+T

Si fzf et Bat sont disponibles et si `FZF_CTRL_T_OPTS` n'a pas déjà été défini,
Ctrl+T affiche un aperçu des 300 premières lignes du fichier sélectionné, avec
numéros de ligne et coloration. L'aperçu ne lance ni l'éditeur ni le fichier.
La sélection insère toujours le chemin dans la ligne de commande.

Les dossiers et fichiers illisibles n'ont pas d'aperçu ; Bat conserve son propre
traitement des fichiers binaires. Le réglage vise uniquement Ctrl+T : il
n'ajoute pas d'aperçu à Ctrl+R, à Alt+C ni au menu Tab de fzf-tab.
Une valeur existante de `FZF_CTRL_T_OPTS`, même vide, est respectée. Sans Bat,
aucun aperçu n'est ajouté. Si la version de fzf ne fournit pas `--zsh`, le
chargement de son intégration reste omis comme auparavant.

Pour personnaliser ou désactiver cet aperçu, définir `FZF_CTRL_T_OPTS` dans
`~/.zshrc.local` ; `export FZF_CTRL_T_OPTS=''` désactive les options de ce
raccourci. Une option d'aperçu globale déjà présente dans `FZF_DEFAULT_OPTS`
peut cependant continuer à agir. Les exemples restent hors des fichiers réels.

### Touches d'édition

Les raccourcis sont définis dans les tables `emacs` et `viins` sans imposer
un changement de mode. Le mode commande Vi reste intact. Les flèches simples,
Tab, Ctrl+R, Ctrl+T et Alt+C ne sont pas réaffectés par ce bloc.

| Touche | Action préparée |
| --- | --- |
| Ctrl+A | Aller au début de la ligne |
| Ctrl+E | Aller à la fin de la ligne |
| Échap puis B | Reculer d'un mot |
| Échap puis F | Avancer d'un mot |
| Option+flèche gauche/droite | Reculer/avancer d'un mot, si le terminal envoie les séquences Alt correspondantes |
| Ctrl+X puis Ctrl+E | Éditer la commande dans l'éditeur, si la fonction native `edit-command-line` est disponible |

La touche Option dépend de la configuration du terminal ; Échap puis B/F
offre une autre façon d'envoyer les séquences attendues. Les raccourcis du
terminal peuvent intercepter une touche avant Zsh. Avec zsh-autosuggestions,
les widgets de déplacement peuvent aussi accepter une partie ou la totalité
d'une suggestion selon sa configuration ; ces interactions restent à tester.

Pour l'édition externe, la fonction Zsh choisit `VISUAL`, puis `EDITOR`, puis
son éditeur de repli. La configuration partagée définit déjà `EDITOR=nvim`
si Neovim est disponible ; une préférence locale peut le remplacer. La fonction
crée un fichier temporaire lors de son utilisation, puis restitue le texte
édité dans le shell. Le raccourci seul ne valide pas une exécution : relire
la ligne avant d'appuyer sur Entrée. Aucun éditeur n'est lancé au chargement.

Les raccourcis sont préparés avant zsh-autosuggestions ; les préférences locales
sont chargées ensuite pour permettre de les redéfinir. Pour les retirer,
rétablir les lignes antérieures dans la source `.zshrc` et appliquer ensuite
le parcours habituel sur la machine cible. Aucun état des anciennes touches
n'est enregistré automatiquement.

Références : [complétion Zsh](https://zsh.sourceforge.io/Doc/Release/Completion-System.html),
[intégration fzf](https://github.com/junegunn/fzf#key-bindings-for-command-line),
[fonctions d'édition Zsh](https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#ZLE-Functions).

## Apparence des menus de recherche

fzf et fzf-tab disposent d'une présentation assortie à la palette du terminal,
avec une bordure arrondie et des dimensions adaptées à chaque contexte.
Les couleurs ANSI suivent notamment Catppuccin dans Ghostty, y compris lorsque
le terminal change de palette. Les options personnelles déjà définies sont
conservées et les réglages de fzf-tab restent séparés des options globales.

La [fiche d'apparence fzf](../docs/apparence-fzf.md) explique les dimensions,
les priorités et la désactivation. Cet ajout n'a pas été analysé, chargé ou
testé visuellement. Des exemples facultatifs figurent dans le modèle local.

## Historique des commandes

La configuration prépare l'historique avec les mécanismes natifs de Zsh,
sans plugin supplémentaire. L'ajout est **non vérifié à ce stade** : aucun
chargement, test ou contrôle syntaxique de ce changement n'a été effectué.

| Réglage | Comportement préparé |
| --- | --- |
| `HISTFILE` | Conserve la valeur déjà définie, notamment celle de macOS ; si absente, utilise `${ZDOTDIR:-$HOME}/.zsh_history` |
| `SAVEHIST` | Au moins 10 000 entrées à conserver ; une valeur déjà supérieure est préservée |
| `HISTSIZE` | Au moins 20 000 entrées en mémoire, avec une marge de 10 000 au-dessus de `SAVEHIST` si nécessaire |
| `APPEND_HISTORY` | Ajoute l'historique à la sortie du shell plutôt que remplacer celui d'autres sessions |
| `HIST_IGNORE_DUPS` | Évite les répétitions immédiatement consécutives |
| `HIST_FIND_NO_DUPS` | Évite de reproposer une même commande lors d'une recherche dans l'historique avec Zsh |
| `HIST_EXPIRE_DUPS_FIRST` | Élimine d'abord les doublons lorsque l'historique en mémoire doit être réduit |

Les capacités sont des nombres d'entrées, pas des limites en octets ni un quota
strict du fichier à chaque instant. Une valeur `HISTFILE` explicitement vide
est conservée : elle empêche l'enregistrement sur disque. Les capacités et les
options peuvent être redéfinies ensuite dans `~/.zshrc.local` ; le modèle
fourni contient des exemples commentés. Les filtres ne lancent pas de nettoyage
immédiat de l'ancien fichier : ils influencent les prochaines utilisations et
la gestion de la capacité. Une réduction de capacité peut faire disparaître
des entrées anciennes lors d'une sauvegarde ultérieure.

### Comportement selon le terminal

Le fichier système `/etc/zshrc` observé pendant la préparation définit déjà
`HISTFILE`, `HISTSIZE=2000` et `SAVEHIST=1000`. Ce sont des observations locales,
pas des valeurs garanties sur toutes les versions de macOS.

Dans Terminal d'Apple, le mécanisme système peut rediriger `HISTFILE` vers un
historique propre à la session, puis fusionner les commandes lors de la sortie.
La configuration conserve cette redirection et ne modifie pas ses hooks.
Elle n'active ni ne désactive `INC_APPEND_HISTORY`, `INC_APPEND_HISTORY_TIME`
ou `SHARE_HISTORY`, ni les variables de gestion des sessions Apple.

Dans Ghostty ou un autre terminal, l'ajout au fichier se fait normalement à la
fermeture du shell, sauf si une autre configuration impose un autre mode.
Il n'y a pas d'import automatique des commandes d'une fenêtre dans les autres
fenêtres déjà ouvertes. Une fermeture forcée peut perdre des commandes non
encore sauvegardées. L'historique ne remplace pas une sauvegarde personnelle.

Les filtres natifs ne configurent pas le filtrage des résultats de Ctrl+R de
fzf ; celui-ci conserve son propre fonctionnement. Les suggestions continuent
d'utiliser les sources prévues par `zsh-autosuggestions`.

### Application et retour arrière manuels

Avant le premier chargement sur la machine cible, conserver une copie datée du
fichier d'historique réellement utilisé et, si nécessaire, du dossier de
sessions de Terminal. Les scripts Stow sauvegardent la configuration `.zshrc`,
mais **ne sauvegardent ni ne restaurent l'historique des commandes**.

Après relecture et lorsque les essais seront possibles, suivre le parcours
d'application du paquet Zsh ci-dessous, puis ouvrir un nouveau terminal sur
la machine cible. Aucun historique n'est créé, lu ou modifié par la préparation
de ces fichiers dans le dépôt.

Pour revenir aux réglages précédents, rétablir l'ancienne configuration `.zshrc`
avec le guide d'annulation et ouvrir une nouvelle session. Ce retour ne recrée
pas les entrées déjà filtrées ou supprimées par la gestion de capacité.
Une éventuelle restauration de l'historique personnel est une opération
manuelle distincte, à préparer après fermeture des sessions susceptibles de
l'écrire, à partir de la copie conservée.

Références : [paramètres d'historique Zsh](https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell),
[options d'historique Zsh](https://zsh.sourceforge.io/Doc/Release/Options.html#History).

## Complétions supplémentaires facultatives

Les deux ajouts sont chargés directement, sans gestionnaire de plugins ni
installation automatique. Sur la machine cible, préparer manuellement les
projets complets, avec leurs fichiers auxiliaires, aux emplacements suivants :

| Projet | Chemin attendu |
| --- | --- |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | `~/.zsh/zsh-completions/src/` |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | `~/.zsh/fzf-tab/fzf-tab.plugin.zsh` |

Ne pas remplacer un dossier existant sans l'examiner et en conserver une copie
horodatée avant toute mise à jour manuelle. Ces dossiers restent extérieurs aux
paquets Stow ; ni le déploiement ni son annulation ne les modifient.

`zsh-completions` enrichit les définitions : son dossier `src/` est ajouté à
`fpath` avant l'unique appel à `compinit`. La configuration n'exécute pas son
fichier de plugin et n'efface pas automatiquement le cache de complétion.
Si de nouvelles définitions ne sont pas visibles, suivre les instructions du
projet pour examiner son cache sur la machine cible.

`fzf-tab` améliore la sélection avec Tab. Son chargement intervient après
`compinit` et `fzf --zsh`, puis avant `zsh-autosuggestions`. La coloration
syntaxique reste en dernier. Cet ordre suit les
[contraintes de fzf-tab](https://github.com/Aloxaf/fzf-tab#install) et évite
que l'intégration fzf réaffecte Tab après le plugin. Les descriptions sont
regroupées et le menu natif est désactivé uniquement lorsque fzf-tab est chargé.
Les intégrations directes de Bat, fzf et Zoxide sont conservées.

En l'absence des ajouts, les complétions et intégrations déjà disponibles restent
en place. Leur absence n'est pas bloquante pour `terminal_setup.sh` ni pour le
diagnostic. Celui-ci inventorie les chemins sans exécuter les plugins externes.

Pour désactiver les ajouts, déplacer manuellement leurs dossiers vers des noms
libres, par exemple avec un suffixe `.desactive.HORODATAGE`, puis ouvrir un
nouveau terminal sur la machine cible. Ne pas supprimer les dossiers pour un
simple essai. Les rétablir à leur emplacement initial permet de les réactiver.

Validation prévue sur le Zsh fourni avec macOS : tester Tab pour les chemins,
options et branches Git, ainsi que Ctrl+R, Ctrl+T et Alt+C de fzf, les suggestions
et la coloration. Répéter avec les deux ajouts absents, chacun séparément, puis
les deux présents. Une préférence dans `~/.zshrc.local` qui réaffecte Tab peut
modifier cette intégration. Les contrôles statiques ne prouvent pas ce comportement
interactif ni la compatibilité des versions installées.

## Préférences propres à chaque Mac

Deux emplacements facultatifs sont disponibles :

| Fichier personnel | Moment et usage |
| --- | --- |
| `~/.zshrc.local.pre` | Avant les valeurs par défaut, les plugins et les outils ; langue, éditeur, options d'initialisation, choix Starship clair |
| `~/.zshrc.local` | Après les fragments, avant la coloration ; surcharges d'alias et de raccourcis, fonctionnement conservé |

Le nouveau modèle [zshrc-local-pre.example.zsh](../config/zshrc-local-pre.example.zsh)
prépare l'amont. L'ancien modèle reste adapté à l'aval. Ni l'un ni l'autre
n'est copié dans le dossier personnel par les scripts. Les variables définies
en amont peuvent être utilisées dès l'initialisation des outils. Les capacités
d'historique minimales du module restent appliquées après l'amont ; utiliser
l'aval pour imposer une capacité inférieure si cela est volontaire.

Le fichier partagé charge `~/.zshrc.local` s'il s'agit d'un fichier lisible,
après les alias communs et avant la coloration syntaxique. Il peut donc
redéfinir un alias ou `EDITOR`, et ajouter des chemins personnels. En son
absence, le chargement se poursuit normalement. Ce fichier contient du code
Zsh exécuté au démarrage : n'y placer que des réglages de confiance, sans
charger à nouveau `~/.zshrc`.

Le modèle [zshrc-local.example.zsh](../config/zshrc-local.example.zsh) contient
uniquement des exemples commentés. Il reste hors du paquet Stow et n'est ni
copié ni lié par les scripts. Aucun fichier personnel existant n'est remplacé.

Pour préparer ses préférences, **manuellement sur la machine cible** :

1. Examiner `~/.zshrc.local`, y compris s'il existe comme lien symbolique. S'il
   existe, conserver une copie horodatée avant de l'éditer ; ne pas le remplacer
   par le modèle. S'il n'existe pas, créer un fichier ordinaire à cet emplacement.
2. Reprendre uniquement les exemples utiles et adapter les valeurs. Garder ce
   fichier hors des paquets Stow et ne pas y stocker de secrets.
3. Contrôler sa syntaxe sans le charger : `zsh -n "$HOME/.zshrc.local"`.
4. Après relecture, ouvrir un nouveau terminal sur la machine cible.

Pour désactiver ces ajouts, renommer manuellement ce fichier avec un nom libre,
par exemple `.zshrc.local.desactive.HORODATAGE`, puis ouvrir un nouveau terminal.
Pour annuler une modification, rétablir sa copie après avoir conservé l'état
courant. L'annulation d'un déploiement Stow ne gère pas ce fichier personnel.

Le bilan du dépôt vérifie la syntaxe du modèle ; il ne lit ni n'exécute le
fichier local réel. La compatibilité du mécanisme vise le Zsh fourni avec macOS ;
les outils utilisés dans les préférences personnelles dépendent de la machine.

## Appliquer la configuration avec les scripts

Depuis la racine du dépôt, commencer par une simulation :

```bash
bash scripts/stow_setup.sh --dry-run --packages zsh
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

Le paquet Zsh peut être lié seul : les outils et plugins absents ne sont pas
chargés. Dans le parcours terminal, `--strict` permet d'exiger les outils et
plugins complémentaires, tandis que `--packages` limite le groupe choisi.

## Autre voie : Stow manuel

Ces commandes sont à lancer soi-même sur la machine cible. Elles n'utilisent
ni les sauvegardes automatiques, ni le journal, ni les protections des scripts.
Examiner les fichiers et les options Stow personnels avant de les employer.

```bash
stow --target="$HOME" --restow --no-folding zsh
```

Pour retirer uniquement les liens du paquet :

```bash
stow --target="$HOME" --delete zsh
```

Ce retrait ne restaure pas les anciennes configurations ; voir
[le retour arrière manuel](../docs/retour-arriere.md#annulation-manuelle-sans-journal).
