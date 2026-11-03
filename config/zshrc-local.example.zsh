# Exemple de préférences Zsh propres à une machine.
# Destination prévue : ~/.zshrc.local, à créer manuellement après relecture.
# Ce fichier est un fragment de configuration, pas un script à lancer.
# Chargement : après les fragments et alias partagés, avant la coloration.
# Les variables nécessaires AVANT initialisation vont dans ~/.zshrc.local.pre.
# Voir config/zshrc-local-pre.example.zsh.
# Aucun exemple n'est activé par défaut : décommenter uniquement ce qui convient.

# Ajouter un dossier personnel au PATH, uniquement s'il existe.
# typeset -U évite les doublons lors du chargement répété de la configuration.
# if [[ -d "$HOME/.local/bin" ]]; then
#     typeset -U path PATH
#     path=("$HOME/.local/bin" "${path[@]}")
# fi

# Choisir un éditeur différent pour cette machine.
# export EDITOR='vi'

# Ajouter un alias personnel ou remplacer un alias partagé.
# alias projets='cd "$HOME/Projets"'

# Adapter les vues Eza, uniquement si l'outil est disponible.
# Exemple : conserver les fichiers cachés dans l'arbre, toujours limité à 2 niveaux.
# if command -v eza >/dev/null 2>&1; then
#     alias lt='eza --tree --level=2 --all --icons=auto --group-directories-first'
# fi

# Adapter la capacité de l'historique sur cette machine.
# Garder HISTSIZE supérieur à SAVEHIST pour la gestion des doublons.
# HISTSIZE=40000
# SAVEHIST=20000

# Désactiver les filtres de doublons de la configuration partagée, si souhaité.
# unsetopt HIST_IGNORE_DUPS HIST_FIND_NO_DUPS HIST_EXPIRE_DUPS_FIRST

# Revenir à une complétion sensible à la casse uniquement.
# zstyle ':completion:*' matcher-list ''

# Désactiver l'aperçu Ctrl+T fourni ici tout en gardant fzf.
# export FZF_CTRL_T_OPTS=''

# Adapter la présentation de fzf sur cette machine.
# Les couleurs ANSI proposées par le dépôt suivent la palette du terminal.
# Une valeur personnelle ici remplace entièrement les options de la variable.
# export FZF_DEFAULT_OPTS='--height=50% --layout=reverse --border=rounded'
# export FZF_CTRL_R_OPTS="--height=50% --prompt='Historique > '"
# export FZF_ALT_C_OPTS="--height=40% --prompt='Dossiers > '"
# Pour modifier Ctrl+T en conservant son aperçu, reprendre aussi son --preview.

# Personnaliser fzf-tab séparément, sans importer FZF_DEFAULT_OPTS.
# zstyle ':fzf-tab:*' fzf-flags '--border=rounded' '--color=hl:4,pointer:5,marker:2'

# Redéfinir un raccourci dans le mode d'édition utilisé sur cette machine.
# Exemple : Ctrl+E accepte la suggestion entière avec zsh-autosuggestions.
# À décommenter uniquement si ce plugin est chargé.
# bindkey -M emacs '^E' autosuggest-accept

# Pages man colorées avec Bat, uniquement si l'on souhaite ce pager personnel.
# Examiner et conserver l'ancienne valeur de MANPAGER avant d'activer ce bloc.
# if command -v bat >/dev/null 2>&1 && command -v col >/dev/null 2>&1; then
#     export MANPAGER="sh -c 'col -bx | bat --language=man --style=plain --paging=always'"
# fi

# Conserver ici uniquement des réglages de confiance, sans identifiants ni jetons.
# Ne pas charger à nouveau ~/.zshrc depuis ce fichier : cela créerait une boucle.
