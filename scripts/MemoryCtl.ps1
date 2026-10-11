[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("doctor", "status", "update", "uninstall", "migrate", "menu", "help")]
    [string]$Command = "menu",
    [string]$BasePath = (Join-Path $env:USERPROFILE "Documents\ObsidianAI"),
    [string]$VaultName = "MemoriaIA",
    [string]$IndexFile = "00 - Inicio.md",
    [string[]]$Tools = @("Codex", "Claude", "Generic"),
    [string]$SourceRoot,
    [string]$BackupPath,
    [switch]$Apply,
    [switch]$Portable
)

$ErrorActionPreference = "Stop"
$validTools = @("Codex", "Claude", "Generic")
$Tools = @($Tools | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$invalidTools = @($Tools | Where-Object { $_ -notin $validTools })
if ($invalidTools.Count) { throw "-Tools only accepts: $($validTools -join ', ')" }
$repoRoot = Split-Path -Parent $PSScriptRoot
if ($Portable) {
    $BasePath = Join-Path $repoRoot "portable-data"
    $Tools = @("Generic")
}
$vaultPath = Join-Path $BasePath $VaultName
if (-not $SourceRoot) { $SourceRoot = $BasePath }
if (-not $BackupPath) { $BackupPath = Join-Path $BasePath "backups" }
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $BasePath "backups\$timestamp"
$managedStart = "<!-- OBSIDIAN-AI-MEMORY:START -->"
$managedEnd = "<!-- OBSIDIAN-AI-MEMORY:END -->"

function Show-Usage {
    Write-Host @"
Uso: obsidian-memory.cmd COMANDO [opciones]

Comandos:
  doctor      Solo lectura. Revisa bóveda, adaptadores, enlaces, posibles secretos y copias.
  status      Solo lectura. Muestra la ruta, adaptadores y última copia encontrada.
  update      Simula la actualización; añade -Apply para aplicarla.
  uninstall   Simula retirar solo los bloques administrados; añade -Apply para aplicarlo.
  migrate     Simula importar notas antiguas; añade -Apply para copiar sin borrar los originales.

Seguridad:
  - Ningún comando se ejecuta automáticamente ni crea sincronización en la nube.
  - doctor nunca modifica archivos.
  - update, uninstall y migrate solo escriben al indicar -Apply y crean copias antes.

Opciones avanzadas: -BasePath, -VaultName, -IndexFile, -Tools, -SourceRoot, -BackupPath, -Portable, -Apply

Empieza por: obsidian-memory.cmd doctor
"@
}

function Show-Status {
    Write-Host "Estado de Obsidian AI Memory"
    Write-Host ""
    Write-Host "Bóveda: $vaultPath"
    Write-Host "Bóveda disponible: $([bool](Test-Path -LiteralPath $vaultPath -PathType Container))"
    Write-Host "Adaptadores seleccionados: $($Tools -join ', ')"
    Write-Host "Copias: $BackupPath"
    $lastBackup = Get-ChildItem -LiteralPath $BackupPath -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name | Select-Object -Last 1
    if ($lastBackup) { Write-Host "Última copia encontrada: $($lastBackup.FullName)" }
    else { Write-Host "Última copia encontrada: ninguna" }
    Write-Host ""
    Write-Host "Para una revisión completa sin cambios: obsidian-memory.cmd doctor"
}

function Confirm-Apply {
    $answer = Read-Host "Esta acción puede modificar archivos y creará copias antes. Escribe APLICAR para continuar"
    if ($answer -ne "APLICAR") { Write-Host "Acción cancelada. No se modificó ningún archivo."; return $false }
    $script:Apply = $true
    return $true
}

function Show-MainMenu {
    if ([Console]::IsInputRedirected) { Show-Usage; return }
    Write-Host @"

Obsidian AI Memory
1) Revisar instalación (doctor, solo lectura)
2) Ver estado rápido (status, solo lectura)
3) Ver actualización disponible (simulación)
4) Aplicar actualización (pide confirmación)
5) Ver migración de bóvedas antiguas (simulación)
6) Ver desconexión de adaptadores (simulación)
0) Salir
"@
    $choice = Read-Host "Elige una opción"
    switch ($choice) {
        "1" { if ((Invoke-Doctor) -ne 0) { Write-Host "La revisión encontró errores." } }
        "2" { Show-Status }
        "3" { Invoke-Update }
        "4" { if (Confirm-Apply) { Invoke-Update } }
        "5" { Invoke-LegacyMigration }
        "6" { Invoke-UninstallAdapters }
        { $_ -in @("", "0") } { Write-Host "Sin cambios." }
        default { Write-Host "Opción no válida. No se modificó ningún archivo." }
    }
}

function Backup-ItemSafe {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    Copy-Item -LiteralPath $Path -Destination (Join-Path $backupRoot $Label) -Recurse -Force
    Write-Host "BACKUP $(Join-Path $backupRoot $Label)"
}

function Find-PossibleSecrets {
    param([string]$Path)
    $pattern = '(sk-[A-Za-z0-9_-]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY|password\s*[:=]\s*\S+)'
    return @(Get-ChildItem -LiteralPath $Path -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue |
        Select-String -Pattern $pattern | Select-Object -ExpandProperty Path -Unique)
}

function Invoke-Doctor {
    $errors = 0
    $warnings = 0
    if (-not (Test-Path -LiteralPath $vaultPath -PathType Container)) {
        Write-Host "ERROR vault not found: $vaultPath"
        return 1
    }
    Write-Host "OK vault found: $vaultPath"
    foreach ($required in @($IndexFile, "AGENTS.md", "AI-MEMORY-PROTOCOL.md", "AI-ONBOARDING.md")) {
        if (Test-Path -LiteralPath (Join-Path $vaultPath $required) -PathType Leaf) { Write-Host "OK required file: $required" }
        else { Write-Host "ERROR missing required file: $required"; $errors++ }
    }
    $adapterPaths = @{
        Codex = Join-Path $env:USERPROFILE ".codex\AGENTS.md"
        Claude = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
    }
    foreach ($tool in @("Codex", "Claude")) {
        if ($Tools -notcontains $tool) { continue }
        $path = $adapterPaths[$tool]
        if ((Test-Path -LiteralPath $path) -and (Get-Content -LiteralPath $path -Raw).Contains($vaultPath)) { Write-Host "OK $tool references the vault" }
        else { Write-Host "WARN $tool does not reference the vault"; $warnings++ }
    }

    $notes = @(Get-ChildItem -LiteralPath $vaultPath -Recurse -File -Filter "*.md" | Where-Object {
        $_.FullName -notmatch '[\\/]\.obsidian[\\/]' -and
        $_.FullName -notmatch '[\\/]Plantillas[\\/]' -and
        $_.Name -ne 'AGENTS.md'
    })
    $titles = @{}; foreach ($note in $notes) { $titles[$note.BaseName] = $true }
    $linked = @{}
    foreach ($note in $notes) {
        $content = Get-Content -LiteralPath $note.FullName -Raw
        foreach ($match in [regex]::Matches($content, '\[\[([^\]]+)\]\]')) {
            $target = ($match.Groups[1].Value -split '\|')[0] -replace '#.*$', ''
            $target = Split-Path $target -Leaf
            if ($target) {
                if ($target -in @("Wiki", "Nota")) { continue }
                $linked[$target] = $true
                if (-not $titles.ContainsKey($target)) { Write-Host "WARN broken link: [[$target]]"; $warnings++ }
            }
        }
    }
    foreach ($title in $titles.Keys) {
        if ($title -notmatch '^00 - ' -and $title -notin @("AGENTS", "AI-MEMORY-PROTOCOL", "AI-ONBOARDING") -and -not $linked.ContainsKey($title)) {
            Write-Host "WARN possible orphan note: $title"; $warnings++
        }
    }
    $secrets = Find-PossibleSecrets $vaultPath
    if ($secrets.Count) { Write-Host "WARN possible secrets detected in:"; $secrets | ForEach-Object { Write-Host $_ }; $warnings++ }
    else { Write-Host "OK no common secret patterns detected" }
    $backups = $BackupPath
    if ((Test-Path -LiteralPath $backups) -and @(Get-ChildItem -LiteralPath $backups -Force).Count) { Write-Host "OK backups found" }
    else { Write-Host "WARN no backups found under $backups"; $warnings++ }
    Write-Host "SUMMARY errors=$errors warnings=$warnings"
    if ($errors) { return 1 }; return 0
}

function Invoke-UninstallAdapters {
    $adapterPaths = @{
        Codex = Join-Path $env:USERPROFILE ".codex\AGENTS.md"
        Claude = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
    }
    $pattern = '(?s)' + [regex]::Escape($managedStart) + '.*?' + [regex]::Escape($managedEnd) + '\s*'
    foreach ($tool in @("Codex", "Claude")) {
        if ($Tools -notcontains $tool) { continue }
        $path = $adapterPaths[$tool]
        if (-not (Test-Path -LiteralPath $path)) { Write-Host "SKIP no configuration: $path"; continue }
        $content = Get-Content -LiteralPath $path -Raw
        if (-not $content.Contains($managedStart)) { Write-Host "SKIP no managed $tool block: $path"; continue }
        if (-not $content.Contains($managedEnd)) { Write-Error "Malformed managed $tool block; no changes made: $path"; continue }
        Write-Host "REMOVE managed $tool block: $path"
        if ($Apply) {
            Backup-ItemSafe $path ("$($tool.ToLower())-" + (Split-Path -Leaf $path))
            Set-Content -LiteralPath $path -Value ([regex]::Replace($content, $pattern, '').TrimEnd() + "`r`n") -Encoding utf8
        }
    }
    if (-not $Apply) { Write-Host "DRY RUN: re-run with -Apply. The vault is never deleted." }
}

function Invoke-Update {
    if (-not (Test-Path -LiteralPath $vaultPath -PathType Container)) { throw "Vault not found: $vaultPath" }
    $managed = @("AI-MEMORY-PROTOCOL.md", "AI-ONBOARDING.md", "Plantillas\Plantilla - Nota atomica.md", "Plantillas\Plantilla - Proyecto con grafo.md")
    foreach ($relative in $managed) {
        $source = Join-Path $repoRoot "templates\shared-vault\$relative"
        $destination = Join-Path $vaultPath $relative
        $same = (Test-Path -LiteralPath $destination) -and ((Get-FileHash $source).Hash -eq (Get-FileHash $destination).Hash)
        if ($same) { Write-Host "OK current: $relative"; continue }
        Write-Host "UPDATE managed file: $relative"
        if ($Apply) {
            if (Test-Path -LiteralPath $destination) { Backup-ItemSafe $destination ("vault-" + (Split-Path -Leaf $destination)) }
            New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
            Copy-Item -LiteralPath $source -Destination $destination -Force
        }
    }
    if ($Apply) {
        & (Join-Path $repoRoot "scripts\Install-ObsidianAIMemory.ps1") -BasePath $BasePath -VaultName $VaultName -Tools $Tools -MergeExisting
        if ($LASTEXITCODE) { throw "Installer update failed with exit code $LASTEXITCODE" }
    }
    else { Write-Host "DRY RUN: re-run with -Apply. User notes, indexes, and preferences will not be overwritten." }
}

function Invoke-LegacyMigration {
    if (-not (Test-Path -LiteralPath $vaultPath -PathType Container)) { throw "Target vault not found: $vaultPath" }
    $sources = @("ChatGptIA", "ClaudeIA") | ForEach-Object { Join-Path $SourceRoot $_ } | Where-Object { Test-Path -LiteralPath $_ -PathType Container }
    if (-not $sources.Count) { throw "No legacy vaults found under $SourceRoot" }
    $secretFiles = @($sources | ForEach-Object { Find-PossibleSecrets $_ })
    if ($secretFiles.Count) { Write-Host "ERROR possible secrets; migration stopped before copying:"; $secretFiles | ForEach-Object { Write-Host $_ }; return }
    if ($Apply) { Backup-ItemSafe $vaultPath "$VaultName-before-legacy-migration" }
    foreach ($sourceVault in $sources) {
        Get-ChildItem -LiteralPath $sourceVault -Recurse -File -Filter "*.md" | Where-Object { $_.FullName -notmatch '[\\/]\.obsidian[\\/]' } | ForEach-Object {
            $relative = $_.FullName.Substring($sourceVault.Length).TrimStart([char[]]"\/")
            $destination = Join-Path $vaultPath $relative
            if (-not (Test-Path -LiteralPath $destination)) {
                Write-Host "ADD $((Split-Path -Leaf $sourceVault))/$relative -> $relative"
                if ($Apply) { New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null; Copy-Item -LiteralPath $_.FullName -Destination $destination }
            }
            elseif ((Get-FileHash $_.FullName).Hash -eq (Get-FileHash $destination).Hash) { Write-Host "DUPLICATE $relative" }
            else { Write-Host "CONFLICT $relative (not copied)" }
        }
    }
    if ($Apply) { Write-Host "Migration applied. Legacy vaults were not changed or deleted." }
    else { Write-Host "DRY RUN: re-run with -Apply. Conflicts remain untouched and legacy vaults are never deleted." }
}

try {
    switch ($Command) {
        doctor { if ((Invoke-Doctor) -ne 0) { throw "Doctor found blocking errors." } }
        status { Show-Status }
        update { Invoke-Update }
        uninstall { Invoke-UninstallAdapters }
        migrate { Invoke-LegacyMigration }
        menu { Show-MainMenu }
        help { Show-Usage }
    }
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
