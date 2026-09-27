import QtQuick

// Shared base for all themes. Holds the common inputs every theme reads
// (geometry, colours, gradient mode, the latest bar values) plus the math
// helpers used to lay out evenly spaced, pixel-snapped bars.
Item {
    id: theme

    // ===== Inputs =====
    property int n: 32
    property int gap: 1
    property int barRadius: 0
    property color barColor: "#3daee9"
    property color gradientTopColor: "#ff5555"
    property int gradientDirection: 0   // 0 = none, 1 = vertical, 2 = horizontal, 3 = center
    property var barValues: []          // length-n array of 0..1
    property real liveAlpha: 0.85

    // Peak caps: a thin marker that floats at each bar's recent maximum
    // and falls slowly. Off by default; the host theme decides how to
    // render the caps (top-only, top+bottom, etc.).
    property bool peakCaps: false
    readonly property real peakDecay: 0.015
    readonly property int capThickness: 2
    property var peakValues: []

    // Segmented bar style — bars are drawn as a stack of small slabs
    // separated by gaps, like a vintage VU meter. The gradient maps
    // across the full bar area (the `area` argument), so a quiet bar
    // shows only the bottom of the gradient and a loud one climbs
    // through it.
    property bool segmented: false
    readonly property int segHeight: 3
    readonly property int segGap: 1

    // Colour for one segment, given which bar it belongs to and the
    // segment's index from the baseline (0 = closest to the baseline)
    // along an axis of total length `area`. Used by both bar themes.
    function segmentColor(barIdx, segIdx, area) {
        if (verticalGradient) {
            const absY = area - (segIdx + 0.5) * segHeight - segIdx * segGap
            const f = Math.max(0, Math.min(1, absY / area))
            const a = gradientTopColor, b = barColor
            return Qt.rgba(a.r + (b.r - a.r) * f,
                           a.g + (b.g - a.g) * f,
                           a.b + (b.b - a.b) * f,
                           a.a + (b.a - a.a) * f)
        }
        if (horizontalGradient) return barColorAt(barIdx)
        if (centerGradient) return barColorAtSymmetric(barIdx)
        return barColor
    }

    // ===== Derived =====
    readonly property bool verticalGradient: gradientDirection === 1
    readonly property bool horizontalGradient: gradientDirection === 2
    readonly property bool centerGradient: gradientDirection === 3

    // Snap each bar's x position to an integer pixel using cumulative
    // rounding. Keeps bar widths within 1 px of each other and avoids
    // antialiased fractional edges that make the gaps look uneven.
    function slotX(i) { return Math.round(i * width / n) }
    function barW(i) { return Math.max(1, slotX(i + 1) - slotX(i) - gap) }
    function barValue(i) {
        return Math.min(1, Math.max(0, barValues[i] || 0))
    }
    function peakValue(i) {
        return Math.min(1, Math.max(0, peakValues[i] || 0))
    }

    // Recompute the peaks whenever a new frame arrives. barValues
    // updates at ~30 Hz both during live audio and the idle sine
    // animation, so this gives roughly per-frame decay.
    onBarValuesChanged: {
        if (!peakCaps) return
        const arr = (peakValues.length === n)
            ? peakValues.slice()
            : new Array(n).fill(0)
        for (let i = 0; i < n; i++) {
            const v = Math.min(1, Math.max(0, barValues[i] || 0))
            arr[i] = Math.max(arr[i] - peakDecay, v)
        }
        peakValues = arr
    }
    onPeakCapsChanged: if (!peakCaps) peakValues = []

    // Per-bar solid colour for the horizontal-gradient case. Rectangle's
    // built-in gradient is always vertical, so to fade colours left→right
    // we paint each bar a single colour interpolated by its index.
    function barColorAt(i) {
        const t = n > 1 ? i / (n - 1) : 0
        const a = barColor, b = gradientTopColor
        return Qt.rgba(a.r + (b.r - a.r) * t,
                       a.g + (b.g - a.g) * t,
                       a.b + (b.b - a.b) * t,
                       a.a + (b.a - a.a) * t)
    }

    // Per-bar colour for the center-gradient case: barColor at the
    // middle index, fading to gradientTopColor at the left/right edges.
    function barColorAtSymmetric(i) {
        const cent = (n - 1) / 2
        const t = cent > 0 ? Math.abs(i - cent) / cent : 0
        const a = barColor, b = gradientTopColor
        return Qt.rgba(a.r + (b.r - a.r) * t,
                       a.g + (b.g - a.g) * t,
                       a.b + (b.b - a.b) * t,
                       a.a + (b.a - a.a) * t)
    }
}
