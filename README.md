# Split Videos for Shorts/Reels/TikTok

Bash script using FFmpeg to automatically split videos into multiple parts with:

* overlap between cuts;
* automatic continuation text;
* current part indicator;
* custom title overlay;
* last part marked as `END` in English or `FIM` in Portuguese.

Ideal for:

* YouTube Shorts
* TikTok
* Instagram Reels
* long videos split automatically

---

# Requirements

Install:

* FFmpeg
* FFprobe

## Ubuntu / Debian

```bash
sudo apt update
sudo apt install ffmpeg
```

## Arch Linux

```bash
sudo pacman -S ffmpeg
```

## Fedora

```bash
sudo dnf install ffmpeg
```

---

# Script

Save as:

```text
split.sh
```

Make it executable:

```bash
chmod +x split.sh
```

---

# Usage

English example:

```bash
./split.sh video.mp4 6 "TITLE" en
```

Portuguese example:

```bash
./split.sh video.mp4 6 "TITULO" pt
```

The `lang` argument is optional and defaults to `pt` if omitted.

```bash
./split.sh video.mp4 6 "TITULO"
```

Where:

| Parameter | Description |
| --------- | ----------- |
| `video.mp4` | original video file |
| `6` | number of parts |
| `"TITLE"` | title displayed on the video |
| `pt` / `en` | output text language |

---

# Output

The script generates files like:

```text
video_part_01.mp4
video_part_02.mp4
video_part_03.mp4
...
```

When using English, the overlay text is:

```text
PART 2/6 | Continues in part 3
```

and the last part shows:

```text
PART 6/6 | END
```

When using Portuguese, the overlay text is:

```text
PARTE 2/6 | Continua na parte 3
```

and the last part shows:

```text
PARTE 6/6 | FIM
```

---

# Features

* Automatic part numbering
* Title overlay on each segment
* Continuation label for non-final parts
* Last part marked as END/FIM
* Overlap between cuts to avoid harsh transitions

The default overlap value is:

```bash
OVERLAP=5
```

---

# Notes

The script also prints progress messages in the selected language:

* English: `Generating part` / `Done`
* Portuguese: `Gerando parte` / `Concluído`

It accepts several language variants for convenience:

* English: `en`, `eng`, `english`
* Portuguese: `pt`, `pt_br`, `br`, `portugues`, `português`

---

# Compatibility

Tested on:

* Linux
* FFmpeg 6+
* vertical videos
* horizontal videos

---

# Future Improvements

Ideas:

* automatic Shorts 9:16 support
* progress bar
* automatic subtitles
* smart cut detection
* graphical interface
* automatic upload

---

# License

MIT

---

# Author

Project created by amdbStacks.
