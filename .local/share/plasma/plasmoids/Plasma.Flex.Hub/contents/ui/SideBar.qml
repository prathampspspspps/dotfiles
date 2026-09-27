/*
 S *PDX-FileCopyrightText: zayronxio
 SPDX-License-Identifier: 2025 GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Controls
import "lib" as Lib
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "js/manager.js" as Manager

Item {
    id: wrapper

    property int max_x: 0
    property int max_y: 0
    property int lastRow: 2
    property int widthFactor: Kirigami.Units.gridUnit * 4
    property int heightFactor: Kirigami.Units.gridUnit * 4
    property int spacing: Kirigami.Units.gridUnit / 2
    property int ajustWidthX: width + 10
    property int factorX: spacing + widthFactor
    property int factorY: spacing + heightFactor
    property var gridsFilled: []

    property var namesByCustom: []
    property var arrayDinamic: []
    property alias desingModel: gridModel

    property var gridsX: [
        spacing - ajustWidthX,
        factorX + spacing - ajustWidthX,
        (factorX * 2) + spacing - ajustWidthX,
        (factorX * 3) + spacing - ajustWidthX
    ]
    property var gridsY: []

    signal readyModel
    signal close

    // ─── Inicialización ───────────────────────────────────────────────────────

    Component.onCompleted: {
        secondModel()
        createGridsY()
        Manager.autoOrganizer(namesModel)
    }

    function createGridsY() {
        gridsY = []
        var rowForFuct = lastRow + 2
        for (var y = 0; y < rowForFuct; y++) {
            gridsY.push(factorY * y + spacing)
        }
        // FIX: eliminado console.log de producción
    }

    // FIX: verificar duplicados antes de agregar al namesModel
    // (ocurre cuando SideBar se destruye y recrea porque sideBarLoader
    // usa sourceComponent: sideBarEnabled ? sideBarComponent : null)
    function secondModel() {
        var customNames = Plasmoid.configuration.customControlNames
        for (var u = 0; u < customNames.length; u++) {
            var alreadyExists = false
            for (var j = 0; j < namesModel.count; j++) {
                if (namesModel.get(j).elementId === customNames[u]) {
                    alreadyExists = true
                    break
                }
            }
            if (!alreadyExists) {
                namesModel.append({
                    name:           customNames[u],
                    elementId:      customNames[u],
                    w:              parseInt(Plasmoid.configuration.customControlWidths[u]),
                                  h:              parseInt(Plasmoid.configuration.customControlHeights[u]),
                                  isCustomControl: true
                })
            }
        }
    }

    // ─── Modelos ──────────────────────────────────────────────────────────────

    Model {
        id: namesModel
    }

    ListModel {
        id: customControlModel
    }

    ListModel {
        id: readyModel
    }

    ListModel {
        id: gridModel
    }

    Component {
        id: customControl
        Lib.CustomControl {}
    }

    // ─── UI ───────────────────────────────────────────────────────────────────

    Flickable {
        id: fli
        width: parent.width
        height: parent.height
        contentWidth: parent.width
        contentHeight: Math.max(parent.height, rectRepeater.count * (heightFactor + spacing))
        clip: true
        // FIX: activar scroll vertical con rueda y touch
        flickableDirection: Flickable.VerticalFlick
        interactive: true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        Repeater {
            id: rectRepeater
            model: readyModel

            delegate: Loader {
                id: rect
                source:          model.isCustomControl ? undefined : model.source
                sourceComponent: model.isCustomControl ? customControl : undefined

                property int originalX: model.x * widthFactor + model.x * spacing + spacing
                property int originalY: model.y * heightFactor + model.y * spacing + spacing
                property int elements: 0

                onLoaded: {
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

                // Badge de contador de usos
                Rectangle {
                    width:  22
                    height: 22
                    color: Kirigami.Theme.highlightColor
                    radius: height / 2
                    visible: elements !== 0
                    opacity: 0.8
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin:  -Kirigami.Units.smallSpacing
                    anchors.rightMargin: -Kirigami.Units.smallSpacing
                    z: 2
                    Text {
                        width: parent.width
                        height: parent.height
                        font.bold: true
                        text: elements
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: parent

                    onEntered: {
                        const globalPos = rect.mapToItem(null, rect.x, rect.y)
                        rect.parent = wrapper
                        const newLocalPos = rect.mapFromItem(null, globalPos.x, globalPos.y)
                        rect.x = newLocalPos.x
                        rect.y = newLocalPos.y
                    }

                    onReleased: {
                        function resetPosition() {
                            rect.parent = rectRepeater
                            rect.x = originalX
                            rect.y = originalY
                        }

                        const realx = rect.x
                        const realy = rect.y

                        if (realx > (-max_x - 10) && realx < 10 && realy > 0 && realy < max_y) {
                            var maxX = Manager.findClosest(gridsX, realx)
                            var maxY = Manager.findClosest(gridsY, realy)

                            if (Manager.isSpaceAvailable(maxX, maxY, model.w, model.h)) {
                                gridModel.append({
                                    w:             model.w,
                                    h:             model.h,
                                    isCustomControl: model.isCustomControl ? model.isCustomControl : false,
                                    indexOrigin:   model.indexOrigin,
                                    elementId:     model.elementId,
                                    source:        model.source,
                                    x:             maxX,
                                    y:             maxY
                                })

                                elements = elements + 1
                                Manager.addedGridsFilled(maxX, maxY, model.h, model.w)

                                // FIX: usar maxY + model.h para rastrear filas correctamente
                                // (antes usaba model.x que es la columna — bug lógico)
                                if ((maxY + model.h) > lastRow) {
                                    lastRow = maxY + model.h
                                }

                                createGridsY()
                                wrapper.readyModel()
                            }
                        }
                        resetPosition()
                    }
                }
            }
        }
    }

    // Botón cerrar sidebar
    Rectangle {
        width:  24
        height: 24
        color: Kirigami.Theme.backgroundColor
        radius: height / 2
        z: 3

        Kirigami.Icon {
            width:  22
            height: 22
            source: "arrow-left-symbolic"
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: close()
        }
    }
}
