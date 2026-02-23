import QtQuick 2.15
import QtQml 2.15

Item {
    id: root
    width: 1920
    height: 1080

    property real time: 0.0

    Timer {
        interval: 16
        running: true
        repeat: true
        onTriggered: root.time += 0.016
    }
    
    // Shader properties mirroring the C++ structure
    property vector3d cfgBackgroundColor: Qt.vector3d(0.66, 0.66, 0.66)
    property vector3d cfgGridColor: Qt.vector3d(0.66, 0.0, 0.66)
    property real cfgShowGrid: 1.0
    property vector4d stageBounds: Qt.vector4d(400, 1520, 950, 1079)
    property real cfgClockMode: 0.0
    property real clockSeconds: 0.0
    property real clockLayer: 0.0
    property vector4d clockDigits: Qt.vector4d(0, 0, 0, 0)
    property vector3d clockPanelColor: Qt.vector3d(0, 0, 0)
    property vector3d clockBorderColor: Qt.vector3d(0, 0, 0)
    property vector3d clockDigitColor: Qt.vector3d(0, 0, 0)
    property vector3d clockOutlineColor: Qt.vector3d(0, 0, 0)
    property vector3d clockBarColor: Qt.vector3d(0, 0, 0)

    ShaderEffect {
        id: bg
        anchors.fill: parent
        
        property vector2d resolution: Qt.vector2d(width, height)
        property vector3d bgColor: root.cfgBackgroundColor
        property vector3d gridColor: root.cfgGridColor
        property real showGrid: root.cfgShowGrid
        property vector4d u_stageBounds: root.stageBounds
        
        property real clockMode: root.cfgClockMode
        property real clockLayer: root.clockLayer
        property real clockSeconds: root.clockSeconds
        property vector4d u_clockDigits: root.clockDigits
        property vector3d clockPanelColor: root.clockPanelColor
        property vector3d clockBorderColor: root.clockBorderColor
        property vector3d clockDigitColor: root.clockDigitColor
        property vector3d clockOutlineColor: root.clockOutlineColor
        property vector3d clockBarColor: root.clockBarColor

        fragmentShader: "file:///home/arcanorca/Projects/Boingwave/contents/shaders/bg.qsb"
    }
}
