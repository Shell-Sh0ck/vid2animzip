#!/bin/bash

log() {
    if "$verbose"; then
        echo "$@"
    fi
}

usage() {
    echo "Created by Shell-Shock v1.0.0"
    echo "https://github.com/Shell-Sh0ck"
    echo ""
    echo "Options:"
    echo "   -i <file>   Input video file (default: ./video.mp4)"
    echo "   -f <fps>    Frame rate (default: 25)"
    echo "   -r <width:height>  Frame resolution (default: 1080:2340)"
    echo "   -t <format> Pixel format (RGBA/RGB, default: RGBA)"
    echo "   -p <number> Number of animation parts (default: 2)"
    echo "   -y          Force delete a directory without confirmation"
    echo "   -z          Enable ZopfliPNG optimization (very slow)"
    echo "   -q          Enable quiet mode (quiet mode)"
    echo "   -h          Show help"
    exit 0
}

main() {
local  MAIN_DIR="./animation" \
force=false choice=false \
verbose=true target_video="./video.mp4" \
width=1080 height=2340 \
format=rgba fps=25 \
en_zopflipng=false count_parts=2 \
png_files=()

for cmd in ffmpeg pngquant zopflipng; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

while getopts ":i:f:r:t:p:yzvh" opt; do
        case $opt in
            i) target_video="$OPTARG" ;;
            f) fps="$OPTARG" ;;
            r) if [[ "$OPTARG" != *":"* ]]; then
                echo "Error: the resolution format should be width:height."
                usage
                exit 1
               fi ;
               width=$(cut -d ':' -f 1 <<< "$OPTARG") ;
               height=$(cut -d ':' -f 2 <<< "$OPTARG") ;;
            t) format="$OPTARG" ;;
            p) count_parts="$OPTARG" ;;
            y) force=true ;;
            z) en_zopflipng=true ;;
            v) verbose=false ;;
            h) usage; exit 0 ;;
            \?) echo "Invalid option: -$OPTARG"; usage ; exit 1 ;;
            :) echo "Option -$OPTARG requires an argument"; usage ; exit 0 ;;
        esac
    done

if [[ -d "$MAIN_DIR" ]]; then
  if [[ "$force" = false ]]; then
      read -p "The animation directory already exists, should I delete this directory? (y/n) " choice
     fi

  if [[ "$choice" == "y" || "$force" == "true" ]]; then
    log "Removing animation directory..."
    rm -rf "$MAIN_DIR"

    log "Creating directories..."
    for i in $(seq 0 $count_parts); do
      mkdir -p "$MAIN_DIR/part${i}"
    done
  else
    log "Directory not removed."
  fi
else
  log "Directory does not exist, creating it now..."
  for i in $(seq 0 $count_parts); do
    mkdir -p "$MAIN_DIR/part${i}"
done
fi

log "Creating configuration file..."
{
    echo "$width $height $fps"
    for i in $(seq 0 $count_parts); do
        echo "c 1 0 part$i"
    done
} > "$MAIN_DIR/desc.txt"

log "Frame generation..."
ffmpeg -i "$target_video" -hide_banner -vf scale="$width:$height",format="$format",fps="$fps" -f image2 -compression_level 0 $MAIN_DIR/part0/frame%03d.png

log "Frame compression and optimization..."

pngquant --force --ext .png $MAIN_DIR/part0/*.png

if [[ "$en_zopflipng" == true ]] then
 for fn in $MAIN_DIR/part0/*.png ; do
     zopflipng -y -m "${fn}" "${fn}".new && mv -f "${fn}".new "${fn}"
  done
fi

png_files=("$MAIN_DIR"/part0/*.png)
total_files=${#png_files[@]}

part_count_total=$((count_parts + 1))  # 2 + 1 = 3
part_size=$((total_files / part_count_total))
remainder=$((total_files % part_count_total))

start=0
for part in $(seq 0 $count_parts); do  # 0, 1, 2
    current_part_size=$part_size
    if (( remainder > 0 )); then
        ((current_part_size++))
        ((remainder--))
    fi

    if (( part > 0 )); then
        mkdir -p "$MAIN_DIR/part$part"
        for ((i = start; i < start + current_part_size; i++)); do
            if [[ -f "${png_files[i]}" ]]; then
                mv -f "${png_files[i]}" "$MAIN_DIR/part$part/"
            fi
        done
    fi

  start=$((start + current_part_size))
done

log "Moving the directory structure to the archive..."

(
        cd "$MAIN_DIR" || exit 1

        zip_files=("desc.txt")
        for i in $(seq 0 "$count_parts"); do
            if [[ -d "part$i" ]]; then
                zip_files+=("part$i")
            fi
        done

        zip -q -0 -r ../bootanimation.zip "${zip_files[@]}"
    )

log "Done."
}

main "$@"
