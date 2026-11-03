#!/usr/bin/env bash
# Objectif : établir un bilan statique du dépôt et des outils disponibles.
# Prérequis : Bash 3.2 ; Zsh, Git, Ruby, Python 3.11+ et ShellCheck pour tous les contrôles.
# Options : --dry-run (défaut), --package NOM, --packages LISTE, --sans-shellcheck, --help.
# Effets : lecture seule ; aucun script de liaison ni aucune application lancés.
# Retour arrière : sans objet, aucun fichier ni réglage modifié.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DRY_RUN=1
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

SUCCES=0
ERREURS=0
INCOMPLETS=0
DEPENDANCES_ABSENTES=0
SELECTED_PACKAGES=()
CIBLE=0
SHELLCHECK_DIFFERE=0

usage() {
    cat <<'EOF'
Usage : bash scripts/verifier-depot.sh [--dry-run] [--package NOM|--packages LISTE]

Sans sélection : bilan complet du dépôt et inventaire de tous les parcours.
--package NOM     Cible un paquet (option répétable)
--packages LISTE  Cible plusieurs paquets séparés par des virgules
--sans-shellcheck Diffère explicitement ShellCheck et signale le bilan incomplet
-h, --help       Affiche cette aide
Les contrôles Bash communs restent effectués dans tous les cas.

Contrôle réellement la syntaxe et lit les configurations, sans les appliquer.
Inventorie les outils sans les lancer. Aucune installation ni connexion réseau.
Les outils absents sont signalés ; les autres contrôles continuent.

Codes de sortie :
  0  Contrôles statiques demandés terminés, outils trouvés ; pas une certification.
  1  Au moins un contrôle a échoué.
  2  Bilan incomplet ou option non prise en charge.
EOF
}

verifier() {
    local titre="$1"
    shift
    log_info "$titre"
    if "$@"; then
        SUCCES=$((SUCCES + 1))
        log_ok "$titre"
    else
        ERREURS=$((ERREURS + 1))
        log_error "$titre"
    fi
}

incomplet() {
    INCOMPLETS=$((INCOMPLETS + 1))
    log_warn "$*"
}

verifier_syntaxe() {
    local fichier
    for fichier in "$SCRIPT_DIR"/*.sh "$REPO_DIR/.githooks/pre-commit"; do
        verifier "Syntaxe Bash : ${fichier#"$REPO_DIR/"}" /bin/bash -n "$fichier"
    done
    if paquet_selectionne zsh; then
        if command -v zsh >/dev/null 2>&1; then
            verifier 'Syntaxe Zsh' zsh -n "$REPO_DIR/zsh/.zshrc"
            verifier 'Syntaxe du modèle Zsh local' zsh -n "$REPO_DIR/config/zshrc-local.example.zsh"
            verifier 'Syntaxe du modèle Zsh avant initialisation' zsh -n "$REPO_DIR/config/zshrc-local-pre.example.zsh"
            for fichier in "$REPO_DIR/zsh/.config/zsh/"*.zsh; do
                verifier "Syntaxe du fragment ${fichier##*/}" zsh -n "$fichier"
            done
        else
            incomplet 'Zsh absent : syntaxe de .zshrc non contrôlée.'
        fi
    fi
    if [ "$SHELLCHECK_DIFFERE" -eq 1 ]; then
        incomplet 'ShellCheck différé explicitement ; analyse non effectuée.'
    elif command -v shellcheck >/dev/null 2>&1; then
        verifier 'Analyse ShellCheck' shellcheck "$SCRIPT_DIR"/*.sh "$REPO_DIR/.githooks/pre-commit"
    else
        incomplet 'ShellCheck absent : analyse approfondie non effectuée. Aucun outil installé.'
    fi
}

verifier_yaml() {
    ruby -r yaml -e '
        document = YAML.safe_load(File.read(ARGV.fetch(0)))
        abort "La configuration doit être un objet YAML." unless document.is_a?(Hash)
    ' "$1"
}

verifier_toml() {
    python3 -B - "$@" <<'PY'
from pathlib import Path
import sys
import tomllib

for argument in sys.argv[1:]:
    source = Path(argument)
    chemins = sorted(source.rglob("*.toml")) if source.is_dir() else [source]
    if not chemins:
        raise SystemExit("Aucun TOML dans " + str(source))
    for chemin in chemins:
        with chemin.open("rb") as fichier:
            tomllib.load(fichier)
        print("TOML valide : " + str(chemin))
PY
}

paquet_selectionne() {
    local paquet
    [ "$CIBLE" -eq 1 ] || return 0
    for paquet in ${SELECTED_PACKAGES[@]+"${SELECTED_PACKAGES[@]}"}; do
        [ "$paquet" != "$1" ] || return 0
    done
    return 1
}

verifier_configurations() {
    local index paquet chemin format
    for ((index=0; index<${#CATALOG_NAMES[@]}; index++)); do
        paquet="${CATALOG_NAMES[$index]}"
        paquet_selectionne "$paquet" || continue
        chemin="$REPO_DIR/$paquet/${CATALOG_SOURCES[$index]}"
        format="${CATALOG_FORMATS[$index]}"
        case "$format" in
            toml)
                if command -v python3 >/dev/null 2>&1 && python3 -B -c 'import tomllib' >/dev/null 2>&1; then
                    verifier "Syntaxe TOML : $paquet" verifier_toml "$chemin"
                else
                    incomplet "Python avec tomllib absent : syntaxe TOML de $paquet non contrôlée."
                fi
                ;;
            yaml)
                if command -v ruby >/dev/null 2>&1; then
                    verifier "Syntaxe YAML : $paquet (schéma applicatif non validé)" verifier_yaml "$chemin"
                else
                    incomplet "Ruby absent : syntaxe YAML de $paquet non contrôlée."
                fi
                ;;
            ghostty|bat) log_warn "Configuration $paquet : format et rendu hors du bilan statique." ;;
            zsh) ;; # Le chargeur, les fragments et modèles sont traités par verifier_syntaxe.
        esac
        verifier "Compatibilité des destinations : $paquet" check_configuration_paths "$paquet"
    done
    log_warn 'Compatibilité des versions : hors du bilan statique.'
}

inventorier_commande() {
    local outil="$1" obligatoire="${2:-1}"
    case " ${INVENTORY_SEEN:-} " in *" $outil "*) return 0 ;; esac
    INVENTORY_SEEN="${INVENTORY_SEEN:-} $outil"
    if command -v "$outil" >/dev/null 2>&1; then
        log_ok "Outil trouvé : $outil"
    elif [ "$obligatoire" -eq 1 ]; then
        DEPENDANCES_ABSENTES=$((DEPENDANCES_ABSENTES + 1))
        log_warn "Dépendance absente du PATH : $outil. Aucune installation effectuée."
    else
        log_warn "Complément facultatif absent du PATH : $outil"
    fi
}

inventorier_plugins() {
    local outil
    for outil in zsh-autosuggestions zsh-syntax-highlighting; do
        if [ -r "$HOME/.zsh/$outil/$outil.zsh" ]; then
            log_ok "Plugin lisible : $outil (contenu non audité)"
        else
            log_warn "Plugin Zsh facultatif absent : $outil ; seul --strict l'exige dans le parcours terminal."
        fi
    done
    if [ -d "$HOME/.zsh/zsh-completions/src" ] &&
       [ -r "$HOME/.zsh/zsh-completions/src" ] && [ -x "$HOME/.zsh/zsh-completions/src" ]; then
        log_ok 'Définitions zsh-completions accessibles (contenu non audité).'
    else
        log_warn 'Complément facultatif absent ou inaccessible : ~/.zsh/zsh-completions/src ; complétions Zsh habituelles conservées.'
    fi
    if [ -f "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ] && [ -r "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ]; then
        if command -v fzf >/dev/null 2>&1; then
            log_ok 'Plugin fzf-tab lisible et fzf disponible (compatibilité non testée).'
        else
            log_warn 'Plugin fzf-tab lisible, mais fzf absent : chargement omis par .zshrc.'
        fi
    else
        log_warn 'Complément facultatif absent ou illisible : ~/.zsh/fzf-tab/fzf-tab.plugin.zsh ; sélection actuelle conservée.'
    fi
}

inventorier_outils() {
    local index outil paquet
    local -a tools
    INVENTORY_SEEN=""
    log_info 'Inventaire uniquement : aucune application ne sera lancée.'
    inventorier_commande stow
    inventorier_commande cksum
    # Les commandes requises sont recensées avant les compléments pour éviter
    # de classer comme facultatif un outil requis par un autre paquet sélectionné.
    for ((index=0; index<${#CATALOG_NAMES[@]}; index++)); do
        paquet="${CATALOG_NAMES[$index]}"
        paquet_selectionne "$paquet" || continue
        IFS=' ' read -r -a tools <<< "${CATALOG_REQUIRED[$index]}"
        for outil in "${tools[@]}"; do
            [ "$outil" = - ] || inventorier_commande "$outil"
        done
    done
    for ((index=0; index<${#CATALOG_NAMES[@]}; index++)); do
        paquet="${CATALOG_NAMES[$index]}"
        paquet_selectionne "$paquet" || continue
        IFS=' ' read -r -a tools <<< "${CATALOG_OPTIONAL[$index]}"
        for outil in "${tools[@]}"; do
            [ "$outil" = - ] || inventorier_commande "$outil" 0
        done
    done
    if paquet_selectionne zsh; then
        inventorier_plugins
    fi
}

main() {
    local paquet
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run) ;;
            --sans-shellcheck) SHELLCHECK_DIFFERE=1 ;;
            --package|--packages)
                if [ "$#" -lt 2 ]; then
                    log_error "Valeur manquante pour $1."
                    return 2
                fi
                add_selected_packages "$2" || return 2
                CIBLE=1
                shift
                ;;
            --package=*|--packages=*)
                add_selected_packages "${1#*=}" || return 2
                CIBLE=1
                ;;
            -h|--help) usage; return 0 ;;
            *) log_error "Option non prise en charge : $1"; usage; return 2 ;;
        esac
        shift
    done
    load_package_catalog || return 2
    for paquet in ${SELECTED_PACKAGES[@]+"${SELECTED_PACKAGES[@]}"}; do
        catalog_package_index "$paquet" || return 2
    done
    if [ "$CIBLE" -eq 1 ]; then
        log_info "Diagnostic ciblé : ${SELECTED_PACKAGES[*]}"
    fi
    cd "$REPO_DIR"
    verifier_syntaxe
    verifier_configurations
    if command -v git >/dev/null 2>&1; then
        verifier 'Espaces des modifications suivies par Git' env GIT_OPTIONAL_LOCKS=0 git -c core.fsmonitor=false --no-pager diff --no-ext-diff --no-textconv --check
    else
        incomplet 'Git absent : contrôle des espaces non effectué.'
    fi
    inventorier_outils
    log_info "Bilan : $SUCCES contrôles réussis, $ERREURS échecs, $INCOMPLETS contrôles incomplets, $DEPENDANCES_ABSENTES dépendances absentes."
    log_warn 'Aucune application, restauration ou interruption testée. Ce bilan ne certifie pas la sécurité du déploiement.'
    [ "$ERREURS" -eq 0 ] || return 1
    [ "$INCOMPLETS" -eq 0 ] && [ "$DEPENDANCES_ABSENTES" -eq 0 ] || return 2
}

main "$@"
