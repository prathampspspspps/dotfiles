import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as Components
import org.kde.kirigami as Kirigami

Column {
    property alias enabled: pmCheckBox.checked

    spacing: 0

    RowLayout {
        width: parent.width
        spacing: Kirigami.Units.gridUnit

        MouseArea {
            id: pmMouseArea
            Layout.fillWidth: true
            height: childrenRect.height
            onClicked: {
                pmCheckBox.forceActiveFocus()
                pmCheckBox.checked = !pmCheckBox.checked
            }

            RowLayout {
                width: parent.width
                spacing: Kirigami.Units.gridUnit

                Item {
                    width: Kirigami.Units.iconSizes.medium
                    height: width

                    Components.CheckBox {
                        id: pmCheckBox
                        anchors.centerIn: parent
                        checked: true
                        opacity: inhibitions.length > 0 ? 0.5 : 1
                        Behavior on opacity {
                            NumberAnimation { duration: Kirigami.Units.longDuration }
                        }
                    }
                }

                Components.Label {
                    Layout.fillWidth: true
                    text: i18n("Enable Power Management")
                }
            }
        }

        Components.ToolButton {
            icon.name: "configure"
            onClicked: batterywidget.action_powerdevilkcm()
            visible: batterywidget.kcmsAuthorized
        }
    }

    Column {
        anchors {
            left: parent.left
            leftMargin: Kirigami.Units.iconSizes.medium + Kirigami.Units.gridUnit
            right: parent.right
        }
        spacing: Kirigami.Units.smallSpacing

        InhibitionHint {
            width: parent.width
            visible: inhibitions.length > 0
            iconSource: inhibitions.length > 0 ? (inhibitions[0].Icon || "") : ""
            text: {
                if (inhibitions.length > 1) {
                    return i18ncp("Some Application and n others are currently suppressing PM",
                                  "%2 and %1 other application are currently suppressing power management.",
                                  "%2 and %1 other applications are currently suppressing power management.",
                                  inhibitions.length - 1, inhibitions[0].Name)
                } else if (inhibitions.length === 1) {
                    if (!inhibitions[0].Reason) {
                        return i18nc("Some Application is suppressing PM",
                                     "%1 is currently suppressing power management.", inhibitions[0].Name)
                    } else {
                        return i18nc("Some Application is suppressing PM: Reason provided by the app",
                                     "%1 is currently suppressing power management: %2", inhibitions[0].Name, inhibitions[0].Reason)
                    }
                } else {
                    return ""
                }
            }
        }
    }
}
