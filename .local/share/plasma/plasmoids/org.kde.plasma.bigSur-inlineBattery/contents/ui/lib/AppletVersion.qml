import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid

Item {
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    property string version: Plasmoid.pluginMetaData.version

    Label {
        id: label
        text: i18n("<b>Version:</b> %1", version)
    }
}
