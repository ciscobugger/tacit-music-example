// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit

// Albums: large covers with the name and the artist under each. An album opens as its own page.
LibraryPage {
    here: "Albums"

    CoverGrid {
        x: Kit.tokens.space.page
        y: Kit.tokens.space.xl
        width: parent.width - 2 * Kit.tokens.space.page
        height: parent.height - y
        readonly property var albums: Library.albums
        items: albums.map(a => ({ source: a.cover, title: a.name, subtitle: a.artist, current: a.key === Player.current?.albumKey }))
        glyph: "music_note"
        onActivated: i => Nav.go("album", albums[i].key, albums[i].name)
    }
}
