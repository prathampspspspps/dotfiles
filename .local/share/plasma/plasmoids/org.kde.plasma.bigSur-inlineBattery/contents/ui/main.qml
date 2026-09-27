import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponent
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.battery as Battery

import "logic.js" as Logic

PlasmoidItem {
    id: batterywidget

    AppletConfig { id: config }

    Battery.BatteryControlModel {
        id: batteryControl
    }

    Plasmoid.status: {
        if (powermanagementDisabled) {
            return PlasmaCore.Types.ActiveStatus
        }

        if (batteryControl.hasCumulative) {
            if (batteryControl.state !== Battery.BatteryControlModel.Charging && batteryControl.percent <= 5) {
                return PlasmaCore.Types.NeedsAttentionStatus
            } else if (batteryControl.state !== Battery.BatteryControlModel.FullyCharged) {
                return PlasmaCore.Types.ActiveStatus
            }
        }

        return PlasmaCore.Types.PassiveStatus
    }

    property bool disableBrightnessUpdate: true
    property int screenBrightness: 0
    readonly property int maximumScreenBrightness: 100

    property int keyboardBrightness: 0
    readonly property int maximumKeyboardBrightness: 100

    readonly property int remainingTime: batteryControl.remainingMsec

    property bool powermanagementDisabled: false

    property var inhibitions: []

    readonly property var kcms: ["powerdevilprofilesconfig.desktop",
                                 "powerdevilactivitiesconfig.desktop",
                                 "powerdevilglobalconfig.desktop"]

    readonly property bool kcmsAuthorized: false

    onScreenBrightnessChanged: {
        if (disableBrightnessUpdate) {
            return;
        }
    }

    onKeyboardBrightnessChanged: {
        if (disableBrightnessUpdate) {
            return;
        }
    }

    function action_powerdevilkcm() {
    }

    Component.onCompleted: {
        if (batterywidget.kcmsAuthorized) {
            setAction("powerdevilkcm", i18n("&Configure Power Saving..."), "preferences-system-power-management");
        }
    }

    property string currentBatteryState: {
        switch (batteryControl.state) {
            case Battery.BatteryControlModel.Charging: return "Charging";
            case Battery.BatteryControlModel.FullyCharged: return "FullyCharged";
            case Battery.BatteryControlModel.Discharging: return "Discharging";
            default: return "NoCharge";
        }
    }
    property int currentBatteryPercent: batteryControl.percent
    property bool currentBatteryLowPower: currentBatteryPercent <= config.lowBatteryPercent
    property color currentTextColor: {
        if (currentBatteryLowPower) {
            return config.lowBatteryColor
        } else {
            return config.normalColor
        }
    }

    compactRepresentation: Item {
        id: panelItem

        MouseArea {
            id: desktopMouseArea
            anchors.fill: parent

            onClicked:
            {
                batterywidget.expanded = !batterywidget.expanded
            }
        }

        Layout.minimumWidth: gridLayout.implicitWidth
        Layout.preferredWidth: gridLayout.implicitWidth

        Layout.minimumHeight: gridLayout.implicitHeight
        Layout.preferredHeight: gridLayout.implicitHeight

        property int textHeight: 12 * Screen.devicePixelRatio

        GridLayout {
            id: gridLayout
            anchors.fill: parent

            property int spacing: 4 * Screen.devicePixelRatio
            columnSpacing: spacing
            rowSpacing: 0

            PlasmaComponent.Label {
                id: percentTextLeft
                visible: Plasmoid.configuration.showPercentage && !!Plasmoid.configuration.alignLeft
                anchors.right: batteryIconContainer.left
                anchors.rightMargin: config.padding
                text: {
                    if (currentBatteryPercent > 0) {
                        return '' + currentBatteryPercent + '%'
                    } else {
                        return '100%';
                    }
                }
                font.pixelSize: config.fontSize
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: currentTextColor
            }

            Item {
                id: batteryIconContainer
                visible: Plasmoid.configuration.showBatteryIcon
                width: config.iconWidth * Screen.devicePixelRatio
                height: config.iconHeight * Screen.devicePixelRatio
                anchors.verticalCenter: parent.verticalCenter

                MacBatteryIcon {
                    id: batteryIcon
                    width: Math.min(parent.width, config.iconWidth * Screen.devicePixelRatio)
                    height: Math.min(parent.height, config.iconHeight * Screen.devicePixelRatio)
                    anchors.centerIn: parent
                    charging: currentBatteryState == "Charging"
                    charge: currentBatteryPercent
                    normalColor: config.normalColor
                    chargingColor: config.chargingColor
                    lowBatteryColor: config.lowBatteryColor
                    lowBatteryPercent: Plasmoid.configuration.lowBatteryPercent
                }
            }

            PlasmaComponent.Label {
                id: percentTextRight
                visible: Plasmoid.configuration.showPercentage && !Plasmoid.configuration.alignLeft
                anchors.left: batteryIconContainer.right
                anchors.leftMargin: config.padding
                text: {
                    if (currentBatteryPercent > 0) {
                        return '' + currentBatteryPercent + '%'
                    } else {
                        return '100%';
                    }
                }
                font.pixelSize: config.fontSize
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: currentTextColor
            }
        }
    }

    fullRepresentation: PopupDialog {
        id: dialogItem
        Layout.minimumWidth: Kirigami.Units.iconSizes.medium * 9
        Layout.minimumHeight: Kirigami.Units.gridUnit * 15

        model: batterywidget.expanded ? batteryControl : null
        anchors.fill: parent
        focus: true

        isBrightnessAvailable: false
        isKeyboardBrightnessAvailable: false

        pluggedIn: batteryControl.pluggedIn

        onPowermanagementChanged: (checked) => {
            batterywidget.powermanagementDisabled = !checked
        }
    }
}
