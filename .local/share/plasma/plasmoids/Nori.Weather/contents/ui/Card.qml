import QtQuick
import org.kde.ksvg 1.0 as KSvg
import Qt5Compat.GraphicalEffects


Item {
    property int marginLeft: maskSvg2.marg
    property color leftColor: "red"

    Grid {
        id: maskSvg2
        width: parent.width
        height: parent.height
        //visible: false
        columns: 2
        property var marg: topleft2.implicitWidth

        KSvg.SvgItem {
            id: topleft2
            imagePath: "dialogs/background"
            elementId: "topleft"
        }
        KSvg.SvgItem {
            id: top2
            imagePath: "dialogs/background"
            elementId: "top"
            width: parent.width - topleft2.implicitWidth *1
        }

        KSvg.SvgItem {
            id: left2
            imagePath: "dialogs/background"
            elementId: "left"
            height: parent.height - topleft2.implicitHeight*2
        }
        KSvg.SvgItem {
            imagePath: "dialogs/background"
            elementId: "center"
            height: parent.height - topleft2.implicitHeight*2
            width: top2.width
        }

        KSvg.SvgItem {
            id: bottomleft2
            imagePath: "dialogs/background"
            elementId: "bottomleft"
        }
        KSvg.SvgItem {
            id: bottom2
            imagePath: "dialogs/background"
            elementId: "bottom"
            width: parent.width - bottomleft2.implicitWidth
        }
    }

    Rectangle {
        color: leftColor //Kirigami.Theme.highlightColor
        width: maskSvg2.width
        height: maskSvg2.height
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: maskSvg2
        }
    }
    Rectangle {
        color: leftColor //Kirigami.Theme.highlightColor
        width: maskSvg2.width
        height: maskSvg2.height
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: maskSvg2
        }
    }

    KSvg.SvgItem {
        anchors.right: maskSvg2.right
        imagePath: "widgets/line"
        elementId: "vertical-line"
        height: parent.height
    }
}
