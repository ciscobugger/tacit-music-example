#!/bin/bash
# SPDX-License-Identifier: MIT
# make-demo.sh <music dir> <covers dir>: a small made-up library to try the app on. Every song is a synthetic tone
# whose loudness rises and falls (so the waveform has a shape), tagged with -metadata. Covers are covers/c1.jpg..c15.jpg:
# most albums get a folder.jpg or cover.jpg, one gets its picture embedded in the song files. One song has a .lrc.
set -e
out=${1:?usage: make-demo.sh <music dir> <covers dir>}
covers=${2:?usage: make-demo.sh <music dir> <covers dir>}
mkdir -p "$out"

# song <dir> <n> <title> <artist> <album> <year> <seconds> <cover file or "embed">
n=0
song() {
    local dir=$1 no=$2 title=$3 artist=$4 album=$5 year=$6 secs=$7 cover=$8
    n=$((n + 1))
    local f=$((180 + (n * 37) % 300))
    local file="$out/$dir/$(printf '%02d' "$no") $title.mp3"
    mkdir -p "$out/$dir"
    # a slow swell, and a different level for every six seconds
    local tone="aevalsrc=0.6*sin(2*PI*$f*t)*(0.08+0.92*pow(abs(sin(PI*t/$((7 + n % 5))))\\,1.3)*(0.3+0.7*abs(sin(floor(t/6)*2.3+$n))))"
    local tags=(-metadata "title=$title" -metadata "artist=$artist" -metadata "album=$album" -metadata "date=$year" -metadata "track=$no")
    if [ "$cover" = embed ]; then
        ffmpeg -nostdin -v error -y -f lavfi -i "$tone:s=16000:d=$secs" -i "$covers/c10.jpg" -map 0 -map 1 -c:a libmp3lame -b:a 32k -c:v copy \
            -id3v2_version 3 "${tags[@]}" "$file"
    else
        ffmpeg -nostdin -v error -y -f lavfi -i "$tone:s=16000:d=$secs" -c:a libmp3lame -b:a 32k "${tags[@]}" "$file"
        [ -f "$out/$dir/$cover" ] || cp "$covers/${cover#*:}" "$out/$dir/${cover%%:*}"
    fi
}

d="Mara Velde/Low Tide"; a="Mara Velde"; al="Low Tide"
i=0
for t in "Harbour Light:222" "Low Tide:255" "Paper Boats:188" "Undertow:301" "Glass Floats:176" "Salt Air:273" "Night Ferry:227" \
         "The Long Way Home:372" "Grey Morning:199" "Sea Wall:242"; do
    i=$((i + 1)); song "$d" $i "${t%%:*}" "$a" "$al" 2024 "${t##*:}" folder.jpg:c1.jpg
done
i=0
for t in "Shoreline:231" "Tin Roof:204" "Gull Count:187" "Evening Swell:266"; do
    i=$((i + 1)); song "Mara Velde/Shore Songs" $i "${t%%:*}" "$a" "Shore Songs" 2021 "${t##*:}" folder.jpg:c11.jpg
done

# artist | album | year | cover | songs (title:seconds, separated by ;)
while IFS='|' read -r artist album year cover songs; do
    i=0
    IFS=';' read -ra list <<< "$songs"
    for t in "${list[@]}"; do
        i=$((i + 1))
        song "$artist/$album" $i "${t%%:*}" "$artist" "$album" "$year" "${t##*:}" "$cover"
    done
done <<'LIST'
Ana Ruiz|Ember Roads|2023|cover.jpg:c14.jpg|Ash Lane:194;Red Dust:211;Slow Burn:240
Arvo Lind|Meridian|2022|folder.jpg:c7.jpg|Cold Light:205;Far Field:233;Still Water:181
Gills|Under Ice|2025|folder.jpg:c9.jpg|Under Ice:217;Thaw:196;Black Lake:249
Harbour Lights|First Tide|2020|folder.jpg:c4.jpg|Amber Dock:208;Rope and Rust:226
Ines Okafor|Tall Grass|2024|cover.jpg:c3.jpg|Seed Bank:260;Tall Grass:192;Green Hour:215
Kaito Mori|Kiln|2023|folder.jpg:c5.jpg|Kiln:211;Cinder:184;Fired Clay:238
Lune|Night Bus|2022|folder.jpg:c6.jpg|Night Bus:284;Last Stop:203;Window Seat:177
Noor Haddad|Dry Season|2021|embed|Dry Season:229;Dust Road:202;Long Noon:247
Okonkwo Trio|Deep Green|2025|folder.jpg:c13.jpg|Deep Green:272;Canopy:198;Understory:231
Petal Club|Bloom|2024|folder.jpg:c15.jpg|Bloom:176;Petal Fall:189;Stem:162
Sofia Brandt|Porcelain|2023|folder.jpg:c8.jpg|Porcelain:223;Hairline:196;Glaze:208
The Northern Room|Brass and Rain|2022|folder.jpg:c2.jpg|Brass and Rain:238;Low Lamps:207;Third Floor:219
Tove and the Pines|Ridge Walk|2021|folder.jpg:c11.jpg|Ridge Walk:251;Cairn:187;Tarn:206
Yuki Hara|Dusk Pilot|2025|folder.jpg:c12.jpg|Dusk Pilot:243;Runway:178;Afterglow:225
LIST

cat > "$out/Mara Velde/Low Tide/04 Undertow.lrc" <<'LRC'
[ti:Undertow]
[00:14.00]The ferry leaves at six
[00:41.00]I count the lights along the pier
[01:12.00]You said the tide would bring it back
[01:50.00]Whatever we let go of here
[02:20.00]Salt on the window, grey on the sea
[02:55.00]The undertow is all I see
[03:30.00]Hold the rope and pull it in
[04:10.00]Low tide, low tide, start again
LRC
echo "made $n songs in $out"
