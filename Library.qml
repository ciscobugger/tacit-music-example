// SPDX-License-Identifier: MIT
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "Format.js" as Format

// The music in the folder, read once at start: `find` lists the files, `ffprobe` reads each one's tags and length, a
// cover is the album folder's folder.jpg or cover.jpg, else the picture inside the first song. Songs, albums and
// artists are plain arrays the pages show as they are; they fill in while the files are being read.
Singleton {
    id: library

    readonly property string home: Quickshell.env("HOME")
    readonly property string folder: Quickshell.env("MUSIC_DIR") || home + "/Music"
    readonly property string cache: (Quickshell.env("XDG_CACHE_HOME") || home + "/.cache") + "/tacit-music-example"

    property var songs: []      // { path, name, artist, album, albumKey, track, year, seconds, added, cover }
    property var albums: []     // { key, name, artist, year, seconds, cover, songs }
    property var artists: []    // { name, cover, albums }
    property var recent: []     // the songs, newest file first
    readonly property bool loading: listing.running || reading.pending > 0
    property var probed: []
    property var covers: ({})   // album folder -> cover url

    // a folder as the owner knows it: Music/Mara Velde/Low Tide
    function relative(dir) { return "Music" + dir.slice(folder.length); }
    function fileUrl(path) { return "file://" + encodeURI(path).replace(/#/g, "%23"); }

    function albumsOf(artist) { return albums.filter(a => a.artist === artist); }
    function songsOf(albumList) { return [].concat(...albumList.map(a => a.songs)); }
    function find(query) {
        const q = query.toLowerCase();
        return songs.filter(s => `${s.name} ${s.artist} ${s.album}`.toLowerCase().includes(q));
    }

    function addSong(path, added, text) {
        let tags, seconds;
        try {
            const format = JSON.parse(text).format;
            seconds = Number(format.duration);
            tags = {};
            for (const key in format.tags) tags[key.toLowerCase()] = format.tags[key];
        } catch (e) {
            return;     // not a file ffprobe can read
        }
        const dir = path.slice(0, path.lastIndexOf("/"));
        const album = tags.album ?? "Unknown album", artist = tags.album_artist ?? tags.artist ?? "Unknown artist";
        probed.push({
            path, dir, album, artist, seconds, added,
            albumKey: artist + "\n" + album,
            name: tags.title ?? path.slice(dir.length + 1).replace(/\.[^.]*$/, ""),
            track: parseInt(tags.track ?? "0"),
            year: (tags.date ?? "").slice(0, 4),
            cover: ""
        });
        if (dir in covers) return;
        covers[dir] = "";
        reading.run(["sh", "-c", coverScript, "sh", dir, path, `${cache}/covers/${Qt.md5(dir)}.jpg`], out => {
            covers[dir] = out.trim() === "" ? "" : fileUrl(out.trim());
        });
    }

    // folder.jpg or cover.jpg next to the song, else the song's own picture saved into the cache
    readonly property string coverScript: `
        for f in "$1"/folder.* "$1"/cover.*; do
            case "$f" in *.jpg|*.jpeg|*.png) [ -f "$f" ] && echo "$f" && exit;; esac
        done
        [ -s "$3" ] || ffmpeg -nostdin -v error -y -i "$2" -an -frames:v 1 "$3" 2>/dev/null
        [ -s "$3" ] && echo "$3"`

    function rebuild() {
        const albumMap = {}, artistMap = {};
        const sorted = probed.slice().sort((a, b) => a.artist.localeCompare(b.artist) || a.album.localeCompare(b.album)
                                                  || a.track - b.track || a.name.localeCompare(b.name));
        for (const song of sorted) {
            song.cover = covers[song.dir] ?? "";
            if (!(song.albumKey in albumMap))
                albumMap[song.albumKey] = { key: song.albumKey, name: song.album, artist: song.artist,
                                            year: song.year, seconds: 0, cover: song.cover, songs: [] };
            const album = albumMap[song.albumKey];
            album.songs.push(song);
            album.seconds += song.seconds;
            if (!(song.artist in artistMap)) artistMap[song.artist] = { name: song.artist, cover: song.cover, albums: [] };
            const artist = artistMap[song.artist];
            if (!artist.albums.includes(album)) artist.albums.push(album);
        }
        songs = sorted;
        albums = Object.values(albumMap).sort((a, b) => a.name.localeCompare(b.name));
        artists = Object.values(artistMap).sort((a, b) => a.name.localeCompare(b.name));
        recent = sorted.slice().sort((a, b) => b.added - a.added);
    }

    Process {
        command: ["mkdir", "-p", library.cache + "/covers", library.cache + "/peaks"]
        running: true
        onExited: listing.running = true
    }
    Process {
        id: listing
        command: ["find", "-L", library.folder, "-type", "f", "(", "-iname", "*.mp3", "-o", "-iname", "*.flac", "-o", "-iname", "*.ogg",
                  "-o", "-iname", "*.opus", "-o", "-iname", "*.m4a", "-o", "-iname", "*.wav", ")", "-printf", "%T@\t%p\n"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    const [added, path] = line.split("\t");
                    if (path) reading.run(["ffprobe", "-v", "error", "-show_entries", "format=duration:format_tags", "-of", "json", path],
                                          out => library.addSong(path, Number(added), out));
                }
            }
        }
    }
    Jobs {
        id: reading
        onFinished: pending === 0 ? library.rebuild() : settle.restart()
    }
    // while files are still being read, show what is known a few times a second
    Timer { id: settle; interval: 300; onTriggered: library.rebuild() }
}
