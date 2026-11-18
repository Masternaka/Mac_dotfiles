# Fragment Zsh chargé par ~/.zshrc ; ne pas lancer comme script.
# --- Homebrew (Apple Silicon ou Intel) ---
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# --- Variables d'environnement ---
if [[ -z ${LANG+x} ]]; then
    export LANG=en_US.UTF-8
fi
