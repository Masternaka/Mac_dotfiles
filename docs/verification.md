# Vérifications statiques

Depuis la racine de Mac_dotfiles, contrôler les changements sans charger les
configurations ni lancer les applications.

## Zsh et Git

```zsh
for fichier in zsh/.zshrc zsh/.config/zsh/*.zsh config/*.example.zsh; do
    zsh -n "$fichier" || break
done
git diff --check
git diff --cached --check
```

## TOML

Avec Python 3.11 ou ultérieur déjà disponible, vérifier les fichiers TOML avec
`tomllib`.

```bash
python3 -B - <<'PYTHON'
from pathlib import Path
import tomllib

for paquet in ("starship", "yazi"):
    for fichier in sorted(Path(paquet).rglob("*.toml")):
        with fichier.open("rb") as source:
            tomllib.load(source)
        print(fichier)
PYTHON
```

Ces contrôles couvrent la syntaxe. Pour vérifier les options reconnues, les
raccourcis, le rendu et les liens, suivre le [protocole sur un macOS jetable](validation-avant-application.md).
