# Yazi

Configuration simple pour [Yazi](https://yazi-rs.github.io), le gestionnaire de fichiers terminal.

## Contenu

- `.config/yazi/yazi.toml` : configuration principale, destinée à `~/.config/yazi/yazi.toml`.
- `.config/yazi/keymap.toml` : raccourcis supplémentaires, destiné à `~/.config/yazi/keymap.toml`.

## Réglages

- Panneau d'aperçu plus large (`ratio = [1, 3, 4]`).
- Tri naturel et dossiers affichés en premier.
- Taille des fichiers affichée dans la liste (`linemode = "size"`).
- Fichiers cachés masqués par défaut, à afficher avec la touche `.`.
- Aperçu limité à 1000 × 1000 pixels.

Les raccourcis natifs restent prioritaires. Le fichier `keymap.toml` ajoute
des commandes avec `append_keymap`, sans remplacer la table native.
La [fiche des touches](../docs/raccourcis-yazi.md) résume les ajouts et les
commandes existantes utiles.

Les ajouts sont préparés à partir de la documentation **Yazi 26.9.1** et
emploient les paramètres `%s` de cette version. Il s'agit d'une cible
documentaire, pas d'une version installée ou validée. Une ancienne version
utilisant d'autres paramètres de shell peut demander une adaptation.

## Déploiement

Vérifier `YAZI_CONFIG_HOME` si Yazi utilise un chemin personnalisé. Le paquet
fournit `yazi.toml` et `keymap.toml`. Les aperçus et la recherche dépendent
des outils disponibles sur le Mac cible.

Suivre la [première utilisation](../docs/premiere-utilisation.md) pour
prévisualiser le déploiement avec Mac_setup ou lier le paquet seul avec
GNU Stow. Pour restaurer une configuration, suivre le
[guide de retour arrière](../docs/retour-arriere.md).

## Lancement

Avec la configuration Zsh du dépôt, taper `y` pour ouvrir Yazi dans le
dossier courant. Pour ouvrir un autre dossier, utiliser par exemple
`y ~/Documents`.

- `q` quitte Yazi et place le terminal dans le dernier dossier visité.
- `Q` quitte Yazi et laisse le terminal dans son dossier de départ.

La commande `yazi` ouvre aussi l’application, avec un dossier du terminal
qui reste celui de départ à la fermeture. [Guide officiel de Yazi](https://yazi-rs.github.io/docs/quick-start/#shell-wrapper)

## Référence

- Documentation : https://yazi-rs.github.io/docs/configuration/overview/
- Schéma de configuration : https://yazi-rs.github.io/schemas/yazi.json
- Raccourcis : https://yazi-rs.github.io/docs/configuration/keymap/
- [Raccourcis natifs de référence 26.9.1](https://github.com/sxyazi/yazi/blob/v26.9.1/yazi-config/preset/keymap-default.toml)
