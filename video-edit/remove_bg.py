import os
import sys
import argparse
import cv2
import numpy as np
from rembg import remove
from PIL import Image

input_path = "input_frames/"
output_path = "processed_frames/"


def process_image(input_img):
    output_img = remove(input_img)
    return output_img


def process_image_file(input_file, output_file):
    input_img = Image.open(input_file)
    output_img = process_image(input_img)
    output_img.save(output_file)
    print(f"Saved: {output_file}")


def process_video(input_video_path, output_video_path):
    cap = cv2.VideoCapture(input_video_path)

    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    fps = cap.get(cv2.CAP_PROP_FPS)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    out = cv2.VideoWriter(output_video_path, fourcc, fps, (width, height))

    frame_idx = 0
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        pil_img = Image.fromarray(frame_rgb)

        processed = process_image(pil_img)
        processed_np = np.array(processed)
        processed_bgr = cv2.cvtColor(processed_np, cv2.COLOR_RGB2BGR)

        out.write(processed_bgr)
        frame_idx += 1
        if frame_idx % 30 == 0:
            print(f"Processed {frame_idx} frames...")

    cap.release()
    out.release()
    print(f"Video saved to {output_video_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Remove background from images or videos"
    )
    parser.add_argument("input", help="Input file or directory")
    parser.add_argument("-o", "--output", help="Output file or directory")
    parser.add_argument("-v", "--video", action="store_true", help="Process as video")

    args = parser.parse_args()

    if args.video:
        output_file = args.output or "output_video.mp4"
        process_video(args.input, output_file)
    else:
        output_dir = args.output or output_path
        os.makedirs(output_dir, exist_ok=True)

        if os.path.isdir(args.input):
            for filename in os.listdir(args.input):
                if filename.endswith((".png", ".jpg")):
                    input_file = os.path.join(args.input, filename)
                    output_file = os.path.join(
                        output_dir, filename.replace(".jpg", ".png")
                    )
                    process_image_file(input_file, output_file)
        else:
            input_file = args.input
            output_file = args.output or input_file.replace(".jpg", ".png")
            process_image_file(input_file, output_file)


if __name__ == "__main__":
    main()
