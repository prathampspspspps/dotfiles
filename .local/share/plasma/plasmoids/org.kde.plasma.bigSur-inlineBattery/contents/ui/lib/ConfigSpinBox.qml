import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid

RowLayout {
    id: configSpinBox

    property string configKey: ''
    property alias from: spinBox.from
    property alias to: spinBox.to
    property alias stepSize: spinBox.stepSize
    property alias value: spinBox.value
    property string suffix: ""
    property string prefix: ""

    property alias before: labelBefore.text
    property alias after: labelAfter.text

    Label {
        id: labelBefore
        text: ""
        visible: text !== ""
    }
    
    SpinBox {
        id: spinBox
        from: 0
        to: 2147483647
        value: Plasmoid.configuration[configKey]
        
        editable: true
        onValueChanged: {
            if (configKey) {
                serializeTimer.restart()
            }
        }

        textFromValue: function(value, locale) {
            return prefix + value + suffix;
        }

        valueFromText: function(text, locale) {
            var v = text;
            if (prefix && v.indexOf(prefix) === 0) v = v.substr(prefix.length);
            if (suffix && v.indexOf(suffix) === v.length - suffix.length) v = v.substr(0, v.length - suffix.length);
            return parseInt(v);
        }
    }

    Label {
        id: labelAfter
        text: ""
        visible: text !== ""
    }

    Timer { // throttle
        id: serializeTimer
        interval: 300
        onTriggered: Plasmoid.configuration[configKey] = spinBox.value
    }
}
