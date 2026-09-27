/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
//import QtQuick.Controls 2.15
//import QtQuick.Effects

Item {
    id: main

    property int plasmoidWidV: 0
    property int plasmoidWidH: 0

    onVisibleChanged: {
        root.visible = !root.visible
    }

    KSvg.FrameSvgItem {
        id : backgroundSvg

        visible: false

        imagePath: "dialogs/background"
    }


    Plasmoid.status: root.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    PlasmaCore.Dialog {
        id: root

        objectName: "popupWindow"
        flags: Qt.WindowStaysOnTopHint
        location: PlasmaCore.Types.Floating
        hideOnWindowDeactivate: true

        onHeightChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        onWidthChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        function toggle() {
            main.visible = !main.visible;
        }

        onVisibleChanged: {
            if (visible) {
                var pos = popupPosition(width, height);
                x = pos.x;
                y = pos.y;

                //animation1.start()
            }
        }


        function popupPosition(width, height) {
            var screenAvail = wrapper.availableScreenRect;
            var screen = wrapper.screenGeometry;
            var panelH = wrapper.height
            var panelW = wrapper.width
            var horizMidPoint = screen.x + (screen.width / 2);
            var vertMidPoint = screen.y + (screen.height / 2);
            var appletTopLeft = parent.mapToGlobal(0, 0);

            function calculatePosition(x, y) {
                return Qt.point(x, y);
            }

            switch (plasmoid.location) {
                case PlasmaCore.Types.BottomEdge:
                    var x = appletTopLeft.x < (screen.width - width/2 + backgroundSvg.margins.left + Kirigami.Units.gridUnit) ? appletTopLeft.x < ((width/2) + backgroundSvg.margins.left) ? Kirigami.Units.gridUnit -  backgroundSvg.margins.left : appletTopLeft.x - width/2  : screen.width - (width - backgroundSvg.margins.left*2) - Kirigami.Units.gridUnit ;
                    var y = appletTopLeft.y - height - Kirigami.Units.gridUnit
                    return calculatePosition(x, y);

                case PlasmaCore.Types.TopEdge:
                    x = appletTopLeft.x < (width/2 + backgroundSvg.margins.left + Kirigami.Units.gridUnit) ? backgroundSvg.margins.left : appletTopLeft.x > (screen.width - (width/2) - backgroundSvg.margins.left - Kirigami.Units.gridUnit) ? screen.width - width - backgroundSvg.margins.left : appletTopLeft.x - width/2 - backgroundSvg.margins.left
                    y = appletTopLeft.y + panelH + Kirigami.Units.gridUnit
                    return calculatePosition(x, y);

                case PlasmaCore.Types.LeftEdge:
                    x = appletTopLeft.x + panelW + Kirigami.Units.gridUnit / 2;
                    y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : appletTopLeft.y - height + iconUser.height / 2;
                    return calculatePosition(x, y);

                case PlasmaCore.Types.RightEdge:
                    x = appletTopLeft.x - width - Kirigami.Units.gridUnit / 2;
                    y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : screen.height - height - Kirigami.Units.gridUnit / 5;
                    return calculatePosition(x, y);

                default:
                    return;
            }
        }
        FocusScope {
            id: rootItem
            Layout.minimumWidth:  Kirigami.Units.gridUnit * 20
            Layout.maximumWidth:  minimumWidth
            Layout.minimumHeight: Kirigami.Units.gridUnit * 9 // 170
            Layout.maximumHeight: minimumHeight
            focus: true

            FullContainer {
                id: fullContainer
                leftPanelMargin: backgroundSvg.margins.left
                topPanelMargin: backgroundSvg.margins.top
                exedentHight: backgroundSvg.margins.top + backgroundSvg.margins.bottom
                widthOfLeftPanel: 130
                width: widthOfLeftPanel
                height: parent.height
            }
            ItemForecasts {
                width: parent.width - fullContainer.width
                height: parent.height
                anchors.left: fullContainer.right
            }
       }
    }
}
