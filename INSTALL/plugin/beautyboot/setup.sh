#!/bin/bash
# ============================================================
# BeautyBoot - Ventoy GRUB Boot Animation Setup (Linux)
# ============================================================
# Usage: sudo bash setup.sh /dev/sdX
# Example: sudo bash setup.sh /dev/sdb
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check root
[ "$(id -u)" -eq 0 ] || print_err "Please run as root: sudo bash setup.sh /dev/sdX"

# Args
DEVICE="${1:-}"
[ -z "$DEVICE" ] && print_err "Usage: sudo bash setup.sh /dev/sdX"
[ -b "$DEVICE" ] || print_err "Device $DEVICE not found."

# Find Ventoy partition (partition 1)
VENTOY_PART="${DEVICE}1"
[ -b "$VENTOY_PART" ] || print_err "Partition ${VENTOY_PART} not found. Is Ventoy installed on ${DEVICE}?"

# Mount
MOUNT_POINT=$(mktemp -d)
print_warn "Mounting ${VENTOY_PART} to ${MOUNT_POINT}..."
mount "$VENTOY_PART" "$MOUNT_POINT" || print_err "Failed to mount ${VENTOY_PART}"
trap "umount '$MOUNT_POINT' 2>/dev/null; rmdir '$MOUNT_POINT' 2>/dev/null" EXIT

# Check ventoy directory
VENTOY_DIR="${MOUNT_POINT}/ventoy"
[ -d "$VENTOY_DIR" ] || print_err "ventoy/ directory not found. Is this a Ventoy USB?"

# Copy plugin ventoy/ files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -d "${SCRIPT_DIR}/ventoy" ]; then
    cp -r "${SCRIPT_DIR}/ventoy/." "$VENTOY_DIR/"
    print_ok "Copied plugin files to ${VENTOY_DIR}"
else
    print_err "ventoy/ folder not found next to setup.sh. Are you running from INSTALL/plugin/beautyboot/?"
fi

# Create phase0 directory
PHASE0_DIR="${VENTOY_DIR}/phase0"
mkdir -p "$PHASE0_DIR"
print_ok "Created ${PHASE0_DIR}"

# Copy animation frames
FRAME_DIR="${SCRIPT_DIR}/frames"
if [ -d "$FRAME_DIR" ]; then
    FRAME_COUNT=$(ls "$FRAME_DIR"/frame_*.png 2>/dev/null | wc -l)
    if [ "$FRAME_COUNT" -gt 0 ]; then
        cp "$FRAME_DIR"/frame_*.png "$PHASE0_DIR/"
        print_ok "Copied ${FRAME_COUNT} animation frames to ${PHASE0_DIR}"
    else
        print_warn "No frame_*.png found in frames/ — skipping frame copy."
    fi
else
    print_warn "frames/ directory not found — skipping frame copy."
    print_warn "Create frames/ next to setup.sh and place your PNG frames there."
fi

# Build frame list
FRAMES_ON_USB=$(ls "$PHASE0_DIR"/frame_*.png 2>/dev/null | wc -l)
if [ "$FRAMES_ON_USB" -eq 0 ]; then
    FRAME_LIST="00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17"
else
    FRAME_LIST=$(ls "$PHASE0_DIR"/frame_*.png | sed 's/.*frame_//' | sed 's/.png//' | tr '\n' ' ')
    print_ok "Detected frames: $FRAME_LIST"
fi

# Write beautyboot_premenu.cfg
PREMENU="${VENTOY_DIR}/beautyboot_premenu.cfg"
cat > "$PREMENU" << GRUBEOF
insmod png
insmod gfxterm
insmod gfxterm_background

set gfxmode=1920x1080,auto
terminal_output gfxterm

# BeautyBoot animation — 167ms per frame (~6fps, ~3s total for 18 frames)
for frame in ${FRAME_LIST}; do
    background_image \${vtoy_iso_part}/ventoy/phase0/frame_\${frame}.png
    clear
    sleep --ms 167
done
GRUBEOF
print_ok "Written: ${PREMENU}"

sync
print_ok "Done! Safely eject the USB and reboot to see the animation."
