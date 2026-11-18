# Bat

Paquet Stow contenant `.config/bat/config`, destiné à `~/.config/bat/config`.
Il complète l'alias Zsh `cat='bat'` et l'aperçu Ctrl+T de fzf déjà préparés.

## Présentation préparée

- Thème intégré `ansi` : reprend les couleurs du terminal, donc sa palette
  Catppuccin lorsque Ghostty l'utilise. Le rendu dépend du terminal choisi.
- En-tête du fichier, numéros de ligne et marques de changements Git, sans grille.
- Pagination automatique ; `q` permet de quitter le pager habituel `less`.
- Couleurs et décorations automatiques, adaptées notamment aux sorties redirigées.

Les options explicites d'une commande peuvent remplacer ces réglages. L'aperçu
fzf conserve ainsi son style avec numéros de ligne, ses couleurs forcées et
sa pagination désactivée. L'alias `cat` peut ouvrir un pager pour un long fichier ;
utiliser `command cat` pour appeler la commande système, ou
`bat --paging=never` pour lire avec Bat sans pagination.

## Déploiement

Vérifier `BAT_CONFIG_PATH` et `XDG_CONFIG_HOME` si Bat utilise un chemin
personnalisé. Le paquet vise `~/.config/bat/config`.

Suivre la [première utilisation](../docs/premiere-utilisation.md) pour
prévisualiser le déploiement avec Mac_setup ou lier le paquet seul avec
GNU Stow. Pour restaurer une configuration, suivre le
[guide de retour arrière](../docs/retour-arriere.md).

## Thème Catppuccin dédié, facultatif

Le thème `ansi` fonctionne sans thème externe. Pour une coloration dédiée
Macchiato, suivre manuellement les instructions du
[projet Catppuccin pour Bat](https://github.com/catppuccin/bat) sur la machine
cible : conserver les fichiers existants, préparer le thème dans le dossier
de thèmes de Bat, puis reconstruire son cache selon ces instructions.
La commande `bat cache --build` reconstruit le cache sur le Mac cible.
Choisir ensuite un thème réellement disponible, par
exemple `--theme="Catppuccin Macchiato"`, en remplaçant l'unique option active
`--theme` du fichier source. Ne pas activer deux lignes de thème simultanément.

Le thème externe et son cache ne sont pas fournis ni gérés par Stow. Leur
compatibilité et leur rendu restent à vérifier sur la machine cible.

## Pages man colorées, facultatif

Le modèle [Zsh local](../config/zshrc-local.example.zsh) contient un bloc
commenté pour `MANPAGER`, à reprendre manuellement dans `~/.zshrc.local` si
souhaité. Il requiert Bat et `col`, utilise une présentation sans en-tête ni
numéros, et prépare une pagination adaptée aux pages longues. Il ne requiert
pas `zsh-bat`. Examiner et conserver toute valeur personnelle de `MANPAGER`
avant de l'activer ; aucun réglage global du pager n'est imposé ici.

Pour désactiver cette option, retirer le bloc personnel ou rétablir l'ancienne
valeur, puis ouvrir un nouveau terminal. Sa compatibilité avec les pages man
du macOS cible n'a pas été testée.

## Référence

Voir [la compatibilité](../docs/compatibilite.md) et
[la documentation Bat](https://github.com/sharkdp/bat#customization).
