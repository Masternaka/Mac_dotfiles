# Fragment Zsh chargé par ~/.zshrc ; ne pas lancer comme script.
# --- Alias CLI modernes ---
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    # Liste détaillée sans grille, variante avec fichiers cachés, arbre limité.
    alias ll='eza --long --header --icons=auto --group-directories-first'
    alias la='eza --long --header --all --icons=auto --group-directories-first'
    alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
fi
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi
alias g='git'

