// SPDX-License-Identifier: MIT
.pragma library

// 222 -> "3:42"
function duration(seconds) {
    const s = Math.max(0, Math.round(seconds));
    return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
}

// "1 album", "2 albums"
function count(n, word) {
    return n + " " + word + (n === 1 ? "" : "s");
}

// When a song was played: the time today, else the day
function when(date) {
    const now = new Date(), days = Math.round((new Date(now.getFullYear(), now.getMonth(), now.getDate())
                                              - new Date(date.getFullYear(), date.getMonth(), date.getDate())) / 86400000);
    if (days === 0) return date.toLocaleTimeString(Qt.locale(), "HH:mm");
    if (days === 1) return "Yesterday";
    return date.toLocaleDateString(Qt.locale(), "dddd");
}
