#!/usr/bin/env python3
"""
BeautyBoot Installer for Ventoy

Usage:
    python3 setup.py /path/to/usb/mountpoint

Copies all files to <USB>/ventoy/ and auto-generates binary assets:
  - PF2 bitmap font (beautyboot.pf2)
  - Star-field background (background.png)
  - Phase 0 meteor animation frames (phase0/frame_00..17.png)

Requires: Pillow  (pip install Pillow)
"""

import sys, shutil, subprocess
from pathlib import Path

PLUGIN_DIR = Path(__file__).parent.resolve()

FILES_TO_COPY = [
    ("ventoy/ventoy.json",             "ventoy.json"),
    ("ventoy/ventoy_grub.cfg",         "ventoy_grub.cfg"),
    ("ventoy/beautyboot.cfg",          "beautyboot.cfg"),
    ("ventoy/beautyboot_phase0.cfg",   "beautyboot_phase0.cfg"),
    ("ventoy/beautyboot_splash.cfg",   "beautyboot_splash.cfg"),
    ("ventoy/beautyboot_exit.cfg",     "beautyboot_exit.cfg"),
    ("ventoy/theme/beautyboot/theme.txt", "theme/beautyboot/theme.txt"),
]

def run_generator(script, out_path, label):
    src = PLUGIN_DIR / "tools" / script
    if not src.exists():
        print(f"  [SKIP] {label}: generator not found")
        return False
    try:
        result = subprocess.run(
            [sys.executable, str(src), str(out_path)],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            print(f"  [GEN]  {label}")
            return True
        print(f"  [ERR]  {label}: {result.stderr.strip()}")
        return False
    except Exception as e:
        print(f"  [ERR]  {label}: {e}")
        return False

def install(usb_root: str):
    ventoy_dir = Path(usb_root) / "ventoy"
    print(f"Installing BeautyBoot to: {ventoy_dir}\n")

    for src_rel, dst_rel in FILES_TO_COPY:
        src = PLUGIN_DIR / src_rel
        dst = ventoy_dir / dst_rel
        if not src.exists():
            print(f"  [SKIP] {dst_rel}")
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.name == "beautyboot.cfg" and dst.exists():
            print(f"  [KEEP] {dst_rel}  (user config preserved)")
            continue
        shutil.copy2(src, dst)
        print(f"  [OK]   {dst_rel}")

    # Generate binary assets
    theme_dir = ventoy_dir / "theme/beautyboot"
    theme_dir.mkdir(parents=True, exist_ok=True)

    run_generator("gen_font.py",
                  theme_dir / "beautyboot.pf2",
                  "theme/beautyboot/beautyboot.pf2")

    run_generator("gen_bg.py",
                  theme_dir / "background.png",
                  "theme/beautyboot/background.png")

    run_generator("gen_meteor_frames.py",
                  ventoy_dir / "phase0",
                  "phase0/frame_00..17.png  (18 frames)")

    print("\nDone! All files installed to USB.")
    print("  Edit <USB>/ventoy/beautyboot.cfg to customise splash text.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 setup.py /path/to/usb")
        sys.exit(1)
    install(sys.argv[1])
