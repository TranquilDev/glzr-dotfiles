$Yasbc = 'C:\Program Files\YASB\yasbc.exe'
$GlazePath = 'C:\Program Files\glzr.io\GlazeWM\glazewm.exe'

# Сначала запускаем верхнюю панель.
if (-not (Get-Process yasb -ErrorAction SilentlyContinue)) {
    & $Yasbc start
}

Start-Sleep -Seconds 4

# Затем запускаем оконный менеджер.
if (-not (Get-Process glazewm -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath $GlazePath -ArgumentList "start"
}