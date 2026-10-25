// SPDX-License-Identifier: MIT
import QtQuick
import Quickshell
import Tacit.Kit

// The Music example: the window, the rail and the page. Run with  qs -p shell.qml  and Tacit.Kit on QML_IMPORT_PATH.
FloatingWindow {
    id: window

    // the rail folds when the window is half width, or when its toggle says so
    property var folding: null
    readonly property bool folded: folding ?? width < 900

    title: "Music"
    implicitWidth: 1280
    implicitHeight: 820
    color: "transparent"

    Item {
        id: app
        anchors.fill: parent
        focus: true

        Rectangle {
            anchors.fill: parent
            radius: Kit.tokens.radius.window
            color: Qt.alpha(Kit.tokens.windowGround, 1 - Kit.tokens.windowSeeThrough)
        }

        // keys no list or button wanted: Space plays and pauses, the arrows seek, Ctrl+F searches
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Space) Player.toggle();
            else if (event.key === Qt.Key_Left && Player.current) Player.seek(Math.max(0, Player.position - 5 / Player.current.seconds));
            else if (event.key === Qt.Key_Right && Player.current) Player.seek(Math.min(1, Player.position + 5 / Player.current.seconds));
            else if (event.key === Qt.Key_F && event.modifiers & Qt.ControlModifier) {
                if (!Nav.inLibrary) Nav.go("songs");
                Nav.searchRequested();
            } else return;
            event.accepted = true;
        }

        Rail {
            id: rail
            height: parent.height
            visible: Nav.here.page !== "lyrics"
            folded: window.folded
            action: "Shuffle all"
            actionSymbol: "shuffle"
            onToggle: window.folding = !window.folded
            onActionActivated: if (Library.songs.length > 0) Player.shuffle(Library.songs)

            RailRow { glyph: "graphic_eq"; label: "Playing"; current: Nav.place === "playing"; onPicked: Nav.go("playing") }
            RailSection { text: "Library" }
            Repeater {
                model: [
                    { glyph: "artist", label: "Artists", page: "artists", count: Library.artists.length },
                    { glyph: "note_stack", label: "Albums", page: "albums", count: Library.albums.length },
                    { glyph: "music_note", label: "Songs", page: "songs", count: Library.songs.length },
                    { glyph: "schedule", label: "Recently added", page: "recent", count: 0 }
                ]
                RailRow {
                    required property var modelData
                    glyph: modelData.glyph
                    label: modelData.label
                    context: modelData.count > 0 ? String(modelData.count) : ""
                    current: Nav.place === modelData.page
                    onPicked: Nav.go(modelData.page)
                }
            }
        }

        Loader {
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right; left: rail.visible ? rail.right : parent.left }
            source: ({ playing: "PlayingPage.qml", lyrics: "LyricsPage.qml", artists: "ArtistsPage.qml", artist: "ArtistPage.qml",
                       albums: "AlbumsPage.qml", album: "AlbumPage.qml", songs: "SongsPage.qml", recent: "RecentPage.qml" })[Nav.here.page]
        }
    }

    // the test hook tools/render.sh drives; nothing here runs without MUSIC_SCENE
    Loader {
        active: !!Quickshell.env("MUSIC_SCENE")   // unset is undefined, not ""
        source: "tools/Scene.qml"
        onLoaded: item.window = window
    }
}
