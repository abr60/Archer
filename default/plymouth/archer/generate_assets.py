#!/usr/bin/env python3
# Archer Plymouth — Asset Generator
# Run this once to generate all PNG assets for the theme.
# Requires: python3, pillow (pip install pillow)
# Usage: python3 generate_assets.py
# Then copy output PNGs + plymouth.png to /usr/share/plymouth/themes/archer/

from PIL import Image, ImageDraw, ImageFont
import os, shutil, sys

OUT = os.path.dirname(os.path.abspath(__file__))

GREEN      = (116, 168, 106)   # #74a86a — bright, matches wallpaper highlights
GREEN_DIM  = (72,  110,  65)   # dimmer for borders/dashes

# ── Font ──────────────────────────────────────────────────────
FONT_PATHS = [
    "/usr/share/fonts/liberation/LiberationMono-Regular.ttf",
    "/usr/share/fonts/TTF/LiberationMono-Regular.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf",
]
font_path = next((p for p in FONT_PATHS if os.path.exists(p)), None)
if not font_path:
    print("ERROR: LiberationMono not found. Install ttf-liberation.")
    sys.exit(1)

font = ImageFont.truetype(font_path, 24)
test_bbox = font.getbbox("A")
CH = test_bbox[3] - test_bbox[1] + 8   # line height with padding

def text_width(s):
    b = font.getbbox(s)
    return b[2] - b[0]

print(f"Font: {font_path}")
print(f"Line height: {CH}px")

# ── 1. entry.png ──────────────────────────────────────────────
lines = [
    ".-- -- -- -- -- -- -- -- -- -- -- --.",
    "|                                    |",
    "|                                    |",
    "'-- -- -- -- -- -- -- -- -- -- -- --'",
]
cw = text_width(lines[0])
img = Image.new("RGBA", (cw + 14, CH * len(lines) + 10), (0,0,0,0))
draw = ImageDraw.Draw(img)
for i, line in enumerate(lines):
    draw.text((7, 5 + i * CH), line, font=font, fill=GREEN_DIM)
img.save(f"{OUT}/entry.png")
print(f"entry.png       {img.size}")

# ── 2. lock.png ───────────────────────────────────────────────
lock_lines = [" /\\ ", "[##]", "[__]"]
lw = text_width("[##]") + 14
lh = CH * len(lock_lines) + 10
lock_img = Image.new("RGBA", (lw, lh), (0,0,0,0))
ldraw = ImageDraw.Draw(lock_img)
for i, line in enumerate(lock_lines):
    ldraw.text((7, 5 + i * CH), line, font=font, fill=GREEN)
lock_img.save(f"{OUT}/lock.png")
print(f"lock.png        {lock_img.size}")

# ── 3. bullet.png ─────────────────────────────────────────────
bull = Image.new("RGBA", (14, 14), (0,0,0,0))
bdraw = ImageDraw.Draw(bull)
bdraw.ellipse([2, 2, 11, 11], fill=GREEN)
bull.save(f"{OUT}/bullet.png")
print(f"bullet.png      {bull.size}")

# ── 4. progress_box.png ───────────────────────────────────────
pb_line = "[" + "- " * 34 + "]"
pb_w = text_width(pb_line) + 14
pb_h = CH + 10
pb_img = Image.new("RGBA", (pb_w, pb_h), (0,0,0,0))
pbdraw = ImageDraw.Draw(pb_img)
pbdraw.text((7, 5), pb_line, font=font, fill=GREEN_DIM)
pb_img.save(f"{OUT}/progress_box.png")
print(f"progress_box.png {pb_img.size}")

# ── 5. progress_bar.png ───────────────────────────────────────
bar_chars = "█" * 34
bar_w = text_width(bar_chars) + 4
bar_h = CH + 6
bar_img = Image.new("RGBA", (bar_w, bar_h), (0,0,0,0))
bardraw = ImageDraw.Draw(bar_img)
bardraw.text((2, 3), bar_chars, font=font, fill=GREEN)
bar_img.save(f"{OUT}/progress_bar.png")
print(f"progress_bar.png {bar_img.size}")

print("\nAll assets generated successfully in:", OUT)
print("Next: copy wallhaven-213wqy.png to this directory as 'plymouth.png'")
print("Then run install.sh as root.")
