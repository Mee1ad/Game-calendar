#!/usr/bin/env python3
"""Generate Game Calendar app icon: calendar + D-Pad, dark mode, neon accents."""
from PIL import Image, ImageDraw

SIZE = 1024
BG = (0x2C, 0x2C, 0x2E)  # Dark charcoal
PURPLE = (0x7C, 0x4D, 0xFF)  # Deep purple
TEAL = (0x00, 0xE5, 0xD4)  # Teal
WHITE = (255, 255, 255)
TRANSPARENT = (0, 0, 0, 0)

def main():
    img = Image.new("RGBA", (SIZE, SIZE), (*BG, 255))
    draw = ImageDraw.Draw(img)
    cx, cy = SIZE // 2, SIZE // 2

    # Calendar body (rounded rect)
    cal_w, cal_h = 520, 580
    cal_x = (SIZE - cal_w) // 2
    cal_y = (SIZE - cal_h) // 2 - 20
    r = 40
    draw.rounded_rectangle(
        [cal_x, cal_y, cal_x + cal_w, cal_y + cal_h],
        radius=r,
        outline=PURPLE,
        width=8,
    )

    # Calendar header (binding)
    header_h = 80
    draw.rectangle(
        [cal_x, cal_y, cal_x + cal_w, cal_y + header_h],
        fill=PURPLE,
    )
    draw.rounded_rectangle(
        [cal_x, cal_y, cal_x + cal_w, cal_y + header_h + r],
        radius=r,
        fill=PURPLE,
    )

    # Calendar rings
    ring_y = cal_y + 50
    for i in range(2):
        x = cal_x + 130 + i * 260
        draw.ellipse([x - 25, ring_y - 25, x + 25, ring_y + 25], outline=TEAL, width=6)

    # D-Pad in center (filled, minimalist)
    dpad_cx, dpad_cy = cx, cy + 30
    arm = 90
    stem = 24
    # Center
    draw.ellipse(
        [dpad_cx - 30, dpad_cy - 30, dpad_cx + 30, dpad_cy + 30],
        fill=TEAL,
    )
    # Up arm
    draw.polygon(
        [(dpad_cx, dpad_cy - arm), (dpad_cx - stem, dpad_cy - stem), (dpad_cx + stem, dpad_cy - stem)],
        fill=TEAL,
    )
    # Down arm
    draw.polygon(
        [(dpad_cx, dpad_cy + arm), (dpad_cx - stem, dpad_cy + stem), (dpad_cx + stem, dpad_cy + stem)],
        fill=TEAL,
    )
    # Left arm
    draw.polygon(
        [(dpad_cx - arm, dpad_cy), (dpad_cx - stem, dpad_cy - stem), (dpad_cx - stem, dpad_cy + stem)],
        fill=TEAL,
    )
    # Right arm
    draw.polygon(
        [(dpad_cx + arm, dpad_cy), (dpad_cx + stem, dpad_cy - stem), (dpad_cx + stem, dpad_cy + stem)],
        fill=TEAL,
    )

    # Grid lines (calendar)
    for row in range(4):
        y = cal_y + header_h + 60 + row * 100
        draw.line([(cal_x + 40, y), (cal_x + cal_w - 40, y)], fill=PURPLE, width=2)
    for col in range(3):
        x = cal_x + 40 + (cal_w - 80) * (col + 1) // 3
        draw.line([(x, cal_y + header_h + 60), (x, cal_y + cal_h - 40)], fill=PURPLE, width=2)

    img.save("assets/icon/app_icon.png")
    print("Saved assets/icon/app_icon.png")

    # Foreground-only for adaptive icon (transparent bg)
    fg = Image.new("RGBA", (SIZE, SIZE), TRANSPARENT)
    fg_draw = ImageDraw.Draw(fg)
    fg_draw.rounded_rectangle(
        [cal_x, cal_y, cal_x + cal_w, cal_y + cal_h],
        radius=r,
        outline=PURPLE,
        width=8,
    )
    fg_draw.rectangle(
        [cal_x, cal_y, cal_x + cal_w, cal_y + header_h + r],
        fill=PURPLE,
    )
    for i in range(2):
        x = cal_x + 130 + i * 260
        fg_draw.ellipse([x - 25, ring_y - 25, x + 25, ring_y + 25], outline=TEAL, width=6)
    fg_draw.ellipse(
        [dpad_cx - 30, dpad_cy - 30, dpad_cx + 30, dpad_cy + 30],
        fill=TEAL,
    )
    fg_draw.polygon(
        [(dpad_cx, dpad_cy - arm), (dpad_cx - stem, dpad_cy - stem), (dpad_cx + stem, dpad_cy - stem)],
        fill=TEAL,
    )
    fg_draw.polygon(
        [(dpad_cx, dpad_cy + arm), (dpad_cx - stem, dpad_cy + stem), (dpad_cx + stem, dpad_cy + stem)],
        fill=TEAL,
    )
    fg_draw.polygon(
        [(dpad_cx - arm, dpad_cy), (dpad_cx - stem, dpad_cy - stem), (dpad_cx - stem, dpad_cy + stem)],
        fill=TEAL,
    )
    fg_draw.polygon(
        [(dpad_cx + arm, dpad_cy), (dpad_cx + stem, dpad_cy - stem), (dpad_cx + stem, dpad_cy + stem)],
        fill=TEAL,
    )
    for row in range(4):
        y = cal_y + header_h + 60 + row * 100
        fg_draw.line([(cal_x + 40, y), (cal_x + cal_w - 40, y)], fill=PURPLE, width=2)
    for col in range(3):
        x = cal_x + 40 + (cal_w - 80) * (col + 1) // 3
        fg_draw.line([(x, cal_y + header_h + 60), (x, cal_y + cal_h - 40)], fill=PURPLE, width=2)

    fg.save("assets/icon/app_icon_foreground.png")
    print("Saved assets/icon/app_icon_foreground.png")

if __name__ == "__main__":
    main()
