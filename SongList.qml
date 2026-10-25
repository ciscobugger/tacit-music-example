// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit
import "Format.js" as Format

// Songs as rows: cover, name, the artist beside it, a length (or whatever `fact` says) at the end. Used by Songs,
// Recently added, the search results and the queue; the page says what Enter does (onActivated).
RowList {
    id: list

    property var songs: []
    property var fact: song => Format.duration(song.seconds)
    property int factWidth: 96

    model: songs
    delegate: LibraryRow {
        id: row
        required property var modelData
        readonly property bool playing: modelData.path === Player.current?.path

        owner: list
        picture: modelData.cover
        glyph: "music_note"
        name: modelData.name
        aside: modelData.artist
        facts: [list.fact(modelData)]
        factWidths: [list.factWidth]
        current: playing
        PlayingMark { visible: row.playing; anchors.rightMargin: Kit.tokens.space.l + list.factWidth }
    }
}
