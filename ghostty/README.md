# Ghostty (config + thèmes)

Ce dossier contient la configuration **Ghostty** du dépôt, organisée comme un paquet [GNU Stow](https://www.gnu.org/software/stow/).

## 🧩 Contenu

- `.config/ghostty/config` : configuration principale, liée vers `~/.config/ghostty/config`.
- Le thème Catppuccin (Mocha en sombre, Latte en clair) est fourni par Ghostty : aucun fichier de thème séparé n'est nécessaire.

## ⚙️ Ce que fait la configuration

Le fichier `config` contient des réglages pour :

- l'apparence (thème, police, transparence, marges)
- le comportement de la fenêtre (taille, barre de titres, boutons macOS)
- le curseur, le scrollback, les onglets et les splits
- des raccourcis clavier personnalisés (ex. : `cmd+enter` pour le plein écran)

## Police du terminal

La configuration utilise `JetBrainsMono Nerd Font`. Pour obtenir ce rendu,
installer la police manuellement sur le Mac cible. Si Homebrew y est déjà
disponible, le cask correspondant est
[`font-jetbrains-mono-nerd-font`](https://formulae.brew.sh/cask/font-jetbrains-mono-nerd-font).
Mac_setup laisse ce choix à l’utilisateur.

Pour utiliser une autre police, relever le nom de la famille sur le Mac
cible avec `ghostty +list-fonts`. Dans `~/.config/ghostty-local.conf`,
reprendre les deux lignes `font-family` du [modèle local](../config/ghostty-local.example.conf)
et adapter le nom. La première remet à zéro la liste des familles, la
seconde définit la police choisie. Après relecture, recharger Ghostty sur
le Mac cible. [Référence de `font-family`](https://ghostty.org/docs/config/reference#font-family)

## Compatibilité

Les notifications de fin de commande et la barre de défilement sont
disponibles à partir de Ghostty 1.3. L’effet Liquid Glass
`macos-glass-regular` demande aussi macOS 26 ou ultérieur.
[Notes de Ghostty 1.3](https://ghostty.org/docs/install/release-notes/1-3-0) ·
[Référence du flou](https://ghostty.org/docs/config/reference#background-blur)

Le tampon de défilement utilise la limite par défaut de Ghostty. Pour
l’ajuster localement, utiliser le réglage documenté pour la version
installée. [Référence du scrollback](https://ghostty.org/docs/config/reference#scrollback-limit)

## Préférences propres à chaque Mac

Le fichier commun prévoit l'inclusion facultative de
`~/.config/ghostty-local.conf`. Les valeurs de ce fichier prennent effet après
la configuration commune. Le modèle
[ghostty-local.example.conf](../config/ghostty-local.example.conf) propose des
exemples commentés de police, dimensions et opacité.

Sur la machine cible, examiner tout fichier existant et en conserver une copie
datée avant édition. Préparer ce fichier manuellement, hors du clone, après
avoir vérifié que son dossier parent n'est pas un lien vers les sources.
Stow ne le copie pas, ne le sauvegarde pas et ne l'annule pas. Pour désactiver
ces ajouts, renommer le fichier personnel vers un nom libre après sauvegarde,
puis recharger soi-même Ghostty. L'absence du fichier est acceptée.

Cette inclusion reste sans essai ; la version compatible est à établir.
Référence : [config-file](https://ghostty.org/docs/config/reference#config-file).

## Déploiement

Vérifier le fichier de configuration réellement lu si Ghostty utilise aussi
un fichier dans `~/Library/Application Support/com.mitchellh.ghostty/`.

Suivre la [première utilisation](../docs/premiere-utilisation.md) pour
prévisualiser le déploiement avec Mac_setup ou lier le paquet seul avec
GNU Stow. Pour restaurer une configuration, suivre le
[guide de retour arrière](../docs/retour-arriere.md).
