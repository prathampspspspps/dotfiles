import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support
import "themes" as Themes

PlasmoidItem {
    id: root

    readonly property string device: Plasmoid.configuration.device
    readonly property color barColor: Plasmoid.configuration.barColor
    readonly property color gradientTopColor: Plasmoid.configuration.gradientTopColor
    readonly property int barCount: Plasmoid.configuration.barCount
    readonly property int barGap: Plasmoid.configuration.barGap
    readonly property real sensitivity: Plasmoid.configuration.sensitivityPct / 100.0
    readonly property real smoothing: Plasmoid.configuration.smoothingPct / 100.0
    readonly property int widgetWidth: Plasmoid.configuration.widgetWidth
    readonly property int theme: Plasmoid.configuration.theme
    readonly property int barRadius: Plasmoid.configuration.barRadius
    readonly property int gradientDirection: Plasmoid.configuration.gradientDirection
    readonly property int sidePadding: Plasmoid.configuration.sidePadding
    readonly property bool reflection: Plasmoid.configuration.reflection
    readonly property int reflectionRatio: Plasmoid.configuration.reflectionRatio
    readonly property int reflectionBlur: Plasmoid.configuration.reflectionBlur
    readonly property int lineWidth: Plasmoid.configuration.lineWidth
    readonly property bool lineGlow: Plasmoid.configuration.lineGlow
    readonly property bool peakCaps: Plasmoid.configuration.peakCaps
    readonly property int barStyle: Plasmoid.configuration.barStyle

    // Drop the desktop "frame" so the bars sit on a transparent background
    // both in the panel and on the desktop.
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property string runtimeDir: ""
    property string dataPath: ""
    property string alivePath: ""
    property string portPath: ""
    property string logPath: ""
    property string spectrumUrl: ""
    property string daemonPath: Qt.resolvedUrl("../code/spectrum-daemon.py").toString().replace("file://", "")
    property string launcherPath: Qt.resolvedUrl("../code/launch-daemon.sh").toString().replace("file://", "")
    property var bars: []
    property string status: "init"           // init | starting | waiting | running | nodevice
    property double lastDataAt: 0
    property double daemonStartedAt: 0

    preferredRepresentation: compactRepresentation

    // One-shot shell command runner (resolveRuntimeDir, startDaemon, heartbeat).
    P5Support.DataSource {
        id: shell
        engine: "executable"
        connectedSources: []

        signal commandFinished(string source, string stdout, string stderr)

        onNewData: (sourceName, data) => {
            commandFinished(sourceName, data["stdout"] || "", data["stderr"] || "")
            disconnectSource(sourceName)
        }

        function run(cmd) {
            connectSource(cmd)
        }
    }

    // Poll the daemon's tiny localhost HTTP endpoint via XHR. Qt's QML XHR
    // refuses file:// reads by default but is happy with http://, so the
    // daemon serves the latest spectrum on 127.0.0.1:<ephemeral-port>.
    property var pollXhr: null

    function pollOnce() {
        if (!root.spectrumUrl) return
        if (pollXhr && pollXhr.readyState !== 0 && pollXhr.readyState !== 4) {
            return
        }
        const xhr = new XMLHttpRequest()
        pollXhr = xhr
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return
            if (xhr.status !== 200) {
                // Daemon not up yet (or restarted with new port). Drop URL so
                // we re-discover the port on the next tick.
                root.spectrumUrl = ""
                portRetry.start()
                return
            }
            const txt = String(xhr.responseText || "").trim()
            if (txt.length === 0) {
                if (root.device && root.status !== "waiting") {
                    root.status = "waiting"
                }
                return
            }
            const parts = txt.split(/\s+/)
            const arr = new Array(parts.length)
            for (let i = 0; i < parts.length; i++) {
                arr[i] = parseFloat(parts[i]) || 0
            }
            root.bars = arr
            root.lastDataAt = Date.now()
            if (root.status !== "running") root.status = "running"
        }
        xhr.open("GET", root.spectrumUrl)
        xhr.send()
    }

    Timer {
        id: pollTick
        interval: 33
        running: root.spectrumUrl !== ""
        repeat: true
        onTriggered: root.pollOnce()
    }

    Timer {
        id: portRetry
        interval: 250
        repeat: false
        onTriggered: root.discoverPort()
    }

    function discoverPort() {
        if (!root.portPath) return
        const cmd = "sh -c 'cat " + shellQuote(root.portPath) + " 2>/dev/null'"
        const handler = function(source, stdout, stderr) {
            if (source !== cmd) return
            shell.commandFinished.disconnect(handler)
            const p = String(stdout).trim()
            if (!p) {
                portRetry.start()
                return
            }
            root.spectrumUrl = "http://127.0.0.1:" + p + "/"
        }
        shell.commandFinished.connect(handler)
        shell.run(cmd)
    }

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function resolveRuntimeDir() {
        const cmd = "sh -c 'printf %s \"${XDG_RUNTIME_DIR:-/tmp}\"'"
        const handler = function(source, stdout, stderr) {
            if (source !== cmd) return
            shell.commandFinished.disconnect(handler)
            const dir = String(stdout).trim() || "/tmp"
            root.runtimeDir = dir
            root.dataPath = dir + "/wavebar.dat"
            root.alivePath = root.dataPath + ".alive"
            root.portPath = root.dataPath + ".port"
            root.logPath = dir + "/wavebar.log"
            startDaemon()
        }
        shell.commandFinished.connect(handler)
        shell.run(cmd)
    }

    function startDaemon() {
        if (!dataPath) return
        if (!device) {
            root.status = "nodevice"
            return
        }
        root.status = "starting"
        root.daemonStartedAt = Date.now()
        // The daemon will pick a fresh ephemeral port; force re-discovery.
        root.spectrumUrl = ""
        portRetry.start()
        // We run a wrapper shell script. Its final `exec python3 ...` replaces
        // bash with python which then double-forks (--daemonize) and the parent
        // exits cleanly within ~milliseconds. The QProcess Plasma uses to invoke
        // the wrapper sees that exit and disconnects normally.
        const cmd = [
            "/bin/bash",
            shellQuote(launcherPath),
            shellQuote(logPath),
            shellQuote(daemonPath),
            shellQuote(device),
            String(barCount),
            String(smoothing),
            String(sensitivity),
            shellQuote(dataPath),
        ].join(" ")
        shell.run(cmd)
    }

    function touchAlive() {
        if (!alivePath) return
        shell.run("touch " + shellQuote(alivePath))
    }

    Component.onCompleted: resolveRuntimeDir()

    onDeviceChanged: startDaemon()
    onBarCountChanged: startDaemon()
    onSmoothingChanged: startDaemon()
    onSensitivityChanged: startDaemon()

    Timer {
        id: heartbeat
        interval: 5000
        running: root.alivePath !== ""
        repeat: true
        onTriggered: root.touchAlive()
    }

    // Demote status to "waiting" if data stops arriving for >2s.
    Timer {
        interval: 1000
        running: root.status === "running"
        repeat: true
        onTriggered: {
            if (Date.now() - root.lastDataAt > 2000) {
                root.status = "waiting"
            }
        }
    }

    // Watchdog: relaunch the daemon if no data has arrived for >10 s. Covers
    // PipeWire restarts on suspend/resume, the daemon being killed externally,
    // sources hot-swapping, etc. We compare against whichever is more recent
    // of the last successful frame and the daemon's start time, so a freshly
    // launched daemon gets a 10 s grace period before being restarted again.
    Timer {
        interval: 5000
        running: root.dataPath !== "" && root.device !== ""
        repeat: true
        onTriggered: {
            const lastSignal = Math.max(root.lastDataAt, root.daemonStartedAt)
            if (lastSignal > 0 && Date.now() - lastSignal > 10000) {
                root.startDaemon()
            }
        }
    }

    compactRepresentation: Item {
        id: compact
        // sidePadding is added on each side so the bars area still measures
        // `widgetWidth`, but the widget reserves extra empty space against
        // its panel neighbours.
        Layout.minimumWidth: root.widgetWidth + 2 * root.sidePadding
        Layout.preferredWidth: root.widgetWidth + 2 * root.sidePadding
        Layout.minimumHeight: 16
        Layout.fillHeight: true

        property real idlePhase: 0

        // While idle (no live audio yet), animate a sine wave so the widget
        // doesn't look frozen. barValues depends on idlePhase, so mutating
        // it re-evaluates the binding automatically.
        Timer {
            interval: 33
            running: root.status !== "running"
            repeat: true
            onTriggered: compact.idlePhase += 0.12
        }

        // The single source of truth for what the active theme renders.
        // Live data when running; otherwise a lazy sine envelope.
        readonly property var barValues: {
            if (root.status === "running") return root.bars
            const n = root.barCount
            const arr = new Array(n)
            for (let i = 0; i < n; i++) {
                const a = Math.sin(idlePhase + i * 0.35)
                const b = Math.sin(idlePhase * 0.6 + i * 0.18)
                arr[i] = 0.5 + 0.35 * (0.6 * a + 0.4 * b)
            }
            return arr
        }

        Themes.ThemeRenderer {
            anchors.fill: parent
            anchors.leftMargin: root.sidePadding
            anchors.rightMargin: root.sidePadding

            themeIndex: root.theme
            n: root.barCount
            gap: Math.max(0, root.barGap)
            barRadius: root.barRadius
            barColor: root.barColor
            gradientTopColor: root.gradientTopColor
            gradientDirection: root.gradientDirection
            barValues: compact.barValues
            liveAlpha: root.status === "running" ? 0.85 : 0.4

            reflection: root.reflection
            reflectionRatio: root.reflectionRatio
            reflectionBlur: root.reflectionBlur
            lineWidth: root.lineWidth
            lineGlow: root.lineGlow
            peakCaps: root.peakCaps
            segmented: root.barStyle === 1
        }
    }

    fullRepresentation: Item {
        implicitWidth: 360
        implicitHeight: 140
        Column {
            anchors.centerIn: parent
            spacing: 6
            Text {
                color: Kirigami.Theme.textColor
                text: root.device
                    ? i18n("Device: %1", root.device)
                    : i18n("No device selected — open Configure.")
                wrapMode: Text.WordWrap
            }
            Text {
                color: Kirigami.Theme.textColor
                opacity: 0.7
                text: root.logPath ? i18n("Log: %1", root.logPath) : ""
                font.pixelSize: 10
            }
            Text {
                color: Kirigami.Theme.textColor
                opacity: 0.7
                text: i18n("Status: %1", root.status)
                font.pixelSize: 10
            }
        }
    }

    toolTipMainText: i18n("Wavebar")
    toolTipSubText: root.device ? root.device : i18n("No device selected")
}
