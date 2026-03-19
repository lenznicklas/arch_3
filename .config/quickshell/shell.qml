import Quickshell
import Quickshell.Hyprland

ShellRoot {
    id: root
    property bool launcherOpen: false

    GlobalShortcut {
        appid: "quickshell"
        name: "launcher"
        description: "Open launcher"
        onPressed: root.launcherOpen = !root.launcherOpen
    }

    Bar {
        id: bar
    }

    Launcher {
        barWindow: bar
        open: root.launcherOpen
        onOpenChanged: root.launcherOpen = open
    }
}