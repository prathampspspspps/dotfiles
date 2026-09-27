import QtQuick
import org.kde.plasma.networkmanagement as PlasmaNM

Item {

    Loader {
        id: helperSsidLoader
        source: "../code/HelperSsid.qml"
    }

    property bool activeConnection: netStatusText.connectivity === 4
    property var icon: activeConnectionIcon.connectionIcon
    property string textConnetion: activeConnection ? i18n("Connect") : i18n("Disconnect")
    property var ssidText: netStatusText.activeConnections
    property string ssidName: helperSsidLoader.item.ssidName

    property var activeConnectionIcon: PlasmaNM.ConnectionIcon {
        connectivity: netStatusText.connectivity
    }

    property var mid: PlasmaNM.NetworkModel{}

    property var handler: PlasmaNM.Handler {}

    property var netStatusText: PlasmaNM.NetworkStatus {}

    property var appletProxyModel: PlasmaNM.AppletProxyModel {
        sourceModel: PlasmaNM.NetworkModel{}
    }

    property var enabledConnections: PlasmaNM.EnabledConnections {}
    property var availableDevices: PlasmaNM.AvailableDevices {}




}

