#!/usr/bin/env python3
"""
gen_bg.py  -  BeautyBoot star-field background generator

Generates a 1920x1080 PNG with randomised star dots for use as
the GRUB theme background (background.png).

Usage:
    python3 gen_bg.py [output_path]
    # default: ventoy/theme/beautyboot/background.png
"""

import sys, random, io
from pathlib import Path
from PIL import Image, ImageDraw

def build_background(w=1920, h=1080, seed=42):
    random.seed(seed)
    img = Image.new("RGB", (w, h), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # dim background stars
    for _ in range(400):
        x = random.randint(0, w-1)
        y = random.randint(0, h-1)
        bri = random.randint(40, 180)
        r = random.randint(0, 1)
        draw.ellipse([x-r, y-r, x+r, y+r], fill=(bri, bri, bri))

    # bright foreground stars
    for _ in range(30):
        x = random.randint(0, w-1)
        y = random.randint(0, h-1)
        draw.ellipse([x-2, y-2, x+2, y+2], fill=(220, 220, 255))

    buf = io.BytesIO()
    img.save(buf, format="PNG", optimize=True)
    return buf.getvalue()

if __name__ == "__main__":
    out = Path(sys.argv[1]) if len(sys.argv) > 1 \
          else Path(__file__).parent.parent / "ventoy/theme/beautyboot/background.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    data = build_background()
    out.write_bytes(data)
    print(f"Written {len(data):,} bytes -> {out}")
