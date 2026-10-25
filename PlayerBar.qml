// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit
import "Format.js" as Format

// The player at the foot of library pages: the song, the transport at 40, the waveform with the time on both sides,
// Lyrics and the volume. When the song cannot be played it says so, and offers the next one. The waveform keeps its
// room as the window narrows: the volume goes first, then the song's name (the cover still shows what plays).
Item {
    id: bar

    readonly property int cover: 52
    readonly property bool narrow: width < 1150   // no volume slider
    readonly property bool tight: width < 820     // no name beside the cover either

    visible: Player.current !== null
    height: visible ? Kit.tokens.height.band : 0
    Rectangle { width: parent.width; height: 1; color: Kit.tokens.hairline }

    Cover {
        id: art
        x: Kit.tokens.space.xl
        anchors.verticalCenter: parent.verticalCenter
        width: bar.cover; height: bar.cover
        source: Player.current?.cover ?? ""
    }

    Item {
        id: playing
        visible: !Player.failed
        anchors { fill: parent; leftMargin: art.x + art.width + Kit.tokens.space.l }
        Column {
            id: names
            visible: !bar.tight
            width: bar.tight ? 0 : 200
            anchors.verticalCenter: parent.verticalCenter
            TacitText { width: parent.width; text: Player.current?.name ?? ""; elide: Text.ElideRight }
            TacitText { width: parent.width; text: Player.current?.artist ?? ""; ink: "sec"; elide: Text.ElideRight }
        }
        Transport {
            id: transport
            size: 40
            anchors { left: names.right; leftMargin: bar.tight ? 0 : Kit.tokens.space.xl; verticalCenter: parent.verticalCenter }
            playing: Player.playing
            canNext: Player.index + 1 < Player.queue.length
            onPrevious: Player.previous()
            onPlayPause: Player.toggle()
            onNext: Player.next()
        }
        TacitText {
            id: elapsed
            anchors { left: transport.right; leftMargin: Kit.tokens.space.xl; verticalCenter: parent.verticalCenter }
            text: Format.duration(Player.seconds)
            ink: "sec"; cut: "numbers"
        }
        Row {
            id: volume
            anchors { right: parent.right; rightMargin: Kit.tokens.space.xl; verticalCenter: parent.verticalCenter }
            spacing: Kit.tokens.space.s
            IconButton { symbol: "lyrics"; label: "Lyrics"; onActivated: Nav.go("lyrics") }
            Symbol { visible: !bar.narrow; anchors.verticalCenter: parent.verticalCenter; text: "volume_up" }
            Slider { visible: !bar.narrow; width: 110; value: Player.volume; label: "Volume"; onMoved: v => Player.volume = v }
        }
        TacitText {
            id: total
            anchors { right: volume.left; rightMargin: Kit.tokens.space.xl; verticalCenter: parent.verticalCenter }
            text: Format.duration(Player.current?.seconds ?? 0)
            ink: "sec"; cut: "numbers"
        }
        Waveform {
            anchors { left: elapsed.right; leftMargin: Kit.tokens.space.m; right: total.left; rightMargin: Kit.tokens.space.m
                      verticalCenter: parent.verticalCenter }
            height: 36
            bar: 2
            peaks: Player.peaks
            position: Player.position
            onSeek: at => Player.seek(at)
        }
    }

    Item {
        visible: Player.failed
        anchors { fill: parent; leftMargin: art.x + art.width + Kit.tokens.space.l }
        Column {
            id: why
            anchors.verticalCenter: parent.verticalCenter
            Row {
                spacing: Kit.tokens.space.s
                Symbol { anchors.verticalCenter: parent.verticalCenter; text: "warning"; size: Kit.tokens.icon.rail; color: Kit.tokens.risk }
                TacitText { text: "Can't play " + (Player.current?.name ?? "") }
            }
            TacitText { text: Player.failure; ink: "sec" }
        }
        Slab {
            anchors { left: why.right; leftMargin: Kit.tokens.space.xl; verticalCenter: parent.verticalCenter }
            visible: Player.index + 1 < Player.queue.length
            text: "Play the next song"
            tone: "default"
            onActivated: Player.next()
        }
    }
}
