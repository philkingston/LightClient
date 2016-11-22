import QtQuick 2.5
import QtQuick.Window 2.2
import QtWebSockets 1.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import "content/ColorUtils.js" as ColorUtils

Window {
    id: root
    visible: true
    width: 480
    height: 640
    title: qsTr("LED Colour selector")
    property int ledCount: 50

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        Row {
            Layout.fillWidth: true
            Layout.preferredHeight: 10
            id: preview

            Repeater {
                anchors.fill: parent
                model: ledCount
                Rectangle {
                    width: parent.width / ledCount
                    height: width
                    radius: width
                    color: "black"
                }
            }
        }

        ColumnLayout {
            id: type1
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColorWheel {
                id: wheel1
                Layout.fillWidth: true
                Layout.fillHeight: true
                onColorRGBAChanged: {
                    type1.update()
                }
            }

            function update() {
                if(socket.status == WebSocket.Open) {
                    var newBytes = ''
                    var r = wheel1.colorRGBA.x
                    var g = wheel1.colorRGBA.y
                    var b = wheel1.colorRGBA.z
                    var rS = String.fromCharCode(r * 255)
                    var gS = String.fromCharCode(g * 255)
                    var bS = String.fromCharCode(b * 255)
                    for(var i = 0; i < ledCount; i++) {
                        newBytes += rS + gS + bS
                    }
                    socket.sendTextMessage(newBytes)
                }
            }
        }

        ColumnLayout {
            id: type2
            visible: true
            Layout.fillWidth: true
            Layout.fillHeight: true

            property int offset: 0

            ColorWheel {
                id: type2wheel1
                Layout.fillWidth: true
                Layout.fillHeight: true
                onColorRGBAChanged: {
                    type2.update()
                }
            }

            ColorWheel {
                id: type2wheel2
                Layout.fillWidth: true
                Layout.fillHeight: true
                onColorRGBAChanged: {
                    type2.update()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                Button {
                    text: "cycle"
                    onClicked: {
                        socket.sendTextMessage("fastcycle")
                    }
                }

                Button {
                    text: "static"
                    onClicked: {
                        socket.sendTextMessage("static")
                    }
                }
            }

            function update() {
                if(socket.status == WebSocket.Open) {
                    var newBytes = ''
                    for(var i = 0; i < ledCount; i++) {
                        var p = (i + type2.offset % ledCount) / ledCount

                        var r1 = type2wheel1.colorRGBA.x
                        var g1 = type2wheel1.colorRGBA.y
                        var b1 = type2wheel1.colorRGBA.z

                        var r2 = type2wheel2.colorRGBA.x
                        var g2 = type2wheel2.colorRGBA.y
                        var b2 = type2wheel2.colorRGBA.z

                        var s1 = Math.max(0, wave(p, 1))
                        var s2 = Math.max(0, wave(p + 0.5, 1))

                        var q = Qt.rgba(r1 * s1, g1 * s1, b1 * s1, 1)
                        q = Qt.tint(q, Qt.rgba(r2 * s2, g2 * s2, b2 * s2, s2))

                        newBytes += String.fromCharCode(q.r * 255)
                        newBytes += String.fromCharCode(q.g * 255)
                        newBytes += String.fromCharCode(q.b * 255)

                        if(!!preview.children[i] && !!preview.children[i].color)
                            preview.children[i].color = q
                    }
                    socket.sendTextMessage(newBytes)
                }
            }
        }

        ColumnLayout {
            id: clock
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColorWheel {
                id: clockWheel1
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            ColorWheel {
                id: clockWheel2
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Timer {
                running: clock.visible == true
                repeat: true
                interval: 1000
                onTriggered: {
                    var d = new Date()
                    if(socket.status == WebSocket.Open) {
                        var newBytes = ''
                        for(var i = 0; i < ledCount; i++) {
                            var p = i / ledCount

                            var r1 = clockWheel1.colorRGBA.x
                            var g1 = clockWheel1.colorRGBA.y
                            var b1 = clockWheel1.colorRGBA.z

                            var r2 = clockWheel2.colorRGBA.x
                            var g2 = clockWheel2.colorRGBA.y
                            var b2 = clockWheel2.colorRGBA.z

                            var q = Qt.rgba(r1, g1, b1, 1)
                            if(p > d.getSeconds() / 60)
                                var q = Qt.rgba(r2, g2, b2, 1)

                            newBytes += String.fromCharCode(q.r * 255)
                            newBytes += String.fromCharCode(q.g * 255)
                            newBytes += String.fromCharCode(q.b * 255)

                            if(!!preview.children[ledCount - i - 1] && !!preview.children[ledCount - i - 1].color)
                                preview.children[ledCount - i - 1].color = q
                        }
                        socket.sendTextMessage(newBytes)
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            Button {
                Layout.fillWidth: true
                text: "1 colour"
                onClicked: {
                    type2.visible = false
                    clock.visible = false
                    type1.visible = true
                }
            }

            Button {
                Layout.fillWidth: true
                text: "2 colours"
                onClicked: {
                    type1.visible = false
                    clock.visible = false
                    type2.visible = true
                }
            }

            Button {
                Layout.fillWidth: true
                text: "clock"
                onClicked: {
                    type1.visible = false
                    type2.visible = false
                    clock.visible = true
                }
            }
        }

        RowLayout {
            visible: !socket.active
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            TextField {
                Layout.fillWidth: true
                id: address
                text: "office.tec20.co.uk:1234"
            }

            Button {
                text: "connect"
                onClicked: {
                    socket.active = true
                }
            }
        }
    }

    WebSocket {
        id: socket
        url: "ws://" + address.text
        onStatusChanged: {
            if (socket.status == WebSocket.Error) {
                console.log("Error: " + socket.errorString)
                active = false
            } else if (socket.status == WebSocket.Open) {
            } else if (socket.status == WebSocket.Closed) {
                active = false
            }
        }
        active: false
    }

    function wave(v, m) {
        return Math.abs(Math.sin(v * Math.PI * m))
    }
}
