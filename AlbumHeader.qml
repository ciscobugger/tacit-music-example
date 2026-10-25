// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit
import "Format.js" as Format

// The top of an album's page: the cover, the name as the page's subject, the artist (a link to their page), the year
// and length, then the two ways to start it.
Item {
    id: header

    property var album
    readonly property bool compact: width < 700
    readonly property int coverSize: compact ? 160 : 240

    height: coverSize + 2 * Kit.tokens.space.xl

    Cover {
        id: cover
        x: Kit.tokens.space.l
        y: Kit.tokens.space.xl
        width: header.coverSize; height: width
        corner: Kit.tokens.radius.slab
        source: header.album?.cover ?? ""
    }
    Column {
        x: cover.x + cover.width + Kit.tokens.space.xxl
        y: cover.y
        width: header.width - x - Kit.tokens.space.l
        TacitText {
            width: parent.width
            text: header.album?.name ?? ""
            size: header.compact ? "headline" : "display"; cut: "display"; weight: "medium"
            wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight
        }
        InlineLink {
            text: header.album?.artist ?? ""
            size: "section"; weight: "medium"
            onActivated: Nav.go("artist", header.album.artist)
        }
        TacitText {
            text: header.album ? [header.album.year, Format.count(header.album.songs.length, "song"),
                                  Format.count(Math.round(header.album.seconds / 60), "minute")].filter(s => s).join(", ") : ""
            ink: "meta"
        }
    }
    Row {
        x: cover.x + cover.width + Kit.tokens.space.xxl
        y: cover.y + cover.height - height
        spacing: Kit.tokens.space.m
        Slab { text: "Play"; tone: "default"; onActivated: Player.playFrom(header.album.songs, 0) }
        Slab { text: "Shuffle"; onActivated: Player.shuffle(header.album.songs) }
    }
}
