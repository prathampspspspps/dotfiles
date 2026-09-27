import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Controls as Controls


Item {
    property int leftPanelMargin: 0
    property int topPanelMargin: 0
    property int exedentHight: 0
    property int widthOfLeftPanel: 130
    property int spacingElements: 5
    property string currentWatherTemp: "?"

    LeftPanel {
        id: leftPanel
        anchors.left: parent.left
        anchors.leftMargin: - leftPanelMargin
        anchors.top: parent.top
        anchors.topMargin: - topPanelMargin
        leftPanelColor: Kirigami.Theme.highlightColor
        width: widthOfLeftPanel
        height: parent.height + exedentHight
    }
    Item {

        width: leftPanel.width
        anchors.top: parent.top
        Kirigami.Heading {
            id: city
            width: parent.width - leftPanel.marginLeftReal
            text: wrapper.location //"Ciudad"
            color: Kirigami.Theme.highlightedTextColor
            level: 3
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Row {
            id: current
            width: parent.width - leftPanel.marginLeftReal
            anchors.top: city.bottom
            anchors.topMargin: spacingElements
            height: text.implicitHeight
            spacing: 5
            Kirigami.Icon {
                id: logo
                source: wrapper.currentIcon
                width: Kirigami.Units.iconSizes.medium
                height: width
                color: Kirigami.Theme.highlightedTextColor
                anchors.verticalCenter: parent.verticalCenter
            }

           Controls.Label {
                id: text
                width: parent.width - logo.width
                text: wrapper.currentTemp
                color: Kirigami.Theme.highlightedTextColor
                font.weight: Font.DemiBold
                font.pixelSize: logo.height
                anchors.verticalCenter: parent.verticalCenter
            }

        }
        Column {
            anchors.top: current.bottom
            width: current.width
            height: textDo.implicitHeight * 2
            anchors.topMargin: spacingElements
            opacity: 0.7
            Kirigami.Heading {
                id: textDo
                width: parent.width - leftPanel.marginLeftReal
                text: wrapper.weather //"Summy"
                color: Kirigami.Theme.highlightedTextColor
                level: 5
                //font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Kirigami.Heading {
                width: parent.width - leftPanel.marginLeftReal
                text: wrapper.currentMaxMin
                color: Kirigami.Theme.highlightedTextColor
                level: 5
                //font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }


    }
    Item {
        width: link.implicitWidth
        height: link.implicitHeight
        anchors.bottom: parent.bottom
        //anchors.bottomMargin: height
        Kirigami.Heading {
            id: link
            width: parent.width
            text: "open-meteo.com"
            color: Kirigami.Theme.highlightedTextColor
            level: 5
            font.underline: true
            opacity: 0.4
            elide: Text.ElideRight
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                Qt.openUrlExternally("https://open-meteo.com")
            }
        }
    }
}
