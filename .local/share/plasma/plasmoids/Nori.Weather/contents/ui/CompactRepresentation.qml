import QtQuick
import QtQuick.Layouts 1.1
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
//import org.kde.plasma.plasma5support as Plasma5Support


Item {
    id: iconAndTem

    Layout.minimumWidth: widthReal
    Layout.minimumHeight: heightReal

    property QtObject dashWindow: null

    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    property string undefanchors: activeweathershottext ? undefined : parent.verticalCenter
    property bool textweather: Plasmoid.configuration.displayWeatherInPanel
    property bool activeweathershottext: heightH > 34
    property int fonssizes: Plasmoid.configuration.sizeFontConfig
    property int heightH: wrapper.height
    property var widthWidget: activeweathershottext ? temOfCo.implicitWidth : temOfCo.implicitWidth + wrapper_weathertext.width
    property var widthReal: isVertical ? wrapper.width : initial.implicitWidth
    property var hVerti: wrapper_vertical.implicitHeight
    property var heightReal: isVertical ? hVerti : wrapper.height


    MouseArea {
        id: compactMouseArea
        anchors.fill: parent

        hoverEnabled: true

        onClicked: {

            dashWindow.visible = !dashWindow.visible;

        }


    }
    RowLayout {
        id: initial
        width: icon.width + columntemandweathertext.width + icon.width * 0.3
        height: parent.height
        spacing: icon.width / 5
        visible: !isVertical
        Kirigami.Icon {
            id: icon
            width: root.height < 17 ? 16 : root.height < 24 ? 22 : 24
            height: width
            source: wrapper.currentIcon
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            roundToIconSize: false
        }
        Column {
            id: columntemandweathertext
            width: widthWidget
            height: temOfCo.implicitHeight
            anchors.verticalCenter: parent.verticalCenter
            Row {
                id: temOfCo
                width: textGrados.implicitWidth + subtextGrados.implicitWidth
                height: textGrados.implicitHeight
                anchors.verticalCenter: undefanchors

                Label {
                    id: textGrados
                    height: parent.height
                    width: parent.width - subtextGrados.implicitWidth
                    text: wrapper.currentTemp
                    font.bold: boldfonts
                    font.pixelSize: fonssizes
                    color: PlasmaCore.Theme.textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                Label {
                    id: subtextGrados
                    height: parent.height
                    width: parent.width - textGrados.implicitWidth
                    text: (wrapper.unitsTemperature === "0") ? " °C " : " °F "
                    horizontalAlignment: Text.AlignLeft
                    font.bold: boldfonts
                    font.pixelSize: fonssizes
                    color: PlasmaCore.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Item {
                id: wrapper_weathertext
                height: shortweathertext.implicitHeight
                width: shortweathertext.implicitWidth
                visible: activeweathershottext & textweather
                Label {
                    id: shortweathertext
                    text: wrapper.weather
                    font.pixelSize: fonssizes
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    ColumnLayout {
        id: wrapper_vertical
        width: root.width
        height: icon_vertical.height +  textGrados_vertical.implicitHeight
        spacing: 2
        visible: isVertical
        Kirigami.Icon {
            id: icon_vertical
            width: wrapper.width < 17 ? 16 : wrapper.width < 24 ? 22 : 24
            height: wrapper.width < 17 ? 16 : wrapper.width < 24 ? 22 : 24
            source: wrapper.currentIcon
            anchors.left: parent.left
            anchors.right: parent.right
            roundToIconSize: false
        }
        Row {
            id: temOfCo_vertical
            width: textGrados_vertical.implicitWidth + subtextGrados_vertical.implicitWidth
            height: textGrados_vertical.implicitHeight
            Layout.alignment: Qt.AlignHCenter

            Label {
                id: textGrados_vertical
                height: parent.height
                text: wrapper.currentTemp
                font.bold: boldfonts
                font.pixelSize: fonssizes
                color: PlasmaCore.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                id: subtextGrados_vertical
                height: parent.height
                text: (wrapper.unitsTemperature === "0") ? " °C" : " °F"
                font.bold: boldfonts
                font.pixelSize: fonssizes
                color: PlasmaCore.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("Representation {}", wrapper);
        plasmoid.activated.connect(function() {
            dashWindow.plasmoidWidV = widthReal
            dashWindow.plasmoidWidH = heightReal
            dashWindow.visible = !dashWindow.visible;
        });

    }

}
