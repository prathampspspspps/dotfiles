import QtQuick
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.workspace.components as PW
import org.kde.kirigami as Kirigami
import "logic.js" as Logic

Item {
    id: batteryItem
    height: childrenRect.height

    property var battery

    readonly property bool isPresent: model.PluggedIn !== undefined ? model.PluggedIn : true
    readonly property bool isBroken: model.Capacity > 0 && model.Capacity < 50

    property Component batteryDetails: Flow {
        id: detailsLayout
        property int leftColumnWidth: 0
        width: Kirigami.Units.gridUnit * 11

        PlasmaComponents.Label {
            id: brokenBatteryLabel
            width: parent ? parent.width : implicitWidth
            wrapMode: Text.WordWrap
            text: batteryItem.isBroken && typeof model.Capacity !== "undefined" ? i18n("The capacity of this battery is %1%. This means it is broken and needs a replacement. Please contact your hardware vendor for more details.", model.Capacity) : ""
            visible: batteryItem.isBroken
        }

        Repeater {
            id: detailsRepeater
            model: Logic.batteryDetails(model, batterywidget.remainingTime)
            PlasmaComponents.Label {
                id: detailsLabel
                width: modelData.value && parent ? parent.width - detailsLayout.leftColumnWidth - Kirigami.Units.smallSpacing : detailsLayout.leftColumnWidth + Kirigami.Units.smallSpacing
                wrapMode: Text.NoWrap
                onPaintedWidthChanged: {
                    if (paintedWidth > detailsLayout.leftColumnWidth) {
                        detailsLayout.leftColumnWidth = paintedWidth
                    }
                }
                height: implicitHeight
                text: modelData.value ? modelData.value : modelData.label
                horizontalAlignment: modelData.value ? Text.AlignRight : Text.AlignLeft
                elide: Text.ElideNone
            }
        }
    }

    Column {
        width: parent.width
        spacing: 0

        RowLayout {
            id: infoRow
            width: parent.width
            spacing: Kirigami.Units.gridUnit

            PW.BatteryIcon {
                id: batteryIcon
                Layout.alignment: Qt.AlignTop
                width: Kirigami.Units.iconSizes.medium
                height: width
                batteryType: model.Type
                percent: model.Percent
                hasBattery: batteryItem.isPresent
                pluggedIn: model.ChargeState === Battery.BatteryControlModel.Charging && model.IsPowerSupply
            }

            Column {
                Layout.fillWidth: true
                Layout.alignment: batteryItem.isPresent ? Qt.AlignTop : Qt.AlignVCenter

                RowLayout {
                    width: parent.width
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        id: batteryNameLabel
                        Layout.fillWidth: true
                        height: implicitHeight
                        elide: Text.ElideRight
                        text: model.PrettyName
                    }

                    PlasmaComponents.Label {
                        text: Logic.stringForBatteryState(model)
                        height: implicitHeight
                        visible: model.IsPowerSupply
                        opacity: 0.6
                    }

                    PlasmaComponents.Label {
                        id: batteryPercent
                        height: paintedHeight
                        horizontalAlignment: Text.AlignRight
                        visible: batteryItem.isPresent
                        text: i18nc("Placeholder is battery percentage", "%1%", model.Percent)
                    }
                }

                PlasmaComponents.ProgressBar {
                    width: parent.width
                    from: 0
                    to: 100
                    visible: batteryItem.isPresent
                    value: Number(model.Percent)
                }
            }
        }

        Loader {
            id: detailsLoader
            anchors {
                left: parent.left
                leftMargin: batteryIcon.width + Kirigami.Units.gridUnit
                right: parent.right
            }
            visible: !!item
            opacity: 0.5
            sourceComponent: batteryDetails
            active: batteryControl.hasBatteries && batteryControl.count < 2
        }
    }
}
