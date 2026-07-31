$ErrorActionPreference = "Stop"

if (Get-Process Obsidian -ErrorAction SilentlyContinue) {
    throw "Сначала полностью закрой Obsidian."
}

$Config = Get-Content "$env:APPDATA\obsidian\obsidian.json" -Raw | ConvertFrom-Json
$Vaults = @($Config.vaults.PSObject.Properties | ForEach-Object { $_.Value } | Where-Object { $_.path -and (Test-Path -LiteralPath $_.path) })
$Vault = $Vaults | Where-Object { $_.open -eq $true } | Select-Object -First 1
if (-not $Vault) { $Vault = $Vaults | Select-Object -First 1 }
if (-not $Vault) { throw "Хранилище Obsidian не найдено." }

$Target = Join-Path $Vault.path ".obsidian"
$Snapshot = Join-Path $PSScriptRoot "snapshot"

New-Item -ItemType Directory -Path "$Target\snippets" -Force | Out-Null
New-Item -ItemType Directory -Path "$Target\themes" -Force | Out-Null
New-Item -ItemType Directory -Path "$Target\plugins" -Force | Out-Null

Copy-Item "$Snapshot\appearance.json" "$Target\appearance.json" -Force
Copy-Item "$Snapshot\snippets\*" "$Target\snippets" -Recurse -Force
Copy-Item "$Snapshot\themes\Encore" "$Target\themes\Encore" -Recurse -Force
Copy-Item "$Snapshot\plugins\obsidian-style-settings" "$Target\plugins\obsidian-style-settings" -Recurse -Force

Write-Host "Оформление восстановлено. Запускай Obsidian." -ForegroundColor Green
