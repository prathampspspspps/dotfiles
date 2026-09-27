import QtQuick

// Dispatches to one of the theme components based on themeIndex. Used
// by both the panel widget (main.qml) and the config preview so the
// per-theme wiring lives in exactly one place.
//
// All themes are instantiated; only the active one is visible.
// Inactive themes have `n: 0`, which empties their Repeaters / makes
// the Line canvas a no-op so they stay cheap.
Item {
    id: r

    property int themeIndex: 0

    // Shared inputs — forwarded to whichever theme is active.
    property int n: 32
    property int gap: 1
    property int barRadius: 0
    property color barColor: "#3daee9"
    property color gradientTopColor: "#ff5555"
    property int gradientDirection: 0   // 0 = none, 1 = vertical, 2 = horizontal, 3 = center
    property var barValues: []
    property real liveAlpha: 0.85

    // Theme-specific inputs — only the matching theme reads them.
    property bool reflection: false
    property int reflectionRatio: 25
    property int reflectionBlur: 6
    property int lineWidth: 2
    property bool lineGlow: false
    property bool peakCaps: false
    property bool segmented: false

    BarsBottom {
        anchors.fill: parent
        visible: r.themeIndex === 0
        n: visible ? r.n : 0
        gap: r.gap; barRadius: r.barRadius
        barColor: r.barColor; gradientTopColor: r.gradientTopColor
        gradientDirection: r.gradientDirection
        barValues: r.barValues; liveAlpha: r.liveAlpha
        peakCaps: r.peakCaps
        segmented: r.segmented
        reflection: r.reflection
        reflectionRatio: r.reflectionRatio
        blurRadius: r.reflectionBlur
    }
    Centered {
        anchors.fill: parent
        visible: r.themeIndex === 1
        n: visible ? r.n : 0
        gap: r.gap; barRadius: r.barRadius
        barColor: r.barColor; gradientTopColor: r.gradientTopColor
        gradientDirection: r.gradientDirection
        barValues: r.barValues; liveAlpha: r.liveAlpha
        peakCaps: r.peakCaps
        segmented: r.segmented
    }
    Line {
        anchors.fill: parent
        visible: r.themeIndex === 2
        n: visible ? r.n : 0
        gap: r.gap; barRadius: r.barRadius
        barColor: r.barColor; gradientTopColor: r.gradientTopColor
        gradientDirection: r.gradientDirection
        barValues: r.barValues; liveAlpha: r.liveAlpha
        lineWidth: r.lineWidth
        lineGlow: r.lineGlow
    }
}
