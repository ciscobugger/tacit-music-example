// SPDX-License-Identifier: MIT
.pragma library

// The text of an .lrc file as [{ at: seconds, text }], in time order. "[01:50.00]Words": a line may carry several
// stamps; tags like [ti:Title] are skipped.
function parse(text) {
    const lines = [];
    for (const raw of text.split("\n")) {
        const words = raw.replace(/\[[^\]]*\]/g, "").trim();
        const stamp = /\[(\d+):(\d+(?:\.\d+)?)\]/g;
        let m;
        while (words !== "" && (m = stamp.exec(raw)) !== null)
            lines.push({ at: Number(m[1]) * 60 + Number(m[2]), text: words });
    }
    return lines.sort((a, b) => a.at - b.at);
}

// the index of the line being sung at `seconds`, -1 before the first
function lineAt(lines, seconds) {
    let i = -1;
    while (i + 1 < lines.length && lines[i + 1].at <= seconds) i++;
    return i;
}
