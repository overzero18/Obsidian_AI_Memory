[CmdletBinding()]
param(
    [string]$BasePath = (Join-Path $env:USERPROFILE "Documents\ObsidianAI"),
    [string]$VaultName = "MemoriaIA",
    [ValidateSet("Codex", "Claude", "Generic")]
    [string[]]$Tools = @("Codex", "Claude", "Generic"),
    [switch]$MergeExisting,
    [switch]$Portable
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
if ($Portable) {
    $BasePath = Join-Path $repoRoot "portable-data"
    $Tools = @("Generic")
}
$vaultPath = Join-Path $BasePath $VaultName
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $BasePath "backups\$timestamp"
$managedStart = "<!-- OBSIDIAN-AI-MEMORY:START -->"
$managedEnd = "<!-- OBSIDIAN-AI-MEMORY:END -->"

function Test-DirectoryHasContent {
    param([string]$Path)
    return (Test-Path -LiteralPath $Path) -and
        (@(Get-ChildItem -LiteralPath $Path -Force).Count -gt 0)
}

function Backup-Path {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path)) { return }

    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    $backup = Join-Path $backupRoot $Label
    if ((Get-Item -LiteralPath $Path).PSIsContainer) {
        Copy-Item -LiteralPath $Path -Destination $backup -Recurse -Force
    }
    else {
        Copy-Item -LiteralPath $Path -Destination $backup -Force
    }
    Write-Host "Backup created: $backup" -ForegroundColor Yellow
}

function Copy-TemplateTreeMissing {
    param([string]$Source, [string]$Destination)

    Get-ChildItem -LiteralPath $Source -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($Source.Length).TrimStart([char[]]"\/")
        $target = Join-Path $Destination $relative
        $targetParent = Split-Path -Parent $target
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null

        if (Test-Path -LiteralPath $target) {
            Write-Host "Preserved existing file: $target" -ForegroundColor DarkYellow
        }
        else {
            Copy-Item -LiteralPath $_.FullName -Destination $target
        }
    }
}

function Install-ManagedBlock {
    param([string]$Template, [string]$Destination)

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $block = (Get-Content -LiteralPath $Template -Raw).Replace("{{VAULT_PATH}}", $vaultPath)
    $wrappedBlock = "$managedStart`r`n$block`r`n$managedEnd"
    $existing = ""

    if (Test-Path -LiteralPath $Destination) {
        Backup-Path -Path $Destination -Label ((Split-Path -Leaf $parent) + "-" + (Split-Path -Leaf $Destination))
        $existing = Get-Content -LiteralPath $Destination -Raw
        $pattern = "(?s)" + [regex]::Escape($managedStart) + ".*?" + [regex]::Escape($managedEnd)
        if ($existing -match $pattern) {
            $updated = [regex]::Replace($existing, $pattern, $wrappedBlock).TrimEnd() + "`r`n"
        }
        else {
            $updated = $existing.TrimEnd() + "`r`n`r`n" + $wrappedBlock + "`r`n"
        }
    }
    else {
        $updated = $wrappedBlock + "`r`n"
    }

    Set-Content -LiteralPath $Destination -Value $updated -Encoding utf8
    Write-Host "Configured: $Destination" -ForegroundColor Green
}

try {
    if ((Test-DirectoryHasContent -Path $vaultPath) -and -not $MergeExisting) {
        throw "'$vaultPath' already contains files. Re-run with -MergeExisting to preserve its files and add only missing templates."
    }

    if ($MergeExisting -and (Test-DirectoryHasContent -Path $vaultPath)) {
        Backup-Path -Path $vaultPath -Label $VaultName
    }

    New-Item -ItemType Directory -Path $vaultPath -Force | Out-Null
    Copy-TemplateTreeMissing `
        -Source (Join-Path $repoRoot "templates\shared-vault") `
        -Destination $vaultPath

    if ($Tools -contains "Codex") {
        Install-ManagedBlock `
            -Template (Join-Path $repoRoot "templates\adapters\codex.md.template") `
            -Destination (Join-Path $env:USERPROFILE ".codex\AGENTS.md")
    }

    if ($Tools -contains "Claude") {
        Install-ManagedBlock `
            -Template (Join-Path $repoRoot "templates\adapters\claude.md.template") `
            -Destination (Join-Path $env:USERPROFILE ".claude\CLAUDE.md")
    }

    Write-Host ""
    Write-Host "Installation completed." -ForegroundColor Green
    Write-Host "Shared vault: $vaultPath"
    Write-Host "Enabled adapters: $($Tools -join ', ')"
    if ($Portable) { Write-Host "Portable mode: no global AI configuration was modified." }
    Write-Host "Open the vault in Obsidian. Restart configured AI tools so they reload their instructions."
    Write-Host "For any other AI, use: $(Join-Path $vaultPath 'AI-ONBOARDING.md')"
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
