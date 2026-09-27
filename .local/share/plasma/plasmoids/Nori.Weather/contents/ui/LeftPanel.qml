import QtQuick

Item {
    property color leftPanelColor: "red"
    property int marginLeftReal:  card.marginLeft
    Card {
        id: card
        leftColor: leftPanelColor
        width: parent.width
        height: parent.height
    }
}
