// SPDX-License-Identifier: MIT
pragma Singleton
import QtQuick
import Quickshell

// Where the window is: a stack of pages with a place in it, so Back and Forward work as in Files. A page is
// { page, arg, title }: "artist" carries the artist's name, "album" the album's key and its title.
Singleton {
    id: nav

    property var stack: [{ page: "artists", arg: "", title: "" }]
    property int at: 0

    readonly property var here: stack[at]
    readonly property bool canBack: at > 0
    readonly property bool canForward: at < stack.length - 1
    // the rail row a page belongs to
    readonly property string place: ({ playing: "playing", artists: "artists", artist: "artists", albums: "albums", album: "albums",
                                       songs: "songs", recent: "recent" })[here.page] ?? ""
    readonly property bool inLibrary: place !== "" && place !== "playing"

    signal searchRequested()

    function go(page, arg = "", title = "") {
        stack = stack.slice(0, at + 1).concat([{ page, arg, title }]);
        at = stack.length - 1;
    }
    function back() { if (canBack) at--; }
    function forward() { if (canForward) at++; }
}
