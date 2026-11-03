#!/usr/bin/env bash
# Objectif : annuler les changements décrits par un journal de ce clone.
# Prérequis : Bash 3.2, cksum et journal local complet ; aucun besoin de Stow.
# Options : --journal FICHIER, --dry-run (défaut), --apply, --help.
# Effets : retire les nouveaux liens attendus, remet les sauvegardes en place.
# Retour arrière : relire puis relancer le déploiement souhaité en simulation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DRY_RUN=1
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

JOURNAL=""
UNDO_ACTIVE=0
UNDO_PKG=() UNDO_REL=() UNDO_STATE=() UNDO_BACKUP=() UNDO_CHECKSUM=()

usage() {
    cat <<'EOF'
Usage : bash scripts/annuler-deploiement.sh --journal FICHIER [--dry-run|--apply]

Sans --apply : vérifie le journal et affiche uniquement les actions prévues.
--journal FICHIER  Journal .tsv situé dans .deployments/ de ce clone
--dry-run          Simulation, comportement par défaut
--apply            Confirme explicitement le retrait des liens et la restauration
-h, --help         Affiche cette aide

Les liens préexistants sont conservés. Une destination modifiée, une sauvegarde
altérée ou manquante et un parent symbolique bloquent l'annulation.
Traiter les déploiements du plus récent au plus ancien, sans opération parallèle.
Codes : 0 bilan terminé, 1 conflit/échec, 2 option ou journal invalide.
EOF
}

invalid_journal() {
    log_error "Journal invalide ou incompatible : $JOURNAL"
    return 2
}

read_journal() {
    local directory format repo target extra kind package relative state backup checksum
    local existing suffix line expected ended=0
    [ -n "$JOURNAL" ] && [ -f "$JOURNAL" ] && [ ! -L "$JOURNAL" ] || { invalid_journal; return 2; }
    directory="$(cd "$(dirname "$JOURNAL")" && pwd -P)" || return 2
    [ ! -L "$REPO_DIR/.deployments" ] && [ "$directory" = "$REPO_DIR/.deployments" ] || { invalid_journal; return 2; }
    JOURNAL="$directory/${JOURNAL##*/}"
    TARGET_HOME="$(cd "${HOME:?Répertoire personnel absent}" && pwd -P)" || return 2
    case "$TARGET_HOME/" in
        /|"$REPO_DIR/"*) invalid_journal; return 2 ;;
    esac
    {
        IFS= read -r line || { invalid_journal; return 2; }
        IFS=$'\t' read -r format repo target extra <<< "$line"
        expected="$(printf 'mac-os-dotfiles-v1\t%s\t%s' "$REPO_DIR" "$TARGET_HOME")"
        if [ "$format" != mac-os-dotfiles-v1 ] || [ "$repo" != "$REPO_DIR" ] ||
           [ "$target" != "$TARGET_HOME" ] || [ -n "$extra" ] || [ "$line" != "$expected" ]; then
            invalid_journal
            return 2
        fi
        while true; do
            line=""
            if ! IFS= read -r line; then
                # Même après la fin attendue, refuser des octets sans saut de ligne.
                [ -z "$line" ] || { invalid_journal; return 2; }
                break
            fi
            IFS=$'\t' read -r kind package relative state backup checksum extra <<< "$line"
            [ "$ended" -eq 0 ] || { invalid_journal; return 2; }
            if [ "$kind" = end ]; then
                expected="$(printf 'end\t%s' "${#UNDO_REL[@]}")"
                [ "$package" = "${#UNDO_REL[@]}" ] && [ "$package" != 0 ] &&
                    [ -z "$relative$state$backup$checksum$extra" ] &&
                    [ "$line" = "$expected" ] || { invalid_journal; return 2; }
                ended=1
                continue
            fi
            [ "$kind" = file ] && [ -z "$extra" ] || { invalid_journal; return 2; }
            expected="$(printf 'file\t%s\t%s\t%s\t%s\t%s' "$package" "$relative" "$state" "$backup" "$checksum")"
            [ "$line" = "$expected" ] || { invalid_journal; return 2; }
            case "$package" in
                ''|.*|-*|*[!a-zA-Z0-9_-]*) invalid_journal; return 2 ;;
            esac
            case "$relative" in
                .zshrc|.config/*|Library/*) ;;
                *) invalid_journal; return 2 ;;
            esac
            case "/$relative/" in
                *'/../'*|*'/./'*|*'//'*) invalid_journal; return 2 ;;
            esac
            validate_journal_text "$relative" || return 2
            for existing in ${UNDO_REL[@]+"${UNDO_REL[@]}"}; do
                [ "$existing" != "$relative" ] || { invalid_journal; return 2; }
            done
            case "$state" in
                owned|absent)
                    [ "$backup" = - ] && [ "$checksum" = - ] || { invalid_journal; return 2; }
                    ;;
                backup)
                    case "$backup" in
                        "$TARGET_HOME/$relative.backup."*) ;;
                        *) invalid_journal; return 2 ;;
                    esac
                    suffix="${backup#"$TARGET_HOME/$relative.backup."}"
                    case "$suffix" in
                        ''|*[!0-9.]*) invalid_journal; return 2 ;;
                    esac
                    [[ "$checksum" =~ ^[0-9]+[[:space:]][0-9]+$ ]] || { invalid_journal; return 2; }
                    ;;
                *) invalid_journal; return 2 ;;
            esac
            UNDO_PKG+=("$package")
            UNDO_REL+=("$relative")
            UNDO_STATE+=("$state")
            UNDO_BACKUP+=("$backup")
            UNDO_CHECKSUM+=("$checksum")
        done
    } < "$JOURNAL"
    [ "$ended" -eq 1 ] || { invalid_journal; return 2; }
}

# Contrôle en lecture seule, réutilisé juste avant chaque action.
inspect_entry() {
    local index="$1" path source backup checksum rest component source_parent
    ACTION=none
    [ "${UNDO_STATE[$index]}" != owned ] || return 0
    path="$TARGET_HOME/${UNDO_REL[$index]}"
    source="$REPO_DIR/${UNDO_PKG[$index]}/${UNDO_REL[$index]}"
    backup="${UNDO_BACKUP[$index]}"
    checksum="${UNDO_CHECKSUM[$index]}"
    check_target_parents "${UNDO_PKG[$index]}" "${UNDO_REL[$index]}" 0 || return 1
    source_parent="$REPO_DIR/${UNDO_PKG[$index]}"
    rest="${UNDO_REL[$index]}"
    while true; do
        if [ -L "$source_parent" ]; then
            log_error "Source devenue symbolique : $source_parent"
            return 1
        fi
        [ -n "$rest" ] || break
        component="${rest%%/*}"
        source_parent="$source_parent/$component"
        if [ "$rest" = "$component" ]; then
            rest=""
        else
            rest="${rest#*/}"
        fi
    done
    if [ "${UNDO_STATE[$index]}" = backup ]; then
        if [ -e "$backup" ] || [ -L "$backup" ]; then
            if [ -L "$backup" ] || [ ! -f "$backup" ] || [ "$(cksum < "$backup")" != "$checksum" ]; then
                log_error "Sauvegarde non ordinaire ou altérée : $backup"
                return 1
            fi
            ACTION=restore
        elif [ ! -L "$path" ] && [ -f "$path" ] && [ "$(cksum < "$path")" = "$checksum" ]; then
            log_info "Fichier déjà restauré ou jamais déplacé : $path"
            return 0
        else
            log_error "Sauvegarde introuvable : $backup ; destination conservée : $path"
            return 1
        fi
    fi
    if [ -L "$path" ] && [ "$path" -ef "$source" ]; then
        [ "$ACTION" = restore ] || ACTION=unlink
    elif [ -e "$path" ] || [ -L "$path" ]; then
        log_error "Destination modifiée ou occupée : $path"
        return 1
    fi
}

restore_entries() {
    local index path backup
    # Refuser l'ensemble du plan en cas de conflit connu, avant tout retrait.
    for ((index=0; index<${#UNDO_REL[@]}; index++)); do
        inspect_entry "$index" || return 1
    done
    for ((index=${#UNDO_REL[@]}-1; index>=0; index--)); do
        inspect_entry "$index" || return 1
        [ "$ACTION" != none ] || continue
        path="$TARGET_HOME/${UNDO_REL[$index]}"
        backup="${UNDO_BACKUP[$index]}"
        if [ -L "$path" ]; then
            run unlink "$path" || return 1
        fi
        if [ "$ACTION" = restore ]; then
            # En simulation, le lien prévu pour retrait est encore présent.
            if [ "$DRY_RUN" -eq 0 ] && { [ -e "$path" ] || [ -L "$path" ]; }; then
                log_error "Destination occupée pendant l'annulation : $path"
                return 1
            fi
            run mv -n "$backup" "$path" || return 1
            if [ "$DRY_RUN" -eq 0 ] && { [ -e "$backup" ] || [ -L "$backup" ]; }; then
                log_error "Restauration refusée ; sauvegarde conservée : $backup"
                return 1
            fi
        fi
    done
}

undo_exit() {
    local status="$1"
    trap - EXIT
    if [ "$UNDO_ACTIVE" -eq 1 ]; then
        run append_journal_event "$JOURNAL" annulation-incomplete || log_warn 'État final du journal non enregistré.'
        [ "$status" -ne 0 ] || status=1
    fi
    exit "$status"
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run) DRY_RUN=1 ;;
            --apply) DRY_RUN=0 ;;
            --journal)
                [ "$#" -ge 2 ] || { log_error 'Valeur manquante pour --journal.'; return 2; }
                [ -z "$JOURNAL" ] || { log_error 'Un seul journal est accepté.'; return 2; }
                JOURNAL="$2"
                shift
                ;;
            -h|--help) usage; return 0 ;;
            *) log_error "Option inconnue : $1"; return 2 ;;
        esac
        shift
    done
    require_commands cksum
    read_journal
    read_journal_event "$JOURNAL"
    case "$JOURNAL_EVENT" in
        annule|retour-automatique)
            log_info "Journal déjà terminé par $JOURNAL_EVENT : aucune nouvelle annulation."
            return 0
            ;;
    esac
    log_info "Annulation préparée depuis : $JOURNAL ; état enregistré : $JOURNAL_EVENT"
    if [ "$DRY_RUN" -eq 0 ]; then
        # Le contrôle complet reste effectué avant le premier retrait.
        # Le marqueur de reprise peut être créé même si un conflit arrête le plan.
        UNDO_ACTIVE=1
        trap 'undo_exit $?' EXIT
        trap 'exit 130' INT
        trap 'exit 143' TERM
        run append_journal_event "$JOURNAL" annulation
    fi
    restore_entries
    if [ "$DRY_RUN" -eq 1 ]; then
        log_info 'Simulation terminée : aucun lien retiré, aucune sauvegarde déplacée.'
    else
        UNDO_ACTIVE=0
        run append_journal_event "$JOURNAL" annule || log_warn 'Annulation terminée ; état final du journal non enregistré.'
        trap - EXIT INT TERM
        log_ok 'Annulation terminée. Journal conservé ; répertoires vides laissés en place.'
    fi
}

main "$@"
