// SPDX-License-Identifier: MIT
import QtQuick

// An artist's own page, "Artists > Name": their name, then each album as a block with its songs.
LibraryPage {
    id: page
    crumbs: ["Artists"]
    here: Nav.here.arg

    AlbumList {
        id: list
        albums: Library.albumsOf(Nav.here.arg)
        blocks: true
        heading: ArtistHeader { width: list.rowWidth; albums: Library.albumsOf(Nav.here.arg) }
    }
}
