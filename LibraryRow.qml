// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit

// A ListRow wired to the RowList that holds it (`owner`): selection, the keyboard ring, clicks and Enter. Every
// list in the app makes its rows from this, so each delegate only says what is in the row.
ListRow {
    required property int index
    property var owner

    width: owner.rowWidth
    focusable: false                        // the list is the one tab stop
    selected: owner.isSelected(index)
    ring: owner.ringAt(index)
    joinAbove: owner.isSelected(index - 1)
    joinBelow: owner.isSelected(index + 1)
    onClicked: m => owner.clickAt(index, m)
    onActivated: owner.activated(index)
    onContextRequested: at => owner.contextRequested(index, at)
}
