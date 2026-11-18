# Apparence de fzf et fzf-tab

La présentation est définie dans le fragment Zsh de recherche. Le rendu et
les versions compatibles restent à vérifier dans le terminal.

## Couleurs et fenêtres

Les couleurs utilisent les emplacements ANSI de la palette du terminal : bleu
pour les correspondances et la recherche, magenta pour le pointeur, vert pour
les éléments marqués et gris pour la bordure. La ligne sélectionnée dispose
d'un fond distinct ; le reste conserve le fond et le texte du terminal.

Dans Ghostty configuré avec Catppuccin, ces couleurs reprennent donc sa palette
claire ou sombre. Ce n'est pas un thème fzf autonome nommé Catppuccin et aucune
détection de l'apparence macOS n'est ajoutée. Dans un autre terminal, le rendu
dépend de sa palette ANSI. Le contraste réel reste à valider dans chaque mode.

| Contexte | Présentation par défaut préparée |
| --- | --- |
| fzf lancé directement | Hauteur de 50 % du terminal, recherche en haut, bordure arrondie |
| Ctrl+R : historique | Hauteur de 40 %, invite `Historique > ` ; aucun aperçu ajouté |
| Ctrl+T : fichiers | Hauteur de 60 %, invite `Fichiers > ` ; aperçu Bat à droite sur la moitié de la fenêtre si Bat est disponible |
| Alt+C : dossiers | Hauteur de 50 %, invite `Dossiers > ` ; aucun aperçu ajouté |
| Tab : fzf-tab | Mêmes couleurs et bordure ; disposition et dimensionnement propres au plugin conservés |

Dans Ctrl+T, les longues lignes de l'aperçu sont repliées visuellement et la
lecture reste limitée aux 300 premières lignes. Les dossiers et fichiers
illisibles n'ont pas d'aperçu. La configuration n'ajoute ni commande de
suppression, ni changement du tri ou du contenu des résultats.

La bordure, les couleurs et la disposition proposées au fzf général peuvent
aussi apparaître dans les autres outils qui l'invoquent. Ces outils peuvent
imposer leurs propres options. Les touches existantes de validation et
d'annulation ne sont pas redéfinies par cet ajout.

## Préférences personnelles

La configuration fournit uniquement des valeurs par défaut :

- `FZF_DEFAULT_OPTS` est défini uniquement si ni cette variable ni
  `FZF_DEFAULT_OPTS_FILE` ne sont déjà définies. Une valeur vide est respectée.
- `FZF_CTRL_R_OPTS`, `FZF_CTRL_T_OPTS` et `FZF_ALT_C_OPTS` sont chacune définies
  uniquement si elles ne le sont pas déjà, même avec une valeur vide.
- Les options propres à un raccourci peuvent préciser une hauteur différente
  de celle héritée des options générales. Une valeur personnelle de la variable
  correspondante reste intacte.
- Les `fzf-flags` génériques déjà configurés pour fzf-tab sont conservés.
  Les styles plus spécifiques de l'utilisateur restent également prioritaires.

Les réglages de fzf-tab sont distincts de `FZF_DEFAULT_OPTS` : la configuration
n'active pas leur import automatique. Un import activé ailleurs par l'utilisateur
peut modifier le résultat. Le modèle
[zshrc-local.example.zsh](../config/zshrc-local.example.zsh) contient des
exemples commentés pour personnaliser ces variables et ce style séparément.

Pour personnaliser sur la machine cible, conserver d'abord les réglages actuels,
puis reprendre les exemples utiles dans `~/.zshrc.local`. Ce fichier est chargé
après la préparation des valeurs partagées. Chaque variable remplacée prend
une valeur complète : pour garder l'aperçu Bat dans une personnalisation de
Ctrl+T, reprendre aussi son option `--preview`.

## Désactivation et retour arrière

Pour retirer les options générales proposées, définir une valeur personnelle
de `FZF_DEFAULT_OPTS`, par exemple vide, dans le fichier local. Les options
spécifiques des raccourcis restent indépendantes : les redéfinir séparément si
nécessaire. Pour fzf-tab, redéfinir son style `fzf-flags`, par exemple avec une
liste vide. Ne pas activer un import global d'options pour contourner ce réglage.

Pour revenir à l'état antérieur au déploiement Zsh, suivre
[le guide de retour arrière](retour-arriere.md), puis ouvrir soi-même un
nouveau terminal sur la machine cible. Les variables exportées dans un terminal
déjà ouvert ne sont pas réinitialisées par la seule modification du fichier.
La reprise d'une ancienne configuration ne modifie pas le fichier local personnel.

Références : [options de fzf](https://github.com/junegunn/fzf/blob/master/man/man1/fzf.1),
[configuration de fzf-tab](https://github.com/Aloxaf/fzf-tab#configure).
