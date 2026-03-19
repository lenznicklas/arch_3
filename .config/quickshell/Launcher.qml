import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

PopupWindow {
    id: launcher

    property var barWindow
    property bool open: false
    property string query: ""

    visible: open

    anchor.window: barWindow
    anchor.rect.x: (anchor.window.width / 2) - (width / 2)
    anchor.rect.y: 18

    implicitWidth: 720
    implicitHeight: 520

    onVisibleChanged: {
        if (visible) {
            searchInput.forceActiveFocus()
        } else {
            query = ""
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: "#dd101216"
        border.width: 1
        border.color: "#33ffffff"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 21
            color: "#ee0d1117"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 16
                color: "#1a1f27"
                border.width: 1
                border.color: searchInput.activeFocus ? "#4c8dff" : "#2a3442"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "󰍉"
                        color: "#9fb3c8"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: "white"
                        font.pixelSize: 16
                        selectionColor: "#4c8dff"
                        selectedTextColor: "white"
                        clip: true

                        text: launcher.query
                        onTextChanged: launcher.query = text

                        Keys.onEscapePressed: {
                            launcher.open = false
                            text = ""
                        }

                        onAccepted: {
                            if (filteredApps.values.length > 0) {
                                filteredApps.values[0].execute()
                                launcher.open = false
                                text = ""
                            }
                        }
                    }

                    Text {
                        text: "esc"
                        color: "#6f8096"
                        font.pixelSize: 12
                    }
                }
            }

            ScriptModel {
                id: filteredApps

                values: DesktopEntries.applications.values.filter(app => {
                    const q = launcher.query.trim().toLowerCase()
                    if (q.length === 0) return true

                    const name = (app.name || "").toLowerCase()
                    const genericName = (app.genericName || "").toLowerCase()
                    const comment = (app.comment || "").toLowerCase()
                    const id = (app.id || "").toLowerCase()

                    return name.includes(q)
                        || genericName.includes(q)
                        || comment.includes(q)
                        || id.includes(q)
                }).slice(0, 10)
            }

            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8
                clip: true
                model: filteredApps

                delegate: Rectangle {
                    required property var modelData

                    width: ListView.view.width
                    height: 58
                    radius: 16
                    color: mouse.containsMouse ? "#202833" : "#141922"
                    border.width: 1
                    border.color: mouse.containsMouse ? "#35527a" : "#1d2630"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 14

                        Rectangle {
                            width: 34
                            height: 34
                            radius: 10
                            color: "#0f141b"
                            border.width: 1
                            border.color: "#26303d"

                            IconImage {
                                anchors.centerIn: parent
                                source: modelData.icon
                                implicitSize: 20
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.name || modelData.id
                                color: "white"
                                font.pixelSize: 15
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.genericName || modelData.id || ""
                                color: "#8ea0b5"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            text: "↵"
                            color: "#708399"
                            font.pixelSize: 14
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            modelData.execute()
                            launcher.open = false
                            launcher.query = ""
                        }
                    }
                }
            }
        }
    }
}