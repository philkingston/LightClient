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
    property int ledCount: 64

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
            id: type3
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColorWheel {
                id: type3wheel1
                Layout.fillWidth: true
                Layout.fillHeight: true
                onColorRGBAChanged: {
                    type3.update()
                }
            }

            ColorWheel {
                id: type3wheel2
                Layout.fillWidth: true
                Layout.fillHeight: true
                onColorRGBAChanged: {
                    type3.update()
                }
            }

            ColorWheel {
                id: type3wheel3
                Layout.fillWidth: true
                Layout.fillHeight: true
                onColorRGBAChanged: {
                    type3.update()
                }
            }

            function update() {
                if(socket.status == WebSocket.Open) {
                    var newBytes = ''
                    for(var i = 0; i < ledCount; i++) {
                        var p = i / ledCount

                        var r1 = type3wheel1.colorRGBA.x
                        var g1 = type3wheel1.colorRGBA.y
                        var b1 = type3wheel1.colorRGBA.z

                        var r2 = type3wheel2.colorRGBA.x
                        var g2 = type3wheel2.colorRGBA.y
                        var b2 = type3wheel2.colorRGBA.z

                        var r3 = type3wheel3.colorRGBA.x
                        var g3 = type3wheel3.colorRGBA.y
                        var b3 = type3wheel3.colorRGBA.z

                        var s1 = Math.max(0, wave(p, 3))
                        var s2 = Math.max(0, wave(p + 0.33, 3))
                        var s3 = Math.max(0, wave(p + 0.66, 3))

                        var q = Qt.rgba(r1 * s1, g1 * s1, b1 * s1, 1)
                        q = Qt.tint(q, Qt.rgba(r2 * s2, g2 * s2, b2 * s2, s2))
                        q = Qt.tint(q, Qt.rgba(r3 * s3, g3 * s3, b3 * s3, s3))

                        newBytes += String.fromCharCode(q.r * 255)
                        newBytes += String.fromCharCode(q.g * 255)
                        newBytes += String.fromCharCode(q.b * 255)
                    }
                    socket.sendTextMessage(newBytes)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            TextField {
                Layout.fillWidth: true
                id: address
                text: "10.0.0.109:1234"
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
                console.log('Connected')
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
