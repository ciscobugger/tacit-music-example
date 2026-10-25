// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit
import "Format.js" as Format

// The top of an artist's page: the name as the page's subject, how much there is, and the two ways to start it.
Item {
    id: header

    property var albums: []
    readonly property var songs: Library.songsOf(albums)

    height: column.height + 2 * Kit.tokens.space.xl

    Column {
        id: column
        x: Kit.tokens.space.l
        y: Kit.tokens.space.xl
        width: header.width - 2 * x
        spacing: Kit.tokens.space.s
        TacitText {
            width: parent.width
            text: header.albums[0]?.artist ?? ""
            size: header.width < 700 ? "headline" : "display"; cut: "display"; weight: "medium"
            elide: Text.ElideRight
        }
        TacitText {
            text: Format.count(header.albums.length, "album") + ", " + Format.count(header.songs.length, "song")
            ink: "meta"
        }
        Row {
            topPadding: Kit.tokens.space.m
            spacing: Kit.tokens.space.m
            Slab { text: "Play"; tone: "default"; onActivated: Player.playFrom(header.songs, 0) }
            Slab { text: "Shuffle"; onActivated: Player.shuffle(header.songs) }
        }
    }
}
