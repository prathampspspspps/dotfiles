import QtQuick
import org.kde.kirigami as Kirigami

Item {

    property int widthTxt: 0
    Row {
        id: hourlyForecast
        width: parent.width
        height: parent.height /2

        Repeater {
            model: forecastHours
            delegate: Item {
                width: parent.width/5
                height: parent.height
                Column {
                    width: text.implicitWidth
                    spacing: Kirigami.Units.iconSizes.small/3
                    anchors.horizontalCenter: parent.horizontalCenter
                    Kirigami.Heading {
                        id: text
                        width: parent.width
                        text: model.hours % 24
                        color: Kirigami.Theme.textColor
                        level: 5
                    }
                    Kirigami.Icon {
                        width: Kirigami.Units.iconSizes.smallMedium
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: model.icon
                    }
                    Kirigami.Heading {
                        width: parent.width
                        text: model.temp
                        color: Kirigami.Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                        level: 5
                    }
                }
            }

        }
    }

    Column {
        width: parent.width
        height: parent.height/2
        anchors.top: hourlyForecast.bottom
        Repeater {
            model: forecastFullModel
            delegate: Row {
                height: parent.height/3
                width: parent.width
                spacing: 8

                Kirigami.Heading {
                    id: day
                    width: parent.width - logo.width - widthTxt - 16
                    height: parent.height
                    text: model.date
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    level: 5
                }
                Kirigami.Icon {
                    id: logo
                    width: Kirigami.Units.iconSizes.smallMedium
                    height: width
                    source: model.icon
                    anchors.verticalCenter: parent.verticalCenter
                }
                Kirigami.Heading {
                    id: forecastText
                    width: widthTxt
                    height: parent.height
                    text: model.maxTemp + "°/" + model.minTemp + "°"
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    level: 5
                }
                Component.onCompleted: {
                    if (forecastText.implicitWidth > widthTxt) {
                        widthTxt = forecastText.implicitWidth
                    }
                }

            }
        }

    }
}
