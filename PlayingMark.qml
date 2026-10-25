// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit

// The accent mark in a row whose music is playing, just before the row's facts. A row adds it as a child; the
// list under it never moves because of playback.
Symbol {
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    text: "graphic_eq"
    color: Kit.tokens.accent
}
