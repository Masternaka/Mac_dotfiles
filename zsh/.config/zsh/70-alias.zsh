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

# --- Consultation Git ---
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'

# --- Finder ---
alias reveal='open -R'

# --- Navigation avec Yazi ---
if command -v yazi >/dev/null 2>&1; then
    function y {
        local fichier_cwd dossier=""
        fichier_cwd="$(command mktemp -t yazi-cwd.XXXXXX)" || return $?

        {
            command yazi --cwd-file="$fichier_cwd" "$@" || return $?
            # Yazi écrit le chemin sans saut de ligne final.
            IFS= read -r -d '' dossier < "$fichier_cwd" || true
            if [[ "$dossier" != "$PWD" && -d "$dossier" ]]; then
                builtin cd -- "$dossier" || return $?
            fi
        } always {
            command rm -f -- "$fichier_cwd"
        }
    }
fi
