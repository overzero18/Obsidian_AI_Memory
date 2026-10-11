#!/bin/sh
set -eu

if [ "$#" -eq 0 ]; then
    command_name=menu
else
    command_name=$1
    shift
fi
base_path="${HOME}/Documents/ObsidianAI"
vault_name="MemoriaIA"
index_file="00 - Inicio.md"
tools="codex,claude,generic"
source_root=""
backup_path=""
apply=0
portable=0

usage() {
    cat <<'EOF'
Uso: obsidian-memory COMANDO [opciones]

Comandos:
  doctor      Solo lectura. Revisa bóveda, adaptadores, enlaces, posibles secretos y copias.
  status      Solo lectura. Muestra la ruta, adaptadores y última copia encontrada.
  update      Simula la actualización de archivos administrados; añade --apply para aplicarla.
  uninstall   Simula retirar solo los bloques administrados; añade --apply para aplicarlo.
  migrate     Simula importar notas antiguas; añade --apply para copiar sin borrar los originales.

Seguridad:
  - Ningún comando se ejecuta automáticamente ni crea sincronización en la nube.
  - doctor nunca modifica archivos.
  - update, uninstall y migrate solo escriben al indicar --apply y crean copias antes.

Opciones avanzadas:
  --base-path RUTA     Carpeta contenedora (predeterminada: ~/Documents/ObsidianAI)
  --vault-name NOMBRE  Nombre de la bóveda (predeterminado: MemoriaIA)
  --index-file ARCHIVO Índice raíz (predeterminado: 00 - Inicio.md)
  --tools LISTA        Separada por comas: codex,claude,generic
  --source-root RUTA   Carpeta de bóvedas antiguas (predeterminada: ruta base)
  --backup-path RUTA   Carpeta de copias a revisar (predeterminada: BASE/backups)
  --portable           Usa portable-data junto a estas herramientas, sin adaptadores globales
  --apply              Confirma update, uninstall o migrate

Empieza por: obsidian-memory doctor
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --base-path) base_path=$2; shift 2 ;;
        --vault-name) vault_name=$2; shift 2 ;;
        --index-file) index_file=$2; shift 2 ;;
        --tools) tools=$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]'); shift 2 ;;
        --source-root) source_root=$2; shift 2 ;;
        --backup-path) backup_path=$2; shift 2 ;;
        --portable) portable=1; shift ;;
        --apply) apply=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(dirname "$script_dir")
if [ "$portable" -eq 1 ]; then
    base_path="$repo_root/portable-data"
    tools="generic"
fi
vault_path="$base_path/$vault_name"
[ -n "$source_root" ] || source_root=$base_path
[ -n "$backup_path" ] || backup_path="$base_path/backups"
timestamp=$(date '+%Y%m%d-%H%M%S')
backup_root="$base_path/backups/$timestamp"
managed_start='<!-- OBSIDIAN-AI-MEMORY:START -->'
managed_end='<!-- OBSIDIAN-AI-MEMORY:END -->'
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/obsidian-ai-memory-control.XXXXXX")
trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM

backup_file() {
    backup_source=$1
    backup_label=$2
    [ -e "$backup_source" ] || return 0
    mkdir -p "$backup_root"
    cp -R "$backup_source" "$backup_root/$backup_label"
    printf 'BACKUP %s\n' "$backup_root/$backup_label"
}

check_secret_patterns() {
    scan_path=$1
    find "$scan_path" -type f -name '*.md' -exec grep -EIl \
        '(sk-[A-Za-z0-9_-]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY|password[[:space:]]*[:=][[:space:]]*[^[:space:]]+)' {} + 2>/dev/null || true
}

doctor() {
    errors=0
    warnings=0
    if [ ! -d "$vault_path" ]; then
        echo "ERROR vault not found: $vault_path"
        return 1
    fi
    echo "OK vault found: $vault_path"
    [ -r "$vault_path" ] || { echo "ERROR vault is not readable"; errors=$((errors + 1)); }
    [ -w "$vault_path" ] || { echo "ERROR vault is not writable"; errors=$((errors + 1)); }

    for required in "$index_file" 'AGENTS.md' 'AI-MEMORY-PROTOCOL.md' 'AI-ONBOARDING.md'; do
        if [ -f "$vault_path/$required" ]; then
            echo "OK required file: $required"
        else
            echo "ERROR missing required file: $required"
            errors=$((errors + 1))
        fi
    done

    case ",$tools," in
        *,codex,*)
            if [ -f "$HOME/.codex/AGENTS.md" ] && grep -Fq "$vault_path" "$HOME/.codex/AGENTS.md"; then
                echo "OK Codex references the vault"
            else
                echo "WARN Codex does not reference the vault"
                warnings=$((warnings + 1))
            fi
            ;;
    esac
    case ",$tools," in
        *,claude,*)
            if [ -f "$HOME/.claude/CLAUDE.md" ] && grep -Fq "$vault_path" "$HOME/.claude/CLAUDE.md"; then
                echo "OK Claude references the vault"
            else
                echo "WARN Claude does not reference the vault"
                warnings=$((warnings + 1))
            fi
            ;;
    esac

    titles="$temp_dir/titles"
    links="$temp_dir/links"
    find "$vault_path" -type f -name '*.md' ! -path '*/.obsidian/*' ! -path '*/Plantillas/*' ! -name 'AGENTS.md' -exec basename {} .md \; | sort -u > "$titles"
    find "$vault_path" -type f -name '*.md' ! -path '*/.obsidian/*' ! -path '*/Plantillas/*' ! -name 'AGENTS.md' -exec grep -hEo '\[\[[^]]+\]\]' {} + 2>/dev/null \
        | sed -e 's/^\[\[//' -e 's/\]\]$//' -e 's/|.*$//' -e 's/#.*$//' -e 's#^.*/##' | sort -u > "$links" || true
    broken=0
    while IFS= read -r link; do
        [ -n "$link" ] || continue
        case "$link" in Wiki|Nota) continue ;; esac
        if ! grep -Fxq "$link" "$titles"; then
            echo "WARN broken link: [[$link]]"
            broken=$((broken + 1))
        fi
    done < "$links"
    warnings=$((warnings + broken))

    orphans=0
    while IFS= read -r title; do
        case "$title" in 00\ -*|AGENTS|AI-MEMORY-PROTOCOL|AI-ONBOARDING) continue ;; esac
        if ! grep -Fxq "$title" "$links"; then
            echo "WARN possible orphan note: $title"
            orphans=$((orphans + 1))
        fi
    done < "$titles"
    warnings=$((warnings + orphans))

    secret_files=$(check_secret_patterns "$vault_path")
    if [ -n "$secret_files" ]; then
        echo "WARN possible secrets detected in:"
        printf '%s\n' "$secret_files"
        warnings=$((warnings + 1))
    else
        echo "OK no common secret patterns detected"
    fi

    if [ -d "$backup_path" ] && [ -n "$(ls -A "$backup_path" 2>/dev/null)" ]; then
        echo "OK backups found"
    else
        echo "WARN no backups found under $backup_path"
        warnings=$((warnings + 1))
    fi
    printf 'SUMMARY errors=%s warnings=%s\n' "$errors" "$warnings"
    [ "$errors" -eq 0 ]
}

uninstall_adapters() {
    changed=0
    for entry in "codex:$HOME/.codex/AGENTS.md" "claude:$HOME/.claude/CLAUDE.md"; do
        tool=${entry%%:*}
        destination=${entry#*:}
        case ",$tools," in *,"$tool",*) ;; *) continue ;; esac
        if [ ! -f "$destination" ] || ! grep -Fq "$managed_start" "$destination"; then
            echo "SKIP no managed $tool block: $destination"
            continue
        fi
        if ! grep -Fq "$managed_end" "$destination"; then
            echo "ERROR malformed managed $tool block; no changes made: $destination" >&2
            continue
        fi
        echo "REMOVE managed $tool block: $destination"
        changed=$((changed + 1))
        [ "$apply" -eq 1 ] || continue
        backup_file "$destination" "$tool-$(basename "$destination")"
        awk -v start="$managed_start" -v end="$managed_end" '
            $0 == start { managed = 1; next }
            managed && $0 == end { managed = 0; next }
            !managed { print }
        ' "$destination" > "$temp_dir/uninstall-$tool"
        mv "$temp_dir/uninstall-$tool" "$destination"
    done
    [ "$apply" -eq 1 ] || echo "DRY RUN: re-run with --apply to remove the listed blocks. The vault is never deleted."
    printf 'SUMMARY managed_blocks=%s applied=%s\n' "$changed" "$apply"
}

update_managed_files() {
    [ -d "$vault_path" ] || { echo "ERROR vault not found: $vault_path" >&2; return 1; }
    changed=0
    for relative in 'AI-MEMORY-PROTOCOL.md' 'AI-ONBOARDING.md' 'Plantillas/Plantilla - Nota atomica.md' 'Plantillas/Plantilla - Proyecto con grafo.md'; do
        source_file="$repo_root/templates/shared-vault/$relative"
        destination="$vault_path/$relative"
        if [ -f "$destination" ] && cmp -s "$source_file" "$destination"; then
            echo "OK current: $relative"
            continue
        fi
        echo "UPDATE managed file: $relative"
        changed=$((changed + 1))
        [ "$apply" -eq 1 ] || continue
        mkdir -p "$(dirname "$destination")"
        if [ -e "$destination" ]; then backup_file "$destination" "vault-${relative##*/}"; fi
        cp "$source_file" "$destination"
    done
    if [ "$apply" -eq 1 ]; then
        "$repo_root/scripts/install-obsidian-ai-memory.sh" --base-path "$base_path" --vault-name "$vault_name" --tools "$tools" --merge-existing
    else
        echo "DRY RUN: re-run with --apply. User notes, indexes, and preferences will not be overwritten."
    fi
    printf 'SUMMARY managed_updates=%s applied=%s\n' "$changed" "$apply"
}

migrate_legacy() {
    [ -d "$vault_path" ] || { echo "ERROR target vault not found: $vault_path" >&2; return 1; }
    sources=0
    blocked=0
    for legacy_name in ChatGptIA ClaudeIA; do
        legacy="$source_root/$legacy_name"
        [ -d "$legacy" ] || continue
        sources=$((sources + 1))
        possible_secrets=$(check_secret_patterns "$legacy")
        if [ -n "$possible_secrets" ]; then
            echo "ERROR possible secrets in $legacy; review before migration:"
            printf '%s\n' "$possible_secrets"
            blocked=1
        fi
    done
    [ "$sources" -gt 0 ] || { echo "ERROR no legacy vaults found under $source_root" >&2; return 1; }
    [ "$blocked" -eq 0 ] || { echo "Migration stopped before copying files." >&2; return 1; }
    if [ "$apply" -eq 1 ]; then backup_file "$vault_path" "$vault_name-before-legacy-migration"; fi

    for legacy_name in ChatGptIA ClaudeIA; do
        legacy="$source_root/$legacy_name"
        [ -d "$legacy" ] || { echo "SKIP legacy vault not found: $legacy"; continue; }
        find "$legacy" -type f -name '*.md' ! -path '*/.obsidian/*' -print | while IFS= read -r source_file; do
            relative=${source_file#"$legacy"/}
            destination="$vault_path/$relative"
            if [ ! -e "$destination" ]; then
                echo "ADD $legacy_name/$relative -> $relative"
                if [ "$apply" -eq 1 ]; then mkdir -p "$(dirname "$destination")"; cp "$source_file" "$destination"; fi
            elif cmp -s "$source_file" "$destination"; then
                echo "DUPLICATE $legacy_name/$relative"
            else
                echo "CONFLICT $legacy_name/$relative (not copied)"
            fi
        done
    done
    if [ "$apply" -eq 1 ]; then
        echo "Migration applied. Legacy vaults were not changed or deleted."
    else
        echo "DRY RUN: re-run with --apply. Conflicts remain untouched and legacy vaults are never deleted."
    fi
}

show_status() {
    printf 'Estado de Obsidian AI Memory\n\n'
    printf 'Bóveda: %s\n' "$vault_path"
    if [ -d "$vault_path" ]; then printf 'Bóveda disponible: sí\n'; else printf 'Bóveda disponible: no\n'; fi
    printf 'Adaptadores seleccionados: %s\n' "$tools"
    printf 'Copias: %s\n' "$backup_path"
    last_backup=$(find "$backup_path" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -n 1 || true)
    if [ -n "$last_backup" ]; then printf 'Última copia encontrada: %s\n' "$last_backup"; else printf 'Última copia encontrada: ninguna\n'; fi
    printf '\nPara una revisión completa sin cambios: obsidian-memory doctor\n'
}

confirm_apply() {
    printf 'Esta acción puede modificar archivos y creará copias antes. Escribe APLICAR para continuar: '
    IFS= read -r answer
    if [ "$answer" != 'APLICAR' ]; then
        echo 'Acción cancelada. No se modificó ningún archivo.'
        return 1
    fi
    apply=1
}

interactive_menu() {
    if [ ! -t 0 ]; then
        usage
        return
    fi
    cat <<'EOF'

Obsidian AI Memory
1) Revisar instalación (doctor, solo lectura)
2) Ver estado rápido (status, solo lectura)
3) Ver actualización disponible (simulación)
4) Aplicar actualización (pide confirmación)
5) Ver migración de bóvedas antiguas (simulación)
6) Ver desconexión de adaptadores (simulación)
0) Salir
EOF
    printf 'Elige una opción: '
    IFS= read -r choice
    case "$choice" in
        1) doctor ;;
        2) show_status ;;
        3) update_managed_files ;;
        4) confirm_apply && update_managed_files ;;
        5) migrate_legacy ;;
        6) uninstall_adapters ;;
        0|'') echo 'Sin cambios.' ;;
        *) echo 'Opción no válida. No se modificó ningún archivo.' ;;
    esac
}

case "$command_name" in
    doctor) doctor ;;
    status) show_status ;;
    update) update_managed_files ;;
    uninstall) uninstall_adapters ;;
    migrate) migrate_legacy ;;
    menu) interactive_menu ;;
    help|-h|--help) usage ;;
    *) echo "Unknown command: $command_name" >&2; usage >&2; exit 2 ;;
esac
