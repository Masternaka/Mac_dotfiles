# Herdr

Configuration simple pour [Herdr](https://herdr.dev), le multiplexeur de terminaux orienté agents.

## Contenu

- `.config/herdr/config.toml` : configuration principale, destinée à `~/.config/herdr/config.toml`.

## Réglages

- `onboarding = false` : passe l'assistant de premier lancement.
- Thème Catppuccin avec bascule automatique clair/sombre (`catppuccin-latte` en clair).
- Shell de connexion pour les nouveaux panneaux (`shell_mode = "auto"`).
- Nouveaux panneaux ouverts dans le répertoire courant (`new_cwd = "follow"`).
- Bordures automatiques et indicateurs d'état sous forme de symboles.
- Notifications intégrées à Herdr, en bas à droite.

Les raccourcis clavier restent ceux par défaut, avec le préfixe `ctrl+b`.

## Appliquer la configuration avec les scripts

Depuis la racine du dépôt, commencer par une simulation :

```bash
bash scripts/stow_setup.sh --dry-run --packages herdr
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
stow --target="$HOME" --restow --no-folding herdr
```

Pour retirer uniquement les liens du paquet :

```bash
stow --target="$HOME" --delete herdr
```

Ce retrait ne restaure pas les anciennes configurations ; voir
[le retour arrière manuel](../docs/retour-arriere.md#annulation-manuelle-sans-journal).

## Recharger la configuration

Après une modification du fichier :

```bash
herdr server reload-config
```

Ou via le menu global de Herdr, action `reload config`.

## Référence

- Configuration : https://herdr.dev/docs/configuration/
- Référence complète : https://herdr.dev/docs/config-reference/
