#!/usr/bin/env python3
"""Authors every Ludo Unbiased image as an SVG source in design/svg/.

Each asset is drawn from a small set of shared shapes (token, dice, cell, yard)
so the same piece looks identical everywhere it appears. Colours come only from
PALETTE, which mirrors the AppColors / BoardPalette theme extensions (spec §1.9).

Writes design/svg/<group>/<file>.svg and design/svg/meta.json; tool/export_assets.py
renders the PNGs and assets/manifest.json from them.

Text is converted to outlines with fontTools from the bundled fonts, so output
does not depend on the fonts installed on the machine.

Usage: python3 tool/design/gen_art.py   (needs: pip install -r tool/requirements.txt)
"""
import colorsys
import json
import math
import pathlib
import shutil

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / 'design' / 'svg'
COLORS = ['red', 'blue', 'yellow', 'green']
MODES = ['light', 'dark']


# --- Colour --------------------------------------------------------------------

def hx(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def to_hex(r, g, b):
    return '#%02X%02X%02X' % tuple(max(0, min(255, round(v))) for v in (r, g, b))


def mix(a, b, t):
    A, B = hx(a), hx(b)
    return to_hex(*[A[i] + (B[i] - A[i]) * t for i in range(3)])


def shade(c, t):
    """t > 0 darkens toward black, t < 0 lightens toward white."""
    return mix(c, '#000000', t) if t > 0 else mix(c, '#FFFFFF', -t)


def desat(c, f=0.9):
    r, g, b = [v / 255 for v in hx(c)]
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    r, g, b = colorsys.hls_to_rgb(h, l, s * f)
    return to_hex(r * 255, g * 255, b * 255)


def luminance(c):
    def ch(v):
        v /= 255
        return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4
    r, g, b = hx(c)
    return 0.2126 * ch(r) + 0.7152 * ch(g) + 0.0722 * ch(b)


def contrast(a, b):
    la, lb = sorted([luminance(a), luminance(b)], reverse=True)
    return (la + 0.05) / (lb + 0.05)


PLAYER_LIGHT = {'red': '#D9342B', 'blue': '#3E8EDE', 'yellow': '#ECCB3A', 'green': '#3D9142'}
PALETTE = {
    'light': dict(
        PLAYER_LIGHT,
        board='#DCE1E9', cell='#FFFFFF', grid='#C9CFD9', star='#7A8394', frame='#FFFFFF', inner='#FFFFFF',
        bg='#F4F5F9', surface='#FFFFFF', surface2='#EEF0F6', text='#1B1E28', text2='#596074', border='#D6DAE3',
        primary='#2563C9', on_primary='#FFFFFF', danger='#C42B23', on_danger='#FFFFFF',
        shadow='#141828', rim=None),
    'dark': dict(
        {k: desat(v) for k, v in PLAYER_LIGHT.items()},
        board='#171A24', cell='#232838', grid='#343A4F', star='#E6E8F0', frame='#1D2030', inner='#1D2030',
        bg='#12141C', surface='#1D2030', surface2='#262A3C', text='#F2F3F7', text2='#A9AEC2', border='#343A4F',
        primary='#6EA6EE', on_primary='#12141C', danger='#EB6F67', on_danger='#12141C',
        shadow='#000000', rim='#FFFFFF'),
}
SYMBOL_ON = {'red': '#FFFFFF', 'blue': '#FFFFFF', 'yellow': '#3B2F00', 'green': '#FFFFFF'}

_uid = [0]


def uid():
    _uid[0] += 1
    return _uid[0]


def n(v):
    r = round(v, 2)
    return str(int(r)) if r == int(r) else str(r)


FONT_FILES = {('Fredoka', 600): 'Fredoka-SemiBold.ttf', ('Fredoka', 700): 'Fredoka-Bold.ttf',
              ('Nunito', 400): 'Nunito-Regular.ttf', ('Nunito', 700): 'Nunito-Bold.ttf'}
_fonts = {}


def _font(family, weight):
    key = (family, weight)
    if key not in _fonts:
        _fonts[key] = TTFont(str(ROOT / 'assets' / 'fonts' / FONT_FILES[key]))
    return _fonts[key]


def text_width(s, size, weight=700, family='Fredoka'):
    f = _font(family, weight)
    cmap, hmtx = f.getBestCmap(), f['hmtx']
    return sum(hmtx[cmap.get(ord(ch), '.notdef')][0] for ch in s) * size / f['head'].unitsPerEm


def txt(x, y, s, size, weight, fill, anchor='start', family='Fredoka', opacity=None):
    """Text as an outlined path; y is the baseline."""
    f = _font(family, weight)
    gs, cmap, hmtx = f.getGlyphSet(), f.getBestCmap(), f['hmtx']
    k = size / f['head'].unitsPerEm
    w = text_width(s, size, weight, family)
    x0 = x - w / 2 if anchor == 'middle' else (x - w if anchor == 'end' else x)
    pen = SVGPathPen(gs)
    cur = 0
    for ch in s:
        g = cmap.get(ord(ch), '.notdef')
        gs[g].draw(TransformPen(pen, (k, 0, 0, -k, x0 + cur * k, y)))
        cur += hmtx[g][0]
    op = f' fill-opacity="{opacity}"' if opacity is not None else ''
    return f'<path d="{pen.getCommands()}" fill="{fill}"{op}/>'


def svg(w, h, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{n(w)}" height="{n(h)}" '
            f'viewBox="0 0 {n(w)} {n(h)}">{body}</svg>')


# --- Shared shapes ----------------------------------------------------------

def star_pts(cx, cy, ro, ri, k=5, rot=-90):
    pts = []
    for i in range(2 * k):
        a = math.radians(rot + i * 180 / k)
        r = ro if i % 2 == 0 else ri
        pts.append(f'{n(cx + r * math.cos(a))},{n(cy + r * math.sin(a))}')
    return ' '.join(pts)


def symbol(cx, cy, s, col, fill):
    """Colour-blind symbol: Red circle, Blue square, Yellow triangle, Green star."""
    if col == 'red':
        return f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(s)}" fill="{fill}"/>'
    if col == 'blue':
        return f'<rect x="{n(cx - s * .88)}" y="{n(cy - s * .88)}" width="{n(s * 1.76)}" height="{n(s * 1.76)}" rx="{n(s * .22)}" fill="{fill}"/>'
    if col == 'yellow':
        return (f'<path d="M{n(cx)} {n(cy - s * 1.1)} L{n(cx + s * 1.08)} {n(cy + s * .8)} L{n(cx - s * 1.08)} {n(cy + s * .8)}Z" '
                f'fill="{fill}" stroke="{fill}" stroke-width="{n(s * .3)}" stroke-linejoin="round"/>')
    return f'<polygon points="{star_pts(cx, cy, s * 1.25, s * .55)}" fill="{fill}" stroke="{fill}" stroke-width="{n(s * .18)}" stroke-linejoin="round"/>'


def token(cx, cy, r, col, mode, state='idle'):
    p = PALETTE[mode]
    c = p[col]
    i = uid()
    if state == 'ghost':
        return (f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r * .8)}" fill="{c}" fill-opacity=".16" stroke="{c}" '
                f'stroke-width="{n(r * .12)}" stroke-dasharray="{n(r * .28)} {n(r * .2)}" stroke-linecap="round"/>'
                f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r * .2)}" fill="{c}"/>')
    defs = (f'<defs><radialGradient id="tg{i}" cx="36%" cy="30%" r="78%">'
            f'<stop offset="0" stop-color="{shade(c, -.42)}"/><stop offset=".5" stop-color="{c}"/>'
            f'<stop offset="1" stop-color="{shade(c, .3)}"/></radialGradient>'
            f'<radialGradient id="td{i}" cx="40%" cy="34%" r="72%"><stop offset="0" stop-color="{shade(c, -.28)}"/>'
            f'<stop offset="1" stop-color="{shade(c, .12)}"/></radialGradient></defs>')
    body = (f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r)}" fill="{shade(c, .38)}"/>'
            f'<circle cx="{n(cx)}" cy="{n(cy - r * .04)}" r="{n(r * .9)}" fill="url(#tg{i})"/>'
            f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r * .63)}" fill="none" stroke="#FFFFFF" stroke-opacity=".92" stroke-width="{n(r * .1)}"/>'
            f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r * .55)}" fill="url(#td{i})"/>'
            + symbol(cx, cy + (r * .03 if col == 'yellow' else 0), r * .26, col, SYMBOL_ON[col])
            + f'<ellipse cx="{n(cx - r * .32)}" cy="{n(cy - r * .42)}" rx="{n(r * .38)}" ry="{n(r * .2)}" '
              f'transform="rotate(-32 {n(cx - r * .32)} {n(cy - r * .42)})" fill="#FFFFFF" fill-opacity=".5"/>')
    if p['rim']:
        body += f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r + .4)}" fill="none" stroke="{p["rim"]}" stroke-opacity=".7" stroke-width="{n(max(1.2, r * .07))}"/>'
    if state == 'hop':
        body = f'<g transform="translate({n(cx)} {n(cy)}) scale(1.12) translate({n(-cx)} {n(-cy)})">{body}</g>'
    pre = ''
    if state == 'movable':
        pre = (f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r * 1.38)}" fill="{c}" fill-opacity=".18"/>'
               f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r * 1.32)}" fill="none" stroke="{c}" stroke-width="{n(r * .14)}"/>')
    if state == 'selected':
        pre = f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r * 1.3)}" fill="none" stroke="{p["text"]}" stroke-width="{n(r * .17)}"/>'
    return defs + pre + body


DICE_PIPS = {1: [(0, 0)], 2: [(-1, -1), (1, 1)], 3: [(-1, -1), (0, 0), (1, 1)], 4: [(-1, -1), (1, -1), (-1, 1), (1, 1)],
             5: [(-1, -1), (1, -1), (0, 0), (-1, 1), (1, 1)], 6: [(-1, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (1, 1)]}


def dice(cx, cy, s, face, mode, angle=0.0, sy=1.0, blur=False):
    p = PALETTE[mode]
    i = uid()
    h = s / 2
    rim = (f'stroke="{p["rim"]}" stroke-opacity=".75" stroke-width="{n(s * .035)}"' if p['rim']
           else f'stroke="#BFC6D2" stroke-width="{n(s * .025)}"')
    out = (f'<defs><linearGradient id="dg{i}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFFFFF"/>'
           f'<stop offset="1" stop-color="#E4E8EF"/></linearGradient></defs>'
           f'<g transform="translate({n(cx)} {n(cy)}) rotate({n(angle)}) scale(1 {n(sy)})">'
           f'<rect x="{n(-h)}" y="{n(-h + s * .05)}" width="{n(s)}" height="{n(s)}" rx="{n(s * .22)}" fill="#C3CAD6"/>'
           f'<rect x="{n(-h)}" y="{n(-h)}" width="{n(s)}" height="{n(s)}" rx="{n(s * .22)}" fill="url(#dg{i})" {rim}/>')
    for px, py in DICE_PIPS[face]:
        rr = s * (.11 if face == 1 else .085)
        out += f'<circle cx="{n(px * s * .26)}" cy="{n(py * s * .26)}" r="{n(rr)}" fill="{"#C42B23" if face == 1 else "#1B1E28"}"/>'
    out += '</g>'
    if blur:
        out = f'<defs><filter id="db{i}" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="{n(s * .015)}"/></filter></defs><g filter="url(#db{i})">{out}</g>'
    return out


def shadow_ellipse(cx, cy, rx, ry, mode, alpha=None):
    i = uid()
    a = alpha if alpha is not None else (.28 if mode == 'light' else .55)
    return (f'<defs><filter id="sh{i}" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="{n(ry * .45)}"/></filter></defs>'
            f'<ellipse cx="{n(cx)}" cy="{n(cy)}" rx="{n(rx)}" ry="{n(ry)}" fill="{PALETTE[mode]["shadow"]}" fill-opacity="{a}" filter="url(#sh{i})"/>')


def cell(x, y, c, mode, fill=None):
    p = PALETTE[mode]
    return (f'<rect x="{n(x)}" y="{n(y)}" width="{n(c)}" height="{n(c)}" fill="{p["grid"]}"/>'
            f'<rect x="{n(x + c * .02)}" y="{n(y + c * .02)}" width="{n(c * .96)}" height="{n(c * .96)}" fill="{fill or p["cell"]}"/>')


def star_cell(x, y, c, mode):
    p = PALETTE[mode]
    return cell(x, y, c, mode) + (f'<polygon points="{star_pts(x + c / 2, y + c / 2 + c * .02, c * .34, c * .15)}" fill="none" '
                                  f'stroke="{p["star"]}" stroke-width="{n(c * .045)}" stroke-linejoin="round"/>')


def start_cell(x, y, c, col, mode):
    p = PALETTE[mode]
    return cell(x, y, c, mode, p[col]) + (f'<polygon points="{star_pts(x + c / 2, y + c / 2 + c * .02, c * .34, c * .15)}" fill="none" '
                                          f'stroke="#FFFFFF" stroke-width="{n(c * .05)}" stroke-linejoin="round"/>')


def home_cell(x, y, c, col, mode):
    p = PALETTE[mode]
    i = uid()
    out = (f'<defs><linearGradient id="hc{i}" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{shade(p[col], -.12)}"/>'
           f'<stop offset="1" stop-color="{shade(p[col], .06)}"/></linearGradient></defs>' + cell(x, y, c, mode, f'url(#hc{i})'))
    if mode == 'dark':
        out += f'<rect x="{n(x + c * .08)}" y="{n(y + c * .08)}" width="{n(c * .84)}" height="{n(c * .84)}" rx="{n(c * .12)}" fill="none" stroke="#FFFFFF" stroke-opacity=".22" stroke-width="{n(c * .04)}"/>'
    return out


def arrow_cell(x, y, c, col, mode, d=0):
    p = PALETTE[mode]
    cx, cy = x + c / 2, y + c / 2
    a = (f'<g transform="rotate({d} {n(cx)} {n(cy)})"><path d="M{n(cx)} {n(cy - c * .32)} L{n(cx + c * .26)} {n(cy - c * .02)} '
         f'L{n(cx + c * .1)} {n(cy - c * .02)} L{n(cx + c * .1)} {n(cy + c * .3)} L{n(cx - c * .1)} {n(cy + c * .3)} '
         f'L{n(cx - c * .1)} {n(cy - c * .02)} L{n(cx - c * .26)} {n(cy - c * .02)}Z" fill="{p[col]}" '
         f'stroke="{p[col]}" stroke-width="{n(c * .03)}" stroke-linejoin="round"/></g>')
    return cell(x, y, c, mode) + a


def yard(x, y, c, col, mode):
    p = PALETTE[mode]
    i = uid()
    Y = 6 * c
    k = p[col]
    out = (f'<defs><radialGradient id="yg{i}" cx="50%" cy="50%" r="72%"><stop offset=".55" stop-color="{k}"/>'
           f'<stop offset="1" stop-color="{shade(k, .18)}"/></radialGradient>'
           f'<filter id="yi{i}" x="-10%" y="-10%" width="120%" height="120%"><feGaussianBlur stdDeviation="{n(c * .12)}"/></filter></defs>'
           f'<rect x="{n(x)}" y="{n(y)}" width="{n(Y)}" height="{n(Y)}" fill="url(#yg{i})"/>')
    if mode == 'dark':
        out += f'<rect x="{n(x + c * .3)}" y="{n(y + c * .3)}" width="{n(Y - c * .6)}" height="{n(Y - c * .6)}" rx="{n(c * .5)}" fill="none" stroke="{shade(k, -.35)}" stroke-opacity=".55" stroke-width="{n(c * .2)}" filter="url(#yi{i})"/>'
    out += (f'<rect x="{n(x + c)}" y="{n(y + c * 1.08)}" width="{n(4 * c)}" height="{n(4 * c)}" rx="{n(c * .5)}" fill="#000000" fill-opacity=".22" filter="url(#yi{i})"/>'
            f'<rect x="{n(x + c)}" y="{n(y + c)}" width="{n(4 * c)}" height="{n(4 * c)}" rx="{n(c * .5)}" fill="{p["inner"]}"/>')
    for dr, dc in [(2, 2), (2, 4), (4, 2), (4, 4)]:
        out += (f'<circle cx="{n(x + dc * c)}" cy="{n(y + dr * c)}" r="{n(c * .58)}" fill="{k}" fill-opacity=".16" '
                f'stroke="{k}" stroke-width="{n(c * .07)}"/>')
    return out


def centre_home(x, y, c, mode):
    p = PALETTE[mode]
    S = 3 * c
    m = (x + S / 2, y + S / 2)
    tl, tr, bl, br = (x, y), (x + S, y), (x, y + S), (x + S, y + S)
    tri = {'red': (bl, br), 'blue': (tl, bl), 'yellow': (tl, tr), 'green': (tr, br)}
    out = f'<rect x="{n(x)}" y="{n(y)}" width="{n(S)}" height="{n(S)}" fill="{p["grid"]}"/>'
    for col, (a, b) in tri.items():
        i = uid()
        out += (f'<defs><linearGradient id="ct{i}" x1="{n(a[0])}" y1="{n(a[1])}" x2="{n(m[0])}" y2="{n(m[1])}" gradientUnits="userSpaceOnUse">'
                f'<stop offset="0" stop-color="{shade(p[col], .06)}"/><stop offset="1" stop-color="{shade(p[col], -.18)}"/></linearGradient></defs>'
                f'<polygon points="{n(a[0])},{n(a[1])} {n(b[0])},{n(b[1])} {n(m[0])},{n(m[1])}" fill="url(#ct{i})" '
                f'stroke="{p["cell"]}" stroke-width="{n(c * .05)}" stroke-linejoin="round"/>')
    out += f'<circle cx="{n(m[0])}" cy="{n(m[1])}" r="{n(c * .16)}" fill="{p["cell"]}"/>'
    return out


# --- Asset registry -----------------------------------------------------------

ASSETS = []


def add(group, stem, w, h, body_fn, modes=('light', 'dark'), anchor=(0.5, 0.5), nine=None, screens=(),
        scales=(1, 2, 3), notes=None, folder=None):
    """Registers one logical asset; body_fn(mode) returns the SVG body for that mode."""
    mode_list = list(modes) if isinstance(modes, (list, tuple)) else [modes]
    for mode in mode_list:
        file = f'{stem}_{mode}' if mode in MODES else stem
        d = OUT / group
        d.mkdir(parents=True, exist_ok=True)
        (d / f'{file}.svg').write_text(svg(w, h, body_fn(mode)), encoding='utf-8')
    ASSETS.append(dict(id=stem, group=group, folder=folder or f'images/{group}', size=[w, h], anchor=list(anchor),
                       nineSlice=list(nine) if nine else None,
                       modes=mode_list if mode_list[0] in MODES else mode_list[0],
                       scales=list(scales), screens=list(screens), notes=notes))


C = 48  # one board cell at 1x


def board_assets():
    G = ['game', 'how_to_play']
    add('board', 'board_bg', 15 * C, 15 * C,
        lambda m: f'<rect width="{15 * C}" height="{15 * C}" rx="6" fill="{PALETTE[m]["board"]}"/>', anchor=(0, 0), screens=G,
        notes='Behind every cell; the gaps between cells read as grid lines.')
    add('board', 'board_cell', C, C, lambda m: cell(0, 0, C, m), anchor=(0, 0), screens=G)
    add('board', 'board_cell_safe_star', C, C, lambda m: star_cell(0, 0, C, m), anchor=(0, 0), screens=G)
    for col in COLORS:
        add('board', f'board_cell_start_{col}', C, C, lambda m, col=col: start_cell(0, 0, C, col, m), anchor=(0, 0), screens=G)
        add('board', f'board_home_column_{col}', C, C, lambda m, col=col: home_cell(0, 0, C, col, m), anchor=(0, 0), screens=G)
        add('board', f'board_yard_{col}', 6 * C, 6 * C, lambda m, col=col: yard(0, 0, C, col, m), anchor=(0, 0), screens=G,
            notes='Slot centres at cell-corner points (2,2), (2,4), (4,2), (4,4) in cell units.')
        add('board', f'board_arrow_{col}', C, C, lambda m, col=col: arrow_cell(0, 0, C, col, m), anchor=(0.5, 0.5), screens=G,
            notes='Points up; Flame rotates it: Red 0°, Blue 90°, Yellow 180°, Green 270°.')
    add('board', 'board_centre_home', 3 * C, 3 * C, lambda m: centre_home(0, 0, C, m), anchor=(0, 0), screens=G)

    def frame(m):
        p = PALETTE[m]
        i = uid()
        sh = (f'<defs><filter id="bf{i}" x="-30%" y="-30%" width="160%" height="160%"><feGaussianBlur stdDeviation="5"/></filter></defs>'
              f'<rect x="12" y="15" width="72" height="72" rx="20" fill="{p["shadow"]}" fill-opacity="{.25 if m == "light" else .6}" filter="url(#bf{i})"/>')
        rim = f' stroke="{p["border"]}" stroke-width="1.5"' if m == 'dark' else ''
        return sh + f'<rect x="10" y="10" width="76" height="76" rx="18" fill="{p["frame"]}"{rim}/>'
    add('board', 'board_frame', 96, 96, frame, anchor=(0, 0), nine=(30, 30, 30, 30), screens=G,
        notes='9-slice; the board sits inside with a 16 px inset at 1x.')


def token_assets():
    T = 64
    for col in COLORS:
        for st in ['idle', 'movable', 'selected', 'hop', 'ghost']:
            add('tokens', f'token_{col}_{st}', T, T, lambda m, col=col, st=st: token(32, 32, 21, col, m, st),
                screens=['game', 'how_to_play'],
                notes={'movable': 'Pulse ring: Flame animates scale 1.0→1.12 and opacity.',
                       'ghost': 'Destination marker on the target cell.',
                       'hop': 'Lifted frame used at the top of each hop arc.'}.get(st))
    add('tokens', 'token_shadow', T, T, lambda m: shadow_ellipse(32, 44, 17, 6.5, m), screens=['game'],
        notes='Drawn under every token; offset and scaled during hops.')
    for k in (2, 3, 4):
        def badge(m, k=k):
            p = PALETTE[m]
            return (f'<circle cx="12" cy="12" r="10.5" fill="{p["text"]}" stroke="{p["surface"]}" stroke-width="2"/>'
                    + txt(12, 16.6, str(k), 13, 700, p['surface'], 'middle'))
        add('tokens', f'token_stack_badge_{k}', 24, 24, badge, screens=['game'], notes='Top-right of a 3–4 token cluster.')


def dice_assets():
    D = 64
    for f in range(1, 7):
        add('dice', f'dice_face_{f}', D, D, lambda m, f=f: dice(32, 32, 52, f, m), screens=['game', 'how_to_play'])
    frames = [(0, 1.0, 5), (38, .92, 3), (82, .86, 6), (130, .94, 2), (178, 1.04, 4), (226, .9, 1), (280, .96, 5), (334, 1.0, 3)]
    for k, (a, sy, f) in enumerate(frames, 1):
        add('dice', f'dice_roll_{k:02d}', D, D, lambda m, a=a, sy=sy, f=f: dice(32, 32 + (1 - sy) * 20, 46, f, m, a, sy, blur=True),
            screens=['game'], notes='800 ms tumble: 8 frames at 100 ms, then the result face.')
    add('dice', 'dice_shadow', D, D, lambda m: shadow_ellipse(32, 54, 22, 6, m), screens=['game'])
    for col in COLORS:
        def tray(m, col=col):
            p = PALETTE[m]
            return (f'<rect x="3" y="3" width="66" height="66" rx="18" fill="{p[col]}" fill-opacity="{.16 if m == "light" else .26}" '
                    f'stroke="{p[col]}" stroke-width="2.5"/>')
        add('dice', f'dice_tray_{col}', 72, 72, tray, screens=['game'], notes='Sits on the active card under the dice.')


CARD_W, CARD_H, CARD_M = 174, 72, 8


def card(col, state, m):
    p = PALETTE[m]
    k = p[col]
    i = uid()
    x, y, w, h, r = CARD_M, CARD_M, CARD_W, CARD_H, 16
    out = ''
    if state == 'active':
        out += (f'<defs><filter id="cg{i}" x="-20%" y="-30%" width="140%" height="160%"><feGaussianBlur stdDeviation="4"/></filter></defs>'
                f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{k}" fill-opacity=".55" filter="url(#cg{i})"/>')
        out += f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{mix(p["surface"], k, .14)}" stroke="{k}" stroke-width="3"/>'
    elif state == 'inactive':
        out += f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{p["surface"]}" stroke="{mix(p["surface"], k, .5)}" stroke-width="2"/>'
    elif state == 'disconnected':
        out += (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{p["surface2"]}" stroke="{p["text2"]}" '
                f'stroke-width="2" stroke-dasharray="6 5" stroke-linecap="round"/>')
    else:  # finished
        out += (f'<defs><linearGradient id="cf{i}" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{mix(p["surface"], k, .26)}"/>'
                f'<stop offset="1" stop-color="{mix(p["surface"], "#F2B632", .22)}"/></linearGradient></defs>'
                f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="url(#cf{i})" stroke="#D9A21E" stroke-width="2.5"/>')
    out += f'<rect x="{x + 6}" y="{y + 3}" width="{w - 12}" height="2" rx="1" fill="#FFFFFF" fill-opacity="{.6 if m == "light" else .08}"/>'
    return out


def ring(kind):
    x, y, w, h, r = CARD_M - 4, CARD_M - 4, CARD_W + 8, CARD_H + 8, 20
    if kind == 'track':
        return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="none" stroke="#FFFFFF" stroke-opacity=".35" stroke-width="4"/>'
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="none" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round"/>'


def medal(rank):
    fills = {1: ('#F2B632', '#B7811A'), 2: ('#C9D0DB', '#8892A3'), 3: ('#D88A4E', '#9A5626'), 4: ('#AEB6C4', '#6B7486')}
    f, d = fills[rank]
    ribbon = '' if rank == 4 else (
        f'<path d="M20 4 L28 4 L34 26 L26 26Z" fill="#3E8EDE"/><path d="M44 4 L36 4 L30 26 L38 26Z" fill="#D9342B"/>')
    return (ribbon + f'<circle cx="32" cy="38" r="21" fill="{d}"/><circle cx="32" cy="36.5" r="19" fill="{f}"/>'
            f'<circle cx="32" cy="36.5" r="14.5" fill="none" stroke="#FFFFFF" stroke-opacity=".55" stroke-width="2"/>'
            + txt(32, 45, str(rank), 24, 700, '#2A1E05', 'middle'))


def crown():
    gems = ''.join(f'<circle cx="{x}" cy="{y}" r="3.6" fill="{PLAYER_LIGHT[c]}" stroke="#FFFFFF" stroke-width="1.2"/>'
                   for x, y, c in [(14, 22, 'red'), (32, 14, 'blue'), (50, 22, 'green'), (32, 41, 'yellow')])
    return ('<path d="M8 50 L6 20 L20 31 L32 12 L44 31 L58 20 L56 50Z" fill="#F2B632" stroke="#B7811A" stroke-width="2.5" stroke-linejoin="round"/>'
            '<rect x="8" y="46" width="48" height="8" rx="3" fill="#E2A521" stroke="#B7811A" stroke-width="2"/>' + gems)


def wifi_off():
    return ('<circle cx="16" cy="16" r="15" fill="#1B1E28" stroke="#FFFFFF" stroke-width="2"/>'
            '<g fill="none" stroke="#FFFFFF" stroke-width="2.2" stroke-linecap="round">'
            '<path d="M8 13.5a11 11 0 0 1 16 0"/><path d="M11 17a6.5 6.5 0 0 1 10 0"/><path d="M9 8l14 16"/></g>'
            '<circle cx="16" cy="21.5" r="1.6" fill="#FFFFFF"/>')


def card_assets():
    S = ['game']
    for col in COLORS:
        for st in ['inactive', 'active', 'disconnected', 'finished']:
            add('cards', f'card_{col}_{st}', CARD_W + 2 * CARD_M, CARD_H + 2 * CARD_M, lambda m, col=col, st=st: card(col, st, m),
                anchor=(0, 0), nine=(28, 28, 28, 28), screens=S,
                notes='Every state has identical pixel size; glow lives in the 8 px margin, so layout never moves.')
    add('cards', 'card_timer_ring_track', CARD_W + 2 * CARD_M, CARD_H + 2 * CARD_M, lambda m: ring('track'), modes='tinted',
        anchor=(0, 0), nine=(28, 28, 28, 28), screens=S, notes='Tinted with the player colour.')
    add('cards', 'card_timer_ring_fill', CARD_W + 2 * CARD_M, CARD_H + 2 * CARD_M, lambda m: ring('fill'), modes='tinted',
        anchor=(0, 0), nine=(28, 28, 28, 28), screens=S,
        notes='Reference stroke for the ring; the app sweeps progress along this exact path (radius 20, 4.5 px).')
    for r in (1, 2, 3, 4):
        add('cards', f'card_rank_{r}', 64, 64, lambda m, r=r: medal(r), modes='any', screens=['results', 'game'])
    add('cards', 'card_crown', 64, 64, lambda m: crown(), modes='any', screens=['game', 'results'])
    add('cards', 'card_wifi_off', 32, 32, lambda m: wifi_off(), modes='any', screens=['game'])


# --- Avatars -------------------------------------------------------------------

AVATARS = [
    dict(name='fox', bg='#FFE3C2', head='#F08A3E', ears='pointed', inner='#FFF2E6', muzzle='#FFF2E6', eyes='dot', nose='#2A2230'),
    dict(name='owl', bg='#E3E8FF', head='#8B6B4E', ears='tufts', inner='#C9A985', eyes='ring', beak='#F5A623'),
    dict(name='cat', bg='#FFE0E6', head='#9AA3B5', ears='pointed', inner='#F7B6C6', eyes='dot', nose='#F07F9C', whiskers=True),
    dict(name='bear', bg='#E8F5E1', head='#A8734D', ears='round', inner='#D9A87C', muzzle='#E6C3A0', eyes='dot', nose='#3A2A20'),
    dict(name='frog', bg='#E2F7EE', head='#5DBB63', ears='frog', eyes='frog', smile=True),
    dict(name='penguin', bg='#DFF1FF', head='#2E3440', ears=None, mask='#FFFFFF', eyes='dot', beak='#F5A623'),
    dict(name='bunny', bg='#D9C6F6', head='#FCFAFF', ears='long', inner='#F7B6C6', eyes='dot', nose='#F07F9C'),
    dict(name='panda', bg='#E9EEF5', head='#FFFFFF', ears='round', inner='#2E3440', ear_fill='#2E3440', patches=True, eyes='dot', nose='#2E3440'),
    dict(name='robot', bg='#FFF4CC', head='#B9C3D3', ears='bolts', eyes='screen', boxy=True),
    dict(name='octopus', bg='#FFE5F0', head='#E86AA6', ears=None, eyes='big', tentacles=True),
    dict(name='chick', bg='#FFF6D6', head='#FFD23F', ears='tuft', eyes='dot', beak='#F08A3E'),
    dict(name='monkey', bg='#FBE9DD', head='#8C5A3C', ears='side', inner='#E8B98F', face='#E8B98F', eyes='dot', nose='#4A2E1E'),
]


def avatar(a):
    cx, cy, R = 128, 142, 78
    ink = '#2A2230'
    i = uid()
    out = (f'<defs><clipPath id="ac{i}"><circle cx="128" cy="128" r="128"/></clipPath></defs><g clip-path="url(#ac{i})">'
           f'<circle cx="128" cy="128" r="128" fill="{a["bg"]}"/>'
           f'<circle cx="128" cy="128" r="112" fill="#FFFFFF" fill-opacity=".35"/>')
    head, ears = a['head'], a.get('ears')
    ef = a.get('ear_fill', head)
    inner = a.get('inner', shade(head, -.3))
    if ears == 'pointed':
        for s in (-1, 1):
            out += (f'<path d="M{cx + s * 30} {cy - 62} L{cx + s * 70} {cy - 108} L{cx + s * 76} {cy - 34}Z" fill="{ef}" stroke="{shade(head, .2)}" stroke-width="4" stroke-linejoin="round"/>'
                    f'<path d="M{cx + s * 42} {cy - 62} L{cx + s * 66} {cy - 90} L{cx + s * 68} {cy - 46}Z" fill="{inner}"/>')
    elif ears == 'round':
        for s in (-1, 1):
            out += f'<circle cx="{cx + s * 60}" cy="{cy - 62}" r="28" fill="{ef}"/><circle cx="{cx + s * 60}" cy="{cy - 62}" r="15" fill="{inner}"/>'
    elif ears == 'long':
        for s in (-1, 1):
            out += (f'<ellipse cx="{cx + s * 32}" cy="{cy - 84}" rx="22" ry="44" transform="rotate({s * 12} {cx + s * 32} {cy - 84})" fill="{ef}" stroke="{shade(head, .12)}" stroke-width="3"/>'
                    f'<ellipse cx="{cx + s * 32}" cy="{cy - 80}" rx="11" ry="32" transform="rotate({s * 12} {cx + s * 32} {cy - 80})" fill="{inner}"/>')
    elif ears == 'tufts':
        for s in (-1, 1):
            out += f'<path d="M{cx + s * 36} {cy - 66} L{cx + s * 64} {cy - 106} L{cx + s * 72} {cy - 46}Z" fill="{shade(head, .1)}"/>'
    elif ears == 'side':
        for s in (-1, 1):
            out += f'<circle cx="{cx + s * 80}" cy="{cy - 6}" r="24" fill="{head}"/><circle cx="{cx + s * 80}" cy="{cy - 6}" r="13" fill="{inner}"/>'
    elif ears == 'bolts':
        for s in (-1, 1):
            out += f'<rect x="{cx + s * 84 - 10}" y="{cy - 22}" width="20" height="36" rx="6" fill="{shade(head, .2)}"/>'
        out += (f'<line x1="{cx}" y1="{cy - 74}" x2="{cx}" y2="{cy - 104}" stroke="{shade(head, .3)}" stroke-width="6" stroke-linecap="round"/>'
                f'<circle cx="{cx}" cy="{cy - 108}" r="10" fill="#D9342B"/>')
    elif ears == 'tuft':
        out += f'<path d="M{cx - 10} {cy - 72} Q{cx - 6} {cy - 106} {cx + 8} {cy - 96} Q{cx + 2} {cy - 84} {cx + 10} {cy - 74}Z" fill="{shade(head, .08)}"/>'
    if a.get('boxy'):
        out += f'<rect x="{cx - 80}" y="{cy - 78}" width="160" height="150" rx="36" fill="{head}" stroke="{shade(head, .2)}" stroke-width="5"/>'
    elif a.get('tentacles'):
        for k in range(-3, 4):
            out += f'<path d="M{cx + k * 22} {cy + 40} q{-8 if k % 2 else 8} 34 {k * 4} 60" stroke="{head}" stroke-width="20" stroke-linecap="round" fill="none"/>'
        out += f'<ellipse cx="{cx}" cy="{cy - 6}" rx="{R}" ry="{R - 4}" fill="{head}"/>'
    else:
        out += f'<circle cx="{cx}" cy="{cy}" r="{R}" fill="{head}"/>'
        out += f'<ellipse cx="{cx - 26}" cy="{cy - 44}" rx="26" ry="13" fill="#FFFFFF" fill-opacity=".22" transform="rotate(-24 {cx - 26} {cy - 44})"/>'
    if a.get('mask'):
        out += f'<path d="M{cx} {cy - 40} C{cx - 70} {cy - 70} {cx - 82} {cy + 40} {cx} {cy + 70} C{cx + 82} {cy + 40} {cx + 70} {cy - 70} {cx} {cy - 40}Z" fill="{a["mask"]}"/>'
    if a.get('face'):
        out += f'<path d="M{cx} {cy - 30} C{cx - 70} {cy - 60} {cx - 74} {cy + 50} {cx} {cy + 64} C{cx + 74} {cy + 50} {cx + 70} {cy - 60} {cx} {cy - 30}Z" fill="{a["face"]}"/>'
    if a.get('muzzle'):
        out += f'<ellipse cx="{cx}" cy="{cy + 30}" rx="40" ry="30" fill="{a["muzzle"]}"/>'
    if a.get('patches'):
        for s in (-1, 1):
            out += f'<ellipse cx="{cx + s * 30}" cy="{cy - 6}" rx="20" ry="25" transform="rotate({s * -24} {cx + s * 30} {cy - 6})" fill="#2E3440"/>'
    if ears == 'frog':
        for s in (-1, 1):
            out += f'<circle cx="{cx + s * 40}" cy="{cy - 66}" r="28" fill="{head}"/>'
    eyes = a.get('eyes')
    for s in (-1, 1):
        ex, ey = cx + s * 30, cy - 6
        if eyes == 'dot':
            out += f'<circle cx="{ex}" cy="{ey}" r="10" fill="{"#FFFFFF" if a.get("patches") else ink}"/>'
            if a.get('patches'):
                out += f'<circle cx="{ex}" cy="{ey}" r="6" fill="{ink}"/>'
            out += f'<circle cx="{ex - 3}" cy="{ey - 4}" r="3" fill="#FFFFFF"/>'
        elif eyes == 'ring':
            out += f'<circle cx="{ex}" cy="{ey}" r="25" fill="#FFFFFF"/><circle cx="{ex}" cy="{ey}" r="25" fill="none" stroke="{a["inner"]}" stroke-width="6"/>'
            out += f'<circle cx="{ex}" cy="{ey + 2}" r="11" fill="{ink}"/><circle cx="{ex - 4}" cy="{ey - 3}" r="4" fill="#FFFFFF"/>'
        elif eyes == 'frog':
            out += f'<circle cx="{cx + s * 40}" cy="{cy - 68}" r="17" fill="#FFFFFF"/><circle cx="{cx + s * 40}" cy="{cy - 66}" r="9" fill="{ink}"/>'
        elif eyes == 'screen':
            pass
        elif eyes == 'big':
            out += f'<ellipse cx="{ex}" cy="{ey}" rx="17" ry="21" fill="#FFFFFF"/><circle cx="{ex + 2}" cy="{ey + 4}" r="10" fill="{ink}"/><circle cx="{ex - 2}" cy="{ey - 2}" r="3.5" fill="#FFFFFF"/>'
    if eyes == 'screen':
        out += f'<rect x="{cx - 56}" y="{cy - 40}" width="112" height="60" rx="18" fill="#26303F"/>'
        for s in (-1, 1):
            out += f'<rect x="{cx + s * 26 - 9}" y="{cy - 22}" width="18" height="22" rx="6" fill="#7FF0C8"/>'
        out += f'<path d="M{cx - 24} {cy + 44} h48" stroke="{shade(head, .35)}" stroke-width="7" stroke-linecap="round"/>'
    if a.get('beak'):
        out += f'<path d="M{cx - 14} {cy + 16} L{cx + 14} {cy + 16} L{cx} {cy + 36}Z" fill="{a["beak"]}" stroke="{shade(a["beak"], .2)}" stroke-width="3" stroke-linejoin="round"/>'
    if a.get('nose'):
        out += f'<ellipse cx="{cx}" cy="{cy + 20}" rx="10" ry="7.5" fill="{a["nose"]}"/>'
        out += f'<path d="M{cx - 14} {cy + 34} Q{cx - 7} {cy + 42} {cx} {cy + 33} Q{cx + 7} {cy + 42} {cx + 14} {cy + 34}" stroke="{ink}" stroke-width="4" fill="none" stroke-linecap="round"/>'
    if a.get('smile'):
        out += f'<path d="M{cx - 36} {cy + 22} Q{cx} {cy + 54} {cx + 36} {cy + 22}" stroke="{ink}" stroke-width="6" fill="none" stroke-linecap="round"/>'
    if a.get('tentacles'):
        out += f'<path d="M{cx - 16} {cy + 30} Q{cx} {cy + 42} {cx + 16} {cy + 30}" stroke="{ink}" stroke-width="5" fill="none" stroke-linecap="round"/>'
    if a.get('whiskers'):
        for s in (-1, 1):
            for k in (-1, 1):
                out += f'<line x1="{cx + s * 22}" y1="{cy + 26 + k * 5}" x2="{cx + s * 62}" y2="{cy + 20 + k * 12}" stroke="{ink}" stroke-width="2.5" stroke-linecap="round"/>'
    for s in (-1, 1):
        if a['name'] not in ('robot', 'penguin', 'owl', 'panda'):
            out += f'<circle cx="{cx + s * 52}" cy="{cy + 22}" r="11" fill="#FF7A8A" fill-opacity=".35"/>'
    return out + '</g>'


def avatar_assets():
    for k, a in enumerate(AVATARS, 1):
        add('avatars', f'avatar_{k:02d}_{a["name"]}', 256, 256, lambda m, a=a: avatar(a), modes='any',
            screens=['home', 'local_setup', 'lobby', 'game', 'results', 'settings'], scales=(1,), folder='images/cards',
            notes='256 px master; shown at 32–96 dp, so one resolution covers 3x.')


# --- UI kit -----------------------------------------------------------------------

def button(kind, state, m):
    p = PALETTE[m]
    if kind == 'primary':
        face, edge, stroke = p['primary'], shade(p['primary'], .28), None
    elif kind == 'danger':
        face, edge, stroke = p['danger'], shade(p['danger'], .28), None
    else:
        face, edge, stroke = p['surface'], p['border'], p['border']
    w, h = (48, 48) if kind == 'icon' else (96, 56)
    r = 14 if kind == 'icon' else 16
    if state == 'disabled':
        return (f'<rect x="1" y="1" width="{w - 2}" height="{h - 4}" rx="{r}" fill="{p["surface2"]}" '
                f'stroke="{p["border"]}" stroke-width="1.5" stroke-dasharray="5 4"/>')
    dy = 2 if state == 'pressed' else 0
    depth = 1 if state == 'pressed' else 3
    if state == 'pressed':
        face = shade(face, .1) if kind in ('primary', 'danger') else p['surface2']
    s = f' stroke="{stroke}" stroke-width="1.5"' if stroke else ''
    return (f'<rect x="1" y="{1 + depth + dy}" width="{w - 2}" height="{h - 4}" rx="{r}" fill="{edge}"/>'
            f'<rect x="1" y="{1 + dy}" width="{w - 2}" height="{h - 4}" rx="{r}" fill="{face}"{s}/>'
            f'<rect x="{r * .7}" y="{3 + dy}" width="{w - r * 1.4}" height="2" rx="1" fill="#FFFFFF" fill-opacity="{.28 if kind in ("primary", "danger") else .6 if m == "light" else .06}"/>')


def panel(kind, m):
    p = PALETTE[m]
    i = uid()
    if kind == 'panel':
        return f'<rect x="1" y="1" width="62" height="62" rx="16" fill="{p["surface"]}" stroke="{p["border"]}" stroke-width="1.5"/>'
    if kind == 'dialog':
        return (f'<defs><filter id="dl{i}" x="-30%" y="-30%" width="160%" height="160%"><feGaussianBlur stdDeviation="8"/></filter></defs>'
                f'<rect x="20" y="24" width="88" height="88" rx="24" fill="{p["shadow"]}" fill-opacity="{.28 if m == "light" else .7}" filter="url(#dl{i})"/>'
                f'<rect x="16" y="16" width="96" height="96" rx="24" fill="{p["surface"]}"'
                + (f' stroke="{p["border"]}" stroke-width="1.5"' if m == 'dark' else '') + '/>')
    if kind == 'toast':
        return f'<rect x="0" y="0" width="64" height="40" rx="20" fill="{p["text"]}"/>'
    return (f'<rect x="1" y="1" width="94" height="46" rx="14" fill="{p["surface2"]}" stroke="{p["border"]}" stroke-width="1.5"/>'
            f'<rect x="10" y="12" width="5" height="24" rx="2.5" fill="{p["text2"]}"/>')


def ui_assets():
    for kind in ['primary', 'secondary', 'danger', 'icon']:
        for st in ['normal', 'pressed', 'disabled']:
            w, h = (48, 48) if kind == 'icon' else (96, 56)
            add('ui', f'ui_button_{kind}_{st}', w, h, lambda m, kind=kind, st=st: button(kind, st, m), anchor=(0, 0),
                nine=(18, 18, 18, 22) if kind != 'icon' else None, screens=['all'],
                notes='Text and icons are drawn by Flutter on top.')
    add('ui', 'ui_panel', 64, 64, lambda m: panel('panel', m), anchor=(0, 0), nine=(20, 20, 20, 20), screens=['all'])
    add('ui', 'ui_dialog', 128, 128, lambda m: panel('dialog', m), anchor=(0, 0), nine=(42, 42, 42, 42), screens=['game', 'join', 'lobby'])
    add('ui', 'ui_toast', 64, 40, lambda m: panel('toast', m), anchor=(0, 0), nine=(20, 20, 20, 20), screens=['game'],
        notes='Text uses the surface colour on this fill.')
    add('ui', 'ui_banner', 96, 48, lambda m: panel('banner', m), anchor=(0, 0), nine=(24, 20, 20, 20), screens=['game', 'join'])


# --- Icons (24 grid, 2 px rounded stroke) -----------------------------------

ICONS = {
    'play': '<path d="M8 5.5v13l10.5-6.5z"/>',
    'pause': '<path d="M9 5.5v13M15 5.5v13"/>',
    'settings': '<circle cx="12" cy="12" r="3"/><path d="M12 3v2.5M12 18.5V21M3 12h2.5M18.5 12H21M5.6 5.6l1.8 1.8M16.6 16.6l1.8 1.8M5.6 18.4l1.8-1.8M16.6 7.4l1.8-1.8"/><circle cx="12" cy="12" r="6.2"/>',
    'home': '<path d="M4 11.5 12 4.5l8 7M6 10v10h12V10M10 20v-5h4v5"/>',
    'wifi': '<path d="M2.5 9.5a14 14 0 0 1 19 0M5.5 13a9.5 9.5 0 0 1 13 0M8.6 16.5a5 5 0 0 1 6.8 0"/><circle cx="12" cy="19.5" r=".6"/>',
    'hotspot': '<circle cx="12" cy="12" r="1.4"/><path d="M8.6 8.6a4.8 4.8 0 0 0 0 6.8M15.4 8.6a4.8 4.8 0 0 1 0 6.8M5.6 5.6a9 9 0 0 0 0 12.8M18.4 5.6a9 9 0 0 1 0 12.8"/>',
    'qr': '<rect x="4" y="4" width="6" height="6" rx="1"/><rect x="14" y="4" width="6" height="6" rx="1"/><rect x="4" y="14" width="6" height="6" rx="1"/><path d="M14 14h2.5v2.5H14zM19.5 14v2M14 19.5h2M19 19.5h.5"/>',
    'link': '<path d="M10 14a4 4 0 0 0 5.66 0l3-3a4 4 0 0 0-5.66-5.66l-1 1"/><path d="M14 10a4 4 0 0 0-5.66 0l-3 3a4 4 0 0 0 5.66 5.66l1-1"/>',
    'refresh': '<path d="M19.5 12a7.5 7.5 0 1 1-2.2-5.3"/><path d="M19.5 4.5v4h-4"/>',
    'sound': '<path d="M4 9.5h3.5L12 5.5v13l-4.5-4H4z"/><path d="M15.5 9a4 4 0 0 1 0 6M18 6.5a7.5 7.5 0 0 1 0 11"/>',
    'music': '<path d="M9 17.5V6l10-2v11.5"/><circle cx="6.5" cy="17.5" r="2.5"/><circle cx="16.5" cy="15.5" r="2.5"/>',
    'haptics': '<rect x="8" y="4" width="8" height="16" rx="2"/><path d="M4.5 9v6M19.5 9v6M2 10.5v3M22 10.5v3"/>',
    'sun': '<circle cx="12" cy="12" r="4"/><path d="M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5.3 5.3l1.4 1.4M17.3 17.3l1.4 1.4M5.3 18.7l1.4-1.4M17.3 6.7l1.4-1.4"/>',
    'moon': '<path d="M19.5 14.5A8 8 0 1 1 9.5 4.5a6.5 6.5 0 0 0 10 10z"/>',
    'auto': '<circle cx="12" cy="12" r="8"/><path d="M12 4a8 8 0 0 1 0 16z" fill="#000000"/>',
    'ai': '<rect x="5" y="8" width="14" height="11" rx="3"/><path d="M12 4.8V8"/><circle cx="12" cy="4" r=".9"/><circle cx="9.5" cy="13.5" r=".9"/><circle cx="14.5" cy="13.5" r=".9"/>',
    'human': '<circle cx="12" cy="8" r="3.5"/><path d="M5 20a7 7 0 0 1 14 0"/>',
    'crown': '<path d="M4 18h16M4.5 18 3.5 8l5 4 3.5-6 3.5 6 5-4-1 10"/>',
    'close': '<path d="M6 6l12 12M18 6 6 18"/>',
    'back': '<path d="M15 5l-7 7 7 7"/>',
    'check': '<path d="M5 12.5l4.5 4.5L19 7.5"/>',
    'info': '<circle cx="12" cy="12" r="9"/><path d="M12 11v6"/><circle cx="12" cy="7.6" r=".6"/>',
}


def icon_assets():
    for k, body in ICONS.items():
        add('icons', f'icon_{k}', 24, 24,
            lambda m, body=body: f'<g fill="none" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">{body}</g>',
            modes='tinted', folder='icons', screens=['all'],
            notes='Single colour; tinted at runtime with the current text or accent colour.')


# --- FX ------------------------------------------------------------------------

def puff(k):
    t = (k - 1) / 5
    out = ''
    for j in range(7):
        a = j * 2 * math.pi / 7 + .4
        d = 14 + 34 * t
        r = 13 + 9 * t - (j % 3) * 2
        op = 1 - t * .85
        out += (f'<circle cx="{n(64 + math.cos(a) * d)}" cy="{n(64 + math.sin(a) * d)}" r="{n(r)}" fill="#F2F3F7" '
                f'fill-opacity="{n(op)}" stroke="#AEB6C4" stroke-opacity="{n(op * .8)}" stroke-width="2"/>')
    if k <= 2:
        out += f'<circle cx="64" cy="64" r="{n(18 - 4 * t)}" fill="#FFFFFF" fill-opacity=".9"/>'
    return out


def sparkle():
    return ('<defs><radialGradient id="sg" cx="50%" cy="50%" r="50%"><stop offset="0" stop-color="#FFF6C8"/>'
            '<stop offset="1" stop-color="#FFF6C8" stop-opacity="0"/></radialGradient></defs>'
            '<circle cx="32" cy="32" r="30" fill="url(#sg)"/>'
            '<path d="M32 4 C34 26 38 30 60 32 C38 34 34 38 32 60 C30 38 26 34 4 32 C26 30 30 26 32 4Z" fill="#FFFFFF" stroke="#F2B632" stroke-width="1.5"/>')


def burst():
    out = ''
    for j in range(16):
        a = j * 2 * math.pi / 16
        c = PLAYER_LIGHT[COLORS[j % 4]]
        x1, y1 = 64 + math.cos(a) * 22, 64 + math.sin(a) * 22
        x2, y2 = 64 + math.cos(a) * 60, 64 + math.sin(a) * 60
        out += f'<line x1="{n(x1)}" y1="{n(y1)}" x2="{n(x2)}" y2="{n(y2)}" stroke="{c}" stroke-width="{6 if j % 2 == 0 else 3.5}" stroke-linecap="round"/>'
    return out + f'<polygon points="{star_pts(64, 64, 20, 9)}" fill="#F2B632" stroke="#FFFFFF" stroke-width="2.5" stroke-linejoin="round"/>'


CONFETTI = {
    'rect': lambda c: f'<rect x="6" y="9" width="12" height="6" rx="1.2" fill="{c}" transform="rotate(-20 12 12)"/>',
    'circle': lambda c: f'<circle cx="12" cy="12" r="5" fill="{c}"/>',
    'triangle': lambda c: f'<path d="M12 5.5 18.5 17h-13z" fill="{c}" stroke="{c}" stroke-width="1.5" stroke-linejoin="round"/>',
    'star': lambda c: f'<polygon points="{star_pts(12, 12.6, 7, 3)}" fill="{c}"/>',
    'ribbon': lambda c: f'<path d="M4 14 Q8 6 12 12 T20 10" stroke="{c}" stroke-width="3.2" fill="none" stroke-linecap="round"/>',
    'diamond': lambda c: f'<path d="M12 4.5 17 12 12 19.5 7 12z" fill="{c}"/>',
}


def fx_assets():
    for k in range(1, 7):
        add('fx', f'fx_capture_puff_{k:02d}', 128, 128, lambda m, k=k: puff(k), modes='any', screens=['game'],
            notes='6 frames over ~240 ms at the capture cell.')
    add('fx', 'fx_sparkle', 64, 64, lambda m: sparkle(), modes='any', screens=['game'])
    add('fx', 'fx_star_burst', 128, 128, lambda m: burst(), modes='any', screens=['game', 'results'])
    for shape, f in CONFETTI.items():
        for col in COLORS:
            add('fx', f'fx_confetti_{shape}_{col}', 24, 24, lambda m, f=f, col=col: f(PLAYER_LIGHT[col]), modes='any',
                screens=['results', 'game'])


# --- How to Play ---------------------------------------------------------------

def htp(k, m):
    p = PALETTE[m]
    W, H = 640, 400
    c = 64
    out = f'<rect width="{W}" height="{H}" rx="32" fill="{p["surface2"]}"/>'

    def arc(x1, y1, x2, y2, lift=46):
        mx = (x1 + x2) / 2
        return (f'<path d="M{n(x1)} {n(y1)} Q{n(mx)} {n(min(y1, y2) - lift)} {n(x2)} {n(y2)}" fill="none" stroke="{p["text2"]}" '
                f'stroke-width="4" stroke-dasharray="2 9" stroke-linecap="round"/>')

    if k == 1:
        out += yard(40, 40, 52, 'red', m)
        for (dr, dc), on in zip([(2, 2), (2, 4), (4, 2), (4, 4)], [1, 1, 1, 0]):
            if on:
                out += shadow_ellipse(40 + dc * 52, 40 + dr * 52 + 12, 18, 6, m) + token(40 + dc * 52, 40 + dr * 52, 21, 'red', m)
        out += start_cell(400, 250, c, 'red', m)
        out += arc(40 + 4 * 52, 40 + 4 * 52 - 24, 432, 262) + shadow_ellipse(432, 296, 22, 7, m) + token(432, 282, 27, 'red', m)
        out += dice(520, 120, 96, 6, m, -8)
    elif k == 2:
        for j in range(7):
            x = 54 + j * c * 1.18
            out += (star_cell if j == 5 else cell)(x, 210, c * 1.18, m)
        out += token(54 + c * .59, 210 + c * .59, 26, 'blue', m, 'idle')
        xs = [54 + c * .59 + j * c * 1.18 for j in range(5)]
        for a, b in zip(xs, xs[1:]):
            out += arc(a, 222, b, 222, 40)
        out += token(xs[-1], 210 + c * .59, 26, 'blue', m, 'ghost')
        out += dice(520, 104, 96, 4, m, 6)
    elif k == 3:
        for j in range(4):
            out += cell(40 + j * 76, 230, 76, m)
        out += token(40 + 76 * 2.5, 268, 28, 'red', m)
        for j in range(6):
            a = j * math.pi / 3
            out += (f'<circle cx="{n(230 + math.cos(a) * 46)}" cy="{n(268 + math.sin(a) * 46)}" r="14" fill="#DCE1E9" '
                    f'stroke="#AEB6C4" stroke-width="2"/>')
        out += token(150, 110, 22, 'blue', m)
        out += (f'<path d="M226 236 Q170 120 160 132" fill="none" stroke="{p["text2"]}" stroke-width="4" stroke-dasharray="2 9" stroke-linecap="round"/>')
        out += star_cell(450, 180, 120, m)
        out += token(492, 226, 26, 'red', m) + token(528, 254, 26, 'yellow', m)
        out += (f'<circle cx="560" cy="170" r="24" fill="{p["primary"]}"/><path d="M549 170l8 8 14-15" fill="none" stroke="{p["on_primary"]}" '
                f'stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>')
    elif k == 4:
        for j, kind in enumerate(['six', 'capture', 'home']):
            x = 40 + j * 196
            out += f'<rect x="{x}" y="70" width="168" height="200" rx="26" fill="{p["surface"]}" stroke="{p["border"]}" stroke-width="2"/>'
            if kind == 'six':
                out += dice(x + 84, 160, 88, 6, m)
            elif kind == 'capture':
                out += token(x + 70, 176, 26, 'blue', m) + token(x + 98, 150, 28, 'red', m, 'hop')
            else:
                out += centre_home(x + 36, 112, 32, m) + token(x + 84, 176, 22, 'red', m)
            out += (f'<circle cx="{x + 84}" cy="310" r="30" fill="{p["primary"]}"/>'
                    + txt(x + 84, 321, '+1', 28, 700, p['on_primary'], 'middle'))
    else:
        out += centre_home(200, 70, 80, m)
        for j, (dx, dy) in enumerate([(-30, -18), (30, -18), (-30, 22), (30, 22)]):
            out += token(320 + dx, 260 + dy, 24, 'red', m)
        out += f'<g transform="translate(278 44) scale(1.3)">{crown()}</g>'
        for j in range(18):
            x, y = 60 + (j * 97) % 520, 40 + (j * 53) % 320
            if abs(x - 320) < 140 and 60 < y < 330:
                continue
            shape = list(CONFETTI)[j % 6]
            out += f'<g transform="translate({x} {y}) scale(1.4) rotate({j * 27} 12 12)">{CONFETTI[shape](PALETTE[m][COLORS[j % 4]])}</g>'
    return out


def htp_assets():
    names = ['leave_base', 'move', 'capture_safe', 'extra_roll', 'win']
    for k, nm in enumerate(names, 1):
        add('htp', f'htp_{k}_{nm}', 640, 400, lambda m, k=k: htp(k, m), anchor=(0, 0), screens=['how_to_play'],
            folder='images/ui', notes='How to Play card illustration.')


# --- Brand -----------------------------------------------------------------------

def mark(cx, cy, s, rim=False):
    """The four-triangle HOME mark inside a white tile, with a token at its heart."""
    i = uid()
    h = s / 2
    out = (f'<defs><filter id="bm{i}" x="-30%" y="-30%" width="160%" height="160%"><feGaussianBlur stdDeviation="{n(s * .03)}"/></filter></defs>'
           f'<rect x="{n(cx - h)}" y="{n(cy - h + s * .04)}" width="{n(s)}" height="{n(s)}" rx="{n(s * .22)}" fill="#000000" fill-opacity=".3" filter="url(#bm{i})"/>'
           f'<rect x="{n(cx - h)}" y="{n(cy - h)}" width="{n(s)}" height="{n(s)}" rx="{n(s * .22)}" fill="#FFFFFF"'
           + (f' stroke="#FFFFFF" stroke-opacity=".5" stroke-width="{n(s * .02)}"' if rim else '') + '/>')
    q = s * .36
    tl, tr, bl, br = (cx - q, cy - q), (cx + q, cy - q), (cx - q, cy + q), (cx + q, cy + q)
    for col, (a, b) in {'red': (bl, br), 'blue': (tl, bl), 'yellow': (tl, tr), 'green': (tr, br)}.items():
        out += (f'<polygon points="{n(a[0])},{n(a[1])} {n(b[0])},{n(b[1])} {n(cx)},{n(cy)}" fill="{PLAYER_LIGHT[col]}" '
                f'stroke="#FFFFFF" stroke-width="{n(s * .03)}" stroke-linejoin="round"/>')
    out += f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(s * .15)}" fill="#FFFFFF"/><circle cx="{n(cx)}" cy="{n(cy)}" r="{n(s * .09)}" fill="#1D2030"/>'
    return out


def brand_bg(w, h):
    return (f'<defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#262A3C"/>'
            f'<stop offset="1" stop-color="#141724"/></linearGradient></defs><rect width="{w}" height="{h}" fill="url(#bg)"/>')


def wordmark(m):
    p = PALETTE[m]
    dots = ''.join(f'<circle cx="{n(26 + j * 22)}" cy="98" r="7" fill="{p[c]}"/>' for j, c in enumerate(COLORS))
    w = text_width('Ludo', 64, 700)
    return txt(16, 72, 'Ludo', 64, 700, p['text']) + txt(16 + w + 14, 72, 'Unbiased', 64, 600, p['text'], opacity=.72) + dots


def brand_assets():
    add('brand', 'brand_app_icon', 1024, 1024, lambda m: brand_bg(1024, 1024) + mark(512, 512, 620), modes='any', scales=(1,),
        screens=['launcher'], notes='Master for flutter_launcher_icons (iOS set and legacy Android).')
    add('brand', 'brand_adaptive_foreground', 1024, 1024, lambda m: mark(512, 512, 560), modes='any', scales=(1,),
        screens=['launcher'], notes='Android adaptive foreground; the mark stays inside the 66% safe zone.')
    add('brand', 'brand_adaptive_background', 1024, 1024, lambda m: brand_bg(1024, 1024), modes='any', scales=(1,),
        screens=['launcher'])
    add('brand', 'brand_splash_logo', 288, 288, lambda m: mark(144, 144, 176, rim=m == 'dark'), screens=['splash'],
        notes='flutter_native_splash image / image_dark; Android 12 icon area is 288 dp.')
    add('brand', 'brand_wordmark', 480, 120, wordmark, anchor=(0, 0.5), screens=['splash', 'home'])


def main():
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)
    for fn in [board_assets, token_assets, dice_assets, card_assets, avatar_assets, ui_assets, icon_assets, fx_assets,
               htp_assets, brand_assets]:
        fn()
    meta = dict(palette=PALETTE, assets=ASSETS)
    (OUT / 'meta.json').write_text(json.dumps(meta, indent=1), encoding='utf-8')
    files = sum(1 for _ in OUT.rglob('*.svg'))
    print(f'{len(ASSETS)} logical assets, {files} SVG files in {OUT}')


if __name__ == '__main__':
    main()
