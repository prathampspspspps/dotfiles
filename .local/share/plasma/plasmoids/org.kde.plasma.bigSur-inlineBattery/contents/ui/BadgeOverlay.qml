/***************************************************************************
 *   Copyright (C) 2016 Kai Uwe Broulik <kde@privat.broulik.de>            *
 *   Copyright (C) 2016 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    property alias text: label.text
    property Item icon

    Rectangle {
        id: badgeRect
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        color: PlasmaCore.ColorScope.backgroundColor
        width: Math.max(Kirigami.Units.gridUnit, label.width + Screen.devicePixelRatio * 2)
        height: label.height
        radius: Screen.devicePixelRatio * 3
        opacity: 0.9
    }

    PlasmaComponents.Label {
        id: label
        anchors.centerIn: badgeRect
        height: paintedHeight
    }

    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 0
        radius: Screen.devicePixelRatio * 2
        samples: radius*2
        color: Qt.rgba(0, 0, 0, 0.5)
    }
}
