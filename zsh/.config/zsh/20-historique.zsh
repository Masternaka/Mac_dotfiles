# Fragment Zsh chargé par ~/.zshrc ; ne pas lancer comme script.
# --- Historique persistant ---
# Garder le fichier choisi par macOS ou une configuration antérieure.
# Une valeur explicitement vide reste vide (pas d'enregistrement sur disque).
if [[ -z ${HISTFILE+x} ]]; then
    HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
fi
# Augmenter les petites valeurs sans réduire une capacité déjà supérieure.
if (( SAVEHIST < 10000 )); then
    SAVEHIST=10000
fi
if (( HISTSIZE < 20000 )); then
    HISTSIZE=20000
fi
if (( HISTSIZE <= SAVEHIST )); then
    HISTSIZE=$(( SAVEHIST + 10000 ))
fi
setopt APPEND_HISTORY HIST_IGNORE_DUPS HIST_FIND_NO_DUPS HIST_EXPIRE_DUPS_FIRST
# Ne pas activer ici INC_APPEND_HISTORY, INC_APPEND_HISTORY_TIME ou SHARE_HISTORY :
# ces modes changeraient le comportement de l'historique par session de Terminal.

