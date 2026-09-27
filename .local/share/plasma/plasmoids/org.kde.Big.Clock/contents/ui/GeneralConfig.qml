import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    QtObject {
        id: positionValue
        property var value
    }

    signal configurationChanged

     property alias cfg_position: positionValue.value
     property alias cfg_customColor: colorHEX.text
     property alias cfg_accetColor: accetColorHEX.text


    ColumnLayout {
        spacing: units.smallSpacing * 2
        GridLayout {
            columns: 2
            Label {
                width: configRoot.width/2
                text: i18n("Position:")
            }
            ComboBox {
                textRole: "text"
                valueRole: "value"
                id: positionComboBox
                model: [
                    {text: i18n("Right"), value: 0},
                    {text: i18n("Left"), value: 1},
                ]
                onActivated: positionValue.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(positionValue.value)
            }
            Label {
                width: configRoot.width/2
                text: i18n("Custom HEX Color:")
            }
            TextField {
                id: colorHEX
                width: 150
            }
            Label {
                width: configRoot.width/2
                text: i18n("Custom HEX Accet Color:")
            }
            TextField {
                id: accetColorHEX
                width: 150
            }
        }

   }
}
