#!/usr/bin/env bash
# Objectif : vérifier les outils et lier Ghostty, Herdr, Starship et Zsh.
# Prérequis : outils et plugins décrits dans scripts/README.md, déjà présents.
# Options : --dry-run (défaut), --apply, --packages LISTE, --strict, --help.
# Effets : sauvegarde des configurations existantes et création des liens Stow.
# Retour arrière : voir docs/retour-arriere.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P || true)"
REPO_DIR=""
if [ -n "$SCRIPT_DIR" ]; then
    REPO_DIR="$(dirname "$SCRIPT_DIR")"
fi

if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/lib.sh" ]; then
    echo "Erreur : lib.sh introuvable." >&2
    exit 1
fi

DRY_RUN=1
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
SELECTED_PACKAGES=()
STRICT=0

usage() {
    cat <<'EOF'
Usage : terminal_setup.sh [options]

Vérifie les outils du terminal et relie les configurations du dépôt avec GNU Stow.

Options :
  --dry-run   Affiche les actions sans rien modifier (défaut)
  --apply     Applique réellement les changements
  --packages LISTE  Choisit un sous-ensemble du groupe terminal
  --strict    Exige aussi les outils et plugins complémentaires
  -h, --help  Affiche cette aide
EOF
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run) DRY_RUN=1 ;;
            --apply)   DRY_RUN=0 ;;
            --strict) STRICT=1 ;;
            --packages)
                [ "$#" -ge 2 ] || { log_error 'Valeur manquante pour --packages.'; exit 2; }
                add_selected_packages "$2" || exit 2
                shift
                ;;
            --packages=*) add_selected_packages "${1#*=}" || exit 2 ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Option inconnue : $1"
                usage
                exit 2
                ;;
        esac
        shift
    done
}

check_repo() {
    local package
    load_package_catalog || return 2
    if [ "${#SELECTED_PACKAGES[@]}" -eq 0 ]; then
        select_catalog_group terminal || return 2
    fi
    for package in "${SELECTED_PACKAGES[@]}"; do
        catalog_package_index "$package" || return 2
        if [ "${CATALOG_GROUPS[$CATALOG_INDEX]}" != terminal ]; then
            log_error "Paquet hors du groupe terminal : $package"
            return 2
        fi
    done
}

check_dependencies() {
    local package plugin mode=parcours
    require_commands stow cksum || return 1
    [ "$STRICT" -eq 0 ] || mode=strict
    for package in "${SELECTED_PACKAGES[@]}"; do
        check_package_dependencies "$package" "$mode" || return 1
        [ "$package" = zsh ] || continue
        for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
            if [ ! -r "$HOME/.zsh/$plugin/$plugin.zsh" ]; then
                if [ "$STRICT" -eq 1 ]; then
                    log_error "Plugin requis en mode strict : $plugin"; return 1
                fi
                log_warn "Plugin facultatif absent : $plugin ; Zsh reste utilisable."
            fi
        done
    done
}

link_configs() {
    log_info "Sauvegarde des configurations existantes puis liaison avec GNU Stow."

    deploy_packages "${SELECTED_PACKAGES[@]}"
}

summary() {
    if [ "$DRY_RUN" -eq 1 ]; then
        log_warn "Mode simulation : aucune modification n'a été effectuée."
        log_info "Relancez avec --apply pour appliquer les changements."
        return 0
    fi

    log_ok "Configurations liées."
    log_info "Ouvrez Ghostty, puis lancez 'source ~/.zshrc' ou redémarrez le terminal."
    log_info "Paquets concernés : ${SELECTED_PACKAGES[*]}"
}

main() {
    parse_args "$@"
    check_repo
    check_dependencies
    link_configs
    summary
}

main "$@"
