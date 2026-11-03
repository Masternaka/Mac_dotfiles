#!/usr/bin/env bash
# Objectif : présenter les journaux locaux et leur dernier état enregistré.
# Prérequis : Bash 3.2 ; bibliothèque du même clone.
# Options : --dry-run (défaut), --help ; aucune option d'application.
# Effets : lecture seule, aucune validation ou restauration des destinations.
# Retour arrière : sans objet ; aucun fichier modifié.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DRY_RUN=1
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

usage() {
    cat <<'EOF'
Usage : bash scripts/lister-deploiements.sh [--dry-run|--help]

Affiche les chemins des journaux, les paquets et le dernier état enregistré.
Ne valide ni les fichiers sauvegardés ni les liens et ne propose aucune suppression.
EOF
}

main() {
    local argument journal kind package rest names count=0
    for argument in "$@"; do
        case "$argument" in
            --dry-run) ;;
            -h|--help) usage; return 0 ;;
            *) log_error "Option non prise en charge : $argument"; return 2 ;;
        esac
    done
    if [ -L "$REPO_DIR/.deployments" ]; then
        log_error 'Dossier .deployments symbolique : lecture refusée.'; return 1
    fi
    for journal in "$REPO_DIR/.deployments/"*.tsv; do
        [ -f "$journal" ] && [ ! -L "$journal" ] || continue
        names=" "
        while IFS=$'\t' read -r kind package rest; do
            [ "$kind" = file ] || continue
            case "$package" in ''|.*|-*|*[!a-zA-Z0-9_-]*) continue ;; esac
            case "$names" in *" $package "*) ;; *) names="$names$package " ;; esac
        done < "$journal"
        if ! read_journal_event "$journal"; then
            JOURNAL_EVENT=metadonnees-invalides
        fi
        log_info "${journal##*/} | paquets : $names| état : $JOURNAL_EVENT | date : $JOURNAL_EVENT_DATE"
        log_info "Journal exact : $journal"
        count=$((count + 1))
    done
    log_info "$count journal(aux). États informatifs ; relire la simulation d'annulation avant toute action."
}

main "$@"
