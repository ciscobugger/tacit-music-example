// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit
import "Format.js" as Format

// Artists: one row each with how many albums, and the jump index at the right. An artist opens as its own page.
// The accent mark shows where the playing music lives; the list does not open or move because of it.
LibraryPage {
    id: page
    here: "Artists"

    RowList {
        id: list
        x: Kit.tokens.space.l
        // the list's measure, or less in a narrow window: never under the jump index
        width: Math.min(Kit.tokens.width.list, parent.width - x - index.width - 2 * Kit.tokens.space.s)
        height: parent.height
        model: Library.artists
        delegate: LibraryRow {
            id: row
            required property var modelData
            readonly property bool playing: modelData.name === Player.current?.artist

            owner: list
            picture: modelData.cover
            glyph: "artist"
            name: modelData.name
            facts: [Format.count(modelData.albums.length, "album")]
            factWidths: [list.factWidth]
            current: playing
            PlayingMark { visible: row.playing; anchors.rightMargin: Kit.tokens.space.l + list.factWidth }
        }
        readonly property int factWidth: 108
        onActivated: i => Nav.go("artist", Library.artists[i].name)
    }
    JumpIndex {
        id: index
        anchors { right: parent.right; rightMargin: Kit.tokens.space.s; top: parent.top; topMargin: Kit.tokens.space.s
                  bottom: parent.bottom; bottomMargin: Kit.tokens.space.s }
        present: Library.artists.map(a => a.name[0].toUpperCase())
        onJump: mark => {
            const i = Library.artists.findIndex(a => a.name.toUpperCase().startsWith(mark));
            list.moveTo(i, "select");
            list.view.positionViewAtIndex(i, ListView.Beginning);
        }
    }
}
