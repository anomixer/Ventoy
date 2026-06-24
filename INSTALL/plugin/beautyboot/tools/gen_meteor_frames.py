#!/usr/bin/env python3
"""
gen_meteor_frames.py  -  BeautyBoot Phase 0 frame generator

Generates 18 pre-rendered PNG animation frames for the GRUB
meteor animation (Phase 0). Frames are 480x270 px (GRUB stretches).

Usage:
    python3 gen_meteor_frames.py [output_dir]
    # default: ventoy/phase0/
"""

import sys, random, io
from pathlib import Path
from PIL import Image, ImageDraw

def build_frames(w=480, h=270, n_frames=15, n_fade=3, seed=42):
    random.seed(seed)
    N_STARS, N_METEORS, METEOR_LEN = 120, 6, 18

    stars = [(random.randint(0,w-1), random.randint(0,h-1),
              random.randint(30,160)) for _ in range(N_STARS)]

    class M:
        def __init__(self):
            self.x = float(random.randint(0,w-1))
            self.y = float(random.randint(-60,-5))
            self.vx = random.uniform(0.8,1.8)
            self.vy = random.uniform(3.0,5.5)
            g = random.randint(160,230)
            self.col = (0, g, g//5)

    meteors = [M() for _ in range(N_METEORS)]
    frames = []

    for _ in range(n_frames):
        img = Image.new("RGB",(w,h),(0,0,0))
        d = ImageDraw.Draw(img)
        for sx,sy,bri in stars:
            d.point((sx,sy),fill=(bri,bri,bri))
        for m in meteors:
            for t in range(METEOR_LEN):
                tx = m.x - m.vx*t/m.vy
                ty = m.y - t
                fac = 1.0 - t/METEOR_LEN
                c = (int(m.col[0]*fac),int(m.col[1]*fac),int(m.col[2]*fac))
                if 0<=int(tx)<w and 0<=int(ty)<h:
                    d.point((int(tx),int(ty)),fill=c)
            if 0<=int(m.x)<w and 0<=int(m.y)<h:
                d.ellipse([m.x-1,m.y-1,m.x+1,m.y+1],fill=(255,255,200))
            m.x+=m.vx; m.y+=m.vy
            if m.y>h+20 or m.x>w+20:
                m.x=float(random.randint(0,w-1))
                m.y=float(random.randint(-60,-5))
        frames.append(img)

    # Fade-out frames
    last = frames[-1]
    for i in range(1, n_fade+1):
        fac = 1.0 - i/(n_fade+1)
        faded = Image.new("RGB",(w,h),(0,0,0))
        src = last.load(); dst = faded.load()
        for y in range(h):
            for x in range(w):
                r,g,b = src[x,y]
                dst[x,y]=(int(r*fac),int(g*fac),int(b*fac))
        frames.append(faded)

    return frames

if __name__ == "__main__":
    out_dir = Path(sys.argv[1]) if len(sys.argv)>1 \
              else Path(__file__).parent.parent/"ventoy/phase0"
    out_dir.mkdir(parents=True, exist_ok=True)

    frames = build_frames()
    for i, img in enumerate(frames):
        buf = __import__("io").BytesIO()
        img.save(buf, format="PNG", optimize=True)
        p = out_dir / f"frame_{i:02d}.png"
        p.write_bytes(buf.getvalue())

    print(f"Generated {len(frames)} frames -> {out_dir}")
