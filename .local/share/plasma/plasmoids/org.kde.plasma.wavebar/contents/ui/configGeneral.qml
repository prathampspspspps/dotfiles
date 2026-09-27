import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

Kirigami.FormLayout {
    id: page

    property string selectedName: ""

    property alias cfg_device: page.selectedName
    property alias cfg_barCount: barCountSpin.value
    property alias cfg_widgetWidth: widthSpin.value
    property alias cfg_sidePadding: sidePaddingSpin.value
    property alias cfg_sensitivityPct: sensitivitySpin.value
    property alias cfg_smoothingPct: smoothingSpin.value

    ListModel { id: deviceModel }

    P5Support.DataSource {
        id: shell
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const out = String(data["stdout"] || "")
            disconnectSource(sourceName)
            parseDevices(out)
        }
        function refresh() {
            // Force English field labels so we can match "Name:" / "Description:"
            connectSource("sh -c 'LANG=C LC_ALL=C pactl list sources'")
        }
    }

    function parseDevices(text) {
        deviceModel.clear()
        // Each "Source #N" starts a new block.
        const blocks = String(text).split(/\nSource #/)
        for (let i = 0; i < blocks.length; i++) {
            const block = blocks[i]
            const nameMatch = block.match(/\bName:\s*([^\n]+)/)
            if (!nameMatch) continue
            const name = nameMatch[1].trim()
            // Only output monitors are useful for visualizing playback.
            if (!name.endsWith(".monitor")) continue
            const descMatch = block.match(/\bDescription:\s*([^\n]+)/)
            const desc = descMatch ? descMatch[1].trim() : name
            deviceModel.append({ name: name, description: desc })
        }
        // If the saved device isn't currently present, append a placeholder
        // entry so the user can still see it selected.
        let idx = -1
        for (let i = 0; i < deviceModel.count; i++) {
            if (deviceModel.get(i).name === page.selectedName) { idx = i; break }
        }
        if (idx < 0 && page.selectedName) {
            deviceModel.append({
                name: page.selectedName,
                description: page.selectedName + " (not currently available)"
            })
            idx = deviceModel.count - 1
        }
        if (idx >= 0) {
            deviceCombo.currentIndex = idx
        } else if (deviceModel.count > 0) {
            deviceCombo.currentIndex = 0
            page.selectedName = deviceModel.get(0).name
        }
    }

    Component.onCompleted: {
        // Pull the initial saved value from the plasmoid config.
        page.selectedName = plasmoid ? (plasmoid.configuration.device || "") : ""
        shell.refresh()
    }

    // Top breathing room — Kirigami.FormLayout otherwise puts the first
    // control flush against the dialog header.
    Item {
        Layout.preferredHeight: Kirigami.Units.smallSpacing * 2
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Audio device:")
        ComboBox {
            id: deviceCombo
            Layout.preferredWidth: 420
            model: deviceModel
            textRole: "description"

            delegate: ItemDelegate {
                width: deviceCombo.width
                contentItem: ColumnLayout {
                    spacing: 0
                    Label {
                        Layout.fillWidth: true
                        text: model.description
                        elide: Text.ElideRight
                    }
                    Label {
                        Layout.fillWidth: true
                        text: model.name
                        elide: Text.ElideRight
                        opacity: 0.6
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }
                }
            }

            onActivated: {
                if (currentIndex >= 0 && currentIndex < deviceModel.count) {
                    page.selectedName = deviceModel.get(currentIndex).name
                }
            }
        }
        Button {
            text: i18n("Refresh")
            icon.name: "view-refresh"
            onClicked: shell.refresh()
        }
    }

    Label {
        Layout.preferredWidth: 420
        wrapMode: Text.WordWrap
        text: i18n("Pick the monitor source for the output you want to visualize. The default sink's monitor is usually correct.")
        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        opacity: 0.75
    }

    Item { Kirigami.FormData.isSection: true }

    SpinBox {
        id: barCountSpin
        Kirigami.FormData.label: i18n("Frequency bands:")
        from: 4
        to: 128
        value: 32
        stepSize: 1
    }

    SpinBox {
        id: widthSpin
        Kirigami.FormData.label: i18n("Widget width (px):")
        from: 80
        to: 800
        value: 220
        stepSize: 10
    }

    SpinBox {
        id: sidePaddingSpin
        Kirigami.FormData.label: i18n("Side padding (px):")
        from: 0
        to: 64
        value: 6
        stepSize: 2
    }

    SpinBox {
        id: sensitivitySpin
        Kirigami.FormData.label: i18n("Sensitivity:")
        from: 25
        to: 400
        value: 100
        stepSize: 5
        textFromValue: function(v) { return (v / 100.0).toFixed(2) + "x" }
        valueFromText: function(t) { return Math.round(parseFloat(t) * 100) }
    }

    SpinBox {
        id: smoothingSpin
        Kirigami.FormData.label: i18n("Smoothing:")
        from: 0
        to: 95
        value: 75
        stepSize: 5
        textFromValue: function(v) { return (v / 100.0).toFixed(2) }
        valueFromText: function(t) { return Math.round(parseFloat(t) * 100) }
    }
}
