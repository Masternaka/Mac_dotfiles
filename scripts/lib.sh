#!/usr/bin/env bash
# Fonctions communes aux scripts de liaison.
# Ce fichier est destiné à être sourcé, pas exécuté directement.

if [ -t 1 ]; then
    C_INFO=$'\033[36m'
    C_OK=$'\033[32m'
    C_WARN=$'\033[33m'
    C_ERR=$'\033[31m'
    C_RESET=$'\033[0m'
else
    C_INFO=""
    C_OK=""
    C_WARN=""
    C_ERR=""
    C_RESET=""
fi

DRY_RUN="${DRY_RUN:-1}"

log_info() {
    printf '%s[INFO]%s %s\n' "$C_INFO" "$C_RESET" "$*"
}

log_ok() {
    printf '%s[OK]%s %s\n' "$C_OK" "$C_RESET" "$*"
}

log_warn() {
    printf '%s[WARN]%s %s\n' "$C_WARN" "$C_RESET" "$*"
}

log_error() {
    printf '%s[ERREUR]%s %s\n' "$C_ERR" "$C_RESET" "$*" >&2
}

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        log_info "[SIMULATION] $*"
    else
        "$@"
    fi
}

require_commands() {
    local tool missing=0
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_error "Outil requis absent : $tool. Installez-le manuellement avant de relancer."
            missing=1
        fi
    done
    [ "$missing" -eq 0 ]
}

load_package_catalog() {
    [ "${CATALOG_LOADED:-0}" -eq 0 ] || return 0
    local file="$REPO_DIR/config/paquets.tsv" line name label required optional group format source menu extra index tool
    if [ ! -f "$file" ] || [ -L "$file" ] || [ ! -r "$file" ]; then
        log_error "Catalogue absent ou illisible : $file"
        return 2
    fi
    CATALOG_NAMES=() CATALOG_LABELS=() CATALOG_REQUIRED=() CATALOG_OPTIONAL=()
    CATALOG_GROUPS=() CATALOG_FORMATS=() CATALOG_SOURCES=() CATALOG_MENU_REQUIRED=()
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in ''|'#'*) continue ;; esac
        IFS=$'\t' read -r name label required optional group format source menu extra <<< "$line"
        if [ -z "$name" ] || [ -z "$label" ] || [ -z "$required" ] || [ -z "$optional" ] ||
           [ -z "$group" ] || [ -z "$source" ] || [ -n "$extra" ]; then
            log_error 'Catalogue : champs manquants ou surnuméraires.'; return 2
        fi
        case "$name" in .*|-*|*[!a-zA-Z0-9_-]*) log_error "Paquet invalide : $name"; return 2 ;; esac
        case "$group" in -|terminal|yazi) ;; *) log_error "Groupe invalide : $group"; return 2 ;; esac
        case "$format" in bat|ghostty|toml|yaml|zsh) ;; *) log_error "Format invalide : $format"; return 2 ;; esac
        case "$menu" in oui|non) ;; *) log_error 'Catalogue : politique de dépendances invalide.'; return 2 ;; esac
        case "$source" in .config|.config/*|Library/*|.zshrc) ;; *) log_error "Source invalide : $source"; return 2 ;; esac
        case "/$source/" in *'/../'*|*'/./'*|*'//'*) log_error "Source invalide : $source"; return 2 ;; esac
        validate_journal_text "$source" || return 2
        # Pas d'évaluation des données ; les listes contiennent seulement des noms.
        case "$required$optional" in *[!a-zA-Z0-9_.+\ -]*) log_error 'Catalogue : nom de commande invalide.'; return 2 ;; esac
        for ((index=0; index<${#CATALOG_NAMES[@]}; index++)); do
            [ "${CATALOG_NAMES[$index]}" != "$name" ] || { log_error "Paquet en double : $name"; return 2; }
        done
        CATALOG_NAMES+=("$name") CATALOG_LABELS+=("$label")
        CATALOG_REQUIRED+=("$required") CATALOG_OPTIONAL+=("$optional")
        CATALOG_GROUPS+=("$group") CATALOG_FORMATS+=("$format")
        CATALOG_SOURCES+=("$source") CATALOG_MENU_REQUIRED+=("$menu")
    done < "$file"
    [ "${#CATALOG_NAMES[@]}" -gt 0 ] || { log_error 'Catalogue vide.'; return 2; }
    CATALOG_LOADED=1
}

catalog_package_index() {
    local index
    load_package_catalog || return 2
    for ((index=0; index<${#CATALOG_NAMES[@]}; index++)); do
        if [ "${CATALOG_NAMES[$index]}" = "$1" ]; then
            CATALOG_INDEX="$index"
            return 0
        fi
    done
    log_error "Paquet absent du catalogue : $1"
    return 2
}

select_catalog_group() {
    local index
    load_package_catalog || return 2
    SELECTED_PACKAGES=()
    for ((index=0; index<${#CATALOG_NAMES[@]}; index++)); do
        if [ "${CATALOG_GROUPS[$index]}" = "$1" ]; then
            SELECTED_PACKAGES+=("${CATALOG_NAMES[$index]}")
        fi
    done
    [ "${#SELECTED_PACKAGES[@]}" -gt 0 ]
}

check_package_dependencies() {
    local package="$1" mode="${2:-parcours}" index tool missing=0
    local -a tools
    catalog_package_index "$package" || return 2
    index="$CATALOG_INDEX"
    IFS=' ' read -r -a tools <<< "${CATALOG_REQUIRED[$index]}"
    for tool in "${tools[@]}"; do
        [ "$tool" != - ] || continue
        if ! command -v "$tool" >/dev/null 2>&1; then
            if [ "$mode" = menu ] && [ "${CATALOG_MENU_REQUIRED[$index]}" = non ]; then
                log_warn "Outil applicatif absent : $tool ; seule la liaison de $package est demandée."
            else
                log_error "Outil requis pour $package absent : $tool. Préparez-le manuellement."
                missing=1
            fi
        fi
    done
    IFS=' ' read -r -a tools <<< "${CATALOG_OPTIONAL[$index]}"
    for tool in "${tools[@]}"; do
        [ "$tool" != - ] || continue
        if ! command -v "$tool" >/dev/null 2>&1; then
            if [ "$mode" = strict ]; then
                log_error "Complément requis en mode strict pour $package : $tool"
                missing=1
            else
                log_warn "Complément facultatif de $package absent : $tool"
            fi
        fi
    done
    [ "$missing" -eq 0 ]
}

# Avertir sans changer de cible ni contourner les protections de chemin.
check_configuration_paths() {
    local package physical_home expected custom
    physical_home="$(cd "${HOME:?Répertoire personnel absent}" && pwd -P)" || return 1
    for package in "$@"; do
        if [ "$package" = lazygit ] && [ -n "${XDG_CONFIG_HOME:-}" ]; then
            log_warn "XDG_CONFIG_HOME est défini : ce paquet Lazygit reste prévu sous Library/Application Support. Examiner le chemin utilisé par l'application."
        fi
        if [ "$package" = zsh ] && [ -n "${ZDOTDIR:-}" ]; then
            expected="$physical_home"
            custom="${ZDOTDIR%/}"
            if [ "$custom" != "$expected" ] && [ "$custom" != "${HOME%/}" ]; then
                log_error "ZDOTDIR=$ZDOTDIR : la liaison prévue est $HOME/.zshrc. Aucun autre compte ou dossier ne sera ciblé."
                return 1
            fi
        fi
        if [ "$package" != lazygit ] && [ -n "${XDG_CONFIG_HOME:-}" ]; then
            if [ "${XDG_CONFIG_HOME%/}" != "$physical_home/.config" ] && [ "${XDG_CONFIG_HOME%/}" != "${HOME%/}/.config" ]; then
                log_error "XDG_CONFIG_HOME=$XDG_CONFIG_HOME diffère de la destination prévue $HOME/.config ($package)."
                return 1
            fi
        fi
        case "$package" in
            bat)
                if [ -n "${BAT_CONFIG_PATH:-}" ] && [ "$BAT_CONFIG_PATH" != "$physical_home/.config/bat/config" ] && [ "$BAT_CONFIG_PATH" != "$HOME/.config/bat/config" ]; then
                    log_error "BAT_CONFIG_PATH=$BAT_CONFIG_PATH : ce paquet ne modifiera pas ce fichier personnalisé."
                    return 1
                fi
                ;;
            starship)
                case "${STARSHIP_CONFIG:-}" in
                    ''|"$physical_home/.config/starship.toml"|"$HOME/.config/starship.toml"|"$physical_home/.config/starship-latte.toml"|"$HOME/.config/starship-latte.toml") ;;
                    *) log_error "STARSHIP_CONFIG=$STARSHIP_CONFIG : cette configuration personnelle n'est pas la cible de ce paquet."; return 1 ;;
                esac
                ;;
        esac
        log_info "Destinations du paquet $package : sous $physical_home (aucune redirection automatique)."
    done
}

# Ajoute une liste explicite sans évaluer son contenu ni développer de glob.
# SELECTED_PACKAGES doit être initialisé par l'appelant.
add_selected_packages() {
    local rest="$1" package existing duplicate
    case "$rest" in
        ''|,*|*,|*,,*) log_error "Liste de paquets vide ou mal formée : $rest"; return 2 ;;
    esac
    while [ -n "$rest" ]; do
        package="${rest%%,*}"
        case "$package" in
            .*|-*|*[!a-zA-Z0-9_-]*) log_error "Nom de paquet non autorisé : $package"; return 2 ;;
        esac
        catalog_package_index "$package" || return 2
        if [ -L "$REPO_DIR/$package" ] ||
           { [ ! -d "$REPO_DIR/$package/.config" ] &&
             [ ! -d "$REPO_DIR/$package/Library" ] &&
             [ ! -f "$REPO_DIR/$package/.zshrc" ]; }; then
            log_error "Paquet inconnu ou symbolique : $package"
            return 2
        fi
        duplicate=0
        # Bash 3.2 avec nounset : protéger aussi le cas d'un tableau vide.
        for existing in ${SELECTED_PACKAGES[@]+"${SELECTED_PACKAGES[@]}"}; do
            [ "$existing" != "$package" ] || duplicate=1
        done
        if [ "$duplicate" -eq 0 ]; then
            SELECTED_PACKAGES+=("$package")
        fi
        if [ "$rest" = "$package" ]; then
            break
        fi
        rest="${rest#*,}"
    done
}

# Les tableaux sont initialisés par deploy_packages, jamais lors du sourçage.
check_target_parents() {
    local package="$1" relative="$2" allow_owned="${3:-1}"
    local rest="$relative" component target="$TARGET_HOME" source="$REPO_DIR/$package"

    while [[ "$rest" == */* ]]; do
        component="${rest%%/*}"
        rest="${rest#*/}"
        target="$target/$component"
        source="$source/$component"
        if [ -L "$target" ]; then
            if [ "$allow_owned" -ne 1 ] || [ ! -d "$target" ] || [ ! "$target" -ef "$source" ]; then
                log_error "Dossier symbolique non autorisé : $target. Aucun fichier ne sera déplacé à travers ce lien."
                return 1
            fi
        elif [ -e "$target" ] && [ ! -d "$target" ]; then
            log_error "Un dossier attendu est occupé par un fichier : $target"
            return 1
        fi
    done
}

classify_target() {
    local package="$1" relative="$2" path="$TARGET_HOME/$2"
    local source="$REPO_DIR/$1/$2"
    check_target_parents "$package" "$relative" || return 1
    if [ -e "$path" ] && [ "$path" -ef "$source" ]; then
        CURRENT_STATE=owned
    elif [ -L "$path" ]; then
        log_error "Lien existant vers une autre cible (ou lien cassé) : $path"
        return 1
    elif [ -f "$path" ]; then
        CURRENT_STATE=backup
    elif [ -e "$path" ]; then
        log_error "La destination n'est pas un fichier ordinaire : $path"
        return 1
    else
        CURRENT_STATE=absent
    fi
}

plan_file() {
    local package="$1" relative="$2" index backup="" suffix=0 checksum=-
    for ((index=0; index<${#PLAN_REL[@]}; index++)); do
        if [ "${PLAN_REL[$index]}" = "$relative" ]; then
            if [ "${PLAN_PKG[$index]}" = "$package" ]; then
                return 0
            fi
            log_error "Plusieurs paquets visent la même destination : $relative"
            return 1
        fi
    done
    classify_target "$package" "$relative" || return 1
    if [ "$CURRENT_STATE" = backup ]; then
        checksum="$(cksum < "$TARGET_HOME/$relative")" || return 1
        backup="$TARGET_HOME/$relative.backup.$(date +%Y%m%d%H%M%S).$$"
        while [ -e "$backup" ] || [ -L "$backup" ]; do
            suffix=$((suffix + 1))
            backup="$TARGET_HOME/$relative.backup.$(date +%Y%m%d%H%M%S).$$.$suffix"
        done
    fi
    PLAN_PKG+=("$package")
    PLAN_REL+=("$relative")
    PLAN_STATE+=("$CURRENT_STATE")
    PLAN_BACKUP+=("$backup")
    PLAN_CHECKSUM+=("$checksum")
    PLAN_MOVED+=(0)
}

plan_tree() {
    local package="$1" relative="${2:-}" entry name child
    local directory="$REPO_DIR/$1${2:+/$2}"
    # Parcours sans suivre les liens et sans fichier temporaire.
    for entry in "$directory"/* "$directory"/.[!.]* "$directory"/..?*; do
        [ -e "$entry" ] || [ -L "$entry" ] || continue
        name="${entry##*/}"
        child="${relative:+$relative/}$name"
        if [ -z "$relative" ]; then
            case "$name" in
                README*|LICENSE*|COPYING*|.stow-local-ignore) continue ;;
                .config|Library|.zshrc) ;;
                *) log_error "Entrée de paquet non prise en charge : $entry"; return 1 ;;
            esac
        fi
        if [ -L "$entry" ]; then
            log_error "Lien symbolique dans le paquet source : $entry"
            return 1
        elif [ -d "$entry" ]; then
            plan_tree "$package" "$child" || return 1
        elif [ -f "$entry" ] && [ -r "$entry" ]; then
            plan_file "$package" "$child" || return 1
        else
            log_error "Source illisible ou non prise en charge : $entry"
            return 1
        fi
    done
}

rollback_deployment() {
    local index package relative path source backup failed=0
    log_warn "Application interrompue : restauration des fichiers sauvegardés."
    for ((index=${#PLAN_REL[@]}-1; index>=0; index--)); do
        [ "${PLAN_STATE[$index]}" != owned ] || continue
        if [ "${PLAN_MOVED[$index]}" -eq 0 ] && [ "$STOW_STARTED" -eq 0 ]; then
            continue
        fi
        package="${PLAN_PKG[$index]}"
        relative="${PLAN_REL[$index]}"
        path="$TARGET_HOME/$relative"
        source="$REPO_DIR/$package/$relative"
        backup="${PLAN_BACKUP[$index]}"
        # Ne jamais restaurer à travers un dossier symbolique apparu entre-temps.
        if ! check_target_parents "$package" "$relative" 0; then
            log_error "Restauration manuelle requise : $path ; sauvegarde : $backup"
            failed=1
            continue
        fi
        # Ne pas retirer le lien si la configuration à remettre a disparu.
        if [ "${PLAN_STATE[$index]}" = backup ] && [ "${PLAN_MOVED[$index]}" -eq 1 ]; then
            if [ -L "$backup" ] || [ ! -f "$backup" ] ||
               [ "$(cksum < "$backup")" != "${PLAN_CHECKSUM[$index]}" ]; then
                # Une interruption peut survenir après l'intention, avant mv.
                if [ ! -e "$backup" ] && [ ! -L "$backup" ] &&
                   [ ! -L "$path" ] && [ -f "$path" ] &&
                   [ "$(cksum < "$path")" = "${PLAN_CHECKSUM[$index]}" ]; then
                    continue
                fi
                log_error "Sauvegarde absente ou altérée : $backup ; destination conservée : $path"
                failed=1
                continue
            fi
        fi
        if [ "$STOW_STARTED" -eq 1 ] && [ -L "$path" ] && [ "$path" -ef "$source" ]; then
            if ! run unlink "$path"; then
                failed=1
                continue
            fi
        fi
        if [ -n "$backup" ] && [ "${PLAN_MOVED[$index]}" -eq 1 ] && { [ -e "$backup" ] || [ -L "$backup" ]; }; then
            if [ -e "$path" ] || [ -L "$path" ]; then
                log_error "Destination occupée : restauration refusée ; sauvegarde conservée : $backup"
                failed=1
            elif run mv -n "$backup" "$path" && [ ! -e "$backup" ] && [ ! -L "$backup" ]; then
                log_ok "Configuration restaurée : $path"
            else
                log_error "Restauration manuelle requise depuis : $backup"
                failed=1
            fi
        fi
    done
    return "$failed"
}

deployment_exit() {
    local status="$1"
    trap - EXIT
    # Laisser finir la restauration même si Ctrl+C est pressé une seconde fois.
    trap '' INT TERM
    if [ "${DEPLOY_ACTIVE:-0}" -eq 1 ]; then
        run append_journal_event "$JOURNAL_PATH" echec || log_warn 'État du journal non enregistré.'
        if rollback_deployment; then
            run append_journal_event "$JOURNAL_PATH" retour-automatique || log_warn 'État du journal non enregistré.'
        else
            log_error "Certaines sauvegardes demandent une restauration manuelle."
            run append_journal_event "$JOURNAL_PATH" restauration-incomplete || log_warn 'État du journal non enregistré.'
        fi
        [ "$status" -ne 0 ] || status=1
    fi
    exit "$status"
}

# Métadonnées informatives, séparées du journal de restauration v1.
read_journal_event() {
    local events="$1.events" timestamp state extra
    JOURNAL_EVENT=inconnu
    JOURNAL_EVENT_DATE=non-enregistree
    [ -e "$events" ] || [ -L "$events" ] || return 0
    if [ -L "$events" ] || [ ! -f "$events" ] || [ ! -r "$events" ]; then
        log_error "Métadonnées de journal non autorisées : $events"; return 1
    fi
    while IFS=$'\t' read -r timestamp state extra; do
        [ -n "$timestamp" ] && [ -z "$extra" ] || return 1
        case "$state" in
            prepare|application|applique|echec|retour-automatique|restauration-incomplete|annulation|annule|annulation-incomplete) JOURNAL_EVENT="$state" ;;
            *) log_error "État de journal non reconnu : $events"; return 1 ;;
        esac
        JOURNAL_EVENT_DATE="$timestamp"
    done < "$events"
}

# Fonction d'écriture appelée seulement à travers run().
append_journal_event() (
    local journal="$1" state="$2" events="$1.events" directory
    directory="$(cd "$(dirname "$journal")" && pwd -P)" || return 1
    if [ -L "$REPO_DIR/.deployments" ] || [ "$directory" != "$REPO_DIR/.deployments" ] ||
       [ -L "$events" ] || { [ -e "$events" ] && [ ! -f "$events" ]; }; then
        log_error "Destination de métadonnées non autorisée : $events"; return 1
    fi
    umask 077
    if [ ! -e "$events" ]; then
        set -C
        printf '%s\t%s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$state" > "$events"
    else
        printf '%s\t%s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$state" >> "$events"
    fi
)

validate_journal_text() {
    case "$1" in
        *$'\t'*|*$'\n'*|*$'\r'*)
            log_error 'Chemin contenant une tabulation ou un retour à la ligne : journal impossible.'
            return 1
            ;;
    esac
}

# Cette fonction d'écriture est appelée exclusivement à travers run().
write_deployment_journal() (
    local index backup
    umask 077
    set -C
    {
        printf 'mac-os-dotfiles-v1\t%s\t%s\n' "$REPO_DIR" "$TARGET_HOME" || return 1
        for ((index=0; index<${#PLAN_REL[@]}; index++)); do
            backup="${PLAN_BACKUP[$index]:--}"
            printf 'file\t%s\t%s\t%s\t%s\t%s\n' \
                "${PLAN_PKG[$index]}" "${PLAN_REL[$index]}" \
                "${PLAN_STATE[$index]}" "$backup" "${PLAN_CHECKSUM[$index]}" || return 1
        done
        printf 'end\t%s\n' "${#PLAN_REL[@]}" || return 1
    } > "$JOURNAL_PATH"
)

prepare_deployment_journal() {
    local index directory="$REPO_DIR/.deployments" suffix=0
    validate_journal_text "$REPO_DIR" || return 1
    validate_journal_text "$TARGET_HOME" || return 1
    for ((index=0; index<${#PLAN_REL[@]}; index++)); do
        validate_journal_text "${PLAN_PKG[$index]}" || return 1
        validate_journal_text "${PLAN_REL[$index]}" || return 1
        validate_journal_text "${PLAN_BACKUP[$index]}" || return 1
    done
    if [ -L "$directory" ] || { [ -e "$directory" ] && [ ! -d "$directory" ]; }; then
        log_error "Dossier de journaux non autorisé : $directory"
        return 1
    fi
    JOURNAL_PATH="$directory/$(date +%Y%m%d%H%M%S).$$.tsv"
    while [ -e "$JOURNAL_PATH" ] || [ -L "$JOURNAL_PATH" ]; do
        suffix=$((suffix + 1))
        JOURNAL_PATH="$directory/$(date +%Y%m%d%H%M%S).$$.$suffix.tsv"
    done
    if [ ! -d "$directory" ]; then
        run mkdir -m 700 "$directory" || return 1
    fi
    run write_deployment_journal || return 1
    run append_journal_event "$JOURNAL_PATH" prepare || return 1
    log_info "Journal de retour arrière : $JOURNAL_PATH"
}

deploy_packages() {
    local package index relative path
    require_commands stow cksum || return 1
    check_configuration_paths "$@" || return 1
    TARGET_HOME="$(cd "${HOME:?Répertoire personnel absent}" && pwd -P)" || return 1
    case "$TARGET_HOME/" in
        /|"$REPO_DIR/"*) log_error "Répertoire cible non autorisé : $TARGET_HOME"; return 1 ;;
    esac
    # Un .stowrc pourrait activer --adopt lors de l'application réelle.
    # Refuser ces options implicites plutôt que risquer de modifier les sources.
    for path in "$HOME/.stowrc" "$REPO_DIR/.stowrc"; do
        if [ -e "$path" ] || [ -L "$path" ]; then
            log_error "Options Stow implicites détectées : $path. Utilisez un environnement sans .stowrc."
            return 1
        fi
    done
    PLAN_PKG=() PLAN_REL=() PLAN_STATE=() PLAN_BACKUP=() PLAN_CHECKSUM=() PLAN_MOVED=()
    for package in "$@"; do
        case "$package" in
            ''|.*|-*|*/*) log_error "Nom de paquet non autorisé : $package"; return 1 ;;
        esac
        if [ ! -d "$REPO_DIR/$package" ] || [ -L "$REPO_DIR/$package" ]; then
            log_error "Paquet absent ou symbolique : $package"
            return 1
        fi
        plan_tree "$package" || return 1
    done
    if [ "${#PLAN_REL[@]}" -eq 0 ]; then
        log_error "Aucun fichier de configuration à lier."
        return 1
    fi
    cd "$REPO_DIR" || return 1
    log_info "Vérification des conflits Stow, sans aucune écriture."
    # --adopt est réservé à cette simulation : les fichiers ordinaires seront
    # sauvegardés par notre code, jamais importés dans les sources du dépôt.
    stow --simulate --adopt --dir="$REPO_DIR" --target="$TARGET_HOME" --no-folding --stow "$@" || return 1

    # Recontrôler l'ensemble des chemins avant le premier déplacement.
    for ((index=0; index<${#PLAN_REL[@]}; index++)); do
        classify_target "${PLAN_PKG[$index]}" "${PLAN_REL[$index]}" || return 1
        if [ "$CURRENT_STATE" != "${PLAN_STATE[$index]}" ]; then
            log_error "La destination a changé pendant la préparation : ${PLAN_REL[$index]}"
            return 1
        fi
    done
    # Journal complet avant tout déplacement ; aucun journal créé en simulation.
    prepare_deployment_journal || return 1
    DEPLOY_ACTIVE=0
    STOW_STARTED=0
    if [ "$DRY_RUN" -eq 0 ]; then
        DEPLOY_ACTIVE=1
        trap 'deployment_exit $?' EXIT
        trap 'exit 130' INT
        trap 'exit 143' TERM
        run append_journal_event "$JOURNAL_PATH" application || return 1
    fi
    for ((index=0; index<${#PLAN_REL[@]}; index++)); do
        [ "${PLAN_STATE[$index]}" = backup ] || continue
        relative="${PLAN_REL[$index]}"
        path="$TARGET_HOME/$relative"
        check_target_parents "${PLAN_PKG[$index]}" "$relative" 0 || return 1
        if [ -L "$path" ] || [ ! -f "$path" ] ||
           [ "$(cksum < "$path")" != "${PLAN_CHECKSUM[$index]}" ]; then
            log_error "Fichier modifié depuis la préparation : $path"
            return 1
        fi
        log_info "Sauvegarde : $path -> ${PLAN_BACKUP[$index]}"
        # Enregistrer l'intention avant mv pour couvrir une interruption juste après.
        PLAN_MOVED[$index]=1
        run mv -n "$path" "${PLAN_BACKUP[$index]}" || return 1
        if [ "$DRY_RUN" -eq 0 ] && { [ -e "$path" ] || [ -L "$path" ]; }; then
            log_error "Le déplacement a été refusé : $path"
            return 1
        fi
    done
    STOW_STARTED=1
    # --stow préserve les liens existants ; --restow les supprimerait d'abord.
    run stow --dir="$REPO_DIR" --target="$TARGET_HOME" --no-folding --stow "$@" || return 1
    if [ "$DRY_RUN" -eq 0 ]; then
        for ((index=0; index<${#PLAN_REL[@]}; index++)); do
            package="${PLAN_PKG[$index]}"
            relative="${PLAN_REL[$index]}"
            if [ ! "$TARGET_HOME/$relative" -ef "$REPO_DIR/$package/$relative" ]; then
                log_error "Lien attendu absent après application : $relative"
                return 1
            fi
        done
        DEPLOY_ACTIVE=0
        run append_journal_event "$JOURNAL_PATH" applique || log_warn 'Application terminée ; état final du journal non enregistré.'
        trap - EXIT INT TERM
    fi
}
