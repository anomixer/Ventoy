# BeautyBoot Plugin for Ventoy

An Apple ][-inspired multi-phase boot experience for [Ventoy](https://www.ventoy.net).

> Inspired by the original **Apple ][ Beautiful Boot** by Mini Appler (1993):
> - Article: [https://ascii.textfiles.com/archives/1054](https://ascii.textfiles.com/archives/1054)
> - Original source: [https://web.archive.org/web/20120427164702/http://boutillon.free.fr/Underground/Outils/Beautiful_Boot/Txt/Boot2_Beautiful_Boot.txt](https://web.archive.org/web/20120427164702/http://boutillon.free.fr/Underground/Outils/Beautiful_Boot/Txt/Boot2_Beautiful_Boot.txt)

## Boot Flow

```
Power on
  └─► UEFI/BIOS
        └─► Ventoy (GRUB2)
              └─► beautyboot_premenu.cfg
              |     Phase 0  PNG frame animation (~3 s)
              └─► Ventoy ISO menu
                    Phase 1  Apple ][ green-on-black theme
                      └─► [user selects ISO]
                            └─► Selected OS boots
```

## Phases

| Phase | File | Effect |
|-------|------|--------|
| **0 - Animation** | `beautyboot_premenu.cfg` | PNG frame sequence, ~6fps, ~3 s |
| **1 - Menu** | `theme.txt` | Apple ][ green-on-black GRUB theme |

## Quick Install

### Linux

```bash
# From the repo root
sudo bash INSTALL/plugin/beautyboot/setup.sh /dev/sdX
```

### Windows

```
1. Open INSTALL\plugin\beautyboot\
2. Create a "frames" folder and place your PNG frames inside
   (frame_00.png, frame_01.png, ... frame_NN.png)
3. Right-click setup.bat -> Run as administrator
4. Enter your Ventoy USB drive letter when prompted (e.g. E)
```

### Manual (any OS)

Copy the `ventoy/` folder to `<USB>/ventoy/`:

```
<USB>/ventoy/
  ├── ventoy_grub.cfg
  ├── beautyboot_premenu.cfg
  └── theme/beautyboot/
      └── theme.txt
```

Then copy your PNG frames to `<USB>/ventoy/phase0/`:

```
<USB>/ventoy/phase0/
  ├── frame_00.png
  ├── frame_01.png
  └── ...
```

## Animation Frames

- **Format:** PNG only (GRUB2 requirement)
- **Recommended size:** Match your screen (e.g. `1920x1080`)
- **Naming:** `frame_00.png`, `frame_01.png`, ... `frame_NN.png`
- **Location on USB:** `<USB>/ventoy/phase0/`

### FFmpeg: Video -> PNG frames

```bash
ffmpeg -i your_animation.mp4 -vf "fps=6,scale=1920:1080" frames/frame_%02d.png
```

## Timing Configuration

Edit `<USB>/ventoy/beautyboot_premenu.cfg` directly:

```grub
# Adjust milliseconds per frame
sleep --ms 167    # default: 167ms x 18 frames = ~3 seconds
```

| `sleep --ms` | FPS | 18 frames total |
|---|---|---|
| `42` | ~24 fps | ~0.75 s |
| `83` | ~12 fps | ~1.5 s |
| `167` | ~6 fps | ~3 s |
| `500` | ~2 fps | ~9 s |

> **Note:** GRUB2 does not support `sleep 0.5`. Always use `sleep --ms <ms>`.

## Repository Layout

```
INSTALL/plugin/beautyboot/
├── README.md
├── setup.sh                     Linux installer
├── setup.bat                    Windows installer
├── setup.py                     Python installer (cross-platform)
├── tools/
│   └── gen_font.py              PF2 font generator
└── ventoy/                      <- copy entire folder to <USB>/ventoy/
    ├── ventoy_grub.cfg
    ├── beautyboot_premenu.cfg
    └── theme/beautyboot/
        └── theme.txt
```

## License

MIT
