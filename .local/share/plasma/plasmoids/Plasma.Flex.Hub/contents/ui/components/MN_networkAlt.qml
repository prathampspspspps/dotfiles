import QtQuick
import "../lib" as Lib
import "../js/utils.js" as Utils
import org.kde.plasma.plasma5support as Plasma5Support
Item {
    width: parent.width
    height: parent.height
    property var transferDataTs: 0
    property var transferData: {}
    property var speedData: {}
    property string interfaceName
    Plasma5Support.DataSource {
        id: dataSource
        engine: 'executable'
        connectedSources: [Utils.NET_DATA_SOURCE]
        interval: 1.0 * 1000
        onNewData: (sourceName, data) => {
            if (data['exit code'] > 0 || !data.stdout) {
                return;
            }
            const lines = data.stdout.trim().split("\n");
            for (let i = 0; i < lines.length; i++) {
                const parts = lines[i].split(",");
                if (parts.length < 3) continue;
                const name = parts[0].trim();
                const rx = parseInt(parts[1]);
                const tx = parseInt(parts[2]);
                if ((rx > 0 || tx > 0) && name !== "lo" && !name.startsWith("virbr")) {
                    if (interfaceName !== name) {
                        console.log("Interfaz activa detectada:", name);
                    }
                    interfaceName = name;
                    break;
                }
            }
            const now = Date.now();
            const duration = now - transferDataTs;
            const nextTransferData = Utils.parseTransferData(data.stdout);
            if (Object.keys(nextTransferData).length === 0) {
                return;
            }
            if (transferDataTs > 0 && Object.keys(transferData).length > 0) {
                speedData = Utils.calcSpeedData(transferData, nextTransferData, duration);
            } else {
                console.warn("Skipping speed calculation, missing previous data.");
            }
            transferDataTs = now;
            transferData = nextTransferData;
        }
    }

    function formatSpeed(value) {
        if (value >= 1000000) {
            return (value / 1024 / 1024).toFixed(1) + " GB";
        } else if (value >= 1000) {
            return (value / 1024).toFixed(1) + " MB";
        } else {
            return Math.round(value) + " kB";
        }
    }

    Lib.Item {
        width: parent.width
        height: parent.height
        activeSub: true
        smallMode: false
        anchorsDinamic: "center"
        customMarginBottom: ((heightFactor - sizeIcon - marginIcons)/2) + spacing/2
        // title arriba → velocidad de subida ↑
        title: {
            const iface = speedData[interfaceName];
            return iface ? formatSpeed(iface.up || 0) + " ↑" : "-- ↑";
        }
        // sub abajo → velocidad de bajada ↓
        sub: {
            const iface = speedData[interfaceName];
            return iface ? formatSpeed(iface.down || 0) + " ↓" : "-- ↓";
        }
        isMaskIcon: true
        itemIcon: Qt.resolvedUrl("../icons/network")
    }
}
