import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import "themes" as Themes

Kirigami.FormLayout {
    id: page

    property alias cfg_theme: themeCombo.currentIndex
    property alias cfg_barColor: colorRect.color
    property alias cfg_gradientTopColor: gradTopRect.color
    property alias cfg_gradientDirection: gradientDirCombo.currentIndex
    property alias cfg_barGap: barGapSpin.value
    property alias cfg_barRadius: barRadiusSpin.value
    property alias cfg_reflectionRatio: reflectionRatioSpin.value
    property alias cfg_reflectionBlur: reflectionBlurSpin.value
    property alias cfg_lineWidth: lineWidthSpin.value
    property alias cfg_lineGlow: lineGlowCheck.checked
    property alias cfg_reflection: reflectionCheck.checked
    property alias cfg_peakCaps: peakCapsCheck.checked
    property alias cfg_barStyle: barStyleCombo.currentIndex

    // The preview reads barCount from the plasmoid configuration directly
    // since it lives on the General page; we just observe the current value.
    readonly property int previewBarCount:
        plasmoid ? plasmoid.configuration.barCount : 32

    // Drives the preview's idle sine wave. Stays running so the user can
    // see motion regardless of audio state.
    QtObject {
        id: previewState
        property real phase: 0
        readonly property var barValues: {
            const n = page.previewBarCount
            const arr = new Array(n)
            for (let i = 0; i < n; i++) {
                const a = Math.sin(phase + i * 0.35)
                const b = Math.sin(phase * 0.6 + i * 0.18)
                arr[i] = 0.5 + 0.35 * (0.6 * a + 0.4 * b)
            }
            return arr
        }
    }
    Timer {
        interval: 33
        running: true
        repeat: true
        onTriggered: previewState.phase += 0.12
    }

    // Top breathing room — Kirigami.FormLayout otherwise puts the first
    // control flush against the dialog header.
    Item {
        Layout.preferredHeight: Kirigami.Units.smallSpacing * 2
    }

    ComboBox {
        id: themeCombo
        Kirigami.FormData.label: i18n("Theme:")
        Layout.preferredWidth: 420
        model: [
            i18n("Default — bars from the bottom"),
            i18n("Centered — bars extend from the centre up and down"),
            i18n("Line — smooth curve through the peaks")
        ]
    }

    // Wrapped in an Item because Kirigami.FormLayout sizes children by
    // their implicit/Layout sizes — Rectangles default to (0,0) implicit
    // and the Layout-attached props alone aren't always honoured here.
    Item {
        Kirigami.FormData.label: i18n("Preview:")
        Layout.fillWidth: true
        Layout.preferredWidth: 420
        Layout.preferredHeight: 80
        implicitWidth: 420
        implicitHeight: 80

        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.alternateBackgroundColor
            radius: 4
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1
            clip: true

            Themes.ThemeRenderer {
                anchors.fill: parent
                anchors.margins: 4
                themeIndex: themeCombo.currentIndex
                n: page.previewBarCount
                gap: barGapSpin.value
                barRadius: barRadiusSpin.value
                barColor: colorRect.color
                gradientTopColor: gradTopRect.color
                gradientDirection: gradientDirCombo.currentIndex
                barValues: previewState.barValues
                liveAlpha: 0.9
                reflection: reflectionCheck.checked
                reflectionRatio: reflectionRatioSpin.value
                reflectionBlur: reflectionBlurSpin.value
                lineWidth: lineWidthSpin.value
                lineGlow: lineGlowCheck.checked
                peakCaps: peakCapsCheck.checked
                segmented: barStyleCombo.currentIndex === 1
            }
        }
    }

    // ===== Theme-specific options =====
    // Only the matching theme's options are visible at a time.

    CheckBox {
        id: reflectionCheck
        Kirigami.FormData.label: i18n("Reflection:")
        text: i18n("Mirror the bars below with a soft blur")
        visible: themeCombo.currentIndex === 0
    }

    SpinBox {
        id: reflectionRatioSpin
        Kirigami.FormData.label: i18n("Reflection size (%):")
        from: 5
        to: 60
        value: 25
        stepSize: 5
        visible: themeCombo.currentIndex === 0 && reflectionCheck.checked
    }

    SpinBox {
        id: reflectionBlurSpin
        Kirigami.FormData.label: i18n("Reflection blur (px):")
        from: 0
        to: 32
        value: 6
        visible: themeCombo.currentIndex === 0 && reflectionCheck.checked
    }

    SpinBox {
        id: lineWidthSpin
        Kirigami.FormData.label: i18n("Line width (px):")
        from: 1
        to: 8
        value: 2
        visible: themeCombo.currentIndex === 2
    }

    CheckBox {
        id: lineGlowCheck
        Kirigami.FormData.label: i18n("Glow trail:")
        text: i18n("Leave a fading trail behind the line")
        visible: themeCombo.currentIndex === 2
    }

    CheckBox {
        id: peakCapsCheck
        Kirigami.FormData.label: i18n("Peak caps:")
        text: i18n("Float a marker at each bar's recent maximum")
        visible: themeCombo.currentIndex !== 2
    }

    ComboBox {
        id: barStyleCombo
        Kirigami.FormData.label: i18n("Bar style:")
        Layout.preferredWidth: 220
        model: [
            i18n("Solid"),
            i18n("Segmented")
        ]
        visible: themeCombo.currentIndex !== 2
    }

    Item { Kirigami.FormData.isSection: true }

    ComboBox {
        id: gradientDirCombo
        Kirigami.FormData.label: i18n("Gradient:")
        Layout.preferredWidth: 220
        model: [
            i18n("None"),
            i18n("Vertical (top → bottom)"),
            i18n("Horizontal (left → right)"),
            i18n("Center (middle → sides)")
        ]
    }

    // Both colour swatches share a row. The second swatch is hidden
    // when no gradient is selected.
    RowLayout {
        Kirigami.FormData.label: i18n("Color:")
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            id: colorRect
            width: 40
            height: 24
            radius: 3
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1
            color: "#3daee9"
            MouseArea {
                anchors.fill: parent
                onClicked: colorDialog.open()
            }
        }
        Rectangle {
            id: gradTopRect
            width: 40
            height: 24
            radius: 3
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1
            color: "#ff5555"
            visible: gradientDirCombo.currentIndex !== 0
            MouseArea {
                anchors.fill: parent
                onClicked: gradColorDialog.open()
            }
        }

        ColorDialog {
            id: colorDialog
            selectedColor: colorRect.color
            onAccepted: colorRect.color = selectedColor
        }
        ColorDialog {
            id: gradColorDialog
            selectedColor: gradTopRect.color
            onAccepted: gradTopRect.color = selectedColor
        }
    }

    SpinBox {
        id: barGapSpin
        Kirigami.FormData.label: i18n("Gap between bars (px):")
        from: 0
        to: 8
        value: 1
        // Line theme is a single curve — no inter-bar gap to set.
        visible: themeCombo.currentIndex !== 2
    }

    SpinBox {
        id: barRadiusSpin
        Kirigami.FormData.label: i18n("Corner radius (px):")
        from: 0
        to: 16
        value: 0
        // Line theme draws a curve, not rectangles — corners don't apply.
        visible: themeCombo.currentIndex !== 2
    }
}
