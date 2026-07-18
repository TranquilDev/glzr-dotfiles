# GlazeWM + YASB dotfiles

Персональная конфигурация Windows 10 на базе GlazeWM и YASB Reborn.

## Возможности

- тайлинговое управление окнами через GlazeWM;
- верхняя панель YASB только на основном мониторе;
- приложения с обоих мониторов отображаются на панели;
- индикатор раскладки RU/EN;
- динамический индикатор VPN для Clash Verge;
- быстрый запуск основных приложений;
- игровой режим с приостановкой GlazeWM.

## Индикатор VPN

Виджет проверяет системный прокси Windows каждую секунду.

- яркий фиолетовый щит и рамка: VPN включён;
- тусклый серый щит: VPN выключен;
- нажатие открывает Clash Verge.

Файлы виджета:

- .config/yasb/vpn-status.ps1
- .config/yasb/open-clash.cmd
- .config/yasb/config.yaml
- .config/yasb/styles.css

## Индикатор языка

Индикатор находится внутри right-island и показывает текущую раскладку en или ru. Нажатие открывает меню установленных раскладок Windows.

## Хоткеи

| Хоткей | Действие |
|---|---|
| Alt + W | Открыть Rio Terminal |
| Alt + E | Открыть Проводник |
| Alt + B | Открыть новое окно Brave |
| Alt + M | Открыть Яндекс Музыку |
| Alt + I | Открыть параметры Windows |
| Alt + Q | Закрыть активное окно |
| Alt + F | Свернуть активное окно |
| Alt + V | Включить или выключить Clash Verge |
| Alt + Shift + P | Включить или выключить игровой режим GlazeWM |
| Ctrl + Alt | Открыть поиск приложений |

Alt + V зарегистрирован непосредственно в Clash Verge. Остальные хоткеи находятся в конфигурации GlazeWM и launcher-скриптах.

## Применение изменений

YASB:

    & "C:\Program Files\YASB\yasbc.exe" reload

GlazeWM:

    & "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe" command "wm-reload-config"

## Локальные пути

- Rio: C:\Program Files\Rio\rio.exe
- Brave: C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe
- Clash Verge: G:\Tools\VPN\Clash Verge\clash-verge.exe
- Яндекс Музыка: %LOCALAPPDATA%\Programs\YandexMusic\Яндекс Музыка.exe
