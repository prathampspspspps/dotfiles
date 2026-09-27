import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: header
    property string headerText: "ciudad"
    property int    currentIndex: 0
    property int    totalPages:   3

    signal next
    signal prev
    signal goTo(int index)

    // Ciudad / título
    Kirigami.Heading {
        id: cityLabel
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        text: headerText
        level: 5
        font.weight: Font.DemiBold
        font.capitalization: Font.Capitalize
        color: Kirigami.Theme.textColor
        elide: Text.ElideRight
        width: parent.width - dotsRow.width - Kirigami.Units.smallSpacing
    }

    // Dots de navegación (clic directo + indicador de página)
    Row {
        id: dotsRow
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: Kirigami.Units.smallSpacing * 0.75

        Repeater {
            model: totalPages
            Rectangle {
                height: Kirigami.Units.smallSpacing * 0.75
                width:  modelData === currentIndex
                ? Kirigami.Units.gridUnit * 1.1
                : Kirigami.Units.smallSpacing * 0.75
                radius: height / 2
                color:  Kirigami.Theme.textColor
                opacity: modelData === currentIndex ? 0.75 : 0.22

                Behavior on width   { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 180 } }

                MouseArea {
                    anchors.fill: parent
                    // área táctil más cómoda
                    anchors.margins: -6
                    onClicked: header.goTo(modelData)
                }
            }
        }
    }
}
