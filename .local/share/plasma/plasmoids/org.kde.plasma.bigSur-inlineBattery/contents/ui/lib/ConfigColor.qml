import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.plasmoid

RowLayout {
    id: configColor
    spacing: 2
    Layout.maximumWidth: 300

    property alias label: label.text
    property alias horizontalAlignment: label.horizontalAlignment

    property string configKey: ''
    property string configValue: configKey ? Plasmoid.configuration[configKey] : ""
    property string defaultColor: ''
    readonly property color value: configValue || defaultColor
    onConfigValueChanged: {
        if (!textField.activeFocus) {
            textField.text = configColor.configValue
        }
        if (configKey) {
            Plasmoid.configuration[configKey] = configValue
        }
    }

    Label {
        id: label
        text: "Label"
        Layout.fillWidth: horizontalAlignment == Text.AlignRight
        horizontalAlignment: Text.AlignLeft
    }

    MouseArea {
        width: textField.height
        height: textField.height
        hoverEnabled: true

        onClicked: dialog.open()

        Rectangle {
            anchors.fill: parent
            color: configColor.value
            border.width: 2
            border.color: parent.containsMouse ? palette.highlight : "#BB000000"
        }
    }

    TextField {
        id: textField
        placeholderText: "#AARRGGBB"
        Layout.fillWidth: label.horizontalAlignment == Text.AlignLeft
        onTextChanged: {
            if (text.length === 0
                || (text.indexOf('#') === 0 && (text.length == 4 || text.length == 7 || text.length == 9))
            ) {
                configColor.configValue = text
            }
        }
    }

    ColorDialog {
        id: dialog
        title: configColor.label
        selectedColor: configColor.value
        onAccepted: {
            configColor.configValue = selectedColor
        }
    }
}
