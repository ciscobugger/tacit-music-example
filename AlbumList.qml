// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit
import "Format.js" as Format

// The songs of one or more albums as one list, so the arrows pass from album to album. The tracks are rows with their
// number before the name and the length at the end; the playing song carries the accent mark and its waveform.
// `heading` is the page's own heading, scrolling with the list. With `blocks` each album stands as a block: its cover on
// the left and, beside it, its name, year and tracks (Apple Music's layout), the blocks apart by space alone.
RowList {
    id: list

    property var albums: []
    property bool blocks: false
    property Component heading
    readonly property var songs: Library.songsOf(albums)
    readonly property int factWidth: 64
    readonly property int digits: String(Math.max(...songs.map(s => s.track))).length
    readonly property int blockCover: 160
    readonly property int indent: blocks ? blockCover + Kit.tokens.space.l : 0   // where the tracks start

    x: Kit.tokens.space.page - Kit.tokens.space.l
    width: parent.width - 2 * x
    height: parent.height
    model: songs
    view.header: heading
    section.property: blocks ? "albumKey" : ""
    section.criteria: ViewSection.FullString
    section.delegate: Item {
        id: block
        readonly property var album: list.albums.find(a => a.key === section)
        // tall enough that a short album still clears its cover
        height: Kit.tokens.space.xxl + Math.max(Kit.tokens.height.richRow, list.blockCover - Kit.tokens.height.row * (album?.songs.length ?? 0))
        width: list.rowWidth

        Cover {
            x: Kit.tokens.space.l
            y: Kit.tokens.space.xxl
            width: list.blockCover; height: width
            corner: Kit.tokens.radius.slab
            source: block.album?.cover ?? ""
        }
        Column {
            x: list.indent + 52   // over the track numbers
            y: Kit.tokens.space.xxl
            TacitText { text: block.album?.name ?? ""; size: "section"; weight: "medium" }
            TacitText { text: block.album?.year ?? ""; ink: "meta" }
        }
    }
    onActivated: i => Player.playFrom(songs, i)
    // a heading that grows as its text is laid out leaves the list scrolled past it
    Connections {
        target: list.view.headerItem
        function onHeightChanged() { list.view.positionViewAtBeginning(); }
    }

    // each row stands in an item of the list's width, so the blocks' tracks can start beside their cover
    delegate: Item {
        id: slot
        required property var modelData
        required property int index

        width: list.rowWidth
        height: Kit.tokens.height.row

        LibraryRow {
            id: row
            readonly property bool playing: slot.modelData.path === Player.current?.path && !failed
            readonly property bool failed: slot.modelData.path === Player.failedPath

            index: slot.index
            owner: list
            x: list.indent
            width: slot.width - list.indent
            lead: slot.modelData.track > 0 ? String(slot.modelData.track) : ""
            leadFigures: list.digits
            name: slot.modelData.name
            facts: [Format.duration(slot.modelData.seconds)]
            factWidths: [list.factWidth]
            current: playing
            accessory: [
                Symbol { visible: row.failed; text: "warning"; color: Kit.tokens.risk },
                Waveform {
                    visible: row.playing
                    anchors.verticalCenter: parent.verticalCenter
                    width: 200; height: 20
                    bar: 2
                    seekable: false
                    peaks: Player.peaks
                    position: Player.position
                },
                Symbol { visible: row.playing; text: "graphic_eq"; color: Kit.tokens.accent }
            ]
        }
    }
}
