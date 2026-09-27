import QtQuick

// Theme 3: oscilloscope-style single line snaking around the vertical
// centreline. Each sample's offset alternates above/below centre, so
// the curve crosses the middle between successive bars — at value=0
// it collapses to a flat horizontal line at the middle.
BarThemeBase {
    id: t

    // Theme-specific options.
    property int lineWidth: 2
    // When true, previous frames are not cleared but faded out, leaving
    // a softly drifting trail behind the moving line — like the
    // phosphor persistence of an analogue oscilloscope.
    property bool lineGlow: false

    // How much of the trail to wipe each frame, 0..1. Smaller = longer
    // trail. 0.15 ≈ ~15-frame tail at 33 ms/frame (~0.5 s).
    readonly property real lineGlowDecay: 0.15

    Canvas {
        id: lineCanvas
        anchors.fill: parent
        antialiasing: true
        renderStrategy: Canvas.Cooperative

        Connections {
            target: t
            function onBarValuesChanged() { lineCanvas.requestPaint() }
            function onGradientDirectionChanged() { lineCanvas.requestPaint() }
            function onBarColorChanged() { lineCanvas.requestPaint() }
            function onGradientTopColorChanged() { lineCanvas.requestPaint() }
            function onLiveAlphaChanged() { lineCanvas.requestPaint() }
            function onLineWidthChanged() { lineCanvas.requestPaint() }
            function onLineGlowChanged() { lineCanvas.requestPaint() }
        }
        Component.onCompleted: requestPaint()
        onVisibleChanged: if (visible) requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            const n = t.n
            if (n < 2 || width < 2 || height < 2) {
                ctx.reset()
                return
            }

            if (t.lineGlow) {
                // Persistence mode: instead of clearing, knock down the
                // alpha of every existing pixel so the previous trace
                // dims a bit. Successive frames stack into a soft fog.
                ctx.globalCompositeOperation = "destination-out"
                ctx.fillStyle = "rgba(0,0,0," + t.lineGlowDecay + ")"
                ctx.fillRect(0, 0, width, height)
                ctx.globalCompositeOperation = "source-over"
            } else {
                ctx.reset()
            }

            const center = height / 2
            // Leave a small clearance at the top/bottom so the
            // stroke (and its anti-aliased halo) never touches the
            // canvas edges. Without this, edge pixels can pick up
            // sub-pixel content that the trail effect then keeps
            // alive as a faint outline.
            const vMargin = Math.max(2, t.lineWidth)
            const halfH = Math.max(1, height / 2 - vMargin)

            // Each sample is placed above or below the centre with
            // alternating sign, so the line oscillates through the
            // middle (oscilloscope feel). The amplitude curve is
            // pow(value, 0.4) * 1.2 (clamped) — heavily compressing
            // the response so even modest signal drives the line all
            // the way to the canvas edges, while loud peaks saturate
            // for a "punching the ceiling" feel.
            //
            // The first and last few bars are tapered down to zero
            // amplitude so the line eases into and out of the
            // centreline at the edges instead of jumping straight
            // from centre to a peak — looks balanced and matches the
            // ~8% horizontal fade mask applied at the very end.
            const edgeBars = Math.max(1, Math.round(n * 0.08))
            const pts = new Array(n)
            for (let i = 0; i < n; i++) {
                const cx = t.slotX(i) + t.barW(i) / 2
                const sign = (i % 2 === 0) ? -1 : 1
                const edge = Math.min(1, Math.min(i, n - 1 - i) / edgeBars)
                const amp = Math.min(1, Math.pow(t.barValue(i), 0.4) * 1.2) * edge
                pts[i] = { x: cx, y: center + sign * amp * halfH }
            }

            // Open quadratic-smoothed path through the points,
            // anchored at the centreline on both edges so the line
            // enters and leaves cleanly.
            ctx.beginPath()
            ctx.moveTo(0, center)
            ctx.lineTo(pts[0].x, pts[0].y)
            for (let i = 1; i < n; i++) {
                const prev = pts[i - 1]
                const curr = pts[i]
                const mx = (prev.x + curr.x) / 2
                const my = (prev.y + curr.y) / 2
                ctx.quadraticCurveTo(prev.x, prev.y, mx, my)
            }
            ctx.lineTo(pts[n - 1].x, pts[n - 1].y)
            ctx.lineTo(width, center)

            const c = t.barColor
            const tc = t.gradientTopColor

            ctx.lineWidth = t.lineWidth
            ctx.lineJoin = "round"
            ctx.lineCap = "round"
            if (t.gradientDirection === 2) {
                // Horizontal: stroke fades base→accent left→right.
                const sg = ctx.createLinearGradient(0, 0, width, 0)
                sg.addColorStop(0, Qt.rgba(c.r, c.g, c.b, t.liveAlpha).toString())
                sg.addColorStop(1, Qt.rgba(tc.r, tc.g, tc.b, t.liveAlpha).toString())
                ctx.strokeStyle = sg
            } else if (t.gradientDirection === 1) {
                // Vertical: accent at the extremes (top/bottom),
                // base near the centreline. Highlights peaks.
                const sg = ctx.createLinearGradient(0, 0, 0, height)
                sg.addColorStop(0,   Qt.rgba(tc.r, tc.g, tc.b, t.liveAlpha).toString())
                sg.addColorStop(0.5, Qt.rgba(c.r,  c.g,  c.b,  t.liveAlpha).toString())
                sg.addColorStop(1,   Qt.rgba(tc.r, tc.g, tc.b, t.liveAlpha).toString())
                ctx.strokeStyle = sg
            } else if (t.gradientDirection === 3) {
                // Center: base in the horizontal middle, accent at
                // the left and right ends.
                const sg = ctx.createLinearGradient(0, 0, width, 0)
                sg.addColorStop(0,   Qt.rgba(tc.r, tc.g, tc.b, t.liveAlpha).toString())
                sg.addColorStop(0.5, Qt.rgba(c.r,  c.g,  c.b,  t.liveAlpha).toString())
                sg.addColorStop(1,   Qt.rgba(tc.r, tc.g, tc.b, t.liveAlpha).toString())
                ctx.strokeStyle = sg
            } else {
                ctx.strokeStyle = Qt.rgba(c.r, c.g, c.b, t.liveAlpha).toString()
            }
            ctx.stroke()

            // Horizontal edge fade so the line fades out at the
            // panel boundaries instead of cutting off abruptly.
            ctx.globalCompositeOperation = "destination-in"
            const hMask = ctx.createLinearGradient(0, 0, width, 0)
            hMask.addColorStop(0,    "rgba(0,0,0,0)")
            hMask.addColorStop(0.08, "rgba(0,0,0,1)")
            hMask.addColorStop(0.92, "rgba(0,0,0,1)")
            hMask.addColorStop(1,    "rgba(0,0,0,0)")
            ctx.fillStyle = hMask
            ctx.fillRect(0, 0, width, height)

            // Hard-clear the very top and bottom rows. Any sub-pixel
            // content the GPU may have rasterised near the canvas
            // edges would otherwise be kept alive by the persistence
            // trail and read as a faint horizontal outline.
            ctx.globalCompositeOperation = "destination-out"
            ctx.fillStyle = "rgba(0,0,0,1)"
            ctx.fillRect(0, 0, width, 1)
            ctx.fillRect(0, height - 1, width, 1)

            ctx.globalCompositeOperation = "source-over"
        }
    }
}
