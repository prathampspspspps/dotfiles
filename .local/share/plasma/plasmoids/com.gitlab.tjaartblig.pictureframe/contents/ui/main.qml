/*
 *  SPDX-FileCopyrightText: 2015 Lars Pontoppidan <dev.larpon@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs

import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kquickcontrolsaddons 2.0
import QtQuick.Effects

import org.kde.plasma.private.mediaframe 2.0

PlasmoidItem {
    id: main

    MediaFrame {
        id: items
        random: plasmoid.configuration.randomize
    }

    preferredRepresentation: fullRepresentation

    switchWidth: Kirigami.Units.gridUnit * 5
    switchHeight: Kirigami.Units.gridUnit * 5

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    width: Kirigami.Units.gridUnit * 20
    height: Kirigami.Units.gridUnit * 13

    property string activeSource: ""
    property string transitionSource: ""

    readonly property bool pause: overlayMouseArea.containsMouse

    readonly property int itemCount: (items.count + items.futureLength)
    readonly property bool hasItems: ((itemCount > 0) || (items.futureLength > 0))
    readonly property bool isTransitioning: faderAnimation.running

    onActiveSourceChanged: {
        items.watch(activeSource)
    }

    onHasItemsChanged: {
        if(hasItems) {
            if(activeSource == "")
                nextItem()
        }
    }

    onExternalData: (mimetype, data) => {
        var type = items.isDir(data) ? "folder" : "file";
        var item = {
            "path": data,
            "type": type
        };

        addItem(item);
    }

    function loadPathList() {
        var list = plasmoid.configuration.pathList
        items.clear()
        for(var i in list) {
            var item = JSON.parse(list[i])
            items.add(item.path,true)
        }
    }

    Component.onCompleted: {
        loadPathList()

        if (items.random)
            nextItem()
    }

    Connections {
        target: plasmoid.configuration
        function onPathListChanged() {
            loadPathList()
        }
    }

    function addItem(item) {

        if(items.isAdded(item.path)) {
            console.info(item.path,"already exists. Skipping…")
            return
        }
        // work-around for QTBUG-67773:
        // C++ object property of type QVariant(QStringList) is not updated on changes from QML
        // so explicitly create a deep JSValue copy, modify that and then set it back to overwrite the old
        var updatedList = plasmoid.configuration.pathList.slice();
        updatedList.push(JSON.stringify(item));
        plasmoid.configuration.pathList = updatedList;
    }

    function nextItem() {

        if(!hasItems) {
            console.warn("No items available")
            return
        }

        var active = activeSource

        // Only record history if we have more than one item
        if(itemCount > 1)
            items.pushHistory(active)

        if(items.futureLength > 0) {
            setActiveSource(items.popFuture())
        } else {
            //setLoading()
            items.get(function(filePath){
                setActiveSource(filePath)
                //unsetLoading()
            },function(errorMessage){
                //unsetLoading()
                console.error("Error while getting next image",errorMessage)
            })
        }
    }

    function previousItem() {
        var active = activeSource
        items.pushFuture(active)
        var filePath = items.popHistory()
        setActiveSource(filePath)
    }

    Connections {
        target: items

        function onItemChanged(path) {
            console.log("item",path,"changed")
            activeSource = ""
            setActiveSource(path)
        }

    }

    Timer {
        id: nextTimer
        interval: (plasmoid.configuration.interval*1000)
        repeat: true
        running: hasItems && !pause
        onTriggered: nextItem()
    }

    Item {
        id: itemView
        anchors.fill: parent


        Item {
            id: imageView
            visible: hasItems
            anchors.fill: parent

            Image {
                id: bufferImage




                anchors.centerIn: parent
                opacity: 0

                cache: false
                source: transitionSource

                 width: parent.height * bufferImage.sourceSize.width > parent.width * bufferImage.sourceSize.height ? parent.width : parent.height * bufferImage.sourceSize.width / bufferImage.sourceSize.height
                height: width * bufferImage.sourceSize.height / bufferImage.sourceSize.width

                visible: false
                layer.enabled: true

                asynchronous: true
                autoTransform: true
            }


            Image {
                    id: frontImage
                    // manual implementation of 1920:1080 preserve aspect fit ...
                    width: parent.height * frontImage.sourceSize.width > parent.width * frontImage.sourceSize.height ? parent.width : parent.height * frontImage.sourceSize.width / frontImage.sourceSize.height
                    height: width * frontImage.sourceSize.height / frontImage.sourceSize.width

                    anchors.centerIn: parent
                    source: activeSource
                    visible: false
                    layer.enabled: true
                }

                MultiEffect {
                    id: a
                        source: frontImage
                        anchors.fill: frontImage
                        anchors.centerIn: parent
                        maskEnabled: true
                        maskSource: mask
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                    }

                                    MultiEffect {
                    id: b
                        source: bufferImage
                        anchors.fill: bufferImage
                        anchors.centerIn: parent
                        maskEnabled: true
                        maskSource: mask
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                    }


            Item {
                id: mask
                width: parent.height * frontImage.sourceSize.width > parent.width * frontImage.sourceSize.height ? parent.width : parent.height * frontImage.sourceSize.width / frontImage.sourceSize.height
                height: width * frontImage.sourceSize.height / frontImage.sourceSize.width
                anchors.fill: frontImage
                layer.enabled: true
                layer.smooth: true
                visible: false
                Rectangle {
                    anchors.fill: parent
                    radius: 15
                }
            }

        }
    }

    function setActiveSource(source) {
        if(itemCount > 1) { // Only do transition if we have more that one item
            transitionSource = source
            faderAnimation.restart()
        } else {
            transitionSource = source
            activeSource = source
        }
    }

    SequentialAnimation {
        id: faderAnimation

        SequentialAnimation {
            OpacityAnimator { target: a; from: 1; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutExpo }
            OpacityAnimator { target: b; from: 0; to: 1; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.InExpo }
        }
        ScriptAction {
            script: {
                // Copy the transitionSource
                var ts = transitionSource
                activeSource = ts
                a.opacity = 1
                transitionSource = ""
                b.opacity = 0
            }
        }
    }

    DragDrop.DropArea {
        id: dropArea
        anchors.fill: parent

        onDrop: {
            var mimeData = event.mimeData
            if (mimeData.hasUrls) {
                var urls = mimeData.urls
                for (var i = 0, j = urls.length; i < j; ++i) {
                    var url = urls[i]
                    var type = items.isDir(url) ? "folder" : "file"
                    var item = { "path":url, "type":type }
                    addItem(item)
                }
            }
            event.accept(Qt.CopyAction)
        }
    }

    Item {
        id: overlay

        anchors.fill: parent

        visible: hasItems
        opacity: overlayMouseArea.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation {}
        }

        PlasmaComponents3.Button {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            enabled: (items.historyLength > 0) && !isTransitioning
            visible: main.itemCount > 1
            icon.name: "arrow-left"
            onClicked: {
                nextTimer.stop()
                previousItem()
            }
        }

        PlasmaComponents3.Button {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            enabled: hasItems && !isTransitioning
            visible: main.itemCount > 1
            icon.name: "arrow-right"
            onClicked: {
                nextTimer.stop()
                nextItem()
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: Kirigami.Units.smallSpacing

            PlasmaComponents3.Button {

                icon.name: "document-preview"
                onClicked: Qt.openUrlExternally(main.activeSource)

            }
        }

        // BUG TODO Fix overlay so _all_ mouse events reach lower components
        MouseArea {
            id: overlayMouseArea
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            //onClicked: mouse => mouse.accepted = false;
            onPressed: mouse => mouse.accepted = false;
            //onReleased: mouse => mouse.accepted = false;
            onDoubleClicked: mouse => mouse.accepted = false;
            //onPositionChanged: mouse => mouse.accepted = false;
            //onPressAndHold: mouse => mouse.accepted = false;
        }
    }

    PlasmaComponents3.Button {

        anchors.centerIn: parent

        visible: !hasItems
        icon.name: "configure"
        text: i18nc("@action:button", "Configure…")
        onClicked: {
            Plasmoid.internalAction("configure").trigger();
        }
    }
}
