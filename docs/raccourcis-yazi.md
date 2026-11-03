# Fiche des touches Yazi

Ajouts préparés pour macOS, d'après Yazi 26.9.1. Aucun essai clavier, lancement
d'application, contrôle TOML ni test du presse-papiers n'a été effectué.

## Ajouts du dépôt

| Touche dans la liste des fichiers | Action |
| --- | --- |
| F2 | Ouvrir les éléments sélectionnés, ou celui sous le curseur, dans `VISUAL`, puis `EDITOR`, puis `vi` en repli |
| F3 | Demander à macOS de les ouvrir avec l'application associée |
| F4 | Copier le chemin de l'élément sous le curseur, même si d'autres sont sélectionnés |
| `g` puis `D` majuscule | Aller dans `~/Documents` |
| `g` puis `B` majuscule | Aller dans `~/Desktop`, affiché comme Bureau par macOS |

Sur certains claviers Mac, maintenir `fn` ou la touche Globe pour transmettre
F2, F3 ou F4 au terminal. L'éditeur de F2 doit déjà être disponible. Pour un
éditeur graphique, son mode d'attente est nécessaire afin que Yazi reprenne
après sa fermeture ; par exemple, un `EDITOR` personnel peut contenir les
arguments prévus par cet éditeur. Le parcours Zsh définit déjà `EDITOR=nvim`
si Neovim est disponible, sauf préférence locale ultérieure.

F2 suspend l'affichage de Yazi pendant l'édition ; F3 lance l'ouverture
macOS uniquement lorsque la touche est pressée. Ces actions peuvent ouvrir
plusieurs éléments si une sélection existe. F4 ne copie pas le fichier : il
copie son chemin avec le mécanisme de presse-papiers de Yazi, dont la prise en
charge reste à vérifier avec le terminal cible.

Les raccourcis sont ajoutés après les touches natives. Si une autre version
attribue déjà la même touche, l'action native reste prioritaire. Les dossiers
rapides doivent exister et être accessibles ; aucune création de dossier n'est
effectuée par les raccourcis. Adapter les destinations dans le fichier source
si elles diffèrent sur la machine cible.

## Commandes natives conservées

| Touche | Usage |
| --- | --- |
| `j` / `k`, flèches haut/bas | Parcourir la liste |
| `h` / `l` | Aller au parent / entrer dans un dossier |
| `g` puis `h` | Dossier personnel |
| `g` puis `d` minuscule | Téléchargements (`~/Downloads`) |
| `g` puis `c` | Dossier `~/.config` |
| `c` puis `c` | Copier les chemins des éléments sélectionnés, ou de l'élément sous le curseur |
| `s` / `S` | Recherche avec fd / ripgrep |
| `z` / `Z` | Navigation avec fzf / Zoxide |
| F1 | Consulter l'aide de la version installée |

Ces touches natives dépendent de Yazi et des outils déjà préparés sur la machine
cible. Le dépôt n'ajoute ni plugin ni installation pour ces fonctions.

## Modifier ou annuler

Modifier de préférence la source `yazi/.config/yazi/keymap.toml` dans le dépôt,
après avoir conservé son état antérieur. Une configuration déjà liée reflète
ces modifications au prochain chargement par Yazi. Ne pas éditer à l'aveugle
un fichier personnel préexistant à travers un lien.

Pour retirer une personnalisation, supprimer l'entrée correspondante de
`append_keymap` dans la source. Pour revenir à la configuration antérieure au
déploiement, utiliser [le journal et les sauvegardes](retour-arriere.md).
Ne pas simplement supprimer le fichier source d'un paquet déjà lié : cela
peut laisser un lien cassé. La reprise manuelle de l'application et de
l'annulation est expliquée dans [le guide Yazi](../yazi/README.md).
