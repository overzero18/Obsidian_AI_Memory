#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
sandbox=$(mktemp -d "${TMPDIR:-/tmp}/obsidian-ai-memory-test.XXXXXX")
trap 'rm -rf "$sandbox"' EXIT HUP INT TERM

for relative in \
    'docs/AUTOMATION.md' \
    'docs/MEMORY-AND-CONTEXT.md' \
    'docs/SOFTWARE-PROJECTS.md' \
    'docs/VERIFY-INTEGRATION.md' \
    'templates/project-adapters/opencode-AGENTS.md.template' \
    'templates/project-worklog/AI-TASK-HANDOFF.md.template'
do
    [ -f "$repo_root/$relative" ] || { echo "Missing project resource: $relative" >&2; exit 1; }
done

grep -Fq '{{VAULT_PATH}}' "$repo_root/templates/project-adapters/opencode-AGENTS.md.template"

export HOME="$sandbox/home"
base_path="$sandbox/vaults"
mkdir -p "$HOME/.codex"
printf '# Existing Codex instructions\n' > "$HOME/.codex/AGENTS.md"

"$repo_root/scripts/install-obsidian-ai-memory.sh" \
    --base-path "$base_path" \
    --vault-name TestMemory \
    --tools codex,claude,generic

vault="$base_path/TestMemory"
[ -x "$base_path/obsidian-memory" ] || { echo "Missing maintenance launcher" >&2; exit 1; }
[ -f "$base_path/ObsidianAI-Memory-Tools/scripts/memoryctl.sh" ] || { echo "Missing maintenance tools" >&2; exit 1; }
for relative in \
    '00 - Inicio.md' \
    '00 - Preferencias.md' \
    'AGENTS.md' \
    'AI-MEMORY-PROTOCOL.md' \
    'AI-ONBOARDING.md' \
    'Proyectos/00 - Proyectos.md' \
    'Plantillas/Plantilla - Proyecto de software.md' \
    'Plantillas/Plantilla - Nota atomica.md'
do
    [ -f "$vault/$relative" ] || { echo "Missing vault file: $relative" >&2; exit 1; }
done

grep -Fq '# Existing Codex instructions' "$HOME/.codex/AGENTS.md"
grep -Fq "$vault" "$HOME/.codex/AGENTS.md"
grep -Fq "$vault" "$HOME/.claude/CLAUDE.md"
! grep -Fq '{{VAULT_PATH}}' "$HOME/.codex/AGENTS.md"

printf 'Keep this note\n' > "$vault/User note.md"
"$repo_root/scripts/install-obsidian-ai-memory.sh" \
    --base-path "$base_path" \
    --vault-name TestMemory \
    --tools codex,claude,generic \
    --merge-existing

[ "$(grep -Fc '<!-- OBSIDIAN-AI-MEMORY:START -->' "$HOME/.codex/AGENTS.md")" -eq 1 ]
[ "$(grep -Fc '<!-- OBSIDIAN-AI-MEMORY:END -->' "$HOME/.codex/AGENTS.md")" -eq 1 ]
[ -f "$vault/User note.md" ]

"$repo_root/scripts/memoryctl.sh" doctor \
    --base-path "$base_path" --vault-name TestMemory --tools codex,claude
"$base_path/obsidian-memory" doctor
"$base_path/obsidian-memory" help > "$sandbox/maintenance-help.txt"
grep -Fq 'doctor nunca modifica archivos' "$sandbox/maintenance-help.txt"
"$base_path/obsidian-memory" status > "$sandbox/maintenance-status.txt"
grep -Fq 'Estado de Obsidian AI Memory' "$sandbox/maintenance-status.txt"

printf 'locally modified protocol\n' > "$vault/AI-MEMORY-PROTOCOL.md"
"$repo_root/scripts/memoryctl.sh" update \
    --base-path "$base_path" --vault-name TestMemory --tools codex,claude
grep -Fq 'locally modified protocol' "$vault/AI-MEMORY-PROTOCOL.md"
"$repo_root/scripts/memoryctl.sh" update \
    --base-path "$base_path" --vault-name TestMemory --tools codex,claude --apply
! grep -Fq 'locally modified protocol' "$vault/AI-MEMORY-PROTOCOL.md"
[ -f "$vault/User note.md" ]
find "$base_path/backups" -type f -name 'vault-AI-MEMORY-PROTOCOL.md' -exec grep -Fq 'locally modified protocol' {} \;

mkdir -p "$base_path/ChatGptIA/notas" "$base_path/ClaudeIA/notas"
printf '# Imported note\n' > "$base_path/ChatGptIA/notas/imported.md"
printf '# Claude note\n' > "$base_path/ClaudeIA/notas/claude.md"
"$repo_root/scripts/memoryctl.sh" migrate \
    --base-path "$base_path" --vault-name TestMemory --source-root "$base_path"
[ ! -f "$vault/notas/imported.md" ]
"$repo_root/scripts/memoryctl.sh" migrate \
    --base-path "$base_path" --vault-name TestMemory --source-root "$base_path" --apply
[ -f "$vault/notas/imported.md" ]
[ -f "$vault/notas/claude.md" ]
[ -f "$base_path/ChatGptIA/notas/imported.md" ]

"$repo_root/scripts/memoryctl.sh" uninstall \
    --base-path "$base_path" --vault-name TestMemory --tools codex,claude
grep -Fq '<!-- OBSIDIAN-AI-MEMORY:START -->' "$HOME/.codex/AGENTS.md"
"$repo_root/scripts/memoryctl.sh" uninstall \
    --base-path "$base_path" --vault-name TestMemory --tools codex,claude --apply
! grep -Fq '<!-- OBSIDIAN-AI-MEMORY:START -->' "$HOME/.codex/AGENTS.md"
grep -Fq '# Existing Codex instructions' "$HOME/.codex/AGENTS.md"
[ -d "$vault" ]
find "$base_path/backups" -type f -name 'codex-AGENTS.md' -exec grep -Fq '<!-- OBSIDIAN-AI-MEMORY:START -->' {} \;

portable_repo="$sandbox/portable-repository"
cp -R "$repo_root" "$portable_repo"
portable_home="$sandbox/portable-home"
mkdir -p "$portable_home"
HOME="$portable_home" sh "$portable_repo/INSTALL.sh" --portable
[ -f "$portable_repo/portable-data/MemoriaIA/00 - Inicio.md" ]
[ ! -e "$portable_home/.codex/AGENTS.md" ]
HOME="$portable_home" "$portable_repo/scripts/memoryctl.sh" doctor --portable

printf 'Shell integration test passed.\n'
