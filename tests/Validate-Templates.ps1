$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

$required = @(
    "scripts\Install-ObsidianAIMemory.ps1",
    "scripts\install-obsidian-ai-memory.sh",
    "scripts\MemoryCtl.ps1",
    "scripts\memoryctl.sh",
    "INSTALL.sh",
    "CHANGELOG.md",
    "VERSION",
    "docs\MAINTENANCE.md",
    "docs\MIGRATION.md",
    "docs\ADAPTERS.md",
    "docs\AUTOMATION.md",
    "docs\MEMORY-AND-CONTEXT.md",
    "docs\SOFTWARE-PROJECTS.md",
    "docs\VERIFY-INTEGRATION.md",
    "docs\RECOVERY.md",
    "docs\RELEASE.md",
    "templates\project-adapters\GEMINI.md.template",
    "templates\project-adapters\windsurf-obsidian-memory.md.template",
    "templates\project-adapters\copilot-instructions.md.template",
    "templates\project-adapters\opencode-AGENTS.md.template",
    "templates\project-worklog\AI-TASK-HANDOFF.md.template",
    "templates\adapters\codex.md.template",
    "templates\adapters\claude.md.template",
    "templates\shared-vault\00 - Inicio.md",
    "templates\shared-vault\00 - Preferencias.md",
    "templates\shared-vault\AGENTS.md",
    "templates\shared-vault\AI-MEMORY-PROTOCOL.md",
    "templates\shared-vault\AI-ONBOARDING.md",
    "templates\shared-vault\Proyectos\00 - Proyectos.md",
    "templates\shared-vault\Plantillas\Plantilla - Proyecto con grafo.md",
    "templates\shared-vault\Plantillas\Plantilla - Proyecto de software.md",
    "templates\shared-vault\Plantillas\Plantilla - Nota atomica.md"
)

foreach ($relative in $required) {
    $path = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing required file: $relative"
    }
}

foreach ($adapter in @("codex.md.template", "claude.md.template")) {
    $path = Join-Path $repoRoot "templates\adapters\$adapter"
    $content = Get-Content -LiteralPath $path -Raw
    if (-not $content.Contains("{{VAULT_PATH}}")) {
        throw "Adapter has no vault placeholder: $adapter"
    }
}

$opencodeAdapter = Get-Content -LiteralPath (Join-Path $repoRoot "templates\project-adapters\opencode-AGENTS.md.template") -Raw
if (-not $opencodeAdapter.Contains("{{VAULT_PATH}}")) {
    throw "OpenCode adapter has no vault placeholder."
}

$installer = Get-Content -LiteralPath (Join-Path $repoRoot "scripts\Install-ObsidianAIMemory.ps1") -Raw
foreach ($marker in @("OBSIDIAN-AI-MEMORY:START", "OBSIDIAN-AI-MEMORY:END")) {
    if (-not $installer.Contains($marker)) {
        throw "Installer is missing managed marker: $marker"
    }
}

$version = (Get-Content -LiteralPath (Join-Path $repoRoot "VERSION") -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') {
    throw "VERSION must use semantic versioning: $version"
}

if (-not (Test-Path -LiteralPath (Join-Path $repoRoot ".github\workflows\release.yml") -PathType Leaf)) {
    throw "Missing release workflow."
}

Write-Host "Template validation passed." -ForegroundColor Green
