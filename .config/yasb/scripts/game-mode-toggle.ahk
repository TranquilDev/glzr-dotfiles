#Requires AutoHotkey v2.0
#SingleInstance Off

StateDir := EnvGet("LOCALAPPDATA") "\HyprWin"
StateFile := StateDir "\alt-lock.state"
StylesFile := EnvGet("USERPROFILE") "\.config\yasb\styles.css"

DirCreate(StateDir)

action := A_Args.Length >= 1 ? StrLower(A_Args[1]) : "toggle"
enabled := ReadState()

switch action {
    case "on":
        enabled := true

    case "off":
        enabled := false

    case "sync":
        ; Keep current state.

    default:
        enabled := !enabled
}

if action != "sync"
    WriteState(enabled)

UpdateVisual(enabled)
ExitApp()

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