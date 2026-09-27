/*
 *   SPDX-FileCopyrightText: 2025 adolfo <adolfo@librepixels.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import QtQuick.Window
import org.kde.kquickcontrols as KQControls

Kirigami.FormLayout {
    id: root

    property int screnValue: Screen.width

    QtObject {
        id: dimensions
        property int width
        property int height
        property int level
        property int connections
    }

    property alias cfg_gradientStart: gradientStart.color
    property alias cfg_gradientEnd: gradientEnd.color
    property alias cfg_quarksColor: quarksColor.color
    property alias cfg_level: dimensions.level
    property alias cfg_elementWidth: dimensions.width
    property alias cfg_elementHeight: dimensions.height
    property alias cfg_connectionsLevel: dimensions.connections

    Text {
        text: funciono + realWidth.length // Screen.width
    }
    KQControls.ColorButton {
        id: gradientStart
        Kirigami.FormData.label: i18n('Gradient start:')
        showAlphaChannel: true
    }
    KQControls.ColorButton {
        id: gradientEnd
        Kirigami.FormData.label: i18n('Gradient end:')
        showAlphaChannel: true
    }
    Label {

    }
    KQControls.ColorButton {
        id: quarksColor
        Kirigami.FormData.label: i18n('Quarks color:')
        showAlphaChannel: true
    }
    Label {

    }
    ComboBox {
        id: levelDensity
        textRole: "name"
        valueRole: "value"
        anchors.left: parent.left
        anchors.leftMargin: root.width / 2
        Kirigami.FormData.label: i18n('Density level:')
        model: [
            { name: "Low", value: 1 },
            { name: "Medium", value: 2},
            { name: "High", value: 3 }
        ]
        onActivated: dimensions.level = currentValue
        Component.onCompleted: {
            currentIndex = indexOfValue(dimensions.level)
        }
    }
    ComboBox {
        id: levelConnections
        textRole: "name"
        valueRole: "value"
        anchors.left: parent.left
        anchors.leftMargin: root.width / 2
        Kirigami.FormData.label: i18n('Density Connections:')
        model: [
            { name: "Low", value: 1 },
            { name: "Medium", value: 2},
            { name: "High", value: 3 }
        ]
        onActivated: dimensions.connections = currentValue
        Component.onCompleted: {
            currentIndex = indexOfValue(dimensions.connections)
        }
    }
    ComboBox {
        anchors.left: parent.left
        anchors.leftMargin: root.width/2
        Kirigami.FormData.label: i18n('Element Width:')
        id: gridWidth
        model: []
        onActivated: dimensions.width = currentValue
        Component.onCompleted: {
            for (var t = 300; t <= Screen.width; t += 100) {
                model.push(t)
            }
            currentIndex = indexOfValue(dimensions.width)}
    }
    ComboBox {
        anchors.left: parent.left
        anchors.leftMargin: root.width/2
        Kirigami.FormData.label: i18n('Element Height:')
        id: gridHeight
        model: []
        onActivated: dimensions.height = currentValue

        Component.onCompleted:{
            for (var t = 300; t <= Screen.height; t += 100) {
                model.push(t)
            }
            currentIndex = indexOfValue(dimensions.height)

        }
    }
}
