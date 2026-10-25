#!/bin/sh
# SPDX-License-Identifier: MIT
# render.sh <music dir> <out dir> [scenes]: every page of the app on dusk and Moss, offscreen and muted, each window laid
# over the wallpaper with a 40 px margin. The palette comes from XDG_STATE_HOME, which the kit reads as it does on Tacit;
# tools/palettes/ holds the two used for the screenshots. Needs python3 with Pillow.
set -e
here=$(cd "$(dirname "$0")/.." && pwd)
music=${1:?usage: render.sh <music dir> <out dir> [scenes]}
out=${2:?usage: render.sh <music dir> <out dir> [scenes]}
scenes=${3:-"playing artists artist albums songs recent lyrics search cantplay half empty"}
mkdir -p "$out"
for palette in dusk moss; do
    for scene in $scenes; do
        size=1520x920; dir=$music
        [ "$scene" = half ] && size=760x920
        [ "$scene" = empty ] && dir=$(mktemp -d)
        raw=$out/raw-$palette-$scene.png
        WAYLAND_DISPLAY= MUSIC_DIR=$dir MUSIC_MUTED=1 MUSIC_SCENE=$scene MUSIC_OUT=$raw MUSIC_SIZE=$size \
        XDG_STATE_HOME=${PALETTES:-$here/tools/palettes}/state-$palette QML_IMPORT_PATH=${QML_IMPORT_PATH:-$HOME/.local/lib/qml} \
        QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=rhi QSG_RHI_BACKEND=opengl timeout 60 qs -p "$here/shell.qml" >/dev/null 2>&1 || true
        python3 "$here/tools/compose.py" "$raw" "$palette" "$out/$palette-$scene.png"
        rm -f "$raw"
    done
done
