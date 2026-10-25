// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit

// What every library page shares: the header (back, forward, the path as the title, Search Music), the player bar at
// the foot, and the two states of an empty library. The page's own content goes inside. Typing in the search
// covers the whole library and replaces the content until the field is empty again.
Item {
    id: page

    property var crumbs: []
    property string parentPage: "artists"      // where the first crumb leads
    property string here
    default property alias content: body.data
    readonly property bool empty: Library.songs.length === 0 && !Library.loading

    Connections {
        target: Nav
        function onSearchRequested() { search.forceActiveFocus(); search.selectAll(); }
    }

    PageHeader {
        id: header
        width: parent.width
        crumbs: page.crumbs
        here: page.here
        canGoBack: Nav.canBack
        canGoForward: Nav.canForward
        loading: Library.loading
        onBack: Nav.back()
        onForward: Nav.forward()
        onCrumbPicked: Nav.go(page.parentPage)
        SearchField {
            id: search
            anchors.verticalCenter: parent.verticalCenter
            scope: "Music"
            onDismissed: page.forceActiveFocus()
            onDown: results.forceActiveFocus()
        }
    }

    Item {
        id: body
        anchors { top: header.bottom; bottom: bar.top; left: parent.left; right: parent.right }
        visible: !page.empty && search.text === ""
    }
    SongList {
        id: results
        anchors { top: header.bottom; bottom: bar.top; left: parent.left; leftMargin: Kit.tokens.space.l
                  right: parent.right; rightMargin: Kit.tokens.space.l }
        visible: !page.empty && search.text !== ""
        songs: search.text === "" ? [] : Library.find(search.text)
        onActivated: i => Player.playFrom(songs, i)
    }
    PageState {
        x: Kit.tokens.space.xl + Kit.tokens.space.l
        anchors.top: header.bottom
        anchors.topMargin: Kit.tokens.space.xxl
        visible: page.empty
        text: "No music in your Music folder yet. Add some, or listen to the sample to try the app."
        action: "Play the sample"
        onActivated: Player.playFrom([Player.sample], 0)
    }
    PlayerBar {
        id: bar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
    }
}
