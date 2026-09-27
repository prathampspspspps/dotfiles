import QtQuick

// Theme 2: bars centred vertically, extending equally up and down.
BarThemeBase {
    id: t

    // Centred-theme gradient: accent at both ends, base in the middle,
    // so the bar looks symmetric around the centreline.
    Gradient {
        id: centeredGradient
        GradientStop { position: 0.0; color: t.gradientTopColor }
        GradientStop { position: 0.5; color: t.barColor }
        GradientStop { position: 1.0; color: t.gradientTopColor }
    }

    Repeater {
        model: t.segmented ? 0 : t.n
        delegate: Rectangle {
            readonly property real value: t.barValue(index)
            readonly property int h: Math.max(1, Math.round(value * t.height))
            x: t.slotX(index)
            width: t.barW(index)
            height: h
            y: Math.round((t.height - h) / 2)
            antialiasing: t.barRadius > 0
            radius: t.barRadius
            opacity: t.liveAlpha
            color: t.verticalGradient
                ? "transparent"
                : (t.horizontalGradient
                    ? t.barColorAt(index)
                    : (t.centerGradient
                        ? t.barColorAtSymmetric(index)
                        : t.barColor))
            gradient: t.verticalGradient ? centeredGradient : null
        }
    }

    // Segmented bars — slabs grow outward from the centreline. We
    // render top half and bottom half independently so the segment
    // grid aligns with both edges instead of one.
    Repeater {
        model: t.segmented ? t.n : 0
        delegate: Item {
            id: bar
            readonly property int barIdx: index
            readonly property real value: t.barValue(barIdx)
            readonly property int halfH: Math.max(1, Math.round(value * t.height / 2))
            readonly property int centerY: Math.round(t.height / 2)
            x: t.slotX(barIdx)
            width: t.barW(barIdx)
            y: 0
            height: t.height
            opacity: t.liveAlpha

            // Top half: segments stack upward from just above the centre.
            Repeater {
                model: Math.max(1, Math.floor((bar.halfH + t.segGap) / (t.segHeight + t.segGap)))
                delegate: Rectangle {
                    readonly property int segIdx: index
                    x: 0
                    y: bar.centerY - (segIdx + 1) * t.segHeight - segIdx * t.segGap
                    width: bar.width
                    height: t.segHeight
                    antialiasing: false
                    color: t.segmentColor(bar.barIdx, segIdx, bar.centerY)
                }
            }
            // Bottom half: mirror — same segment indexing for matching colour.
            Repeater {
                model: Math.max(1, Math.floor((bar.halfH + t.segGap) / (t.segHeight + t.segGap)))
                delegate: Rectangle {
                    readonly property int segIdx: index
                    x: 0
                    y: bar.centerY + segIdx * (t.segHeight + t.segGap)
                    width: bar.width
                    height: t.segHeight
                    antialiasing: false
                    color: t.segmentColor(bar.barIdx, segIdx, bar.centerY)
                }
            }
        }
    }

    // Peak caps — top + bottom markers, since the bar grows symmetrically
    // around the centreline. Each cap is anchored so it never touches
    // its side of the bar (kept at least 1px away), avoiding the
    // "bar got taller" merge artefact when peak meets value.
    Repeater {
        model: t.peakCaps ? t.n : 0
        delegate: Rectangle {
            readonly property int peakPx: Math.max(1, Math.round(t.peakValue(index) * t.height))
            readonly property int barPx: Math.max(1, Math.round(t.barValue(index) * t.height))
            readonly property int barTop: Math.round((t.height - barPx) / 2)
            readonly property int peakTop: Math.round((t.height - peakPx) / 2)
            x: t.slotX(index)
            width: t.barW(index)
            height: t.capThickness
            y: Math.max(0, Math.min(
                peakTop - t.capThickness,
                barTop - t.capThickness - 2))
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
    Repeater {
        model: t.peakCaps ? t.n : 0
        delegate: Rectangle {
            readonly property int peakPx: Math.max(1, Math.round(t.peakValue(index) * t.height))
            readonly property int barPx: Math.max(1, Math.round(t.barValue(index) * t.height))
            readonly property int barBot: Math.round((t.height + barPx) / 2)
            readonly property int peakBot: Math.round((t.height + peakPx) / 2)
            x: t.slotX(index)
            width: t.barW(index)
            height: t.capThickness
            y: Math.min(t.height - t.capThickness, Math.max(peakBot, barBot + 2))
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
}
