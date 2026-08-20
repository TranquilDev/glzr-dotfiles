Start-Process "G:\Tools\VPN\Clash Verge\clash-verge.exe"

Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public class ClashStartupWindow {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc callback, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);

    [DllImport("user32.dll")]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder text, int count);

    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int command);

    public static IntPtr Find(uint targetPid) {
        IntPtr found = IntPtr.Zero;

        EnumWindows((hWnd, lParam) => {
            uint pid;
            GetWindowThreadProcessId(hWnd, out pid);

            if (pid != targetPid)
                return true;

            var cls = new StringBuilder(256);
            var title = new StringBuilder(512);

            GetClassName(hWnd, cls, cls.Capacity);
            GetWindowText(hWnd, title, title.Capacity);

            if (cls.ToString() == "Tauri Window" &&
                title.ToString() == "Clash Verge") {
                found = hWnd;
                return false;
            }

            return true;
        }, IntPtr.Zero);

        return found;
    }
}
"@

$p = $null
$h = [IntPtr]::Zero

for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Milliseconds 500

    $p = Get-Process clash-verge -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($p) {
        $h = [ClashStartupWindow]::Find([uint32]$p.Id)

        if ($h -ne [IntPtr]::Zero) {
            break
        }
    }
}

# Даём Clash полностью инициализироваться:
# трей, глобальные хоткеи и core.
Start-Sleep -Seconds 3

if ($h -ne [IntPtr]::Zero) {
    [ClashStartupWindow]::ShowWindow($h, 0) | Out-Null
}
