# Fragment Zsh chargé par ~/.zshrc ; ne pas lancer comme script.
# Les anciennes versions de fzf ne proposent pas --zsh.
# Couleurs ANSI : suivent notamment la palette Catppuccin du terminal,
# avec son fond par défaut et sans imposer un fond sombre en mode clair.
_dotfiles_fzf_colors='--color=fg:-1,bg:-1,hl:4,fg+:-1,bg+:8,hl+:4,pointer:5,marker:2,prompt:4,spinner:5,info:8,border:8,header:6'
if command -v fzf >/dev/null 2>&1; then
    # Une variable explicitement vide compte aussi comme une préférence.
    if [[ -z ${FZF_DEFAULT_OPTS+x} && -z ${FZF_DEFAULT_OPTS_FILE+x} ]]; then
        export FZF_DEFAULT_OPTS="--height=50% --layout=reverse --border=rounded $_dotfiles_fzf_colors"
    fi
    if [[ -z ${FZF_CTRL_R_OPTS+x} ]]; then
        export FZF_CTRL_R_OPTS="--height=40% --prompt='Historique > '"
    fi
    if [[ -z ${FZF_ALT_C_OPTS+x} ]]; then
        export FZF_ALT_C_OPTS="--height=50% --prompt='Dossiers > '"
    fi
    # Personnaliser seulement Ctrl+T, en respectant toute valeur déjà définie.
    # fzf protège les chemins substitués dans {} ; -- termine les options de Bat.
    if [[ -z ${FZF_CTRL_T_OPTS+x} ]]; then
        export FZF_CTRL_T_OPTS="--height=60% --prompt='Fichiers > '"
        if command -v bat >/dev/null 2>&1; then
            export FZF_CTRL_T_OPTS="$FZF_CTRL_T_OPTS --preview 'if [ -f {} ] && [ -r {} ]; then bat --color=always --style=numbers --paging=never --line-range=:300 -- {}; fi' --preview-window=right:50%:wrap"
        fi
    fi
    if _fzf_initialisation="$(fzf --zsh 2>/dev/null)"; then
        eval "$_fzf_initialisation"
    fi
    unset _fzf_initialisation
fi

# --- Sélection des complétions, puis suggestions ---
# Charger après fzf --zsh pour préserver son intégration et reprendre Tab,
# mais avant les plugins qui enveloppent les widgets Zsh.
if command -v fzf >/dev/null 2>&1 && [[ -f "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" && -r "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ]]; then
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' menu no
    # fzf-tab garde ses choix de disposition ; ne pas importer les options
    # générales de fzf, dont certaines changeraient son fonctionnement.
    if ! zstyle -a ':fzf-tab:*' fzf-flags _dotfiles_fzf_tab_flags; then
        zstyle ':fzf-tab:*' fzf-flags "$_dotfiles_fzf_colors" --border=rounded
    fi
    source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"
fi
unset _dotfiles_fzf_colors _dotfiles_fzf_tab_flags

