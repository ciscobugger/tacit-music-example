// SPDX-License-Identifier: MIT
import QtQuick

// An album's own page, "Albums > Name": its header and its songs.
LibraryPage {
    id: page
    crumbs: ["Albums"]
    here: Nav.here.title
    parentPage: "albums"

    AlbumList {
        id: list
        albums: Library.albums.filter(a => a.key === Nav.here.arg)
        heading: AlbumHeader { width: list.rowWidth; album: Library.albums.find(a => a.key === Nav.here.arg) }
    }
}
