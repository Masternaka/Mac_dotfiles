# Première utilisation

## Déployer avec Mac_setup

Sur le Mac cible, conserver le clone de Mac_dotfiles à un emplacement stable.
Depuis la racine du clone voisin Mac_setup, commencer par la simulation
documentée dans son [guide de déploiement](https://github.com/Masternaka/Mac_setup#simulation-et-application).

```bash
bash scripts/zsh-setup.sh --dry-run
```

Mac_setup vérifie les prérequis et prépare les liens pour Zsh, Ghostty, Yazi,
Bat et Starship. Sur le Mac cible, `--apply` installe les outils et les
plugins manquants, puis déploie les cinq paquets. L’option `--dotfiles` permet
d’indiquer un autre emplacement pour le clone de Mac_dotfiles. Relire les
destinations et suivre le guide de Mac_setup pour l’application et les
sauvegardes. Les [versions à valider](compatibilite.md) et le
[protocole d’essai](validation-avant-application.md) aident à préparer un essai
sur un macOS jetable.

## Lier un paquet manuellement avec GNU Stow

Pour lier un seul paquet, se placer à la racine de **Mac_dotfiles** sur le
Mac cible. Préparer GNU Stow et l’application concernée. Examiner les
destinations et les options des éventuels fichiers `~/.stowrc` et `.stowrc`.
Voici la simulation pour Bat.

```bash
stow --dir="$PWD" --target="$HOME" --no-folding --simulate --verbose --stow bat
```

Vérifier les conflits et sauvegarder les fichiers personnels avant de les
déplacer. GNU Stow ne crée pas de sauvegarde ni de journal de restauration pour
cette commande. Après relecture, reprendre la commande sans `--simulate` sur
le Mac cible. Pour un autre paquet, reprendre son nom dans
[la liste des configurations](../README.md#configurations). Pour Zsh, garder
le chargeur et ses sept fragments dans le même paquet.

## Comprendre les liens Stow

Chaque paquet reproduit les chemins relatifs au dossier personnel. Stow crée
des liens vers les fichiers du clone. Un changement du fichier source devient
visible à la prochaine lecture par l’application. Déplacer le clone peut
casser les liens. Déployer depuis un autre clone demande de vérifier d’abord
les liens existants et leurs cibles.

Conserver les préférences propres à chaque Mac dans leurs fichiers locaux.
Les [modèles](../config/) servent de référence. Pour défaire un déploiement,
suivre le [guide de retour arrière](retour-arriere.md).
