#Requires AutoHotkey v2.0
#SingleInstance Force

InstallKeybdHook()

StateDir := EnvGet("LOCALAPPDATA") "\HyprWin"
StateFile := StateDir "\alt-lock.state"
StylesFile := EnvGet("USERPROFILE") "\.config\yasb\styles.css"

DirCreate(StateDir)

if !FileExist(StateFile)
    WriteState(false)

AltBlocked := ReadState()

UpdateVisual(AltBlocked)
SetTimer(CheckAltState, 25)
CheckAltState()

#HotIf AltBlocked
*LAlt::Return
*LAlt Up::Return
*RAlt::Return
*RAlt Up::Return
#HotIf

^+F12::ForceAltFree()

CheckAltState(*) {
    global AltBlocked

    nextState := ReadState()

    if nextState = AltBlocked
        return

    AltBlocked := nextState
    ReleaseAltKeys()
}

ForceAltFree(*) {
    global AltBlocked

    WriteState(false)
    AltBlocked := false

    ReleaseAltKeys()
    UpdateVisual(false)
}

ReadState() {
    global StateFile

    if !FileExist(StateFile)
        return false

    try {
        return Trim(FileRead(StateFile, "UTF-8")) = "1"
    } catch {
        return false
    }
}

WriteState(enabled) {
    global StateFile
    WriteUtf8(StateFile, enabled ? "1" : "0")
}

UpdateVisual(enabled) {
    global StylesFile

    if !FileExist(StylesFile)
        return

    try {
        css := FileRead(StylesFile, "UTF-8")
    } catch {
        return
    }

    pattern := "s)\R?/\* HYPR GAME MODE STATE START \*/.*?/\* HYPR GAME MODE STATE END \*/\R?"

    css := RegExReplace(css, pattern, "`r`n")

    if enabled {
        activeCss := "
(
/* HYPR GAME MODE STATE START */
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
)"

        css := RTrim(css, "`r`n") . "`r`n`r`n" . activeCss . "`r`n"
    }

    WriteUtf8(StylesFile, css)
}

WriteUtf8(path, text) {
    file := FileOpen(path, "w", "UTF-8-RAW")

    if !IsObject(file)
        return false

    file.Write(text)
    file.Close()

    return true
}

ReleaseAltKeys() {
    static KEYEVENTF_KEYUP := 0x0002

    DllCall(
        "user32\keybd_event",
        "UChar", 0xA4,
        "UChar", 0,
        "UInt", KEYEVENTF_KEYUP,
        "UPtr", 0
    )

    DllCall(
        "user32\keybd_event",
        "UChar", 0xA5,
        "UChar", 0,
        "UInt", KEYEVENTF_KEYUP,
        "UPtr", 0
    )

    DllCall(
        "user32\keybd_event",
        "UChar", 0x12,
        "UChar", 0,
        "UInt", KEYEVENTF_KEYUP,
        "UPtr", 0
    )
}