import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

PlasmaComponents.CheckBox {
    id: configCheckBox

    property string configKey: ''
    checked: configKey ? Plasmoid.configuration[configKey] : false
    onToggled: {
        if (configKey) {
            Plasmoid.configuration[configKey] = checked
        }
    }
}
