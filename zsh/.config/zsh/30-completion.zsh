# Fragment Zsh chargé par ~/.zshrc ; ne pas lancer comme script.
# --- Complétion ---
# Les définitions supplémentaires doivent être connues avant compinit.
if [[ -d "$HOME/.zsh/zsh-completions/src" && -r "$HOME/.zsh/zsh-completions/src" && -x "$HOME/.zsh/zsh-completions/src" ]]; then
    typeset -U fpath
    fpath=("$HOME/.zsh/zsh-completions/src" "${fpath[@]}")
fi
autoload -Uz compinit
compinit
# Essayer la casse exacte, puis ignorer les différences de majuscules/minuscules.
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

