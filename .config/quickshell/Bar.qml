import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io


PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 34

        Rectangle {
            anchors.fill: parent
            color: "#111111"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 16

                // GANZ LINKS: Arch Icon
                Text {
                    text: ""
                    color: "white"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                }

                // WORKSPACES
                Row {
                    spacing: 8

                    Repeater {
                        model: Hyprland.workspaces

                        delegate: Rectangle {
                            required property var modelData
                            visible: modelData.lastIpcObject.windows > 0 || modelData.active
                            radius: 6
                            height: 24
                            width: wsText.implicitWidth + 16
                            color: modelData.focused ? "#3b82f6" : "#2a2a2a"

                            Text {
                                id: wsText
                                anchors.centerIn: parent
                                color: "white"
                                text: modelData.id
                                font.pixelSize: 13
                                font.bold: modelData.focused
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.activate()
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // NETZWERK
                Text {
                    id: netText
                    color: "white"
                    font.pixelSize: 13
                    text: "Netz wird geladen..."
                }

                Process {
                    id: nmcliProc
                    command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d: -f2- | head -n1"]

                    stdout: StdioCollector {
                        onTextChanged: {
                            const s = text.trim()
                            netText.text = s.length > 0 ? ("  " + s) : "󰖪 offline"
                        }
                    }

                    onExited: exitCode => {
                        if (exitCode !== 0 && netText.text === "Netz wird geladen...") {
                            netText.text = "󰖪 offline"
                        }
                    }
                }

                Timer {
                    interval: 5000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: nmcliProc.running = true
                }

                // UHR
                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }

                Text {
                    color: "white"
                    font.pixelSize: 13
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                }

                // AKKU
                Text {
                    id: batteryText
                    color: "white"
                    font.pixelSize: 13
                    text: "󰂑 --%"
                }

                Process {
                    id: batteryProc
                    command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null"]
                    
                    stdout: StdioCollector {
                        onTextChanged: {
                            const s = text.trim()
                            batteryText.text = s.length > 0 ? ("󰂁 " + s + "%") : "󰂑 --%"
                        }
                    }

                    onExited: exitCode => {
                        if (exitCode !== 0) {
                            batteryText.text = "󰂑 --%"
                        }
                    }
                }

                Timer {
                    interval: 10000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: batteryProc.running = true
                }
            }
        }
    }