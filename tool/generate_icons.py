"""Generates the Go Book launcher icons (Android + Google Play).

The logo is a white code page with a folded corner, a blue "Go" title and
coloured code lines, on a Go-blue gradient.

Run from the project root:  python3 tool/generate_icons.py
Requires Pillow and the Ubuntu Sans font (fonts-ubuntu).
"""
import os
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
FONT = "/usr/share/fonts/truetype/ubuntu/UbuntuSans[wdth,wght].ttf"

S = 1024      # master canvas = 108dp adaptive-icon canvas
SS = 4        # supersampling factor
N = S * SS
SCALE = 0.78  # keeps the glyph inside the 66dp safe zone

GO_BLUE = (0, 173, 216)
GO_DARK = (0, 118, 160)
GO_LIGHT = (125, 211, 232)
PINK = (206, 48, 98)
EAR = (190, 225, 238)


def background(size=S):
    """Diagonal Go-blue gradient (top-left light, bottom-right dark)."""
    grad = Image.new("L", (size, size))
    grad.putdata([min(255, (x + y) * 255 // (2 * size - 2))
                  for y in range(size) for x in range(size)])
    a = Image.new("RGB", (size, size), GO_BLUE)
    b = Image.new("RGB", (size, size), GO_DARK)
    return Image.composite(b, a, grad)


def draw_page(mono=False):
    """Returns the foreground glyph (RGBA, N x N, unscaled).

    With mono=True the page is solid white and its details are cut out,
    which is what Android 13+ themed icons expect.
    """
    im = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = N / 2
    clear = (0, 0, 0, 0)
    ink = (lambda col: clear) if mono else (lambda col: col + (255,))

    w, h = N * 0.40, N * 0.48
    x0, y0 = c - w / 2, c - h / 2
    ear, r = N * 0.11, N * 0.035

    # Page with a folded top-right corner.
    d.rounded_rectangle((x0, y0, x0 + w, y0 + h), r, fill=(255, 255, 255, 255))
    d.polygon([(x0 + w - ear, y0 - 2), (x0 + w + 2, y0 - 2),
               (x0 + w + 2, y0 + ear)], fill=clear)
    d.polygon([(x0 + w - ear, y0), (x0 + w - ear, y0 + ear - r * 0.3),
               (x0 + w, y0 + ear)], fill=clear if mono else EAR + (255,))

    font = ImageFont.truetype(FONT, int(N * 0.15))
    font.set_variation_by_name(b"ExtraBold")
    d.text((x0 + N * 0.05, y0 + N * 0.15), "Go", font=font,
           fill=ink(GO_BLUE), anchor="lm")

    # Code lines: (y, colour, indent, length, colour, length)
    lines = [(0.30, GO_BLUE, 0.00, 0.14, PINK, 0.10),
             (0.37, GO_LIGHT, 0.05, 0.10, GO_BLUE, 0.08),
             (0.44, PINK, 0.05, 0.08, GO_LIGHT, 0.12)]
    t, gap = N * 0.013, N * 0.025
    for fy, c1, ind, l1, c2, l2 in lines:
        y = y0 + N * fy
        lx = x0 + N * (0.05 + ind)
        d.rounded_rectangle((lx, y - t, lx + N * l1, y + t), t, fill=ink(c1))
        lx2 = lx + N * l1 + gap
        d.rounded_rectangle((lx2, y - t, lx2 + N * l2, y + t), t, fill=ink(c2))
    return im


def fit(glyph):
    """Downsamples the glyph to S and centres it at SCALE."""
    k = int(S * SCALE)
    small = glyph.resize((k, k), Image.LANCZOS)
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    o = (S - k) // 2
    out.alpha_composite(small, (o, o))
    return out


def main():
    fg = fit(draw_page())
    mono = fit(draw_page(mono=True))
    full = background().convert("RGBA")
    full.alpha_composite(fg)

    out_dir = os.path.join(ROOT, "assets", "icon")
    os.makedirs(out_dir, exist_ok=True)
    full.convert("RGB").save(os.path.join(out_dir, "icon_1024.png"))
    fg.save(os.path.join(out_dir, "foreground_1024.png"))

    # Google Play store icon: 512x512, 32-bit PNG, full-bleed square
    # (Play applies its own mask). Uses the 72dp visible area so the glyph
    # has the same weight as on the home screen.
    crop = int(S * 18 / 108)
    visible = full.crop((crop, crop, S - crop, S - crop))
    visible.resize((512, 512), Image.LANCZOS).save(
        os.path.join(out_dir, "play_store_512.png"))

    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    for name, f in densities.items():
        d = os.path.join(RES, f"mipmap-{name}")
        os.makedirs(d, exist_ok=True)

        # Adaptive layers: 108dp.
        a = round(108 * f)
        fg.resize((a, a), Image.LANCZOS).save(
            os.path.join(d, "ic_launcher_foreground.png"))
        mono.resize((a, a), Image.LANCZOS).save(
            os.path.join(d, "ic_launcher_monochrome.png"))

        # Legacy icons (API < 26): 48dp, drawn from the 72dp visible area.
        L = round(48 * f)
        big = visible.resize((L * 4, L * 4), Image.LANCZOS)
        for fname, shape in (("ic_launcher.png", "square"),
                             ("ic_launcher_round.png", "circle")):
            m = Image.new("L", big.size, 0)
            md = ImageDraw.Draw(m)
            inset = int(big.width * 0.04)
            box = (inset, inset, big.width - inset, big.height - inset)
            if shape == "circle":
                md.ellipse(box, fill=255)
            else:
                md.rounded_rectangle(box, radius=big.width * 0.18, fill=255)
            icon = Image.new("RGBA", big.size, (0, 0, 0, 0))
            icon.paste(big, (0, 0), m)
            icon.resize((L, L), Image.LANCZOS).save(os.path.join(d, fname))

    print("Icons generated.")


if __name__ == "__main__":
    main()
