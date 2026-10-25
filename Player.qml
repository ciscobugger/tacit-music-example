// SPDX-License-Identifier: MIT
pragma Singleton
import QtQuick
import QtMultimedia
import Quickshell

// What is playing and what comes next. One queue of songs and a place in it; the song before the current one goes to
// the history when the place moves on. Nothing here changes the pages: they read `current`, `upNext` and `history`.
Singleton {
    id: player

    property var queue: []
    property int index: -1
    property var history: []            // { song, at }, the latest first
    property var peaks: []              // 0 to 1, as many as the waveform folds into its bars
    property string failedPath: ""      // the song that could not be played, if any
    property string failure: ""
    property real volume: 0.8

    readonly property var current: queue[index] ?? null
    readonly property var upNext: queue.slice(index + 1)
    readonly property bool playing: media.playbackState === MediaPlayer.PlayingState
    readonly property bool failed: current !== null && current.path === failedPath
    readonly property real seconds: media.position / 1000 || 0
    readonly property real position: current && current.seconds > 0 ? Math.min(1, seconds / current.seconds) : 0
    readonly property var sample: ({ path: Quickshell.shellPath("sample/Sample.mp3"), name: "Sample", artist: "Tacit",
                                     album: "Sample", seconds: 24, cover: "", dir: Quickshell.shellPath("sample") })

    function playFrom(songs, at) {
        remember();
        queue = songs;
        index = at;
        start();
    }
    function shuffle(songs) {
        const mixed = songs.slice();
        for (let i = mixed.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [mixed[i], mixed[j]] = [mixed[j], mixed[i]];
        }
        playFrom(mixed, 0);
    }
    function skipTo(at) {
        remember();
        index = at;
        start();
    }
    function remember() {
        if (current) history = [{ song: current, at: new Date() }].concat(history);
    }
    function start() {
        failedPath = "";
        media.source = "file://" + current.path;
        media.play();
        peaks = [];
        const song = current;
        // the peaks of a song are kept in the cache; 600 of them is more than any window has bars
        helper.run(["sh", "-c", peaksScript, "sh", `${Library.cache}/peaks/${Qt.md5(song.path)}`, song.path,
                    String(Math.max(1, Math.round(song.seconds * 8000 / 600)))], text => {
            if (player.current === song) player.peaks = peaksOf(text);
        });
    }
    function next() { if (index + 1 < queue.length) skipTo(index + 1); }
    function previous() {
        if (seconds > 3 || index === 0) seek(0);
        else skipTo(index - 1);
    }
    function toggle() { if (current) playing ? media.pause() : media.play(); }
    function seek(fraction) { media.position = fraction * current.seconds * 1000; }

    // the loudest sample of each stretch, in decibels (ffmpeg's astats), as 0 to 1
    readonly property string peaksScript: `
        [ -s "$1" ] || ffmpeg -nostdin -v error -i "$2" -af "aresample=8000,asetnsamples=n=$3,astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.Peak_level:file=-" -f null - 2>/dev/null | grep Peak_level > "$1"
        cat "$1"`
    function peaksOf(text) {
        const levels = text.split("\n").filter(l => l !== "").map(l => Math.pow(10, Number(l.split("=")[1]) / 20) || 0);
        const loudest = Math.max(...levels, 0.001);
        return levels.map(l => Math.pow(l / loudest, 0.7));
    }

    Jobs { id: helper; workers: 1 }
    MediaPlayer {
        id: media
        audioOutput: AudioOutput { volume: player.volume; muted: Quickshell.env("MUSIC_MUTED") === "1" }
        onMediaStatusChanged: if (mediaStatus === MediaPlayer.EndOfMedia) player.next()
        onErrorOccurred: (error, message) => {
            player.failedPath = player.current.path;
            player.failure = error === MediaPlayer.ResourceError ? "It was moved or deleted from " + Library.relative(player.current.dir) + "." : message;
        }
    }
}
