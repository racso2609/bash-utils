# Video Edit

Remove background from images and videos using rembg.

## Install

```bash
npm install
```

## Usage

### Single Image

```bash
npm run remove-bg -- input.jpg -o output.png
# or
python remove_bg.py input.jpg -o output.png
```

### Directory of Images

```bash
npm run remove-bg -- input_frames/ -o processed_frames/
```

### Video

```bash
npm run remove-bg:video -- input.mp4 -o output.mp4
# or
python remove_bg.py input.mp4 -o output.mp4 -v
```

## Options

- `-o, --output` - Output file or directory (default: same name with `_nobg` suffix for images, `output_video.mp4` for video)
- `-v, --video` - Process as video (required for video input)

## Requirements

- Python 3.8+
- rembg
- opencv-python
- pillow
- numpy