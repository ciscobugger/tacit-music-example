// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Effects
import Tacit.Kit

// A cover with the kit's corner for pictures. Where there is none: the container colour and a note.
Item {
    id: cover

    property url source: ""
    property real corner: Kit.tokens.radius.art

    Image {
        id: picture
        visible: false
        anchors.fill: parent
        source: cover.source
        sourceSize: Qt.size(cover.width * 2, cover.height * 2)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle {
        id: mask
        visible: false
        anchors.fill: parent
        radius: cover.corner
        layer.enabled: true
    }
    MultiEffect {
        anchors.fill: parent
        visible: picture.status === Image.Ready
        source: picture
        maskEnabled: true
        maskSource: mask
    }
    Rectangle {
        anchors.fill: parent
        visible: picture.status !== Image.Ready
        radius: cover.corner
        color: Kit.tokens.container
        Symbol {
            anchors.centerIn: parent
            text: "music_note"
            size: Math.round(cover.width / 3)
        }
    }
}
