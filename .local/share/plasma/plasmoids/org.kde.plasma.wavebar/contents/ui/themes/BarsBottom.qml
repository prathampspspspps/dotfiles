import QtQuick
import Qt5Compat.GraphicalEffects

// Theme 0: bars grow upward from the baseline. Optionally a blurred
// mirror image is rendered below — when reflection is on, the bars
// retract to leave room for it.
BarThemeBase {
    id: t

    // Reflection toggle and its tuning knobs.
    property bool reflection: false
    property int reflectionRatio: 25   // % of height taken by reflection
    property int blurRadius: 6

    readonly property real reflFraction: t.reflection
        ? Math.max(5, Math.min(60, reflectionRatio)) / 100.0
        : 0
    readonly property real topH: Math.max(1, Math.round(t.height * (1 - reflFraction)))
    readonly property real reflH: Math.max(0, t.height - topH)

    Gradient {
        id: barGradient
        GradientStop { position: 0.0; color: t.gradientTopColor }
        GradientStop { position: 1.0; color: t.barColor }
    }
    // Reflection gradient (with-gradient option): top of reflection
    // continues from the bottom of the upright bar, fading to the
    // accent colour at full transparency at the far edge.
    Gradient {
        id: reflGradient
        GradientStop { position: 0.0; color: t.barColor }
        GradientStop {
            position: 1.0
            color: Qt.rgba(t.gradientTopColor.r,
                           t.gradientTopColor.g,
                           t.gradientTopColor.b, 0)
        }
    }
    // Reflection gradient (plain): same colour, fading to transparent.
    Gradient {
        id: reflGradientPlain
        GradientStop { position: 0.0; color: t.barColor }
        GradientStop {
            position: 1.0
            color: Qt.rgba(t.barColor.r, t.barColor.g, t.barColor.b, 0)
        }
    }

    // Upright bars. With reflection off, topH equals the full height
    // and they grow from the very bottom; with reflection on, they
    // grow from the split line, leaving the reflection band below.
    Repeater {
        model: t.segmented ? 0 : t.n
        delegate: Rectangle {
            readonly property real value: t.barValue(index)
            x: t.slotX(index)
            width: t.barW(index)
            height: Math.max(1, Math.round(value * t.topH))
            y: t.topH - height
            antialiasing: t.barRadius > 0
            topLeftRadius: t.barRadius
            topRightRadius: t.barRadius
            opacity: t.liveAlpha
            color: t.verticalGradient
                ? "transparent"
                : (t.horizontalGradient
                    ? t.barColorAt(index)
                    : (t.centerGradient
                        ? t.barColorAtSymmetric(index)
                        : t.barColor))
            gradient: t.verticalGradient ? barGradient : null
        }
    }

    // Segmented upright bars — a stack of slabs growing from the
    // baseline. Inner Repeater sizes its model by the bar height.
    Repeater {
        model: t.segmented ? t.n : 0
        delegate: Item {
            id: bar
            readonly property int barIdx: index
            readonly property real value: t.barValue(barIdx)
            readonly property real h: Math.max(1, Math.round(value * t.topH))
            x: t.slotX(barIdx)
            width: t.barW(barIdx)
            height: h
            y: t.topH - height
            opacity: t.liveAlpha

            Repeater {
                model: Math.max(1, Math.floor((bar.h + t.segGap) / (t.segHeight + t.segGap)))
                delegate: Rectangle {
                    readonly property int segIdx: index
                    x: 0
                    y: bar.h - (segIdx + 1) * t.segHeight - segIdx * t.segGap
                    width: bar.width
                    height: t.segHeight
                    antialiasing: false
                    color: t.segmentColor(bar.barIdx, segIdx, t.topH)
                }
            }
        }
    }

    // Peak caps — float a thin marker at each bar's recent maximum
    // value. Sits in the upright band so it never drifts into the
    // reflection area below.
    //
    // We force a 2-logical-pixel minimum gap between cap and bar.
    // With fractional display scaling (e.g. 1.5x) a 1 px gap
    // rasterises to 1 or 2 device pixels depending on the cap's y,
    // which makes the descending cap appear to thicken and thin as
    // it slides. A 2 px gap always rasterises to ≥3 device pixels —
    // visually constant.
    Repeater {
        model: t.peakCaps ? t.n : 0
        delegate: Rectangle {
            readonly property int peakPx: Math.max(1, Math.round(t.peakValue(index) * t.topH))
            readonly property int barPx: Math.max(1, Math.round(t.barValue(index) * t.topH))
            x: t.slotX(index)
            width: t.barW(index)
            height: t.capThickness
            y: Math.max(0, Math.min(
                t.topH - peakPx - t.capThickness,
                t.topH - barPx - t.capThickness - 2))
            antialiasing: false
            opacity: t.liveAlpha
            color: t.horizontalGradient
                ? t.barColorAt(index)
                : (t.centerGradient
                    ? t.barColorAtSymmetric(index)
                    : (t.verticalGradient
                        ? t.gradientTopColor
                        : t.barColor))
        }
    }

    // Reflection layer — only present when enabled. Wrapped in a
    // layered Item so FastBlur softens the edges.
    Item {
        id: reflectionLayer
        visible: t.reflection
        anchors.left: parent.left
        anchors.right: parent.right
        y: t.topH
        height: t.reflH

        layer.enabled: true
        layer.smooth: true
        layer.effect: FastBlur { radius: t.blurRadius }

        Repeater {
            model: t.reflection ? t.n : 0
            delegate: Rectangle {
                id: reflBar
                readonly property real value: t.barValue(index)
                readonly property color tint: t.centerGradient
                    ? t.barColorAtSymmetric(index)
                    : t.barColorAt(index)
                x: t.slotX(index)
                width: t.barW(index)
                // Always span the full reflection band so the
                // gradient's transparent end lines up with the
                // panel edge. The audio level is conveyed via
                // opacity instead.
                height: t.reflH
                y: 0
                antialiasing: false
                opacity: t.liveAlpha * 0.85 * Math.max(0.15, value)
                color: "transparent"
                // Reflection always uses a vertical fade-to-transparent
                // — that's what makes it read as a reflection. With
                // horizontal/center gradient mode we start from the
                // per-bar tint instead of the shared base colour.
                Gradient {
                    id: tintedReflGradient
                    GradientStop { position: 0.0; color: reflBar.tint }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(reflBar.tint.r,
                                       reflBar.tint.g,
                                       reflBar.tint.b, 0)
                    }
                }
                gradient: (t.horizontalGradient || t.centerGradient)
                    ? tintedReflGradient
                    : (t.gradientDirection !== 0 ? reflGradient : reflGradientPlain)
            }
        }
    }
}
