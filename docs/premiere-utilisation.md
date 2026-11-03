# Première utilisation

Ce guide explique comment choisir les scripts et lire leurs résultats. Les
scripts n'installent aucun outil. Toute application réelle est à effectuer
manuellement sur la machine cible, après validation dans un macOS jetable.
Les parcours de déploiement et d'annulation ne sont pas encore validés en
fonctionnement : voir [la compatibilité](compatibilite.md).

## 1. Se placer dans le dépôt

Ouvrir un terminal à la racine du clone : c'est le dossier qui contient
`README.md`, `scripts/`, `ghostty/` et `zsh/`. Les commandes suivantes utilisent
`bash` : il n'est pas nécessaire de rendre les scripts exécutables.

Garder ce clone à un emplacement durable. Lire d'abord
[le fonctionnement des liens](#comprendre-les-liens-stow).

## 2. Choisir ce que l'on veut configurer

Il n'est **pas nécessaire de lancer les trois scripts de déploiement**.
Choisir un parcours selon le besoin :

| Besoin | Parcours |
| --- | --- |
| Un ou plusieurs paquets au choix | `stow_setup.sh --packages ghostty,zsh`, ou son menu sans `--packages` |
| Ghostty, Herdr, Starship et Zsh ensemble, ou sous-ensemble choisi | `terminal_setup.sh`, éventuellement `--packages ghostty,zsh` |
| Yazi, avec signalement des compléments de prévisualisation absents | `yazi_setup.sh` (`--strict` pour les exiger) |

Le menu propose actuellement `bat`, `ghostty`, `herdr`, `starship`, `yazi`, `zsh` et
`lazygit`. `terminal_setup.sh` et `yazi_setup.sh` ne sont pas des étapes
obligatoires après le menu : ils proposent des regroupements avec des prérequis applicatifs et une option
`--strict` pour exiger leurs compléments. Le menu seul ne vérifie pas tous les outils applicatifs, sauf
Lazygit et Delta pour leur paquet, et Bat pour le sien. La présence d'un lien ne prouve pas qu'une
application est installée ou que sa version accepte la configuration.

Le paquet `bat` est facultatif et se choisit séparément ; il n'est pas lié par
`terminal_setup.sh`, même si ce dernier exige déjà l'outil Bat pour le shell.

## 3. Faire le diagnostic

Exemple pour Ghostty et Zsh, en laissant ShellCheck pour plus tard :

```bash
bash scripts/verifier-depot.sh --dry-run --sans-shellcheck --packages ghostty,zsh
```

Le diagnostic lit le dépôt, analyse les syntaxes disponibles et inventorie les
prérequis. Il ne crée aucun lien et n'exécute pas les plugins Zsh. Adapter la
liste aux paquets choisis ; sans sélection, il examine tous les parcours.

| Résultat | Comment le lire |
| --- | --- |
| Code `0` | Contrôles prévus terminés et prérequis requis trouvés ; ne certifie pas le déploiement |
| Code `1` | Une analyse a échoué ; lire et corriger l'erreur |
| Code `2` | Contrôle indisponible, dépendance manquante ou option invalide ; lire les détails |

Avec `--sans-shellcheck`, le bilan reste volontairement incomplet. Un complément
facultatif absent ne bloque pas à lui seul le diagnostic. Les dépendances se
préparent manuellement sur la machine cible ; voir
[la liste des prérequis](../scripts/README.md#prérequis-à-préparer-manuellement).

## 4. Prévisualiser un seul parcours

Pour reprendre l'exemple :

```bash
bash scripts/stow_setup.sh --dry-run --packages ghostty,zsh
```

Autres choix, à utiliser selon le besoin plutôt qu'à lancer systématiquement :

```bash
bash scripts/terminal_setup.sh --dry-run
bash scripts/yazi_setup.sh --dry-run
```

Attendu : les contrôles s'effectuent, les conflits éventuels sont affichés,
puis les sauvegardes, le journal et la commande de liaison sont annoncés en
simulation. **Aucun lien, sauvegarde ni journal n'est créé.** Stow doit déjà
être disponible, car sa propre simulation est réellement exécutée en lecture
seule. Un arrêt faute de dépendance n'est pas une simulation réussie.

Avec le menu, Entrée ou `0` ne sélectionne rien. Sans terminal interactif,
le script ne sélectionne rien non plus, sauf avec `--packages`.

## 5. Appliquer après validation et relecture

Suivre d'abord [les essais dans un macOS jetable](validation-avant-application.md).
Sur la machine cible, reprendre ensuite **la même sélection** et remplacer
`--dry-run` par `--apply`. Exemple à lancer soi-même uniquement après cette étape :

```bash
bash scripts/stow_setup.sh --apply --packages ghostty,zsh
```

Le script enregistre le journal, déplace les fichiers ordinaires existants
vers leurs sauvegardes horodatées et crée les liens. Les liens déjà corrects
sont conservés. Noter les chemins affichés, notamment
`.deployments/IDENTIFIANT.tsv`. Le script ne lance aucune application.
Une erreur après les sauvegardes déclenche une tentative de retour automatique ;
en cas de restauration incomplète, conserver les fichiers et suivre les
messages plutôt que relancer avec d'autres options.

Les préférences sont prises en compte au prochain chargement de la configuration
par l'application. Pour Zsh, ouvrir soi-même un nouveau terminal sur la machine
cible. Consulter le guide du paquet pour les autres modalités de rechargement.

## 6. Préparer une annulation

Pour retrouver les journaux et leur dernier état enregistré :

```bash
bash scripts/lister-deploiements.sh --dry-run
```

Cette liste est informative ; elle ne valide pas les sauvegardes. Reprendre
ensuite le chemin exact du journal de l'application à annuler :

```bash
bash scripts/annuler-deploiement.sh --dry-run --journal .deployments/IDENTIFIANT.tsv
```

`IDENTIFIANT.tsv` est un exemple à remplacer, pas un nom de fichier fourni.
Après examen du plan, `--apply` confirme l'annulation sur la machine cible.
Lire [le guide de retour arrière](retour-arriere.md) : utiliser les journaux du
plus récent au plus ancien, ne pas rejouer un ancien journal après un nouveau
déploiement, et conserver les sauvegardes. Sans journal, suivre le retour manuel.

## Comprendre les liens Stow

Un lien symbolique est un chemin qui renvoie au fichier du dépôt. Par exemple,
`~/.config/ghostty/config` renvoie à `ghostty/.config/ghostty/config` dans ce clone.
Il ne s'agit pas d'une copie indépendante.

- Modifier le contenu du fichier à travers son chemin lié modifie aussi le
  fichier du dépôt. Certains éditeurs peuvent remplacer le lien par un fichier
  ordinaire lors de l'enregistrement : modifier de préférence la source dans
  le dépôt, puis examiner les changements Git.
- Déplacer, renommer ou supprimer le clone peut casser les liens. Avant un
  changement d'emplacement, préparer un retour arrière depuis le clone actuel ;
  les scripts refusent les liens vers un ancien clone.
- Retirer un lien ne restaure pas automatiquement l'ancienne configuration.
  C'est le rôle du journal et des sauvegardes.
- Un `git pull` qui change une configuration liée change aussi le contenu que
  l'application pourra lire. Examiner les modifications avant de mettre à jour.

Les commandes Stow directes documentées dans les guides sont une autre voie,
destinée à une gestion manuelle : elles n'utilisent ni les sauvegardes, ni le
journal, ni les protections ajoutées par les scripts.

## En cas de blocage

| Message ou situation | Suite à donner |
| --- | --- |
| Outil absent du PATH | Vérifier sa disponibilité dans le terminal cible ; le préparer manuellement si nécessaire |
| `.stowrc` détecté | Examiner ses options ; ne pas le supprimer aveuglément pour contourner le refus |
| Lien vers une autre cible ou dossier symbolique refusé | Examiner le lien et son origine ; ne pas forcer l'écrasement |
| Journal introuvable | Utiliser le chemin affiché pendant une application réelle ; une simulation ne produit pas de journal |
| Destination modifiée ou sauvegarde altérée | Conserver les données, arrêter l'annulation et suivre le retour manuel |

Le [catalogue des scripts](../scripts/README.md#quel-script-utiliser) donne les
options exactes. `lib.sh` est une bibliothèque interne, pas une commande à lancer.

Le [guide d'organisation](organisation-configuration.md) détaille également le
catalogue des paquets, les préférences locales en amont/aval et le choix clair
ou sombre de Starship. Ces évolutions n'ont pas été exécutées ni vérifiées.
