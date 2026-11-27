"""Builds every platform's launcher icon from the brand masters.

Masters (1024 px):
  assets/images/brand/app_icon.png          opaque square (iOS)
  assets/images/brand/app_icon_rounded.png  transparent corners (others)

Run from the repo root:  python3 tool/gen_launcher_icons.py
"""

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
BRAND = ROOT / 'assets/images/brand'
OPAQUE = Image.open(BRAND / 'app_icon.png').convert('RGB')
ROUNDED = Image.open(BRAND / 'app_icon_rounded.png').convert('RGBA')
# Deep blue from the icon's sky, behind the Android adaptive and web maskable icons.
BG = (11, 58, 140, 255)
BG_HEX = '#0B3A8C'


def sized(img, px):
    return img.resize((px, px), Image.LANCZOS)


def inset(img, px, scale, bg=None):
    """img scaled to `scale` of a px canvas, centred on bg (or transparent)."""
    canvas = Image.new('RGBA', (px, px), bg or (0, 0, 0, 0))
    inner = sized(img, round(px * scale))
    off = (px - inner.width) // 2
    canvas.alpha_composite(inner, (off, off))
    return canvas


def ios():
    d = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for entry in json.loads((d / 'Contents.json').read_text())['images']:
        pt = float(entry['size'].split('x')[0])
        px = round(pt * int(entry['scale'][0]))
        sized(OPAQUE, px).save(d / entry['filename'])


def android():
    res = ROOT / 'android/app/src/main/res'
    for name, k in [('mdpi', 1), ('hdpi', 1.5), ('xhdpi', 2),
                    ('xxhdpi', 3), ('xxxhdpi', 4)]:
        folder = res / f'mipmap-{name}'
        folder.mkdir(exist_ok=True)
        sized(ROUNDED, round(48 * k)).save(folder / 'ic_launcher.png')
        # Adaptive foreground: 108 dp canvas; the mask shows the inner 72 dp.
        inset(ROUNDED, round(108 * k), 72 / 108).save(
            folder / 'ic_launcher_foreground.png')
    (res / 'values/colors.xml').write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        f'    <color name="ic_launcher_background">{BG_HEX}</color>\n'
        '</resources>\n')
    anydpi = res / 'mipmap-anydpi-v26'
    anydpi.mkdir(exist_ok=True)
    (anydpi / 'ic_launcher.xml').write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '</adaptive-icon>\n')


def web():
    w = ROOT / 'web'
    for px in (192, 512):
        sized(ROUNDED, px).save(w / f'icons/Icon-{px}.png')
        # Maskable safe zone is the inner 80% circle.
        inset(ROUNDED, px, .78, BG).save(w / f'icons/Icon-maskable-{px}.png')
    sized(ROUNDED, 32).save(w / 'favicon.png')


def macos():
    d = ROOT / 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
    for px in (16, 32, 64, 128, 256, 512, 1024):
        # macOS icons sit on a 1024 grid with an ~824 px body.
        inset(ROUNDED, px, 824 / 1024).save(d / f'app_icon_{px}.png')


if __name__ == '__main__':
    ios()
    android()
    web()
    macos()
    print('Launcher icons written.')
