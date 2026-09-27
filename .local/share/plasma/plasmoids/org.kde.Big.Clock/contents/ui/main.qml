/*
    SPDX-FileCopyrightText: 2022 qewer33
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import "js/Texts.js" as Texts

PlasmoidItem {
    id: root
    preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    property string fontsiser: root.height/4.5
    property int customAlignment: plasmoid.configuration.position
    property int maxWidth: Math.max(year.implicitWidth, day.implicitWidth, dayshortNum.implicitWidth, mes.implicitWidth, time.implicitWidth)

    property string codelang: ((Qt.locale().name)[0] + (Qt.locale().name)[1])

    function eliminateZero(x) {
        return x[0] === "0" ? x[1] : x;
    }


    FontLoader {
    id: fontB
    source: "../fonts/LeagueGothic-Condensed.ttf"
    }
          ColumnLayout {
             id:  datefull
             height: root.height
             width: maxWidth < root.width ? root.width : maxWidth
             Column {
                 id: firstcolumnR
                 width: maxWidth
                 height: parent.height
                 spacing: -fontsiser*0.35
                 anchors.right: parent.right
                 visible: (customAlignment === 0)
                 Kirigami.Heading {
                     id: year
                     width: parent.width
                     text: Qt.formatDateTime(new Date(), "yyyy")
                     font.family: fontB.name
                     font.pixelSize: fontsiser
                     color: Plasmoid.configuration.customColor
                     horizontalAlignment: Text.AlignRight

                 }
                 Kirigami.Heading {
                     id: day
                     width: parent.width
                     text: Texts.getDayWeekText(codelang, (new Date()).getDay());
                     font.family: fontB.name
                     font.pixelSize: fontsiser
                     font.capitalization: Font.AllUppercase
                     color: Plasmoid.configuration.customColor
                     horizontalAlignment: Text.AlignRight
                 }
                 Kirigami.Heading {
                     id: dayshortNum
                     width: parent.width
                     text: Qt.formatDateTime(new Date(), "d")
                     font.family: fontB.name
                     font.pixelSize: fontsiser
                     color: Plasmoid.configuration.customColor
                     horizontalAlignment: Text.AlignRight
                 }
                 Kirigami.Heading {
                     id: mes
                     width: parent.width
                     text: Texts.getMonthText(codelang, eliminateZero(Qt.formatDateTime(new Date(), "MM")) - 1)
                     font.family: fontB.name
                     color: Plasmoid.configuration.customColor
                     font.pixelSize: fontsiser
                     horizontalAlignment: Text.AlignRight
                     font.capitalization: Font.AllUppercase

                 }
                 Row {
                     id: time
                     spacing: 0
                     width: horas.implicitWidth + minutos.implicitWidth
                     Layout.alignment: Qt.AlignRight
                     anchors.right: parent.right
                     Kirigami.Heading {
                         id: horas
                         text: ((((Qt.formatDateTime(new Date(), "h ap:")).replace(/a./g, "")).replace(/m./g, "")).replace(/p/g, ":")).replace(/\s{2,}/g, "")
                         color: Plasmoid.configuration.customColor
                         font.family: fontB.name
                         font.pixelSize: fontsiser
                     }
                     Kirigami.Heading {
                         id: minutos
                         text: Qt.formatDateTime(new Date(), "mm")
                         font.family: fontB.name
                         color: Plasmoid.configuration.accetColor
                         font.pixelSize: fontsiser
                     }
                 }
            }
            Column {
                id: firstcolumnL
                width: maxWidth
                height: parent.height
                spacing: -fontsiser*0.35
                visible: (customAlignment === 1)
                Kirigami.Heading {
                    id: yearL
                    width: parent.width
                    text: year.text
                    font.family: fontB.name
                    font.pixelSize: fontsiser
                    color: Plasmoid.configuration.customColor
                    horizontalAlignment: Text.AlignLeft

                }
                Kirigami.Heading {
                    id: dayL
                    width: parent.width
                    text: day.text
                    font.family: fontB.name
                    font.pixelSize: fontsiser
                    font.capitalization: Font.AllUppercase
                    color: Plasmoid.configuration.customColor
                    horizontalAlignment: Text.AlignLeft
                }
                Kirigami.Heading {
                    id: dayshortNumL
                    width: parent.width
                    text: dayshortNum.text
                    font.family: fontB.name
                    font.pixelSize: fontsiser
                    color: Plasmoid.configuration.customColor
                    horizontalAlignment: Text.AlignLeft
                }
                Kirigami.Heading {
                    id: mesL
                    width: parent.width
                    text: mes.text
                    font.family: fontB.name
                    color: Plasmoid.configuration.customColor
                    font.pixelSize: fontsiser
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.AllUppercase

                }
                Row {
                    id: timeL
                    spacing: 0
                    width: horas.implicitWidth + minutos.implicitWidth
                    Layout.alignment: Qt.AlignLeft
                    anchors.left: parent.left
                    Kirigami.Heading {
                        id: horasL
                        text: horas.text
                        color: Plasmoid.configuration.customColor
                        font.family: fontB.name
                        font.pixelSize: fontsiser
                    }
                    Kirigami.Heading {
                        id: minutosL
                        text: minutos.text
                        font.family: fontB.name
                        color: Plasmoid.configuration.accetColor
                        font.pixelSize: fontsiser
                    }
                }
            }

            Timer {
            interval: 10000 // Intervalo de actualización en milisegundos (1 segundo en este caso)
            running: true
            repeat: true
            onTriggered: {
                horas.text = ((((Qt.formatDateTime(new Date(), "h ap:")).replace(/a./g, "")).replace(/m./g, "")).replace(/p/g, ":")).replace(/\s{2,}/g, "")
                minutos.text = Qt.formatDateTime(new Date(), "mm")
                mes.text = Texts.getMonthText(codelang, eliminateZero(Qt.formatDateTime(new Date(), "MM")) - 1)
                dayshortNum.text = Qt.formatDateTime(new Date(), "d")
                day.text = Texts.getDayWeekText(codelang, (new Date()).getDay());
                year.text = Qt.formatDateTime(new Date(), "yyyy")
            }

        }
        }
            }



