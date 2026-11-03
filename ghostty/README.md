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

## Appliquer la configuration avec les scripts

Depuis la racine du dépôt, commencer par une simulation :

```bash
bash scripts/stow_setup.sh --dry-run --packages ghostty
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

## Autre voie : Stow manuel

Ces commandes sont à lancer soi-même sur la machine cible. Elles n'utilisent
ni les sauvegardes automatiques, ni le journal, ni les protections des scripts.
Examiner les fichiers et les options Stow personnels avant de les employer.

```bash
stow --target="$HOME" --restow --no-folding ghostty
```

Pour retirer uniquement les liens du paquet :

```bash
stow --target="$HOME" --delete ghostty
```

Ce retrait ne restaure pas les anciennes configurations ; voir
[le retour arrière manuel](../docs/retour-arriere.md#annulation-manuelle-sans-journal).
