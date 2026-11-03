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
La configuration et le diagnostic modifié n'ont été ni analysés ni exécutés.

## Appliquer la configuration avec les scripts

Depuis la racine du dépôt, commencer par une simulation :

```bash
bash scripts/yazi_setup.sh --dry-run
```

Ce parcours exige Yazi et signale les outils de prévisualisation ou recherche
absents. Ajouter `--strict` pour exiger tous les compléments avant toute sauvegarde.
Sans eux, les fonctions correspondantes peuvent être indisponibles.
Il lie les deux fichiers du paquet et sauvegarde leurs anciennes versions
ordinaires si elles existent. Les autres fichiers personnels du dossier Yazi,
comme un éventuel `theme.toml` ou `init.lua`, ne sont pas remplacés par ce paquet.
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

## Autre voie : Stow manuel

Ces commandes sont à lancer soi-même sur la machine cible. Elles n'utilisent
ni les sauvegardes automatiques, ni le journal, ni les protections des scripts.
Examiner les fichiers et les options Stow personnels avant de les employer.

```bash
stow --target="$HOME" --restow --no-folding yazi
```

Pour retirer uniquement les liens du paquet :

```bash
stow --target="$HOME" --delete yazi
```

Ce retrait ne restaure pas les anciennes configurations ; voir
[le retour arrière manuel](../docs/retour-arriere.md#annulation-manuelle-sans-journal).

## Lancement

```bash
yazi
```

## Référence

- Documentation : https://yazi-rs.github.io/docs/configuration/overview/
- Schéma de configuration : https://yazi-rs.github.io/schemas/yazi.json
- Raccourcis : https://yazi-rs.github.io/docs/configuration/keymap/
- [Raccourcis natifs de référence 26.9.1](https://github.com/sxyazi/yazi/blob/v26.9.1/yazi-config/preset/keymap-default.toml)
