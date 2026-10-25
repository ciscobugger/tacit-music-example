// SPDX-License-Identifier: MIT
import QtQuick
import Tacit.Kit
import "Format.js" as Format

// Playing, a stage page: the cover, the song as the subject at display size, the transport at 64, the waveform with
// its playhead, and what plays next and what played before as rows. At half width it keeps one column.
Item {
    id: page

    readonly property bool compact: width < 900
    readonly property int coverSize: compact ? 160 : Math.max(232, Math.min(320, width - 900))
    readonly property int margin: Kit.tokens.space.page

    Slab {
        anchors { top: parent.top; right: parent.right; margins: Kit.tokens.space.xl }
        text: "Lyrics"
        onActivated: Nav.go("lyrics")
    }

    Cover {
        id: cover
        x: page.margin
        y: 64
        width: page.coverSize; height: page.coverSize
        corner: Kit.tokens.radius.slab
        source: Player.current?.cover ?? ""
    }
    Column {
        x: cover.x + cover.width + Kit.tokens.space.xxl
        y: cover.y
        width: parent.width - x - page.margin
        TacitText {
            width: parent.width
            text: Player.current?.name ?? "Nothing playing"
            size: page.compact ? "alarm" : "display"; cut: "display"; weight: "medium"
            elide: Text.ElideRight
        }
        TacitText { text: Player.current?.artist ?? ""; size: "section"; weight: "medium" }
        TacitText { text: Player.current ? [Player.current.album, Player.current.year].filter(s => s).join(", ") : ""; ink: "sec" }
    }
    Transport {
        id: transport
        x: cover.x + cover.width + Kit.tokens.space.xxl
        y: cover.y + cover.height - height
        size: page.compact ? 52 : 64
        playing: Player.playing
        canPrevious: Player.current !== null
        canNext: Player.index + 1 < Player.queue.length
        onPrevious: Player.previous()
        onPlayPause: Player.toggle()
        onNext: Player.next()
    }
    Row {
        visible: !page.compact
        anchors { right: parent.right; rightMargin: page.margin; verticalCenter: transport.verticalCenter }
        spacing: Kit.tokens.space.s
        Symbol { anchors.verticalCenter: parent.verticalCenter; text: "volume_up" }
        Slider { width: 160; value: Player.volume; label: "Volume"; onMoved: v => Player.volume = v }
    }

    Waveform {
        id: wave
        x: page.margin
        y: cover.y + cover.height + Kit.tokens.space.xxl + Kit.tokens.space.s
        width: parent.width - 2 * page.margin
        height: 120
        playhead: true
        peaks: Player.peaks
        position: Player.position
        onSeek: at => Player.seek(at)
    }
    TacitText {
        x: wave.x; y: wave.y + wave.height + Kit.tokens.space.xl
        text: Format.duration(Player.seconds)
        ink: "sec"; cut: "numbers"
    }
    TacitText {
        x: wave.x + wave.width - width; y: wave.y + wave.height + Kit.tokens.space.xl
        text: "-" + Format.duration((Player.current?.seconds ?? 0) - Player.seconds)
        ink: "sec"; cut: "numbers"
    }

    readonly property real queueTop: wave.y + wave.height + Kit.tokens.space.xl + 2 * Kit.tokens.space.xxl
    readonly property real column: compact ? width - 2 * (margin - Kit.tokens.space.l)
                                           : (width - 2 * (margin - Kit.tokens.space.l) - Kit.tokens.space.page) / 2

    SectionHeading { x: page.margin - Kit.tokens.space.l; y: page.queueTop; text: "Up next" }
    SongList {
        x: page.margin - Kit.tokens.space.l
        y: page.queueTop + 50 + Kit.tokens.space.s
        width: page.column
        height: page.height - y - Kit.tokens.space.xl
        songs: Player.upNext
        onActivated: i => Player.skipTo(Player.index + 1 + i)
    }
    SectionHeading { visible: !page.compact; x: page.margin - Kit.tokens.space.l + page.column + Kit.tokens.space.page; y: page.queueTop; text: "Played before" }
    SongList {
        visible: !page.compact
        x: page.margin - Kit.tokens.space.l + page.column + Kit.tokens.space.page
        y: page.queueTop + 50 + Kit.tokens.space.s
        width: page.column
        height: page.height - y - Kit.tokens.space.xl
        songs: Player.history.map(h => Object.assign({}, h.song, { played: h.at }))
        fact: song => Format.when(song.played)
        factWidth: 108
        onActivated: i => Player.playFrom([songs[i]].concat(Player.upNext), 0)
    }
}
