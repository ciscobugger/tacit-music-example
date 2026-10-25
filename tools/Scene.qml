// SPDX-License-Identifier: MIT
import QtQuick
import Quickshell
import ".."

// The test hook for tools/render.sh: shell.qml loads this only when MUSIC_SCENE is set. It waits for the library to
// be read, puts the app into the named scene (a page, a song at a place in it), saves the window to MUSIC_OUT and quits.
Item {
    id: scene

    property var window
    property int waited: 0
    property real seekTo: -1
    readonly property string name: Quickshell.env("MUSIC_SCENE")
    readonly property string out: Quickshell.env("MUSIC_OUT")

    // the first item under the window with this property, for the one thing the app has no handle on (the search field)
    function find(item, property) {
        if (item[property] !== undefined) return item;
        for (const child of item.children) {
            const found = find(child, property);
            if (found) return found;
        }
        return null;
    }
    function play(songName, seconds) {
        const i = Library.songs.findIndex(s => s.name === songName);
        for (let k = Math.max(0, i - 3); k < i; k++) Player.playFrom(Library.songs, k);
        Player.playFrom(Library.songs, i);
        seekTo = seconds / Library.songs[i].seconds;
    }
    onWindowChanged: {
        const [w, h] = (Quickshell.env("MUSIC_SIZE") || "1520x920").split("x");
        window.implicitWidth = Number(w);
        window.implicitHeight = Number(h);
    }
    function arrange() {
        switch (name) {
        case "playing": play("Undertow", 116); Nav.go("playing"); break;
        case "half": play("Undertow", 116); Nav.go("playing"); break;
        case "lyrics": play("Undertow", 116); Nav.go("lyrics"); break;
        case "artists": play("Undertow", 116); break;
        case "artist": play("Undertow", 116); Nav.go("artist", "Mara Velde"); break;
        case "album": {
            const album = Library.albums.find(a => a.key === Library.songs.find(s => s.name === "Undertow").albumKey);
            play("Undertow", 116);
            Nav.go("album", album.key, album.name);
            break;
        }
        case "albums": play("Undertow", 116); Nav.go("albums"); break;
        case "songs": play("Undertow", 116); Nav.go("songs"); break;
        case "recent": play("Undertow", 116); Nav.go("recent"); break;
        case "search": play("Undertow", 116); Nav.go("songs"); find(window.contentItem, "scope").text = "tide"; break;
        case "cantplay":
            const gone = Library.songs.findIndex(s => s.name === "Undertow");
            Library.songs[gone].path += ".gone";   // the file is gone when the player opens it
            Player.playFrom(Library.songs, gone);
            Nav.go("artist", "Mara Velde");
            break;
        }
    }
    function grab() {
        window.contentItem.children[0].grabToImage(result => { result.saveToFile(out); Qt.quit(); });
    }

    Timer {
        interval: 250; repeat: true; running: true
        onTriggered: if (++scene.waited > 3 && !Library.loading) { running = false; scene.arrange(); seek.start(); }
    }
    // a song cannot be sought before it is loaded
    Timer { id: seek; interval: 1200; onTriggered: { if (scene.seekTo >= 0) Player.seek(scene.seekTo); shot.start(); } }
    Timer { id: shot; interval: 700; onTriggered: scene.grab() }
}
