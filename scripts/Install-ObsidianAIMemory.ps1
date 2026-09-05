[CmdletBinding()]
param(
    [string]$BasePath = (Join-Path $env:USERPROFILE "Documents\ObsidianAI"),
    [string]$CodexVaultName = "ChatGptIA",
    [string]$ClaudeVaultName = "ClaudeIA",
    [switch]$MergeExisting
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$codexVault = Join-Path $BasePath $CodexVaultName
$claudeVault = Join-Path $BasePath $ClaudeVaultName
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $BasePath "backups\$timestamp"

function Test-DirectoryHasContent {
    param([string]$Path)
    return (Test-Path -LiteralPath $Path) -and
        (@(Get-ChildItem -LiteralPath $Path -Force).Count -gt 0)
}

function Backup-Directory {
    param([string]$Path)
    if (Test-DirectoryHasContent -Path $Path) {
        $backup = Join-Path $backupRoot (Split-Path -Leaf $Path)
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
        Get-ChildItem -LiteralPath $Path -Force |
            Copy-Item -Destination $backup -Recurse -Force
        Write-Host "Backup created: $backup" -ForegroundColor Yellow
    }
}

function Install-GlobalFile {
    param([string]$Source, [string]$Destination, [hashtable]$Replacements)

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    if (Test-Path -LiteralPath $Destination) {
        Copy-Item -LiteralPath $Destination -Destination "$Destination.backup-$timestamp"
    }

    $content = Get-Content -LiteralPath $Source -Raw
    foreach ($key in $Replacements.Keys) {
        $content = $content.Replace($key, $Replacements[$key])
    }
    Set-Content -LiteralPath $Destination -Value $content -Encoding utf8
}

try {
    foreach ($vault in @($codexVault, $claudeVault)) {
        if ((Test-DirectoryHasContent -Path $vault) -and -not $MergeExisting) {
            throw "'$vault' already contains files. Re-run with -MergeExisting to back it up and merge safely."
        }
    }

    if ($MergeExisting) {
        Backup-Directory -Path $codexVault
        Backup-Directory -Path $claudeVault
    }

    New-Item -ItemType Directory -Path $codexVault -Force | Out-Null
    New-Item -ItemType Directory -Path $claudeVault -Force | Out-Null
    Copy-Item -Path (Join-Path $repoRoot "templates\codex-vault\*") -Destination $codexVault -Recurse -Force
    Copy-Item -Path (Join-Path $repoRoot "templates\claude-vault\*") -Destination $claudeVault -Recurse -Force

    Install-GlobalFile `
        -Source (Join-Path $repoRoot "templates\global\AGENTS.md.template") `
        -Destination (Join-Path $env:USERPROFILE ".codex\AGENTS.md") `
        -Replacements @{ "{{CODEX_VAULT}}" = $codexVault }

    Install-GlobalFile `
        -Source (Join-Path $repoRoot "templates\global\CLAUDE.md.template") `
        -Destination (Join-Path $env:USERPROFILE ".claude\CLAUDE.md") `
        -Replacements @{ "{{CLAUDE_VAULT}}" = $claudeVault }

    Write-Host "Installation completed." -ForegroundColor Green
    Write-Host "Codex vault:  $codexVault"
    Write-Host "Claude vault: $claudeVault"
    Write-Host "Restart Codex and Claude Code so they load the new instructions."
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
