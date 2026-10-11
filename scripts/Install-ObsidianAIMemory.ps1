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

function Test-ManagedBlockIntegrity {
    param([string]$Destination)
    if (-not (Test-Path -LiteralPath $Destination)) { return }

    $content = Get-Content -LiteralPath $Destination -Raw
    $hasStart = $content.Contains($managedStart)
    $hasEnd = $content.Contains($managedEnd)
    if ($hasStart -ne $hasEnd) {
        throw "Malformed managed block; no changes made: $Destination"
    }
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
        Test-ManagedBlockIntegrity -Destination $Destination
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

function Install-MaintenanceTools {
    $toolsRoot = Join-Path $BasePath "ObsidianAI-Memory-Tools"
    $launcher = Join-Path $BasePath "obsidian-memory.cmd"
    if (Test-Path -LiteralPath $toolsRoot) { Backup-Path -Path $toolsRoot -Label "ObsidianAI-Memory-Tools" }
    New-Item -ItemType Directory -Path $toolsRoot -Force | Out-Null
    foreach ($managedDirectory in @("scripts", "templates")) {
        Copy-Item -LiteralPath (Join-Path $repoRoot $managedDirectory) -Destination $toolsRoot -Recurse -Force
    }
    if (Test-Path -LiteralPath $launcher) { Backup-Path -Path $launcher -Label "obsidian-memory.cmd" }
    $toolsArgument = $Tools -join ','
    $launcherContent = "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$toolsRoot\scripts\MemoryCtl.ps1`" %* -BasePath `"$BasePath`" -VaultName `"$VaultName`" -Tools $toolsArgument`r`n"
    Set-Content -LiteralPath $launcher -Value $launcherContent -Encoding ascii
}

try {
    if ($Tools -contains "Codex") {
        Test-ManagedBlockIntegrity -Destination (Join-Path $env:USERPROFILE ".codex\AGENTS.md")
    }
    if ($Tools -contains "Claude") {
        Test-ManagedBlockIntegrity -Destination (Join-Path $env:USERPROFILE ".claude\CLAUDE.md")
    }

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
    Install-MaintenanceTools

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
    Write-Host ""
    Write-Host "Maintenance command: $(Join-Path $BasePath 'obsidian-memory.cmd') doctor"
    Write-Host "It checks the installation only; it does not change files."
    Write-Host "Update, uninstall, and migrate are manual and start as a preview. Add -Apply only after reviewing it."
    Write-Host "No scheduled task or automatic cloud backup was created."
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
