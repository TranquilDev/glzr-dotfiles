#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
Persistent
; Вставка по физической клавише V независимо от RU/EN.
; sc02F — физическая клавиша V в нижнем ряду клавиатуры.
$^sc02F::Send("^v")

; Приложения
!w::LaunchNew("Rio")
!e::Run("explorer.exe")
!b::ActivateOrLaunch("brave.exe", "Brave")
!+b::LaunchNew("Brave")
!g::OpenGames()
!m::LaunchNew("Яндекс Музыка")
!i::Run("ms-settings:")

; Управление окнами
!q::CloseActiveWindow()
!f::MinimizeActiveWindow()
!LButton::MoveWindowUnderMouse()

; Управление самим скриптом
^!+r::Reload()
^!+q::ExitApp()

LaunchNew(shortcutName) {
    shortcut := FindStartMenuShortcut(shortcutName)

    if (shortcut = "") {
        MsgBox("Не найден ярлык приложения: " shortcutName)
        return
    }

    Run(shortcut)
}

ActivateOrLaunch(processName, shortcutName) {
    window := "ahk_exe " processName

    if WinExist(window) {
        try {
            if (WinGetMinMax(window) = -1)
                WinRestore(window)

            WinActivate(window)
            return
        }
    }

    LaunchNew(shortcutName)
}

OpenGames() {
    try {
        Run("steam://open/games")
    } catch {
        LaunchNew("Steam")
    }
}

CloseActiveWindow() {
    hwnd := WinExist("A")

    if !hwnd
        return

    try {
        className := WinGetClass("ahk_id " hwnd)

        if (
            className = "Progman"
            || className = "WorkerW"
            || className = "Shell_TrayWnd"
        )
            return

        WinClose("ahk_id " hwnd)
    }
}

MinimizeActiveWindow() {
    hwnd := WinExist("A")

    if !hwnd
        return

    try {
        className := WinGetClass("ahk_id " hwnd)

        if (
            className = "Progman"
            || className = "WorkerW"
            || className = "Shell_TrayWnd"
        )
            return

        WinMinimize("ahk_id " hwnd)
    }
}

MoveWindowUnderMouse() {
    MouseGetPos(,, &hwnd)

    if !hwnd
        return

    hwnd := DllCall(
        "GetAncestor",
        "Ptr", hwnd,
        "UInt", 2,
        "Ptr"
    )

    if !hwnd
        return

    try WinActivate("ahk_id " hwnd)
    catch
        return

    DllCall("ReleaseCapture")
    PostMessage(0xA1, 2,,, "ahk_id " hwnd)
}

FindStartMenuShortcut(name) {
    needle := StrLower(name)
    fallback := ""

    for root in [A_Programs, A_ProgramsCommon] {
        if !DirExist(root)
            continue

        Loop Files, root "\*.lnk", "R" {
            shortcutName := StrLower(
                RegExReplace(A_LoopFileName, "\.lnk$")
            )

            if (shortcutName = needle)
                return A_LoopFileFullPath

            if (fallback = "" && InStr(shortcutName, needle))
                fallback := A_LoopFileFullPath
        }
    }

    return fallback
}