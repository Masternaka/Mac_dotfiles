# Mac_dotfiles

Configurations macOS organisées en paquets GNU Stow. La préparation du Mac,
le diagnostic et le déploiement sont documentés dans [Mac_setup](https://github.com/Masternaka/Mac_setup#préparer-zsh-ghostty-yazi-et-bat).

## Configurations

| Paquet | Destination |
| --- | --- |
| [Zsh](zsh/README.md) | `~/.zshrc` et `~/.config/zsh/` |
| [Ghostty](ghostty/README.md) | `~/.config/ghostty/config` |
| [Yazi](yazi/README.md) | `~/.config/yazi/yazi.toml` et `~/.config/yazi/keymap.toml` |
| [Bat](bat/README.md) | `~/.config/bat/config` |
| [Starship](starship/README.md) | `~/.config/starship.toml` et `~/.config/starship-latte.toml` |

`config/` contient les modèles de préférences Zsh et Ghostty à adapter pour
chaque Mac. Chaque paquet possède son propre fichier `.stow-local-ignore`.
Voir [l’organisation des configurations](docs/organisation-configuration.md).

## Utilisation

- Mac_setup déploie Zsh, Ghostty, Yazi, Bat et Starship avec GNU Stow. Sur le Mac
  cible, il installe les outils et plugins manquants avec `--apply`.
- Pour lier un seul paquet avec GNU Stow, suivre le
  [guide de première utilisation](docs/premiere-utilisation.md).
- Avant toute application, suivre les [contrôles statiques](docs/verification.md)
  et le [protocole sur un macOS jetable](docs/validation-avant-application.md).
- Pour restaurer une configuration, conserver les journaux et sauvegardes et
  suivre le [guide de retour arrière](docs/retour-arriere.md).

La [revue historique](docs/revue-coherence.md) conserve les résultats de
l’ancien parcours de déploiement.
