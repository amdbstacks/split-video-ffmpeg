#!/bin/bash

set -euo pipefail
export LC_ALL=C

COMMAND_NAME=$(basename "$0")

if [ $# -lt 3 ]; then
    echo "Usage: ./$COMMAND_NAME file.mp4 parts \"TITLE\" [lang]"
    echo "Uso: ./$COMMAND_NAME arquivo.mp4 partes \"TÍTULO\" [lang]"
    echo "lang: pt (default) | en"
    exit 1
fi

VIDEO_FILE="$1"
PARTS="$2"
TITLE="$3"
LANG_CODE="${4:-pt}"

case "${LANG_CODE,,}" in
    en|eng|english)
        LANG_CODE="en"
        MSG_USAGE="Usage: ./$COMMAND_NAME file.mp4 parts \"TITLE\" [lang]"
        MSG_FILE_NOT_FOUND="File not found"
        MSG_PARTS_NUMBER="Parts must be a number."
        MSG_GENERATING_PART="Generating part"
        MSG_DONE="Done"
        TEXT_END_TEMPLATE="PART %s/%s | END"
        TEXT_CONTINUE_TEMPLATE="PART %s/%s | Continues in part %s"
        ;;
    pt|pt_br|br|portugues|português)
        LANG_CODE="pt"
        MSG_USAGE="Uso: ./$COMMAND_NAME arquivo.mp4 partes \"TÍTULO\" [lang]"
        MSG_FILE_NOT_FOUND="Arquivo não encontrado"
        MSG_PARTS_NUMBER="A quantidade de partes deve ser um número."
        MSG_GENERATING_PART="Gerando parte"
        MSG_DONE="Concluído"
        TEXT_END_TEMPLATE="PARTE %s/%s | FIM"
        TEXT_CONTINUE_TEMPLATE="PARTE %s/%s | Continua na parte %s"
        ;;
    *)
        LANG_CODE="pt"
        MSG_USAGE="Uso: ./$COMMAND_NAME arquivo.mp4 partes \"TÍTULO\" [lang]"
        MSG_FILE_NOT_FOUND="Arquivo não encontrado"
        MSG_PARTS_NUMBER="A quantidade de partes deve ser um número."
        MSG_GENERATING_PART="Gerando parte"
        MSG_DONE="Concluído"
        TEXT_END_TEMPLATE="PARTE %s/%s | FIM"
        TEXT_CONTINUE_TEMPLATE="PARTE %s/%s | Continua na parte %s"
        ;;
esac

if [ ! -f "$VIDEO_FILE" ]; then
    echo "$MSG_FILE_NOT_FOUND: $VIDEO_FILE"
    exit 1
fi

if ! [[ "$PARTS" =~ ^[0-9]+$ ]]; then
    echo "$MSG_PARTS_NUMBER"
    exit 1
fi

FILE_NAME=$(basename "$VIDEO_FILE")
BASE_NAME="${FILE_NAME%.*}"
OVERLAP=5

DURATION=$(ffprobe -v error \
    -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 \
    "$VIDEO_FILE")

PART_DURATION=$(awk "BEGIN {print $DURATION/$PARTS}")

for ((i=0; i<PARTS; i++)); do
    PART_NUMBER=$((i+1))
    PART_NUMBER_FORMATTED=$(printf "%02d" "$PART_NUMBER")

    START_TIME=$(awk "BEGIN {
        x=($i*$PART_DURATION)-($i*$OVERLAP)
        if (x<0) x=0
        print x
    }")

    if [ "$PART_NUMBER" -eq "$PARTS" ]; then
        SEGMENT_DURATION=$(awk "BEGIN {print $DURATION-$START_TIME}")
        TEXT=$(printf "$TEXT_END_TEMPLATE" "$PART_NUMBER" "$PARTS")
    else
        SEGMENT_DURATION=$(awk "BEGIN {print $PART_DURATION+$OVERLAP}")
        NEXT_PART=$((PART_NUMBER+1))
        TEXT=$(printf "$TEXT_CONTINUE_TEMPLATE" "$PART_NUMBER" "$PARTS" "$NEXT_PART")
    fi

    echo "$MSG_GENERATING_PART $PART_NUMBER..."

    ffmpeg -y \
        -ss "$START_TIME" \
        -i "$VIDEO_FILE" \
        -t "$SEGMENT_DURATION" \
        -vf "\
    drawtext=text='${TITLE}':\
    fontsize=42:\
    x=(w-text_w)/2:\
    y=60:\
    fontcolor=white:\
    box=1:\
    boxcolor=black@0.6:\
    boxborderw=12,\
    drawtext=text='${TEXT}':\
    fontsize=34:\
    x=(w-text_w)/2:\
    y=130:\
    fontcolor=white:\
    box=1:\
    boxcolor=black@0.6:\
    boxborderw=10" \
        -c:v libx264 \
        -c:a aac \
        "${BASE_NAME}_part_${PART_NUMBER_FORMATTED}.mp4"
done

echo "$MSG_DONE"
