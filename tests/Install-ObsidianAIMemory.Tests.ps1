$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $repositoryRoot "scripts\Install-ObsidianAIMemory.ps1"
$sandbox = Join-Path ([System.IO.Path]::GetTempPath()) ("obsidian-ai-memory-" + [guid]::NewGuid())
$originalUserProfile = $env:USERPROFILE

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

try {
    $profilePath = Join-Path $sandbox "profile"
    $basePath = Join-Path $sandbox "vaults"
    $codexDirectory = Join-Path $profilePath ".codex"
    New-Item -ItemType Directory -Path $codexDirectory -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $codexDirectory "AGENTS.md") -Value "# Existing Codex instructions" -Encoding UTF8
    $env:USERPROFILE = $profilePath

    & $installer -BasePath $basePath -VaultName "TestMemory" -Tools Codex, Claude, Generic

    $vaultPath = Join-Path $basePath "TestMemory"
    $launcher = Join-Path $basePath "obsidian-memory.cmd"
    Assert-True (Test-Path -LiteralPath $launcher) "Missing maintenance launcher."
    Assert-True (Test-Path -LiteralPath (Join-Path $basePath "ObsidianAI-Memory-Tools\scripts\MemoryCtl.ps1")) "Missing maintenance tools."
    foreach ($relativePath in @(
        "00 - Inicio.md",
        "00 - Preferencias.md",
        "AGENTS.md",
        "AI-MEMORY-PROTOCOL.md",
        "AI-ONBOARDING.md",
        "Proyectos\00 - Proyectos.md",
        "Plantillas\Plantilla - Nota atomica.md"
    )) {
        Assert-True (Test-Path -LiteralPath (Join-Path $vaultPath $relativePath)) "Missing vault file: $relativePath"
    }

    $codexConfig = Get-Content -LiteralPath (Join-Path $profilePath ".codex\AGENTS.md") -Raw
    $claudeConfig = Get-Content -LiteralPath (Join-Path $profilePath ".claude\CLAUDE.md") -Raw
    Assert-True ($codexConfig.Contains("# Existing Codex instructions")) "The existing Codex configuration was not preserved."
    Assert-True ($codexConfig.Contains($vaultPath)) "The Codex adapter does not reference the installed vault."
    Assert-True ($claudeConfig.Contains($vaultPath)) "The Claude adapter does not reference the installed vault."
    Assert-True (-not $codexConfig.Contains("{{VAULT_PATH}}")) "A Codex placeholder was not replaced."

    Set-Content -LiteralPath (Join-Path $vaultPath "User note.md") -Value "Keep this note" -Encoding UTF8
    & $installer -BasePath $basePath -VaultName "TestMemory" -Tools Codex, Claude, Generic -MergeExisting

    $codexConfigAfter = Get-Content -LiteralPath (Join-Path $profilePath ".codex\AGENTS.md") -Raw
    Assert-True ([regex]::Matches($codexConfigAfter, '<!-- OBSIDIAN-AI-MEMORY:START -->').Count -eq 1) "Reinstallation duplicated the start marker."
    Assert-True ([regex]::Matches($codexConfigAfter, '<!-- OBSIDIAN-AI-MEMORY:END -->').Count -eq 1) "Reinstallation duplicated the end marker."
    Assert-True (Test-Path -LiteralPath (Join-Path $vaultPath "User note.md")) "Merge removed a user note."

    $memoryCtl = Join-Path $repositoryRoot "scripts\MemoryCtl.ps1"
    & $memoryCtl doctor -BasePath $basePath -VaultName "TestMemory" -Tools Codex, Claude
    & $launcher doctor
    Assert-True ($LASTEXITCODE -eq 0) "The maintenance launcher failed."
    $launcherHelp = & $launcher help | Out-String
    Assert-True ($launcherHelp.Contains("doctor nunca modifica archivos")) "The maintenance help does not explain read-only doctor."

    Set-Content -LiteralPath (Join-Path $vaultPath "AI-MEMORY-PROTOCOL.md") -Value "locally modified protocol" -Encoding UTF8
    & $memoryCtl update -BasePath $basePath -VaultName "TestMemory" -Tools Codex, Claude
    Assert-True ((Get-Content -LiteralPath (Join-Path $vaultPath "AI-MEMORY-PROTOCOL.md") -Raw).Contains("locally modified protocol")) "Update dry run changed a file."
    & $memoryCtl update -BasePath $basePath -VaultName "TestMemory" -Tools Codex, Claude -Apply
    Assert-True (-not (Get-Content -LiteralPath (Join-Path $vaultPath "AI-MEMORY-PROTOCOL.md") -Raw).Contains("locally modified protocol")) "Update did not refresh a managed file."

    $legacyCodex = Join-Path $basePath "ChatGptIA\notas"
    $legacyClaude = Join-Path $basePath "ClaudeIA\notas"
    New-Item -ItemType Directory -Path $legacyCodex, $legacyClaude -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $legacyCodex "imported.md") -Value "# Imported note" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $legacyClaude "claude.md") -Value "# Claude note" -Encoding UTF8
    & $memoryCtl migrate -BasePath $basePath -VaultName "TestMemory" -SourceRoot $basePath
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $vaultPath "notas\imported.md"))) "Migration dry run copied a note."
    & $memoryCtl migrate -BasePath $basePath -VaultName "TestMemory" -SourceRoot $basePath -Apply
    Assert-True (Test-Path -LiteralPath (Join-Path $vaultPath "notas\imported.md")) "Migration did not import a note."
    Assert-True (Test-Path -LiteralPath (Join-Path $legacyCodex "imported.md")) "Migration changed a legacy vault."

    & $memoryCtl uninstall -BasePath $basePath -VaultName "TestMemory" -Tools Codex, Claude
    Assert-True ((Get-Content -LiteralPath (Join-Path $profilePath ".codex\AGENTS.md") -Raw).Contains("OBSIDIAN-AI-MEMORY:START")) "Uninstall dry run removed the block."
    & $memoryCtl uninstall -BasePath $basePath -VaultName "TestMemory" -Tools Codex, Claude -Apply
    $codexAfterUninstall = Get-Content -LiteralPath (Join-Path $profilePath ".codex\AGENTS.md") -Raw
    Assert-True (-not $codexAfterUninstall.Contains("OBSIDIAN-AI-MEMORY:START")) "Uninstall did not remove the managed block."
    Assert-True ($codexAfterUninstall.Contains("# Existing Codex instructions")) "Uninstall removed existing instructions."
    Assert-True (Test-Path -LiteralPath $vaultPath) "Uninstall removed the vault."

    $backupProtocol = Get-ChildItem -LiteralPath (Join-Path $basePath "backups") -Recurse -Filter "vault-AI-MEMORY-PROTOCOL.md" |
        Where-Object { (Get-Content -LiteralPath $_.FullName -Raw).Contains("locally modified protocol") } |
        Select-Object -First 1
    Assert-True ($null -ne $backupProtocol) "A recoverable protocol backup was not created."

    $portableRepo = Join-Path $sandbox "portable-repository"
    Copy-Item -LiteralPath $repositoryRoot -Destination $portableRepo -Recurse
    $portableProfile = Join-Path $sandbox "portable-profile"
    New-Item -ItemType Directory -Path $portableProfile -Force | Out-Null
    $env:USERPROFILE = $portableProfile
    & (Join-Path $portableRepo "scripts\Install-ObsidianAIMemory.ps1") -Portable
    Assert-True (Test-Path -LiteralPath (Join-Path $portableRepo "portable-data\MemoriaIA\00 - Inicio.md")) "Portable install did not create its vault."
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $portableProfile ".codex\AGENTS.md"))) "Portable install changed a global Codex configuration."
    & (Join-Path $portableRepo "scripts\MemoryCtl.ps1") doctor -Portable

    Write-Host "Integration test passed." -ForegroundColor Green
}
finally {
    $env:USERPROFILE = $originalUserProfile
    if (Test-Path -LiteralPath $sandbox) {
        Remove-Item -LiteralPath $sandbox -Recurse -Force
    }
}
