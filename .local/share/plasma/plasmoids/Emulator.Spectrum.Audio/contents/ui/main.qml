import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid

import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg

PlasmoidItem {
    id: root
    width: 500
    height: 250
    Plasmoid.backgroundHints: "NoBackground"

    Item  {
        width: parent.width
        height: parent.height

        Item {
            id: wrapper
            width: parent.width //(parent.height * 3) > parent.width ? parent.width : parent.height * 3
            height: parent.height
            anchors.centerIn: parent

            SpectrumBars {
                id: bar
                width: parent.width
                height: parent.height
                plasmoidwidth: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                //anchors.left: parent.left
                //anchors.leftMargin: (parent.width - bar.implicitWidth)/2
                anchors.top: info.bottom
                anchors.topMargin: 15
                colorBars: Kirigami.Theme.textColor
            }
        }
    }


}
