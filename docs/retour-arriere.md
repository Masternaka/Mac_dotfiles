# Retour arrière

Ces commandes sont des instructions à relire et à lancer soi-même sur la machine
cible. Elles n'ont pas été exécutées pendant le développement.

## Annulation guidée avec un journal

Pour retrouver les journaux, paquets et derniers états horodatés :

```bash
bash scripts/lister-deploiements.sh --dry-run
```

Le fichier voisin `.events` contient des métadonnées informatives, distinctes
du plan TSV. Les anciens journaux restent indiqués avec un état inconnu.
La liste ne vérifie pas les sauvegardes ni les liens ; elle ne choisit pas
automatiquement un journal à rejouer. Voir
[les états et leurs limites](organisation-configuration.md#lecture-des-journaux).

Les nouvelles annulations enregistrent un état de début, de fin ou de reprise
incomplète. Un journal enregistré comme `annule` ou `retour-automatique` est
laissé sans nouvelle action. Les journaux encore marqués `applique` restent à
examiner selon l'ordre des opérations ; ces marqueurs ne sont pas une preuve
de l'état présent du système de fichiers.

Les nouveaux déploiements conservent un journal local dans `.deployments/` du
clone, créé avant tout déplacement de configuration. Son chemin est affiché
pendant l'application. En simulation, aucun journal n'est créé. Les sauvegardes
restent à côté des fichiers d'origine ; le journal ne les remplace pas.

Depuis le même clone, sur le même compte de la machine cible, préparer le plan :

```bash
bash scripts/annuler-deploiement.sh --dry-run --journal .deployments/IDENTIFIANT.tsv
```

Remplacer `IDENTIFIANT.tsv` par le journal exact. Après relecture, remplacer
`--dry-run` par `--apply` pour confirmer le retrait des liens attendus et la
remise en place des sauvegardes. Aucun paquet complet n'est supprimé : les liens
qui existaient avant ce déploiement sont conservés.

Le script lit le journal comme des données et vérifie tous les chemins avant
la première action. Il refuse les journaux incomplets, les destinations en
double, les traversées de chemin, un autre clone ou compte, les parents
symboliques, les sources devenues symboliques et les liens vers d'autres cibles.
Une sauvegarde doit être un fichier ordinaire dont le contenu correspond à
l'empreinte CRC enregistrée. Cette empreinte détecte des changements ordinaires ;
ce n'est pas une authentification cryptographique du journal ou des sauvegardes.

Une destination modifiée est conservée et bloque l'annulation. Si une sauvegarde
manque, le script ne retire pas le lien : il s'arrête, sauf si le fichier
d'origine se trouve déjà à destination avec l'empreinte attendue. Les chemins
déjà restaurés et les liens déjà retirés sont laissés tels quels. Une source
supprimée peut empêcher de reconnaître un lien : examiner alors le cas
manuellement, sans le remplacer de force.

Utiliser les journaux du plus récent au plus ancien, immédiatement après
inspection de la simulation. Un journal ancien ne permet pas de distinguer un
lien identique recréé plus tard : ne pas le réutiliser après un nouveau déploiement.
Ne pas déplacer le clone, éditer les destinations ou lancer deux opérations
simultanément. Le script recontrôle chaque chemin avant d'agir, mais n'offre
ni verrouillage concurrent ni transaction atomique.

Le journal est conservé, les sauvegardes restaurées sont déplacées à destination,
et les dossiers vides ne sont pas supprimés. Une interruption peut laisser une
annulation partielle : refaire une simulation avec le même journal avant de
reprendre. Aucun retour automatique à la configuration déployée n'est tenté.
Pour la remettre, relancer d'abord la simulation du déploiement souhaité.

Les parcours d'application et d'annulation n'ont pas été exécutés sur ce Mac.
Ils restent à valider manuellement dans un macOS jetable, selon
[le guide de validation](validation-avant-application.md).

## Après une application échouée

Le script tente automatiquement de restaurer les fichiers déplacés si Stow
échoue, si la vérification finale échoue ou après une interruption `INT`/`TERM`.
Il ne supprime que les nouveaux liens pointant vers les sources attendues ;
les liens déjà corrects avant l'opération sont conservés.

Avant de retirer un nouveau lien remplaçant un fichier ordinaire, le retour
automatique vérifie aussi la présence et l'empreinte de la sauvegarde. Si elle
est absente, symbolique ou altérée, la destination est conservée et une
restauration manuelle est signalée.

Si une destination a été occupée ou si un dossier parent est devenu symbolique,
la restauration de ce chemin est refusée : lire le chemin de sauvegarde affiché
et examiner la situation avant toute action manuelle. Une interruption `KILL`
ou une coupure électrique peut empêcher la restauration automatique. Des dossiers
vides créés pendant la tentative peuvent subsister.

**Ne pas commencer par retirer tous les paquets après un échec** : cela
retirerait aussi des liens qui étaient corrects avant la tentative. Restaurer
uniquement les chemins signalés, comme expliqué aux étapes 2 à 4 ci-dessous.

## Annulation manuelle sans journal

1. Depuis la racine du même clone, retirer uniquement les paquets appliqués :

```bash
stow --target="$HOME" --delete ghostty herdr starship yazi zsh
```

Ajouter `lazygit` si son paquet a été appliqué. Sa sauvegarde se trouve à côté
de `~/Library/Application Support/lazygit/config.yml` : conserver les guillemets
autour de ces chemins contenant des espaces.

Pour Bat, ajouter `bat` uniquement si son paquet a été lié. Sa configuration
est `~/.config/bat/config` et ses sauvegardes sont à côté de ce fichier. Le
retrait ne modifie ni un éventuel cache de thèmes ni le `MANPAGER` personnel.

2. Consulter les chemins de sauvegarde affichés pendant l'application. Les
   sauvegardes sont à côté des fichiers d'origine, avec le suffixe
   `.backup.HORODATAGE`, éventuellement suivi d'un numéro. Choisir la sauvegarde
   correspondant à l'état voulu ; ne pas toutes les restaurer successivement.
3. Vérifier que la destination n'existe plus, y compris comme lien symbolique.
   Si elle existe, s'arrêter et l'examiner avant tout remplacement.
4. Restaurer chaque sauvegarde en utilisant ses chemins exacts. Par exemple,
   remplacer la valeur ci-dessous par le véritable chemin affiché :

```bash
sauvegarde="$HOME/.zshrc.backup.HORODATAGE"
destination="$HOME/.zshrc"
if { [ -e "$sauvegarde" ] || [ -L "$sauvegarde" ]; } &&
   [ ! -e "$destination" ] && [ ! -L "$destination" ]; then
    mv -i "$sauvegarde" "$destination"
else
    printf '%s\n' 'Restauration non effectuée : vérifier les deux chemins.'
fi
```

Répéter avec les chemins exacts pour les configurations sous `~/.config`.
Les fichiers qui n'existaient pas avant application n'ont pas de sauvegarde :
le retrait du lien suffit. Les scripts n'installent aucun logiciel ; il n'y a
pas de désinstallation de dépendances à effectuer.

Après restauration, ouvrir une nouvelle session de terminal sur la machine cible.

Pour retirer l'automatisation avant commit, suivre la section de désactivation
du [guide de vérification](verification.md). Elle est indépendante des liens Stow.
