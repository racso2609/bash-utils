#!/bin/bash

INPUT=$1
OUTPUT=$2

SCALE=${SCALE:-"1920:-2"}
CRF=${CRF:-23}
PRESET=${PRESET:-medium}

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: $0 <input> <output> [scale] [crf] [preset]"
    echo "  scale   Resolution scale (default: 1920:-2)"
    echo "  crf     Quality 0-51, lower is better (default: 23)"
    echo "  preset  Encoding speed: ultrafast..veryslow (default: medium)"
    exit 1
fi

echo "Reducing video size..."
echo "Input: $INPUT"
echo "Output: $OUTPUT"
echo "Scale: $SCALE, CRF: $CRF, Preset: $PRESET"

ffmpeg -i "$INPUT" -vf "scale=$SCALE" -c:v libx264 -crf $CRF -preset $PRESET -c:a aac -b:a 128k "$OUTPUT"

echo "Done: $OUTPUT"