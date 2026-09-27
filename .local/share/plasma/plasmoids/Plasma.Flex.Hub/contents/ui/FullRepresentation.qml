/*
 S *PDX-FileCopyrightText: zayronxio
 SPDX-License-Identifier: 2025 GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components
import "pages" as Pages
import org.kde.ksysguard.sensors as Sensors
import "lib" as Lib

Item {
    id: root

    // ─── Brightness dynamic loader ────────────────────────────────────────────
    property string code: ""
    property var control: null  // FIX: inicializar explícitamente a null

    property string sourceBrightnessPlasma64orPlusQml: `
    import QtQuick
    import "components" as Components
    Components.SourceBrightnessPlasma64orPlus {
        id: dynamic
    }
    `
    property string sourceBrightnessQML: `
    import QtQuick
    import "components" as Components
    Components.SourceBrightness {
        id: dynamic
    }
    `

    Sensors.SensorDataModel {
        id: plasmaVersionModel
        sensors: ["os/plasma/plasmaVersion"]
        enabled: true

        onDataChanged: {
            // FIX: evitar memory leak — solo crear el control una vez
            if (control !== null && control !== undefined) return

                const value = data(index(0, 0), Sensors.SensorDataModel.Value);
            if (value !== undefined && value !== null) {
                code = (value.indexOf("6.4") >= 0)
                ? sourceBrightnessPlasma64orPlusQml
                : sourceBrightnessQML;
                control = Qt.createQmlObject(code, root, "control");
                plasmaVersionModel.enabled = false  // FIX: deshabilitar sensor tras usarlo
            }
        }
    }

    // ─── Constantes de texto ──────────────────────────────────────────────────
    TextConstants {
        id: textConstants
    }

    // ─── Estado del modelo ────────────────────────────────────────────────────
    property var listElements: []
    property var list_y: []
    property var list_x: []
    property var listCustomControls: []
    property var listControlsX: []
    property var listControlsY: []

    property int mainLastRow: 0

    // ─── Dimensiones ─────────────────────────────────────────────────────────
    property bool sideBarEnabled: false
    property int widthFactor: Kirigami.Units.gridUnit * 4
    property int heightFactor: Kirigami.Units.gridUnit * 4
    property int footer_height: 32
    property int spacing: Kirigami.Units.gridUnit / 2
    property int factorX: spacing + widthFactor
    property int factorY: spacing + heightFactor

    // FIX: propiedades de ancho calculadas una sola vez, reutilizadas en todo el archivo
    readonly property int defaultWidth:  widthFactor * 4 + spacing * 5
    readonly property int expandedWidth: widthFactor * 8 + spacing * 11

    property var mainGridsFilled: []
    property int rows: gridModel.count > 0 ? lastR() : 2
    property int exedent: sideBarEnabled ? 2 : 0
    property int heightF: (rows + exedent) * factorY + footer_height

    property int generalMargin: heightFactor / 2
    property int miniIconsSize: 22

    property var namesCustomControls: Plasmoid.configuration.customControlNames
    property string nameTh: Plasmoid.configuration.selected_theme
    property var page: ""

    // ─── Layout ───────────────────────────────────────────────────────────────
    Layout.preferredWidth:  sideBarEnabled ? expandedWidth : defaultWidth
    Layout.preferredHeight: heightF
    Layout.minimumWidth:  Layout.preferredWidth
    Layout.maximumWidth:  Layout.preferredWidth
    Layout.minimumHeight: Layout.preferredHeight
    Layout.maximumHeight: Layout.preferredHeight

    // ─── Handlers de cambio ───────────────────────────────────────────────────

    onRowsChanged: {
        calculateHeight()
    }

    // FIX: unificar onSideBarEnabledChanged (antes había un `onSideBarEnabled` separado
    // que nunca disparaba porque no existe esa señal — la lógica de updateHeight()
    // se perdía silenciosamente)
    onSideBarEnabledChanged: {
        const w = sideBarEnabled ? expandedWidth : defaultWidth
        Layout.preferredWidth  = w
        Layout.minimumWidth    = w
        Layout.maximumWidth    = w
        Layout.preferredHeight = heightF
        updateHeight()  // FIX: movido aquí desde el handler huérfano
    }

    onNameThChanged: {
        updateModel()
    }

    onPageChanged: {
        leftPanel.visible = (page === "")
    }

    // ─── Modelos ──────────────────────────────────────────────────────────────
    Model {
        id: namesModel
    }

    ListModel {
        id: gridModel
    }

    // ─── Lógica principal ─────────────────────────────────────────────────────

    Component.onCompleted: {
        updateModel()
        rows = gridModel.count > 0 ? lastR() : 2
    }

    function updateModel() {
        gridModel.clear()
        mainGridsFilled = []

        listElements       = Plasmoid.configuration.elements
        list_y             = Plasmoid.configuration.yElements
        list_x             = Plasmoid.configuration.xElements
        listCustomControls = Plasmoid.configuration.listCustomControls
        listControlsX      = Plasmoid.configuration.listControlsX
        listControlsY      = Plasmoid.configuration.listControlsY

        for (var v = 0; v < listElements.length; v++) {
            var entry = namesModel.get(listElements[v])
            if (!entry) {
                console.warn("FullRepresentation: elemento no encontrado en namesModel, índice:", listElements[v])
                continue
            }
            gridModel.append({
                elementId:     entry.elementId,
                w:             entry.w,
                indexOrigin:   listElements[v],
                h:             entry.h,
                source:        entry.source,
                isCustomControl: false,
                x:             parseInt(list_x[v]),
                             y:             parseInt(list_y[v]),
                             loadFailed:    false   // FIX: campo de estado de carga
            })
            if (entry.elementId === "weather1") activeWeather = true
                addedGridsFilled(parseInt(list_x[v]), parseInt(list_y[v]), entry.h, entry.w)
        }

        for (var y = 0; y < listCustomControls.length; y++) {
            var dinamicArray = Plasmoid.configuration.customControlNames
            var ind = dinamicArray.indexOf(listCustomControls[y])
            if (ind === -1) {
                console.warn("FullRepresentation: customControl no encontrado:", listCustomControls[y])
                continue
            }
            gridModel.append({
                elementId:      listCustomControls[y],
                w:              Plasmoid.configuration.customControlWidths[ind] === "1" ? 1 : 2,
                indexOrigin:    listCustomControls[y],
                h:              1,
                source:         "",
                isCustomControl: true,
                x:              parseInt(listControlsX[y]),
                             y:              parseInt(listControlsY[y]),
                             loadFailed:     false   // FIX: campo de estado de carga
            })
            addedGridsFilled(
                parseInt(listControlsX[y]),
                             parseInt(listControlsY[y]),
                             Plasmoid.configuration.customControlHeights[ind],
                             Plasmoid.configuration.customControlWidths[ind]
            )
        }

        calculateHeight()
    }

    function addedGridsFilled(x, y, h, w) {
        for (var z = 0; z < h; z++) {
            for (var i = 0; i < w; i++) {
                var value = (y + z) + " " + (x + i)
                mainGridsFilled.push(value)
            }
        }
    }

    // FIX: nueva función — libera las celdas de un elemento fallido del mapa de ocupación
    // para que esa zona vuelva a estar disponible para nuevos controles
    function releaseGridCells(x, y, h, w) {
        for (var z = 0; z < h; z++) {
            for (var i = 0; i < w; i++) {
                var value = (y + z) + " " + (x + i)
                var idx = mainGridsFilled.indexOf(value)
                if (idx !== -1) {
                    mainGridsFilled.splice(idx, 1)
                }
            }
        }
    }

    // FIX: llamada cuando un Loader reporta error — libera celdas y marca el elemento
    // para que el usuario pueda ver cuál falló y la zona quede disponible
    function handleLoadFailure(modelIndex, gridX, gridY, h, w, indexOrigin, isCustomControl) {
        console.warn("FullRepresentation: fallo al cargar componente en posición",
                     gridX, gridY, "— liberando celdas ocupadas")

        // Liberar las celdas en el mapa de colisión
        releaseGridCells(gridX, gridY, h, w)

        // Marcar el elemento en el modelo para mostrar placeholder visual
        if (modelIndex >= 0 && modelIndex < gridModel.count) {
            gridModel.setProperty(modelIndex, "loadFailed", true)
        }

        // También eliminar de las listas de configuración persistida
        // para que al reiniciar el plasmoid ya no intente cargar el elemento roto
        if (!isCustomControl) {
            for (var k = 0; k < listElements.length; k++) {
                if (listElements[k] === indexOrigin) {
                    listElements.splice(k, 1)
                    list_y.splice(k, 1)
                    list_x.splice(k, 1)
                    break
                }
            }
        } else {
            for (var t = 0; t < listCustomControls.length; t++) {
                if (listCustomControls[t] === indexOrigin) {
                    listCustomControls.splice(t, 1)
                    listControlsX.splice(t, 1)
                    listControlsY.splice(t, 1)
                    break
                }
            }
        }

        updateConfigs()
    }

    function updateConfigs() {
        Plasmoid.configuration.elements          = listElements
        Plasmoid.configuration.yElements         = list_y
        Plasmoid.configuration.xElements         = list_x
        Plasmoid.configuration.selected_theme    = "Custom"
        Plasmoid.configuration.listCustomControls = listCustomControls
        Plasmoid.configuration.listControlsX     = listControlsX
        Plasmoid.configuration.listControlsY     = listControlsY
    }

    function calculateHeight() {
        exedent = sideBarEnabled ? 2 : 0
        // FIX: llamar lastR() una sola vez y reutilizar el valor
        let value = lastR()
        rows    = value !== 0 ? value : 2
        heightF = (rows + exedent) * factorY + footer_height
        Layout.preferredHeight = heightF
        Layout.minimumHeight   = heightF
        Layout.maximumHeight   = heightF
    }

    function updateHeight() {
        exedent = sideBarEnabled ? 2 : 0
        heightF = (rows + exedent) * factorY + footer_height
        Layout.preferredHeight = heightF
        Layout.minimumHeight   = heightF
        Layout.maximumHeight   = heightF
    }

    // FIX: comparación numérica correcta (antes era lexicográfica con strings,
    // causando que "9" > "10" evaluara como true)
    function lastR() {
        let row = 0
        for (var u = 0; u < mainGridsFilled.length; u++) {
            let numbers = mainGridsFilled[u].split(" ")
            let n = parseInt(numbers[0])  // FIX: parsear a entero antes de comparar
            if (n > row) {
                row = n
            }
        }
        return (row + 1)
    }

    function removeItem(item, h, w) {
        for (var k = 0; k < listElements.length; k++) {
            if (listElements[k] === item) {
                for (var z = 0; z < h; z++) {
                    for (var i = 0; i < w; i++) {
                        var value = (parseInt(list_y[k]) + z) + " " + (parseInt(list_x[k]) + i)
                        var index = mainGridsFilled.indexOf(value)
                        if (index !== -1) {
                            mainGridsFilled.splice(index, 1)
                        }
                    }
                }
                listElements.splice(k, 1)
                list_y.splice(k, 1)
                list_x.splice(k, 1)
                updateConfigs()
                return  // FIX: salir tras encontrar el elemento para evitar splice con índices desplazados
            }
        }
        for (var t = 0; t < listCustomControls.length; t++) {
            if (listCustomControls[t] === item) {
                for (var z = 0; z < h; z++) {
                    for (var i = 0; i < w; i++) {
                        var value = (parseInt(listControlsY[t]) + z) + " " + (parseInt(listControlsX[t]) + i)
                        var index = mainGridsFilled.indexOf(value)
                        if (index !== -1) {
                            mainGridsFilled.splice(index, 1)
                        }
                    }
                }
                listCustomControls.splice(t, 1)
                listControlsY.splice(t, 1)
                listControlsX.splice(t, 1)
                updateConfigs()
                return  // FIX: salir tras encontrar el elemento
            }
        }
    }

    // ─── UI ───────────────────────────────────────────────────────────────────

    // Botón inferior "Editar"
    Rectangle {
        height: Kirigami.Units.iconSizes.small + 8
        width: txtEdith.implicitWidth + Kirigami.Units.iconSizes.small
        radius: height / 2
        color: "transparent"
        visible: !sideBarEnabled
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: root.horizontalCenter

        Rectangle {
            height: parent.height
            width: parent.width
            radius: height / 2
            color: "transparent"
            anchors.centerIn: parent
            border.color: "transparent"
            opacity: 0.3
        }
        Kirigami.Heading {
            id: txtEdith
            text: textConstants.edit
            width: parent.width
            height: parent.height
            color: Kirigami.Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            level: 5
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                sideBarEnabled = true
                rows = rows + 2
            }
        }
    }

    // Loader de páginas internas (Network, Bluetooth, etc.)
    Loader {
        id: pageLoader
        source: page
        width: parent.width
        height: parent.height
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 600 } }

        onLoaded: {
            if (page !== "") opacity = 1
        }
        onStatusChanged: {
            if (status === Loader.Error) {
                page = ""
                opacity = 0
                leftPanel.visible = true
            }
        }
    }

    Component {
        id: customControl
        Lib.CustomControl {}
    }

    // Panel principal de controles
    Item {
        id: leftPanel
        // FIX: usar defaultWidth en lugar de parent.width/2
        // (con sidebar activo parent.width es expandedWidth, dando ancho incorrecto)
        width: defaultWidth
        height: rows * factorY

        Repeater {
            model: gridModel
            delegate: Loader {
                id: rect
                source:          model.isCustomControl ? undefined : model.source
                sourceComponent: model.isCustomControl ? customControl : undefined

                // ── Carga exitosa ─────────────────────────────────────────────
                onLoaded: {
                    if (item && item.hasOwnProperty("mouseAreaActive")) {
                        item.mouseAreaActive = true
                    }
                    if (model.isCustomControl) {
                        var dinamicArray = Plasmoid.configuration.customControlNames
                        var ind = dinamicArray.indexOf(model.elementId)
                        item.isButton      = Plasmoid.configuration.customControlEnabledButton[ind] === "true"
                        item.icon          = Plasmoid.configuration.customControlIcons[ind]
                        item.controlTitle  = model.elementId
                        item.enabledIcon   = Plasmoid.configuration.customControlEnabledIcons[ind] === "true"
                        item.exeCommand    = Plasmoid.configuration.customControlCommand[ind]
                        item.isPercentage  = Plasmoid.configuration.customControlIsPercentage[ind] === "true"
                        item.isLarge       = !item.isButton
                        item.subTitle      = Plasmoid.configuration.customControlSubTitle[ind]
                        item.idSensor      = Plasmoid.configuration.customControlIdSensor[ind]
                    }
                    width  = widthFactor  * model.w + spacing * (model.w - 1)
                    height = heightFactor * model.h + spacing * (model.h - 1)
                    x = model.x * widthFactor + model.x * spacing + spacing
                    y = model.y * heightFactor + model.y * spacing + spacing
                }

                // ── FIX: Carga fallida ────────────────────────────────────────
                // Cuando el QML del componente no puede cargarse (archivo faltante,
                // error de sintaxis, dependencia rota) se libera la zona del grid
                // y se muestra un placeholder para avisar al usuario.
                onStatusChanged: {
                    if (status === Loader.Error) {
                        console.warn("FullRepresentation: error cargando", model.source,
                                     "en posición [", model.x, ",", model.y, "]")

                        // Posicionar el placeholder en la celda correspondiente
                        width  = widthFactor  * model.w + spacing * (model.w - 1)
                        height = heightFactor * model.h + spacing * (model.h - 1)
                        x = model.x * widthFactor + model.x * spacing + spacing
                        y = model.y * heightFactor + model.y * spacing + spacing

                        // Liberar celdas en el mapa de colisión y limpiar configuración
                        handleLoadFailure(
                            model.index,
                            model.x,
                            model.y,
                            model.h,
                            model.w,
                            model.indexOrigin,
                            model.isCustomControl
                        )
                    }
                }

                // ── Placeholder visual para elemento fallido ──────────────────
                Rectangle {
                    anchors.fill: parent
                    // Solo visible si el Loader falló
                    visible: rect.status === Loader.Error || model.loadFailed
                    color: Qt.rgba(
                        Kirigami.Theme.negativeTextColor.r,
                        Kirigami.Theme.negativeTextColor.g,
                        Kirigami.Theme.negativeTextColor.b,
                        0.12
                    )
                    radius: Kirigami.Units.cornerRadius
                    border.color: Kirigami.Theme.negativeTextColor
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: Kirigami.Units.smallSpacing

                        Kirigami.Icon {
                            width:  Kirigami.Units.iconSizes.small
                            height: Kirigami.Units.iconSizes.small
                            source: "dialog-warning-symbolic"
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Kirigami.Theme.negativeTextColor
                        }
                        Text {
                            text: qsTr("Error")
                            color: Kirigami.Theme.negativeTextColor
                            font.pixelSize: Kirigami.Units.gridUnit * 0.65
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    // Al hacer clic en el placeholder se elimina definitivamente
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Las celdas ya fueron liberadas en handleLoadFailure,
                            // solo queda quitar el delegate del modelo visual
                            gridModel.remove(model.index)
                            calculateHeight()
                        }
                    }
                }

                // Botón cerrar (modo edición)
                Kirigami.Icon {
                    width:  24
                    height: 24
                    source: "dialog-close-symbolic"
                    visible: sideBarEnabled
                    z: 5
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            removeItem(model.indexOrigin, model.h, model.w)
                            gridModel.remove(model.index)
                        }
                    }
                }
            }
        }
    }

    // SideBar (carga diferida)
    Loader {
        id: sideBarLoader
        sourceComponent: sideBarEnabled ? sideBarComponent : null
        anchors.right: parent.right
        width: defaultWidth
        height: parent.height
    }

    Component {
        id: sideBarComponent
        SideBar {
            id: sideBar
            max_x: defaultWidth
            max_y: parent.height
            anchors.right: parent.right
            width: max_x
            gridsFilled: mainGridsFilled
            lastRow: rows
            height: parent.height
            opacity: 0.8

            onReadyModel: {
                var last = sideBar.desingModel.get(sideBar.desingModel.count - 1)
                gridModel.append({
                    isCustomControl: last.isCustomControl,
                    elementId:       last.elementId,
                    w:               last.w,
                    h:               last.h,
                    source:          last.source,
                    indexOrigin:     (last.indexOrigin).toString(),
                                 x:               parseInt(last.x),
                                 y:               parseInt(last.y),
                                 loadFailed:      false
                })
                if (last.elementId === "weather1") activeWeather = true

                    if (last.isCustomControl) {
                        listCustomControls.push(last.elementId)
                        listControlsX.push(parseInt(last.x))
                        listControlsY.push(parseInt(last.y))
                    } else {
                        listElements.push(last.indexOrigin)
                        list_y.push(parseInt(last.y))
                        list_x.push(parseInt(last.x))
                    }

                    updateConfigs()
                    calculateHeight()
                    Plasmoid.configuration.selected_theme = "Custom"
            }

            onClose: {
                sideBarEnabled = false
                // FIX: usar defaultWidth en lugar de repetir la expresión literal
                Layout.preferredWidth = defaultWidth
                Layout.minimumWidth   = defaultWidth
                Layout.maximumWidth   = defaultWidth
                calculateHeight()
            }
        }
    }
}
