// SPDX-License-Identifier: MIT
import QtQuick
import Quickshell.Io
import Tacit.Kit
import "Format.js" as Format
import "Lrc.js" as Lrc

// Lyrics, a stage page with a way back. The words come from the .lrc file next to the song (same name, `.lrc`): the
// line being sung in the main ink, the lines to come in the quiet ink, the lines sung in the past ink.
Item {
    id: page

    property var lines: []
    readonly property int line: Lrc.lineAt(lines, Player.seconds)

    FileView {
        path: Player.current ? Player.current.path.replace(/\.[^./]*$/, ".lrc") : ""
        printErrors: false
        onLoaded: page.lines = Lrc.parse(text())
        onLoadFailed: page.lines = []
    }

    Row {
        x: Kit.tokens.space.l
        height: Kit.tokens.height.header
        spacing: Kit.tokens.space.s
        IconButton { anchors.verticalCenter: parent.verticalCenter; symbol: "arrow_back"; size: Kit.tokens.icon.nav; label: "Back to Playing"; onActivated: Nav.go("playing") }
        TacitText { anchors.verticalCenter: parent.verticalCenter; text: "Playing"; ink: "sec" }
    }

    Column {
        id: song
        x: Kit.tokens.space.page * 3
        y: Kit.tokens.space.page * 3 + Kit.tokens.space.xl
        width: 380
        spacing: Kit.tokens.space.l
        Cover {
            width: parent.width; height: width
            corner: Kit.tokens.radius.slab
            source: Player.current?.cover ?? ""
        }
        Column {
            width: parent.width
            TacitText { width: parent.width; text: Player.current?.name ?? ""; size: "section"; cut: "display"; weight: "medium"; elide: Text.ElideRight }
            TacitText { text: Player.current?.artist ?? ""; ink: "sec" }
        }
        Waveform {
            width: parent.width
            peaks: Player.peaks
            position: Player.position
            onSeek: at => Player.seek(at)
        }
        Item {
            width: parent.width; height: elapsed.height
            TacitText { id: elapsed; text: Format.duration(Player.seconds); size: "meta"; ink: "sec"; cut: "numbers" }
            TacitText {
                anchors.right: parent.right
                text: "-" + Format.duration((Player.current?.seconds ?? 0) - Player.seconds)
                size: "meta"; ink: "sec"; cut: "numbers"
            }
        }
        Transport {
            anchors.horizontalCenter: parent.horizontalCenter
            playing: Player.playing
            canNext: Player.index + 1 < Player.queue.length
            onPrevious: Player.previous()
            onPlayPause: Player.toggle()
            onNext: Player.next()
        }
    }

    ListView {
        id: words
        anchors { left: song.right; leftMargin: Kit.tokens.space.page * 2; right: parent.right; rightMargin: Kit.tokens.space.page
                  top: parent.top; topMargin: Kit.tokens.height.header; bottom: parent.bottom }
        clip: true
        model: page.lines
        currentIndex: page.line
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: height * 0.28
        preferredHighlightEnd: height * 0.28 + Kit.tokens.height.richRow
        highlightMoveDuration: Kit.tokens.motion.arrive.ms
        topMargin: height * 0.28
        bottomMargin: height * 0.5
        delegate: TacitText {
            required property var modelData
            required property int index
            width: words.width
            height: implicitHeight + Kit.tokens.space.xxl
            text: modelData.text
            size: "headline"
            weight: index === page.line ? "medium" : "regular"
            ink: index === page.line ? "main" : index < page.line ? "past" : "quiet"
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }
    }
    PageState {
        visible: page.lines.length === 0
        anchors { left: song.right; leftMargin: Kit.tokens.space.page * 2; top: parent.top; topMargin: Kit.tokens.height.header + Kit.tokens.space.xxl }
        text: "No lyrics for this song. Put an .lrc file with the same name next to it."
    }
}
