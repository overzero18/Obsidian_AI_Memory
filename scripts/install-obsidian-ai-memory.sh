#!/bin/sh
set -eu

base_path="${HOME}/Documents/ObsidianAI"
vault_name="MemoriaIA"
tools="codex,claude,generic"
merge_existing=0
portable=0

usage() {
    cat <<'EOF'
Usage: ./scripts/install-obsidian-ai-memory.sh [options]

Options:
  --base-path PATH    Parent directory for the vault
  --vault-name NAME   Vault directory name (default: MemoriaIA)
  --tools LIST        Comma-separated: codex,claude,generic
  --merge-existing    Back up an existing vault and add only missing files
  --portable          Store the vault beside this repository; do not modify tool settings
  -h, --help          Show this help
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --base-path)
            [ "$#" -ge 2 ] || { echo "Missing value for --base-path" >&2; exit 2; }
            base_path=$2
            shift 2
            ;;
        --vault-name)
            [ "$#" -ge 2 ] || { echo "Missing value for --vault-name" >&2; exit 2; }
            vault_name=$2
            shift 2
            ;;
        --tools)
            [ "$#" -ge 2 ] || { echo "Missing value for --tools" >&2; exit 2; }
            tools=$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')
            shift 2
            ;;
        --merge-existing)
            merge_existing=1
            shift
            ;;
        --portable)
            portable=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

case ",$tools," in
    *,codex,*|*,claude,*|*,generic,*) ;;
    *) echo "--tools must contain codex, claude, or generic" >&2; exit 2 ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(dirname "$script_dir")
if [ "$portable" -eq 1 ]; then
    base_path="$repo_root/portable-data"
    tools="generic"
fi
vault_path="${base_path}/${vault_name}"
timestamp=$(date '+%Y%m%d-%H%M%S')
backup_root="${base_path}/backups/${timestamp}"
managed_start='<!-- OBSIDIAN-AI-MEMORY:START -->'
managed_end='<!-- OBSIDIAN-AI-MEMORY:END -->'
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/obsidian-ai-memory.XXXXXX")
trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM

directory_has_content() {
    [ -d "$1" ] && [ -n "$(ls -A "$1" 2>/dev/null)" ]
}

backup_path() {
    source_path=$1
    label=$2
    [ -e "$source_path" ] || return 0
    mkdir -p "$backup_root"
    cp -R "$source_path" "$backup_root/$label"
    printf 'Backup created: %s\n' "$backup_root/$label"
}

validate_managed_block() {
    destination=$1
    [ -f "$destination" ] || return 0

    has_start=0
    has_end=0
    grep -Fq "$managed_start" "$destination" && has_start=1
    grep -Fq "$managed_end" "$destination" && has_end=1
    if [ "$has_start" -ne "$has_end" ]; then
        echo "Malformed managed block; no changes made: $destination" >&2
        return 1
    fi
}

copy_missing_templates() {
    source_root=$1
    destination_root=$2
    find "$source_root" -type f -print | while IFS= read -r source_file; do
        relative_path=${source_file#"$source_root"/}
        target_file="$destination_root/$relative_path"
        mkdir -p "$(dirname "$target_file")"
        if [ -e "$target_file" ]; then
            printf 'Preserved existing file: %s\n' "$target_file"
        else
            cp "$source_file" "$target_file"
        fi
    done
}

install_maintenance_tools() {
    tools_root="$base_path/ObsidianAI-Memory-Tools"
    launcher="$base_path/obsidian-memory"

    if [ -d "$tools_root" ]; then
        backup_path "$tools_root" "ObsidianAI-Memory-Tools"
    fi
    mkdir -p "$tools_root"
    for managed_directory in scripts templates; do
        find "$repo_root/$managed_directory" -type f -print | while IFS= read -r source_file; do
            relative_path=${source_file#"$repo_root/"}
            target_file="$tools_root/$relative_path"
            mkdir -p "$(dirname "$target_file")"
            cp "$source_file" "$target_file"
        done
    done

    if [ -f "$launcher" ]; then backup_path "$launcher" "obsidian-memory"; fi
    {
        printf '%s\n' '#!/bin/sh'
        printf 'exec sh "%s/scripts/memoryctl.sh" "$@" --base-path "%s" --vault-name "%s" --tools "%s"\n' \
            "$tools_root" "$base_path" "$vault_name" "$tools"
    } > "$launcher"
    chmod +x "$launcher"
}

install_managed_block() {
    template=$1
    destination=$2
    label=$3
    rendered="$temp_dir/rendered-$label"
    wrapped="$temp_dir/wrapped-$label"
    updated="$temp_dir/updated-$label"
    escaped_vault=$(printf '%s' "$vault_path" | sed 's/[\/&]/\\&/g')

    sed "s/{{VAULT_PATH}}/$escaped_vault/g" "$template" > "$rendered"
    {
        printf '%s\n' "$managed_start"
        cat "$rendered"
        printf '%s\n' "$managed_end"
    } > "$wrapped"

    mkdir -p "$(dirname "$destination")"
    if [ -f "$destination" ]; then
        validate_managed_block "$destination"
        backup_path "$destination" "$label"
        if grep -Fq "$managed_start" "$destination" && grep -Fq "$managed_end" "$destination"; then
            awk -v start="$managed_start" -v end="$managed_end" -v block="$wrapped" '
                BEGIN {
                    while ((getline line < block) > 0) replacement = replacement line ORS
                    close(block)
                }
                $0 == start { printf "%s", replacement; managed = 1; next }
                managed && $0 == end { managed = 0; next }
                !managed { print }
            ' "$destination" > "$updated"
        else
            cp "$destination" "$updated"
            printf '\n' >> "$updated"
            cat "$wrapped" >> "$updated"
        fi
    else
        cp "$wrapped" "$updated"
    fi
    mv "$updated" "$destination"
    printf 'Configured: %s\n' "$destination"
}

case ",$tools," in
    *,codex,*) validate_managed_block "$HOME/.codex/AGENTS.md" ;;
esac
case ",$tools," in
    *,claude,*) validate_managed_block "$HOME/.claude/CLAUDE.md" ;;
esac

if directory_has_content "$vault_path" && [ "$merge_existing" -ne 1 ]; then
    echo "'$vault_path' already contains files. Re-run with --merge-existing to preserve its files and add only missing templates." >&2
    exit 1
fi

if [ "$merge_existing" -eq 1 ] && directory_has_content "$vault_path"; then
    backup_path "$vault_path" "$vault_name"
fi

mkdir -p "$vault_path"
copy_missing_templates "$repo_root/templates/shared-vault" "$vault_path"
install_maintenance_tools

case ",$tools," in
    *,codex,*)
        install_managed_block "$repo_root/templates/adapters/codex.md.template" "$HOME/.codex/AGENTS.md" "codex-AGENTS.md"
        ;;
esac
case ",$tools," in
    *,claude,*)
        install_managed_block "$repo_root/templates/adapters/claude.md.template" "$HOME/.claude/CLAUDE.md" "claude-CLAUDE.md"
        ;;
esac

printf '\nInstallation completed.\n'
printf 'Shared vault: %s\n' "$vault_path"
printf 'Enabled adapters: %s\n' "$tools"
if [ "$portable" -eq 1 ]; then printf 'Portable mode: no global AI configuration was modified.\n'; fi
printf 'Open the vault in Obsidian and restart configured AI tools.\n'
printf 'For any other AI, use: %s/AI-ONBOARDING.md\n' "$vault_path"
printf '\nMaintenance command: %s doctor\n' "$base_path/obsidian-memory"
printf 'It checks the installation only; it does not change files.\n'
printf 'Update, uninstall, and migrate are manual and start as a preview. Add --apply only after reviewing it.\n'
printf 'No scheduled task or automatic cloud backup was created.\n'
