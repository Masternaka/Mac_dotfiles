# Fragment Zsh chargé par ~/.zshrc ; ne pas lancer comme script.
# --- Raccourcis d'édition (sans changer le mode Emacs ou Vi choisi) ---
for _dotfiles_keymap in emacs viins; do
    bindkey -M "$_dotfiles_keymap" '^A' beginning-of-line
    bindkey -M "$_dotfiles_keymap" '^E' end-of-line
    # Échap puis B/F fonctionne aussi sans touche Option configurée comme Alt.
    bindkey -M "$_dotfiles_keymap" '\eb' backward-word
    bindkey -M "$_dotfiles_keymap" '\ef' forward-word
    bindkey -M "$_dotfiles_keymap" '\e[1;3D' backward-word
    bindkey -M "$_dotfiles_keymap" '\e[1;3C' forward-word
done
# Charger la fonction native sans l'exécuter ; ne lier que si elle est disponible.
if autoload -Uz +X edit-command-line 2>/dev/null; then
    zle -N edit-command-line
    for _dotfiles_keymap in emacs viins; do
        bindkey -M "$_dotfiles_keymap" '^X^E' edit-command-line
    done
fi
unset _dotfiles_keymap

if [[ -r "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

