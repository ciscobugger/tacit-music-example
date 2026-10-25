// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit

// Songs: every song, by artist and album. Enter plays from that song on.
LibraryPage {
    here: "Songs"

    SongList {
        x: Kit.tokens.space.l
        width: parent.width - 2 * Kit.tokens.space.l
        height: parent.height
        songs: Library.songs
        onActivated: i => Player.playFrom(songs, i)
    }
}
