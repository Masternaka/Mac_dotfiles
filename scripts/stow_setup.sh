#!/usr/bin/env bash
# Objectif : proposer les paquets du dépôt à lier avec GNU Stow.
# Prérequis : GNU Stow déjà installé ; macOS avec Bash 3.2 ou ultérieur.
# Options : --dry-run (défaut), --apply, --packages LISTE, --help.
# Effets : sauvegarde des fichiers existants et création des liens choisis.
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

usage() {
    cat <<'EOF'
Usage : stow_setup.sh [options]

Vérifie GNU Stow puis propose un menu pour choisir les configurations à lier.

Options :
  --dry-run   Affiche les actions sans rien modifier (défaut)
  --apply     Applique réellement les changements
  --packages LISTE  Sélection directe, noms séparés par des virgules
  -h, --help  Affiche cette aide
EOF
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run) DRY_RUN=1 ;;
            --apply)   DRY_RUN=0 ;;
            --packages)
                if [ "$#" -lt 2 ]; then
                    log_error 'Valeur manquante pour --packages.'
                    exit 2
                fi
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

detect_packages() {
    load_package_catalog || return 2
    PACKAGES=("${CATALOG_NAMES[@]}")

    if [ ${#PACKAGES[@]} -eq 0 ]; then
        log_error "Aucun paquet Stow trouvé dans $REPO_DIR."
        exit 1
    fi
}

check_repo() {
    if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR" ]; then
        log_error "Dépôt introuvable. Lancez ce script depuis un clone du dépôt."
        exit 1
    fi
}

select_packages() {
    local index=1 name choice valid selection
    local -a selected

    if [ ! -t 0 ]; then
        log_info "Entrée non interactive : aucun lien ne sera créé."
        return 0
    fi

    echo ""
    echo "Paquets Stow disponibles :"
    for name in "${PACKAGES[@]}"; do
        echo "  $index) $name"
        index=$((index + 1))
    done
    echo "  0) Aucun (par défaut)"

    selected=()
    while true; do
        printf 'Votre choix (numéros séparés par des espaces, 0 = aucun) [0] : '
        if ! read -r selection; then
            selection=""
        fi
        selection="${selection:-0}"

        if [ "$selection" = "0" ]; then
            selected=()
            break
        fi

        valid=1
        selected=()
        for choice in $selection; do
            case "$choice" in
                *[!0-9]*)
                    valid=0
                    break
                    ;;
            esac
            if [ "$choice" -ge 1 ] && [ "$choice" -le "${#PACKAGES[@]}" ]; then
                selected+=("${PACKAGES[$((choice - 1))]}")
            else
                valid=0
                break
            fi
        done

        if [ "$valid" -eq 1 ]; then
            break
        fi
        log_warn "Choix invalide. Entrez des numéros entre 1 et ${#PACKAGES[@]}, ou 0 pour aucun."
    done

    if [ ${#selected[@]} -eq 0 ]; then
        log_info "Aucun lien créé (choix par défaut)."
        return 0
    fi

    apply_selection "${selected[@]}"
}

apply_selection() {
    local name
    # Vérifier tous les prérequis avant la première sauvegarde.
    for name in "$@"; do
        check_package_dependencies "$name" menu || return 1
    done

    deploy_packages "$@"

    if [ "$DRY_RUN" -eq 1 ]; then
        log_warn "Mode simulation : les liens n'ont pas été créés."
        log_info "Relancez avec --apply pour appliquer les changements."
    else
        log_ok "Paquets liés : $*"
        log_info "Consultez le guide du paquet pour son utilisation ; aucun autre parcours n'est obligatoire."
    fi
}

main() {
    parse_args "$@"
    check_repo
    require_commands stow
    detect_packages
    if [ "${#SELECTED_PACKAGES[@]}" -gt 0 ]; then
        apply_selection "${SELECTED_PACKAGES[@]}"
    else
        select_packages
    fi
}

main "$@"
