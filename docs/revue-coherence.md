# Revue de cohérence du déploiement et de l'annulation

Revue du 3 novembre 2026, sur les fichiers de travail comprenant les changements
non commités. ShellCheck est explicitement différé. Cette revue comprend une
lecture du code et des analyses statiques ; aucun script de déploiement ou
d'annulation n'a été exécuté, même en simulation.

Les résultats ci-dessous précèdent les ajouts d'historique, de complétion
tolérante, d'aperçu Ctrl+T et de raccourcis Zsh. Ces ajouts n'ont fait l'objet
d'aucune nouvelle vérification ni de ShellCheck.

La personnalisation Starship sur deux lignes, ajoutée ensuite, reste elle aussi
sans vérification TOML, exécution ou validation visuelle.

L'ajout suivant du paquet Bat, des prérequis de sa sélection, de son diagnostic
et de l'exemple de pager man n'a pas été vérifié. Les résultats ci-dessous ne
valident donc pas l'état actuel de ces fichiers modifiés.

Les raccourcis Yazi et le contrôle TOML prévu pour son nouveau `keymap.toml`
ont également été ajoutés après cette revue, sans nouvelle vérification.

La présentation commune fzf/fzf-tab a ensuite été préparée sans analyse,
chargement ou validation visuelle ; elle n'est pas couverte par les anciens résultats.

Les vues Eza `ll`, `la` et `lt` et leur exemple local sont aussi postérieurs
à cette revue et n'ont pas fait l'objet de nouveaux contrôles.

L'évolution suivante — catalogue partagé, prérequis souples/stricts, contrôle
des chemins, fragments Zsh, fichiers locaux amont/aval, métadonnées de journaux
et variantes Mocha/Latte — n'est pas couverte par cette revue historique.
Aucun nouveau contrôle n'a été lancé. Les comportements préparés sont décrits
dans [le guide d'organisation](organisation-configuration.md).

## Corrections issues de la revue

### Vérifier la sauvegarde avant de retirer le lien lors d'un échec

Le retour arrière automatique pouvait retirer un nouveau lien sans vérifier
d'abord la disponibilité du fichier sauvegardé. Il vérifie maintenant que la
sauvegarde est un fichier ordinaire, non symbolique, dont le contenu correspond
à l'empreinte relevée pendant la préparation. Sinon, il conserve la destination
et signale une restauration manuelle. L'interruption juste avant le déplacement
est distinguée si le fichier d'origine est toujours à sa place, intact.

La même empreinte est enregistrée dans le journal et recontrôlée juste avant le
déplacement initial. Un fichier modifié depuis la préparation bloque cette
étape. L'annulation guidée conserve ses contrôles préalables de l'ensemble du
plan, puis recontrôle chaque entrée avant d'agir.

### Refuser les journaux mal formés sans les interpréter

La lecture TSV est désormais stricte : en-tête, champs et marqueur final doivent
correspondre au format produit. Des tabulations superflues, champs vides et
octets ajoutés après la fin, même sans saut de ligne, sont refusés. Les données
ne sont jamais sourcées ni évaluées. Les contrôles des chemins, doublons,
parents symboliques et empreintes restent nécessaires.

### Permettre de reporter explicitement ShellCheck

`verifier-depot.sh --sans-shellcheck` effectue les autres contrôles et signale
l'analyse différée comme incomplète. Le bilan ne devient donc pas artificiellement
complet. Le hook avant commit conserve ses exigences ; il n'a pas été exécuté
ni activé pendant cette revue.

## Cohérence vérifiée par lecture

| Parcours | Règle conservée |
| --- | --- |
| Menu et sélection directe | Même fonction de déploiement et mêmes protections ; simulation par défaut |
| Préparation Stow | `--adopt` réservé à la simulation ; refus des `.stowrc` implicites |
| Sources | Refus des liens symboliques des paquets et des types non pris en charge |
| Sauvegardes | Chemins horodatés sans écrasement ; empreinte initiale partagée avec le journal |
| Journal | Créé avant les déplacements, privé et ignoré par Git ; aucune création en simulation |
| Annulation | Liens préexistants conservés ; conflit connu bloquant avant le premier retrait |
| Plugins Zsh | Facultatifs, sans installation ; ordre de chargement documenté ; coloration en dernier |
| Préférences locales | Fichier extérieur au paquet Stow ; aucune copie ni modification automatique |

## Contrôles et limites

Les commandes prévues pour les contrôles de cette revue sont :

```bash
bash scripts/verifier-depot.sh --dry-run --sans-shellcheck
zsh -n zsh/.zshrc
zsh -n config/zshrc-local.example.zsh
git diff --check
```

Résultats observés lors de cette revue :

| Contrôle | Résultat |
| --- | --- |
| Syntaxe des six fichiers `scripts/*.sh` et du hook | Réussite avec Bash 3.2.57 |
| Syntaxe `.zshrc` et modèle local | Réussite avec Zsh 5.9 |
| YAML de Lazygit | Réussite syntaxique ; schéma applicatif non validé |
| Espaces Git et cibles des liens Markdown locaux | Aucun problème détecté ; contrôle Git limité aux fichiers suivis |
| Bilan complet avec `--sans-shellcheck` | Code `2` : 11 contrôles réussis, 0 échecs, 4 contrôles incomplets, 18 dépendances absentes |
| ShellCheck | Différé explicitement, non lancé |
| Trois configurations TOML | Non contrôlées : `tomllib` indisponible dans le Python de cette session |
| Déploiement, annulation et plugins interactifs | Non exécutés |

Les dépendances absentes correspondent au PATH de cette session d'analyse,
pas à une preuve d'absence de toute installation sur la machine.
Les versions observées et celles encore à déterminer figurent dans
[la matrice de compatibilité](compatibilite.md).

Le déploiement et l'annulation ne sont pas des transactions atomiques. Les accès
concurrents, changements de chemins pendant les opérations, `KILL` et coupures
électriques restent hors de la garantie du retour automatique. Une empreinte
CRC n'authentifie pas les journaux et sauvegardes. Un journal ancien ne doit
pas être rejoué sur un lien identique recréé depuis un autre déploiement.

La validation réelle dans un macOS jetable reste à effectuer manuellement avec
[le protocole détaillé](validation-avant-application.md). La revue statique ne
remplace aucun de ces scénarios et ne certifie pas l'application sur un Mac.
