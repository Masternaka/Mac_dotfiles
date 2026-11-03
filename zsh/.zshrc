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

# La coloration syntaxique reste en dernier.
if [[ -r "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
