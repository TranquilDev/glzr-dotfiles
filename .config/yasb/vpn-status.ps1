$ProxyEnabled = $false

try {
    $InternetSettings = Get-ItemProperty `
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

    $ProxyEnabled = [int]$InternetSettings.ProxyEnable -eq 1
} catch {}

$Styles = Join-Path $PSScriptRoot "styles.css"
$StateFile = Join-Path $PSScriptRoot ".vpn-widget-state"

if ($ProxyEnabled) {
    $State = "ON"
    $Color = "#f4e6ff"
    $Background = "rgba(203, 166, 247, 0.34)"
    $Border = "#d8a8ff"
} else {
    $State = "OFF"
    $Color = "#585b70"
    $Background = "rgba(49, 50, 68, 0.32)"
    $Border = "rgba(127, 132, 156, 0.18)"
}

$PreviousState = ""

if (Test-Path $StateFile) {
    $PreviousState = [IO.File]::ReadAllText($StateFile).Trim()
}

if ($PreviousState -ne $State -and (Test-Path $Styles)) {
    $Css = [IO.File]::ReadAllText($Styles)

    $DynamicCss = @"

/* VPN-DYNAMIC-BEGIN */
.vpn-status-widget .label {
    color: $Color;
    background-color: $Background;
    border: 1px solid $Border;
    border-radius: 6px;
    padding: 0;
    margin: 0;
    qproperty-alignment: AlignCenter;
}
/* VPN-DYNAMIC-END */
"@

    $Match = [regex]::Match(
        $Css,
        '(?s)/\* VPN-DYNAMIC-BEGIN \*/.*?/\* VPN-DYNAMIC-END \*/'
    )

    if ($Match.Success) {
        $Css = $Css.Remove(
            $Match.Index,
            $Match.Length
        ).Insert(
            $Match.Index,
            $DynamicCss
        )
    } else {
        $Css = $Css.TrimEnd() + "`r`n`r`n" + $DynamicCss
    }

    [IO.File]::WriteAllText(
        $Styles,
        $Css,
        [Text.UTF8Encoding]::new($false)
    )

    [IO.File]::WriteAllText(
        $StateFile,
        $State,
        [Text.ASCIIEncoding]::new()
    )
}

@{
    text = "VPN $State"
} | ConvertTo-Json -Compress