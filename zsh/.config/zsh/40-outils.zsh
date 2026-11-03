# Fragment Zsh chargé par ~/.zshrc ; ne pas lancer comme script.
# --- Initialisations des outils ---
# Le choix clair est explicite ; une configuration Starship personnelle prévaut.
if [[ -z ${STARSHIP_CONFIG+x} && ${DOTFILES_APPARENCE:-sombre} == clair && -r "$HOME/.config/starship-latte.toml" ]]; then
    export STARSHIP_CONFIG="$HOME/.config/starship-latte.toml"
fi
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi
