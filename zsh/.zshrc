# Configuration Zsh — destinée à ~/.zshrc, avec ses fragments via GNU Stow.
# Préférences de démarrage propres à la machine, non gérées par Stow.
if [[ -f "$HOME/.zshrc.local.pre" && -r "$HOME/.zshrc.local.pre" ]]; then
    source "$HOME/.zshrc.local.pre"
fi

# Ordre explicite : conserver ensemble le chargeur et les fragments du paquet.
_dotfiles_zsh_dir="$HOME/.config/zsh"
for _dotfiles_zsh_module in \
    10-environnement.zsh 20-historique.zsh 30-completion.zsh 40-outils.zsh \
    50-recherche.zsh 60-edition.zsh 70-alias.zsh; do
    if [[ ! -f "$_dotfiles_zsh_dir/$_dotfiles_zsh_module" || ! -r "$_dotfiles_zsh_dir/$_dotfiles_zsh_module" ]]; then
        printf '[ERREUR] Fragment Zsh absent ou illisible : %s\n' "$_dotfiles_zsh_dir/$_dotfiles_zsh_module" >&2
        unset _dotfiles_zsh_dir _dotfiles_zsh_module
        return 1
    fi
    source "$_dotfiles_zsh_dir/$_dotfiles_zsh_module"
done
unset _dotfiles_zsh_dir _dotfiles_zsh_module

# Préférences après initialisation : alias, raccourcis et options à remplacer.
if [[ -f "$HOME/.zshrc.local" && -r "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

# Initialiser la coloration avant la recherche d’historique.
if [[ -r "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Charger la recherche d’historique après la coloration, comme le plugin le demande.
_dotfiles_brew_prefix="${HOMEBREW_PREFIX:-}"
if [[ -z "$_dotfiles_brew_prefix" ]] && command -v brew >/dev/null 2>&1; then
    _dotfiles_brew_prefix="$(brew --prefix 2>/dev/null)" || _dotfiles_brew_prefix=''
fi
_dotfiles_history_search="$_dotfiles_brew_prefix/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
if [[ "$_dotfiles_brew_prefix" == /* && -f "$_dotfiles_history_search" && -r "$_dotfiles_history_search" ]]; then
    if source "$_dotfiles_history_search"; then
        for _dotfiles_keymap in emacs viins; do
            bindkey -M "$_dotfiles_keymap" $'\e[A' history-substring-search-up
            bindkey -M "$_dotfiles_keymap" $'\e[B' history-substring-search-down
            bindkey -M "$_dotfiles_keymap" $'\eOA' history-substring-search-up
            bindkey -M "$_dotfiles_keymap" $'\eOB' history-substring-search-down
        done
    fi
fi
unset _dotfiles_brew_prefix _dotfiles_history_search _dotfiles_keymap
