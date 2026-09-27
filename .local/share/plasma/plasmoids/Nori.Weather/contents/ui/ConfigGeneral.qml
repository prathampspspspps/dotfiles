import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root


    signal configurationChanged

    //QtObject {
      //  id: toCurrency
        //property var value
    //}
    QtObject {
        id: fontsizeValue
        property var value
    }

    QtObject {
        id: unidWeatherValue
        property var value
    }

    property alias cfg_coordinatesIP: coordinatesIP.checked
    property alias cfg_displayWeatherInPanel: displayWeather.checked
    property alias cfg_manualLatitude: latitude.text
    property alias cfg_manualLongitude: longitude.text
    property alias cfg_temperatureUnit: unidWeatherValue.value
    property alias cfg_sizeFontConfig: fontsizeValue.value
    property alias cfg_fontBoldWeather: boldWeather.checked


    ColumnLayout {
        id:mainColumn
        spacing: Kirigami.Units.largeSpacing
        Layout.fillWidth: true

        GridLayout{
            id: firslayout
            columns: 2

            Label {
                id: refrestitle
                Layout.minimumWidth: root.width/2
                text: i18n("Use geographical coordinates from the IP") + ":"
                horizontalAlignment: Label.AlignRight
            }
            CheckBox {
                id: coordinatesIP
            }
        }


        GridLayout{
            columns: 2
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Latitude") + ":"
                visible: !coordinatesIP.checked
                horizontalAlignment: Label.AlignRight
            }
            TextField {
                id: latitude
                visible: !coordinatesIP.checked
                width: 110
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Longitude") + ":"
                visible: !coordinatesIP.checked
                horizontalAlignment: Label.AlignRight
            }
            TextField {
                id: longitude
                visible: !coordinatesIP.checked
                width: 110
            }



            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Display weather conditions on the panel") + ":"
                horizontalAlignment: Label.AlignRight
            }
            CheckBox {
                id: displayWeather
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Bold Weather Conditions") + ":"
                horizontalAlignment: Label.AlignRight
            }
            CheckBox {
                id: boldWeather
            }


            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Temperature unit") + ":"
                horizontalAlignment: Label.AlignRight
            }
            ComboBox {
                textRole: "text"
                valueRole: "value"
                id: positionComboBox
                model: [
                    {text: i18n("Celsius (°C)"), value: 0},
                    {text: i18n("Fahrenheit (°F)"), value: 1},
                ]
                onActivated: unidWeatherValue.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(unidWeatherValue.value)
            }

            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Font Size") + ":"
                horizontalAlignment: Label.AlignRight
            }

            ComboBox {
                textRole: "text"
                valueRole: "value"
                width: 32
                id: valueForSizeFont
                model: [
                    {text: i18n("8"), value: 8},
                    {text: i18n("9"), value: 9},
                    {text: i18n("10"), value: 10},
                    {text: i18n("11"), value: 11},
                    {text: i18n("12"), value: 12},
                    {text: i18n("13"), value: 13},
                    {text: i18n("14"), value: 14},
                    {text: i18n("15"), value: 15},
                    {text: i18n("16"), value: 16},
                    {text: i18n("17"), value: 17},
                    {text: i18n("18"), value: 18},

                ]
                onActivated: fontsizeValue.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(fontsizeValue.value)
            }

        }
    }
}
