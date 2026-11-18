# Retour arrière

## Déploiement réalisé avec Mac_setup

Utiliser le fichier `liens.tsv` du dossier `~/.mac-setup-backup.XXXXXXXX`
affiché par Mac_setup. Suivre son [guide de retour arrière](https://github.com/Masternaka/Mac_setup#retour-arrière)
pour vérifier les destinations, conserver les liens préexistants et remettre
les fichiers sous `fichiers/` à leur emplacement d’origine.

## Ancien déploiement Mac_dotfiles

Conserver ensemble les journaux `.deployments/*.tsv`, leurs fichiers
`.events` et les sauvegardes situées à côté des fichiers d’origine
(`*.backup.HORODATAGE.PID`, avec un suffixe numérique éventuel). Les journaux
restent ignorés par Git.

Lire le journal comme du texte. Son en-tête `mac-os-dotfiles-v1` indique le
clone et le dossier personnel utilisés. Chaque ligne `file` donne le paquet,
le chemin relatif au dossier personnel, l’état initial, le chemin exact de
sauvegarde et son empreinte `cksum`. La ligne `end` indique le nombre
d’entrées. Le fichier `.events` associé, s’il existe, consigne les étapes déjà
enregistrées.

1. Identifier le déploiement et vérifier que le journal est complet. En cas
   d’échec, d’interruption ou d’annulation déjà enregistrée, examiner l’état
   actuel de chaque destination et sauvegarde. Pour plusieurs déploiements
   sur les mêmes chemins, commencer par le plus récent.
2. Conserver les entrées `owned`, qui désignent les liens préexistants.
3. Pour une entrée `absent`, retirer le lien seulement s’il pointe toujours
   vers le fichier attendu du clone et correspond à ce déploiement.
4. Pour une entrée `backup`, vérifier d’abord que la sauvegarde exacte est un
   fichier ordinaire, que son empreinte correspond et que les parents et la
   destination sont ceux attendus. Retirer ensuite le lien vérifié et remettre
   une copie de la sauvegarde à la destination libérée, sans écraser un fichier.
   Conserver la sauvegarde d’origine.

En cas de doute sur un lien, une empreinte ou un chemin, laisser l’entrée en
place. Un lien de même cible peut avoir été recréé lors d’un autre déploiement.

Si un lien vise encore un paquet retiré du dépôt, sa cible peut être absente.
Sur le Mac cible, comparer le chemin affiché par `readlink` avec le clone et
le fichier source attendus. Pour un ancien lien replié par Stow, examiner
aussi les dossiers parents. Retirer uniquement le lien dont l’origine est
confirmée, puis restaurer la sauvegarde à la destination libérée, si elle
existe.

## Lien créé manuellement avec GNU Stow

Depuis la racine de Mac_dotfiles sur le Mac cible, simuler le retrait du paquet
concerné. Exemple pour Bat.

```bash
stow --dir="$PWD" --target="$HOME" --no-folding --simulate --verbose --delete bat
```

Vérifier que les liens annoncés appartiennent à ce déploiement. Après relecture,
reprendre la commande sans `--simulate`, puis remettre les fichiers sauvegardés
à leurs destinations libérées. Le retrait concerne les liens. La restauration
des fichiers et des préférences locales se fait à partir de leurs copies.
