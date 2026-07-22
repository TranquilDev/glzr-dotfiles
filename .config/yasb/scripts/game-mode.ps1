param(
    [ValidateSet("status", "toggle", "on", "off", "sync")]
    [string]$Action = "status"
)

$ErrorActionPreference = "Stop"

$Styles = Join-Path $HOME ".config\yasb\styles.css"
$GuardScript = Join-Path $HOME ".config\hotkeys\alt-lock-guard.ahk"

$StateDir = Join-Path $env:LOCALAPPDATA "HyprWin"
$StateFile = Join-Path $StateDir "alt-lock.state"

New-Item -ItemType Directory -Path $StateDir -Force | Out-Null

function Get-GameModeState {
    if (-not (Test-Path -LiteralPath $StateFile)) {
        return $false
    }

    return (
        [IO.File]::ReadAllText($StateFile).Trim() -eq "1"
    )
}

function Set-GameModeState {
    param([bool]$Enabled)

    [IO.File]::WriteAllText(
        $StateFile,
        $(if ($Enabled) { "1" } else { "0" }),
        [Text.UTF8Encoding]::new($false)
    )
}

function Set-GameModeVisual {
    param([bool]$Enabled)

    if (-not (Test-Path -LiteralPath $Styles)) {
        return
    }

    $Css = [IO.File]::ReadAllText($Styles)

    $Pattern =
        '(?ms)\r?\n?/\* HYPR GAME MODE STATE START \*/.*?/\* HYPR GAME MODE STATE END \*/\r?\n?'

    $Css = [regex]::Replace(
        $Css,
        $Pattern,
        "`r`n"
    )

    if ($Enabled) {
        $ActiveBlock = @"

/* HYPR GAME MODE STATE START */

/* Активный игровой режим */
.game-mode-widget,
.game-mode-widget:hover {
    border-color: rgba(216, 168, 255, 0.98);
    background-color: rgba(203, 166, 247, 0.42);
}

.game-mode-widget .label,
.game-mode-widget:hover .label {
    color: #ffffff;
}

/* HYPR GAME MODE STATE END */
"@

        $Css = $Css.TrimEnd() + $ActiveBlock + "`r`n"
    }

    [IO.File]::WriteAllText(
        $Styles,
        $Css,
        [Text.UTF8Encoding]::new($false)
    )
}

function Ensure-AltGuard {
    $Running = Get-CimInstance Win32_Process |
        Where-Object {
            $_.Name -like "AutoHotkey*.exe" -and
            $_.CommandLine -like "*alt-lock-guard.ahk*"
        } |
        Select-Object -First 1

    if ($Running) {
        return
    }

    $AhkExe = @(
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey32.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey32.exe"
    ) |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1

    if ($AhkExe -and (Test-Path -LiteralPath $GuardScript)) {
        Start-Process `
            -FilePath $AhkExe `
            -ArgumentList ('"{0}"' -f $GuardScript) `
            -WindowStyle Hidden
    }
}

$Current = Get-GameModeState

switch ($Action) {
    "status" {
        if ($Current) { "GAME MODE ON" } else { "GAME MODE OFF" }
        exit 0
    }

    "sync" {
        Set-GameModeVisual -Enabled $Current
        exit 0
    }

    "toggle" {
        $Target = -not $Current
    }

    "on" {
        $Target = $true
    }

    "off" {
        $Target = $false
    }
}

if ($Target) {
    Ensure-AltGuard
}

Set-GameModeState -Enabled $Target
Set-GameModeVisual -Enabled $Target

try {
    if ($Target) {
        [Console]::Beep(1100, 90)
    }
    else {
        [Console]::Beep(650, 90)
    }
}
catch {
}

if ($Target) {
    "GAME MODE ON"
}
else {
    "GAME MODE OFF"
}