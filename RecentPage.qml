// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit

// Recently added: the albums with the newest files first, as the same covers Albums has.
LibraryPage {
    here: "Recently added"

    CoverGrid {
        x: Kit.tokens.space.page
        y: Kit.tokens.space.xl
        width: parent.width - 2 * Kit.tokens.space.page
        height: parent.height - y
        readonly property var albums: [...new Set(Library.recent.map(s => s.albumKey))].map(key => Library.albums.find(a => a.key === key))
        items: albums.map(a => ({ source: a.cover, title: a.name, subtitle: a.artist, current: a.key === Player.current?.albumKey }))
        glyph: "music_note"
        onActivated: i => Nav.go("album", albums[i].key, albums[i].name)
    }
}
