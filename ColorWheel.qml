import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import "content"
import "content/ColorUtils.js" as ColorUtils

Item {
    id: root

    // Color value in RGBA with floating point values between 0.0 and 1.0.

    property vector4d colorHSVA: Qt.vector4d(1, 0, 1, 1)
    property alias colorRGBA: m.colorRGBA

    QtObject {
        id: m
        // Color value in HSVA with floating point values between 0.0 and 1.0.
        property vector4d colorRGBA: ColorUtils.hsva2rgba(root.colorHSVA)
    }

    signal accepted

    RowLayout {
        spacing: 20
        anchors.fill: parent

        Wheel {
            id: wheel
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.minimumHeight: 200

            hue: colorHSVA.x
            saturation: colorHSVA.y
            onUpdateHS: {
                colorHSVA = Qt.vector4d(hueSignal,saturationSignal, colorHSVA.z, colorHSVA.w)
            }
            onAccepted: {
                root.accepted()
            }
        }

        // brightness picker slider
        Item {
            Layout.fillHeight: true
            Layout.minimumWidth: 100
            Layout.minimumHeight: 200

            //Brightness background
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        id: brightnessBeginColor
                        position: 0.0
                        color: {
                            var rgba = ColorUtils.hsva2rgba(
                                        Qt.vector4d(colorHSVA.x,
                                                    colorHSVA.y, 1, 1))
                            return Qt.rgba(rgba.x, rgba.y, rgba.z, rgba.w)
                        }
                    }
                    GradientStop {
                        position: 1.0
                        color: "#000000"
                    }
                }
            }

            VerticalSlider {
                id: brigthnessSlider
                anchors.fill: parent
                value: colorHSVA.z
                onValueChanged: {
                    colorHSVA = Qt.vector4d(colorHSVA.x, colorHSVA.y, value, colorHSVA.w)
                }
                onAccepted: {
                    root.accepted()
                }
            }
        }
    }
}
