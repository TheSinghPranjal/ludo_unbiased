#!/usr/bin/env python3
"""Generates design/wireframes.html, the Phase 2 wireframe sheets.

Every board is drawn from the spec §1.1 tables below, the same tables that
lib/core/constants/board_constants.dart will hold, so the wireframe board is
the layout reference for the Flame board.

Usage: python3 tool/design/gen_wireframes.py [fragment_out.html]
The optional argument also writes a copy without the document skeleton, for
publishing as an artifact.
"""
import html
import math
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]

# --- Board geometry (spec §1.1) -------------------------------------------

TRACK = [(13, 6), (12, 6), (11, 6), (10, 6), (9, 6), (8, 5), (8, 4), (8, 3), (8, 2), (8, 1),
         (8, 0), (7, 0), (6, 0), (6, 1), (6, 2), (6, 3), (6, 4), (6, 5), (5, 6), (4, 6),
         (3, 6), (2, 6), (1, 6), (0, 6), (0, 7), (0, 8), (1, 8), (2, 8), (3, 8), (4, 8),
         (5, 8), (6, 9), (6, 10), (6, 11), (6, 12), (6, 13), (6, 14), (7, 14), (8, 14), (8, 13),
         (8, 12), (8, 11), (8, 10), (8, 9), (9, 8), (10, 8), (11, 8), (12, 8), (13, 8), (14, 8),
         (14, 7), (14, 6)]
COLORS = ['red', 'blue', 'yellow', 'green']
START = {'red': 0, 'blue': 13, 'yellow': 26, 'green': 39}
STARS = {8, 21, 34, 47}
HOME_COL = {
    'red': [(13, 7), (12, 7), (11, 7), (10, 7), (9, 7)],
    'blue': [(7, 1), (7, 2), (7, 3), (7, 4), (7, 5)],
    'yellow': [(1, 7), (2, 7), (3, 7), (4, 7), (5, 7)],
    'green': [(7, 13), (7, 12), (7, 11), (7, 10), (7, 9)],
}
YARD = {'blue': (0, 0), 'yellow': (0, 9), 'green': (9, 9), 'red': (9, 0)}
ENTRY = {'red': ((14, 7), 'up'), 'blue': ((7, 0), 'right'),
         'yellow': ((0, 7), 'down'), 'green': ((7, 14), 'left')}
FINISH = {'red': (8.4, 7.5), 'blue': (7.5, 6.6), 'yellow': (6.6, 7.5), 'green': (7.5, 8.4)}
NAME = {'red': 'Red', 'blue': 'Blue', 'yellow': 'Yellow', 'green': 'Green'}
SYMBOL = {'red': '●', 'blue': '■', 'yellow': '▲', 'green': '★'}

assert len(TRACK) == 52 and len(set(TRACK)) == 52


def cell_of(color, rel):
    if 0 <= rel <= 50:
        return TRACK[(START[color] + rel) % 52]
    if 51 <= rel <= 55:
        return HOME_COL[color][rel - 51]
    raise ValueError(rel)


# --- SVG builder -------------------------------------------------------------

def esc(t):
    return html.escape(str(t), quote=True)


def n(v):
    r = round(v, 1)
    return str(int(r)) if r == int(r) else str(r)


class S:
    """An SVG sheet. Shapes get the wobble filter, text never does.

    Planes stack in order, so an overlay drawn on a new plane covers the
    text of the screen beneath it.
    """

    def __init__(self, w, h):
        self.w, self.h = w, h
        self.planes = []
        self.top = {'anno': [], 'annotext': [], 'call': []}
        self.off = (0, 0)
        self.dark = False
        self.alpha = 1.0
        self.plane()

    def plane(self):
        self.planes.append({'base': [], 'text': []})

    def add(self, layer, el):
        if self.alpha < 1:
            el = f'<g opacity="{self.alpha:g}">{el}</g>'
        if self.dark and layer in ('base', 'text'):
            el = f'<g class="dk">{el}</g>'
        ox, oy = self.off
        if ox or oy:
            el = f'<g transform="translate({n(ox)} {n(oy)})">{el}</g>'
        if layer in ('base', 'text'):
            self.planes[-1][layer].append(el)
        else:
            self.top[layer].append(el)

    # primitives
    def rect(self, x, y, w, h, cls='s fw', rx=0, extra='', layer='base'):
        r = f' rx="{n(rx)}"' if rx else ''
        self.add(layer, f'<rect x="{n(x)}" y="{n(y)}" width="{n(w)}" height="{n(h)}"{r} class="{cls}"{extra}/>')

    def circle(self, cx, cy, r, cls='s fw', extra='', layer='base'):
        self.add(layer, f'<circle cx="{n(cx)}" cy="{n(cy)}" r="{n(r)}" class="{cls}"{extra}/>')

    def line(self, x1, y1, x2, y2, cls='s', layer='base', extra=''):
        self.add(layer, f'<line x1="{n(x1)}" y1="{n(y1)}" x2="{n(x2)}" y2="{n(y2)}" class="{cls}"{extra}/>')

    def path(self, d, cls='s', layer='base', extra=''):
        self.add(layer, f'<path d="{d}" class="{cls}"{extra}/>')

    def poly(self, pts, cls='s fw', layer='base'):
        p = ' '.join(f'{n(x)},{n(y)}' for x, y in pts)
        self.add(layer, f'<polygon points="{p}" class="{cls}"/>')

    def text(self, x, y, t, size=16, cls='h', anchor='start', weight=None, layer='text'):
        lines = str(t).split('\n')
        wgt = f' font-weight="{weight}"' if weight else ''
        a = f' text-anchor="{anchor}"' if anchor != 'start' else ''
        if len(lines) == 1:
            self.add(layer, f'<text x="{n(x)}" y="{n(y)}" font-size="{n(size)}" class="{cls}"{a}{wgt}>{esc(t)}</text>')
            return
        spans = ''.join(
            f'<tspan x="{n(x)}" dy="{n(0 if i == 0 else size * 1.18)}">{esc(l)}</tspan>' for i, l in enumerate(lines))
        self.add(layer, f'<text x="{n(x)}" y="{n(y)}" font-size="{n(size)}" class="{cls}"{a}{wgt}>{spans}</text>')

    def squig(self, x, y, w, amp=2.2, cls='s1'):
        d = f'M{n(x)} {n(y)}'
        step = 9
        k = 0
        xx = x
        while xx + step <= x + w:
            k += 1
            d += f' q{n(step / 2)} {n(-amp if k % 2 else amp)} {n(step)} 0'
            xx += step
        self.path(d, cls)

    def lines(self, x, y, w, count, gap=16, last=0.6):
        for i in range(count):
            self.squig(x, y + i * gap, w * (last if i == count - 1 and count > 1 else 1))

    def xbox(self, x, y, w, h, rx=6, cls='s1 fw'):
        self.rect(x, y, w, h, cls, rx=rx)
        self.line(x + 4, y + 4, x + w - 4, y + h - 4, 's1')
        self.line(x + w - 4, y + 4, x + 4, y + h - 4, 's1')

    # annotations
    def arrow(self, x1, y1, x2, y2, bend=0.0, cls='pb'):
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        dx, dy = x2 - x1, y2 - y1
        ln = math.hypot(dx, dy) or 1
        cx, cy = mx - dy / ln * bend * ln, my + dx / ln * bend * ln
        self.add('anno', f'<path d="M{n(x1)} {n(y1)} Q{n(cx)} {n(cy)} {n(x2)} {n(y2)}" class="{cls}" marker-end="url(#ah)"/>')

    def note(self, x, y, t, size=17, anchor='start'):
        self.text(x, y, t, size, 'nb', anchor, layer='annotext')

    def dim(self, x1, y1, x2, y2, label, size=15, lx=None, ly=None):
        self.add('anno', f'<line x1="{n(x1)}" y1="{n(y1)}" x2="{n(x2)}" y2="{n(y2)}" class="pb thin" '
                         f'marker-start="url(#ah)" marker-end="url(#ah)"/>')
        if lx is None:
            lx, ly = (x1 + x2) / 2, (y1 + y2) / 2 - 6
        self.add('annotext', f'<text x="{n(lx)}" y="{n(ly)}" font-size="{n(size)}" class="nb dimlbl" '
                             f'text-anchor="middle">{esc(label)}</text>')

    def callout(self, num, x, y):
        self.add('call', f'<circle cx="{n(x)}" cy="{n(y)}" r="12" class="co"/>'
                         f'<text x="{n(x)}" y="{n(y + 5)}" font-size="15" class="cot" text-anchor="middle">{num}</text>')

    def render(self, label):
        parts = []
        for p in self.planes:
            parts.append(f'<g filter="url(#wob)">{"".join(p["base"])}</g><g>{"".join(p["text"])}</g>')
        parts.append(f'<g filter="url(#wob)">{"".join(self.top["anno"])}</g>')
        parts.append(f'<g>{"".join(self.top["annotext"])}</g><g>{"".join(self.top["call"])}</g>')
        return (f'<svg viewBox="0 0 {n(self.w)} {n(self.h)}" role="img" aria-label="{esc(label)}">'
                + ''.join(parts) + '</svg>')


# --- Small drawings ----------------------------------------------------------

def sym(s, cx, cy, r, color, cls='ink'):
    if color == 'red':
        s.circle(cx, cy, r, cls)
    elif color == 'blue':
        s.rect(cx - r * .85, cy - r * .85, r * 1.7, r * 1.7, cls)
    elif color == 'yellow':
        s.poly([(cx, cy - r * 1.05), (cx + r, cy + r * .75), (cx - r, cy + r * .75)], cls)
    else:
        pts = []
        for i in range(10):
            a = -math.pi / 2 + i * math.pi / 5
            rr = r * 1.15 if i % 2 == 0 else r * .5
            pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
        s.poly(pts, cls)


def star_outline(s, cx, cy, r, cls='s1'):
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else r * .45
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    s.add('base', '<polygon points="' + ' '.join(f'{n(x)},{n(y)}' for x, y in pts) + f'" class="{cls}"/>')


def glyph(s, cx, cy, kind, sz=10):
    if kind == 'pause':
        s.rect(cx - sz * .6, cy - sz * .7, sz * .4, sz * 1.4, 'ink', rx=1)
        s.rect(cx + sz * .2, cy - sz * .7, sz * .4, sz * 1.4, 'ink', rx=1)
    elif kind == 'back':
        s.path(f'M{n(cx + sz * .35)} {n(cy - sz * .7)} L{n(cx - sz * .4)} {n(cy)} L{n(cx + sz * .35)} {n(cy + sz * .7)}')
    elif kind == 'close':
        s.line(cx - sz * .6, cy - sz * .6, cx + sz * .6, cy + sz * .6)
        s.line(cx + sz * .6, cy - sz * .6, cx - sz * .6, cy + sz * .6)
    elif kind == 'gear':
        s.circle(cx, cy, sz * .45, 's fw')
        for i in range(8):
            a = i * math.pi / 4
            s.line(cx + math.cos(a) * sz * .6, cy + math.sin(a) * sz * .6,
                   cx + math.cos(a) * sz * .95, cy + math.sin(a) * sz * .95)
    elif kind == 'qr':
        for dx, dy in [(-1, -1), (1, -1), (-1, 1)]:
            s.rect(cx + dx * sz * .55 - sz * .35, cy + dy * sz * .55 - sz * .35, sz * .7, sz * .7, 's1 fw')
        s.rect(cx + sz * .3, cy + sz * .3, sz * .45, sz * .45, 'ink')
    elif kind == 'wifi':
        for k in (1, 2, 3):
            r = sz * .32 * k
            s.path(f'M{n(cx - r * .8)} {n(cy + sz * .4 - r * .6)} Q{n(cx)} {n(cy + sz * .4 - r * 1.3)} '
                   f'{n(cx + r * .8)} {n(cy + sz * .4 - r * .6)}', 's1')
        s.circle(cx, cy + sz * .45, 1.8, 'ink')
    elif kind == 'wifioff':
        glyph(s, cx, cy, 'wifi', sz)
        s.line(cx - sz * .8, cy - sz * .7, cx + sz * .8, cy + sz * .8)
    elif kind == 'check':
        s.path(f'M{n(cx - sz * .6)} {n(cy)} L{n(cx - sz * .15)} {n(cy + sz * .5)} L{n(cx + sz * .7)} {n(cy - sz * .55)}')
    elif kind == 'plus':
        s.line(cx - sz * .6, cy, cx + sz * .6, cy)
        s.line(cx, cy - sz * .6, cx, cy + sz * .6)
    elif kind == 'crown':
        s.poly([(cx - sz, cy + sz * .5), (cx - sz, cy - sz * .4), (cx - sz * .45, cy + sz * .05), (cx, cy - sz * .7),
                (cx + sz * .45, cy + sz * .05), (cx + sz, cy - sz * .4), (cx + sz, cy + sz * .5)], 's1 g2')
    elif kind == 'ai':
        s.rect(cx - sz * .7, cy - sz * .5, sz * 1.4, sz * 1.1, 's1 fw', rx=3)
        s.circle(cx - sz * .3, cy, 1.6, 'ink')
        s.circle(cx + sz * .3, cy, 1.6, 'ink')
        s.line(cx, cy - sz * .5, cx, cy - sz * .85, 's1')
    elif kind == 'person':
        s.circle(cx, cy - sz * .35, sz * .32, 's1 fw')
        s.path(f'M{n(cx - sz * .65)} {n(cy + sz * .7)} Q{n(cx)} {n(cy - sz * .2)} {n(cx + sz * .65)} {n(cy + sz * .7)}', 's1')


def icon_btn(s, x, y, kind, size=40):
    s.rect(x, y, size, size, 's fw', rx=12)
    glyph(s, x + size / 2, y + size / 2, kind, size * .3)


def btn(s, x, y, w, h, label, kind='primary', size=None, icon=None):
    size = size or min(20, h * .42)
    if kind == 'primary':
        s.rect(x, y, w, h, 's ink', rx=14)
        tcls = 'b w'
    elif kind == 'danger':
        s.rect(x, y, w, h, 's3 fw', rx=14)
        s.rect(x + 4, y + 4, w - 8, h - 8, 's1 fw', rx=10)
        tcls = 'b'
    elif kind == 'disabled':
        s.rect(x, y, w, h, 's1 g1 dash', rx=14)
        tcls = 'b m'
    else:
        s.rect(x, y, w, h, 's fw', rx=14)
        tcls = 'b'
    tx = x + w / 2
    if icon:
        glyph(s, x + 26, y + h / 2, icon, 9)
    s.text(tx, y + h / 2 + size * .36, label, size, tcls, 'middle', 700)


def toggle(s, x, y, on):
    if on:
        s.rect(x, y, 48, 28, 's ink', rx=14)
        s.circle(x + 34, y + 14, 9, 's1 fw')
    else:
        s.rect(x, y, 48, 28, 's fw', rx=14)
        s.circle(x + 14, y + 14, 9, 's1 g2')


def seg(s, x, y, w, h, opts, sel, size=15):
    s.rect(x, y, w, h, 's fw', rx=12)
    k = len(opts)
    sw = w / k
    s.rect(x + sel * sw + 3, y + 3, sw - 6, h - 6, 's1 g2', rx=9)
    for i, o in enumerate(opts):
        if 0 < i:
            s.line(x + i * sw, y + 8, x + i * sw, y + h - 8, 's1')
        s.text(x + i * sw + sw / 2, y + h / 2 + size * .36, o, size, 'b', 'middle', 700 if i == sel else None)


def field(s, x, y, w, label, value, err=None, h=48, placeholder=False):
    s.text(x, y - 8, label, 14, 'b m', weight=700)
    s.rect(x, y, w, h, 's3 fw' if err else 's fw', rx=12)
    s.text(x + 14, y + h / 2 + 6, value, 17, 'b m' if placeholder else 'b')
    if err:
        s.circle(x + w - 22, y + h / 2, 9, 's1 fw')
        s.text(x + w - 22, y + h / 2 + 5, '!', 14, 'b', 'middle', 700)
        s.text(x, y + h + 20, err, 14, 'b', weight=700)


def topbar(s, w, title, back=True, right=None, y=56):
    if back:
        icon_btn(s, 16, y, 'back')
    s.text(w / 2, y + 28, title, 26, 'h', 'middle')
    if right:
        icon_btn(s, w - 56, y, right)


def statusbar(s, w, y=0):
    s.text(34, y + 33, '9:41', 15, 'b', weight=700)
    s.rect(w - 58, y + 21, 26, 13, 's1 fw', rx=3)
    s.rect(w - 56, y + 23, 17, 9, 'ink', rx=1)


def dice(s, cx, cy, size, face=None, tumble=False, blank_label=None):
    if tumble:
        s.alpha = .35
        s.add('base', f'<rect x="{n(cx - size / 2 - 10)}" y="{n(cy - size / 2 + 4)}" width="{n(size)}" height="{n(size)}" '
                      f'rx="{n(size * .22)}" class="s1 fw" transform="rotate(-24 {n(cx - 10)} {n(cy + 4)})"/>')
        s.alpha = 1
        for k in (1, 2):
            s.path(f'M{n(cx - size * .9)} {n(cy - size * .1 * k)} q{n(size * .2)} {n(-size * .15)} {n(size * .35)} 0', 's1')
    rot = f' transform="rotate(18 {n(cx)} {n(cy)})"' if tumble else ''
    s.add('base', f'<rect x="{n(cx - size / 2)}" y="{n(cy - size / 2)}" width="{n(size)}" height="{n(size)}" '
                  f'rx="{n(size * .22)}" class="s fw"{rot}/>')
    if face is None:
        if blank_label:
            s.text(cx, cy + size * .12, blank_label, size * .3, 'h', 'middle')
        return
    pip = {1: [(0, 0)], 2: [(-1, -1), (1, 1)], 3: [(-1, -1), (0, 0), (1, 1)],
           4: [(-1, -1), (1, -1), (-1, 1), (1, 1)], 5: [(-1, -1), (1, -1), (0, 0), (-1, 1), (1, 1)],
           6: [(-1, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (1, 1)]}[face]
    a = math.radians(18) if tumble else 0
    for px, py in pip:
        dx, dy = px * size * .26, py * size * .26
        rx, ry = dx * math.cos(a) - dy * math.sin(a), dx * math.sin(a) + dy * math.cos(a)
        s.circle(cx + rx, cy + ry, size * .085, 'ink')


def toast(s, cx, cy, label, size=20):
    w = len(label) * size * .52 + 40
    h = size * 2.1
    s.rect(cx - w / 2, cy - h / 2, w, h, 's ink', rx=h / 2)
    s.text(cx, cy + size * .36, label, size, 'b w', 'middle', 700)


def spinner(s, cx, cy, r=18):
    for i in range(8):
        a = i * math.pi / 4
        s.alpha = .25 + .09 * i
        s.circle(cx + math.cos(a) * r, cy + math.sin(a) * r, r * .2, 'ink')
    s.alpha = 1


# --- Board -------------------------------------------------------------------

class Board:
    def __init__(self, x, y, size):
        self.x, self.y, self.size = x, y, size
        self.c = size / 15

    def cc(self, r, c):
        return self.x + (c + .5) * self.c, self.y + (r + .5) * self.c

    def pt(self, r, c):
        return self.x + c * self.c, self.y + r * self.c

    def slot(self, color, tid):
        r0, c0 = YARD[color]
        dr, dc = [(2, 2), (2, 4), (4, 2), (4, 4)][tid]
        return self.pt(r0 + dr, c0 + dc)

    def tok_xy(self, color, tid, rel):
        if rel == -1:
            return self.slot(color, tid)
        if rel == 56:
            r, c = FINISH[color]
            return self.pt(r, c)
        return self.cc(*cell_of(color, rel))


def token(s, x, y, r, color):
    s.add('base', f'<ellipse cx="{n(x + r * .12)}" cy="{n(y + r * .55)}" rx="{n(r)}" ry="{n(r * .55)}" class="shadow"/>')
    s.circle(x, y, r, 's fw')
    s.circle(x, y, r * .7, 's1 fw')
    sym(s, x, y, r * .36, color)


def arrow_glyph(s, cx, cy, d, c):
    v = {'up': (0, -1), 'down': (0, 1), 'left': (-1, 0), 'right': (1, 0)}[d]
    px, py = -v[1], v[0]
    tip = (cx + v[0] * c * .32, cy + v[1] * c * .32)
    tail = (cx - v[0] * c * .3, cy - v[1] * c * .3)
    s.line(tail[0], tail[1], tip[0], tip[1], 's1')
    s.poly([tip, (tip[0] - v[0] * c * .2 + px * c * .16, tip[1] - v[1] * c * .2 + py * c * .16),
            (tip[0] - v[0] * c * .2 - px * c * .16, tip[1] - v[1] * c * .2 - py * c * .16)], 'ink')


def draw_board(s, B, tokens=(), movable=(), ghosts=(), indices=False, badge_stacks=True, hide=()):
    c = B.c
    s.rect(B.x - 3, B.y - 3, B.size + 6, B.size + 6, 's3 fw', rx=6)
    for col, (r0, c0) in YARD.items():
        x, y = B.pt(r0, c0)
        s.rect(x, y, 6 * c, 6 * c, 's1 g2')
        s.rect(x + c, y + c, 4 * c, 4 * c, 's1 fw', rx=c * .3)
        for t in range(4):
            sx, sy = B.slot(col, t)
            s.circle(sx, sy, c * .55, 's1 fw')
        lx, ly = x + 3 * c, (y + .68 * c) if r0 == 0 else (y + 5.68 * c)
        if c >= 14:
            s.text(lx, ly, f'{NAME[col].upper()} {SYMBOL[col]}', c * .5, 'h', 'middle')
    for i, (r, cc) in enumerate(TRACK):
        x, y = B.pt(r, cc)
        s.rect(x, y, c, c, 's1 g1' if i in START.values() else 's1 fw')
    for col, cells in HOME_COL.items():
        for k, (r, cc) in enumerate(cells):
            x, y = B.pt(r, cc)
            s.rect(x, y, c, c, 's1 hatch')
            if indices:
                s.rect(x + c * .18, y + c * .26, c * .64, c * .48, 'fw', rx=2)
                s.text(x + c / 2, y + c * .62, str(51 + k), c * .36, 'b', 'middle', 700)
    for i in STARS:
        x, y = B.cc(*TRACK[i])
        star_outline(s, x, y, c * .4)
    for col, i in START.items():
        x, y = B.cc(*TRACK[i])
        s.text(x, y + c * .2, 'S', c * .56, 'h', 'middle')
    for col, ((r, cc), d) in ENTRY.items():
        x, y = B.cc(r, cc)
        arrow_glyph(s, x, y, d, c)
    # centre: four triangles meeting at the middle
    m = B.pt(7.5, 7.5)
    tl, tr, bl, br = B.pt(6, 6), B.pt(6, 9), B.pt(9, 6), B.pt(9, 9)
    s.poly([bl, br, m], 's1 g2')
    s.poly([tl, bl, m], 's1 g1')
    s.poly([tl, tr, m], 's1 g2')
    s.poly([tr, br, m], 's1 g1')
    for col in COLORS:
        fx, fy = B.pt(*FINISH[col])
        if c >= 14:
            sym(s, fx, fy, c * .17, col, 'ink lite')
    if indices:
        for i, (r, cc) in enumerate(TRACK):
            x, y = B.pt(r, cc)
            if i in STARS or i in START.values() or i in (11, 24, 37, 50):
                s.text(x + c * .08, y + c * .3, str(i), c * .26, 'b', weight=700)
            else:
                s.text(x + c / 2, y + c * .64, str(i), c * .38, 'b', 'middle', 700)
    # tokens, grouped by position so stacks can be drawn
    groups = {}
    for col, tid, rel in tokens:
        if (col, tid) in hide:
            continue
        x, y = B.tok_xy(col, tid, rel)
        if rel == 56:
            x += (tid - 1.5) * c * .18
        groups.setdefault((round(x, 1), round(y, 1)), []).append((col, tid, rel, x, y))
    r = c * .36
    for (gx, gy), items in groups.items():
        k = len(items)
        if k == 1:
            offs = [(0, 0)]
        elif k == 2:
            offs = [(-c * .16, -c * .12), (c * .16, c * .12)]
        else:
            offs = [(-c * .17, c * .1), (c * .17, c * .1), (0, -c * .16)]
        rr = r if k == 1 else r * .8
        for j, (col, tid, rel, x, y) in enumerate(items[:3]):
            token(s, x + offs[j][0], y + offs[j][1], rr, col)
        if k >= 3 and badge_stacks:
            bx, by = gx + c * .38, gy - c * .38
            s.circle(bx, by, c * .26, 's1 ink')
            s.text(bx, by + c * .1, str(k), c * .3, 'b w', 'middle', 700)
        for col, tid, rel, x, y in items:
            if (col, tid) in movable:
                s.circle(gx, gy, r * 1.55, 's2 dash')
                break
    for col, rel in ghosts:
        x, y = B.cc(*cell_of(col, rel))
        s.circle(x, y, r * .95, 's1 dash ghost')
        s.circle(x, y, r * .2, 'ink')


# --- Player card -------------------------------------------------------------

def card(s, x, y, w, h, color, name, side='left', state='inactive', active=False, ring=None,
         die=None, home=0, sub=None, rank=None):
    pad = 8
    if state == 'empty':
        s.rect(x, y, w, h, 's1 dash fw', rx=14)
        s.text(x + w / 2, y + h / 2 - 2, f'{NAME[color]} seat', h * .22, 'b m', 'middle', 700)
        s.text(x + w / 2, y + h / 2 + h * .24, 'empty', h * .2, 'b m', 'middle')
        return
    if active:
        s.rect(x - 7, y - 7, w + 14, h + 14, 'glow', rx=20)
        s.rect(x - 3.5, y - 3.5, w + 7, h + 7, 'ringtrack', rx=17)
        if ring is not None:
            s.add('base', f'<rect x="{n(x - 3.5)}" y="{n(y - 3.5)}" width="{n(w + 7)}" height="{n(h + 7)}" rx="17" '
                          f'pathLength="100" stroke-dasharray="{n(ring * 100)} 100" class="ring"/>')
    s.rect(x, y, w, h, 's3 fw' if active else 's fw', rx=14)
    if state == 'disconnected':
        s.alpha = .45
    compact = w < 160
    ar = 13 if compact else (h - 2 * pad) * .42
    ds = h * .52 if compact else h - 2 * pad - 6
    if side == 'left':
        ax, dx = x + pad + ar + 2, x + w - pad - ds / 2 - 2
        tx = ax + ar + 8
        tmax = dx - ds / 2 - 6 - tx
    else:
        ax, dx = x + w - pad - ar - 2, x + pad + ds / 2 + 2
        tx = dx + ds / 2 + 8
        tmax = ax - ar - 8 - tx
    ay = y + h / 2
    s.circle(ax, ay, ar, 's1 g1')
    if compact:
        sym(s, ax, ay, ar * .42, color)
    else:
        glyph(s, ax, ay, 'ai' if '(AI)' in name else 'person', ar * .9)
        s.circle(ax + ar * .72, ay + ar * .72, ar * .36, 's1 fw')
        sym(s, ax + ar * .72, ay + ar * .72, ar * .17, color)
    size = 14 if compact else h * .23
    label = name.replace(' (AI)', '')
    maxc = max(3, int(tmax / (size * .5)))
    if len(label) > maxc:
        label = label[:maxc - 1] + '…'
    s.text(tx, y + h * .43, label, size, 'b', weight=700)
    if sub:
        s.text(tx, y + h * .76, sub, h * .17, 'b m' if state != 'disconnected' else 'b', weight=700)
    else:
        for k in range(4):
            s.circle(tx + 5 + k * size * .62, y + h * .7, h * .055, 'ink' if k < home else 's1 fw')
    s.alpha = 1
    if state == 'disconnected':
        s.circle(ax - ar * .6, ay - ar * .6, ar * .45, 's1 fw')
        glyph(s, ax - ar * .6, ay - ar * .6, 'wifioff', ar * .38)
    if state == 'finished':
        glyph(s, ax, ay - ar - 4, 'crown', ar * .45)
    if rank:
        s.text(dx, ay + 6, rank, h * .28, 'h', 'middle')
    elif state == 'disconnected' and die is None:
        s.text(dx, ay + h * .1, '0:45', h * .3, 'h', 'middle')
    elif state == 'thinking':
        s.rect(dx - ds / 2, ay - ds / 2, ds, ds, 's1 dash', rx=ds * .22)
        for k in (-1, 0, 1):
            s.circle(dx + k * ds * .22, ay, ds * .07, 'ink')
    elif die == 'roll':
        dice(s, dx, ay, ds * .9, 5, tumble=True)
    elif die == 'tap':
        dice(s, dx, ay, ds, None, blank_label='tap')
    elif isinstance(die, int):
        dice(s, dx, ay, ds, die)
    elif state != 'finished':
        s.rect(dx - ds / 2, ay - ds / 2, ds, ds, 's1 dash', rx=ds * .22)


# --- Game screen --------------------------------------------------------------

SEATS4 = {'red': 'Asha', 'blue': 'Kiwi (AI)', 'yellow': 'Ravi', 'green': 'Moss (AI)'}
BASE_TOKENS = [('red', 0, -1), ('red', 1, -1), ('red', 2, 12), ('red', 3, 30),
               ('blue', 0, -1), ('blue', 1, 5), ('blue', 2, -1), ('blue', 3, -1),
               ('yellow', 0, -1), ('yellow', 1, -1), ('yellow', 2, -1), ('yellow', 3, 20),
               ('green', 0, 44), ('green', 1, -1), ('green', 2, -1), ('green', 3, -1)]


def with_tokens(changes, base=None):
    """Returns BASE_TOKENS with (color, tid) -> rel changes applied."""
    base = base or BASE_TOKENS
    return [(c, t, changes.get((c, t), r)) for c, t, r in base]


def game_layout(w, h):
    big = w >= 700
    m = 40 if big else (12 if w < 360 else 16)
    top = 60 if big else 50
    content_top = top + 54
    gap = 16 if big else (8 if w < 360 else 10)
    ch = 104 if big else (64 if w < 360 else 72)
    sh = 52 if big else (36 if w < 360 else 40)
    bottom = 34
    board = min(w - 2 * m, h - content_top - bottom - 2 * ch - 3 * gap - sh - 14)
    total = 2 * ch + 3 * gap + board + sh
    y0 = content_top + max(0, (h - bottom - content_top - total) / 2)
    bx = (w - board) / 2
    cw = (board - gap) / 2
    by = y0 + ch + gap
    L = {'m': m, 'top': top, 'gap': gap, 'ch': ch, 'cw': cw, 'sh': sh, 'board': board, 'bx': bx, 'by': by,
         'cards': {'blue': (bx, y0, 'left'), 'yellow': (bx + cw + gap, y0, 'right'),
                   'red': (bx, by + board + gap, 'left'), 'green': (bx + cw + gap, by + board + gap, 'right')},
         'status_y': by + board + gap + ch + gap}
    return L


def game(s, w, h, active='red', ring=.72, die=None, tokens=None, movable=(), ghosts=(), status=None,
         toast_text=None, seats=None, states=None, homes=None, title='Local game', chip=None, extra=None,
         subs=None, hide=()):
    statusbar(s, w)
    L = game_layout(w, h)
    icon_btn(s, L['m'], L['top'] + 4, 'pause', 44 if w >= 700 else 40)
    s.text(w / 2, L['top'] + 31, title, 24 if w >= 700 else 20, 'h', 'middle')
    if chip:
        cw = len(chip) * 8.4 + 22
        s.rect(w - L['m'] - cw, L['top'] + 10, cw, 30, 's1 fw', rx=15)
        s.text(w - L['m'] - cw / 2, L['top'] + 30, chip, 14, 'b', 'middle', 700)
    seats = seats or SEATS4
    states = states or {}
    homes = homes or {}
    subs = subs or {}
    for col, (cx, cy, side) in L['cards'].items():
        if col not in seats:
            card(s, cx, cy, L['cw'], L['ch'], col, '', side, 'empty')
            continue
        st = states.get(col, 'inactive')
        is_active = col == active
        card(s, cx, cy, L['cw'], L['ch'], col, seats[col], side, st, is_active,
             ring if is_active else None, die if is_active else None, homes.get(col, 0), subs.get(col))
    B = Board(L['bx'], L['by'], L['board'])
    toks = tokens if tokens is not None else [t for t in BASE_TOKENS if t[0] in seats]
    draw_board(s, B, toks, movable, ghosts, hide=hide)
    if extra:
        extra(s, B, L)
    if status:
        s.rect(L['bx'], L['status_y'], L['board'], L['sh'], 's1 g1', rx=12)
        s.text(w / 2, L['status_y'] + L['sh'] / 2 + 6, status, 17 if w < 700 else 20, 'b', 'middle', 700)
    if toast_text:
        toast(s, w / 2, L['by'] + L['board'] / 2, toast_text, 20 if w < 700 else 26)
    s.rect(w / 2 - 67, h - 14, 134, 5, 'ink', rx=2.5)
    return B, L


# --- Sheet scaffolding -----------------------------------------------------

def phone_frame(s, x, y, w, h, tablet=False):
    s.rect(x - 8, y - 8, w + 16, h + 16, 's3 fw', rx=64 if not tablet else 40)
    s.rect(x, y, w, h, 's1 fw', rx=52 if not tablet else 30)
    if tablet:
        s.circle(x + w / 2, y - 1, 3.5, 'ink')
    else:
        s.rect(x + w / 2 - 62, y + 10, 124, 30, 'ink', rx=15)


def phone_sheet(label, draw, w=390, h=844, pad=24, dark=False, left=0, right=0, tablet=False, top_extra=0):
    s = S(w + 2 * pad + left + right, h + 2 * pad + top_extra)
    s.dark = dark
    phone_frame(s, pad + left, pad + top_extra, w, h, tablet)
    s.off = (pad + left, pad + top_extra)
    draw(s, w, h)
    s.off = (0, 0)
    s.dark = False
    return s


def figure(svg, title, items=(), note=None):
    lis = ''.join(f'<li>{i}</li>' for i in items)
    ol = f'<ol>{lis}</ol>' if items else ''
    nt = f'<p>{note}</p>' if note else ''
    return f'<figure class="sheet">{svg}<figcaption><strong>{title}</strong>{nt}{ol}</figcaption></figure>'


# --- Section 1: Flow -------------------------------------------------------

def flow_sheet():
    s = S(1440, 700)
    N = {
        'splash': (100, 330, 'Splash'), 'home': (300, 330, 'Home'),
        'settings': (300, 120, 'Settings'), 'how': (300, 540, 'How to Play'),
        'local': (540, 110, 'Local Setup'), 'quick': (540, 230, 'Quick Play'),
        'host': (540, 400, 'Host Lobby'), 'join': (540, 560, 'Join'),
        'joined': (790, 620, 'Joined lobby'), 'errors': (790, 490, 'Room full ·\nVersion · Kicked'),
        'game': (1010, 330, 'Game'), 'pause': (1010, 120, 'Pause'),
        'results': (1190, 190, 'Results'), 'recon': (1190, 440, 'Reconnecting'),
        'hostlost': (1190, 590, 'Host lost'),
    }
    W, H = 168, 64
    for k, (cx, cy, label) in N.items():
        big = k == 'game'
        w, h = (W + 30, H + 24) if big else (W, H)
        s.rect(cx - w / 2, cy - h / 2, w, h, 's3 fw' if big else 's fw', rx=14)
        if '\n' in label:
            s.text(cx, cy - 6, label, 21, 'h', 'middle')
        else:
            s.text(cx, cy + 8, label, 26 if big else 23, 'h', 'middle')

    def edge(k, tx, ty):
        cx, cy, _ = N[k]
        w, h = ((W + 30) / 2 + 6, (H + 24) / 2 + 6) if k == 'game' else (W / 2 + 6, H / 2 + 6)
        dx, dy = tx - cx, ty - cy
        t = min(w / abs(dx) if dx else 1e9, h / abs(dy) if dy else 1e9)
        return cx + dx * t, cy + dy * t

    def link(a, b, cls, label=None, bend=0.0, lpos=.5, ldx=0, ldy=-8):
        ax, ay, _ = N[a]
        bx, by, _ = N[b]
        x1, y1 = edge(a, bx, by)
        x2, y2 = edge(b, ax, ay)
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        dx, dy = x2 - x1, y2 - y1
        cx, cy = mx - dy * bend, my + dx * bend
        mk = 'ah' if 'recon' in cls else 'ahk'
        s.add('anno', f'<path d="M{n(x1)} {n(y1)} Q{n(cx)} {n(cy)} {n(x2)} {n(y2)}" class="{cls}" marker-end="url(#{mk})"/>')
        if label:
            t = lpos
            lx = (1 - t) ** 2 * x1 + 2 * (1 - t) * t * cx + t * t * x2 + ldx
            ly = (1 - t) ** 2 * y1 + 2 * (1 - t) * t * cy + t * t * y2 + ldy
            s.text(lx, ly, label, 17, 'nb', 'middle', layer='annotext')

    link('splash', 'home', 'fl fl-local')
    link('home', 'settings', 'fl fl-local')
    link('home', 'how', 'fl fl-local')
    link('home', 'local', 'fl fl-local')
    link('home', 'quick', 'fl fl-local', 'one tap', ldy=-10)
    link('home', 'host', 'fl fl-host')
    link('home', 'join', 'fl fl-join')
    link('home', 'game', 'fl fl-local', 'Continue (saved game)', bend=-.0, lpos=.42, ldy=-10)
    link('local', 'game', 'fl fl-local', 'Start', lpos=.55, ldx=26)
    link('quick', 'game', 'fl fl-local')
    link('host', 'game', 'fl fl-host', 'all humans ready, Start', lpos=.5, ldx=40, ldy=24)
    link('join', 'joined', 'fl fl-join', 'joined', lpos=.45, ldy=24)
    link('join', 'errors', 'fl fl-join')
    link('errors', 'join', 'fl fl-join', 'OK', bend=-.25, lpos=.5, ldy=-6)
    link('joined', 'game', 'fl fl-join', 'host starts', lpos=.5, ldx=52)
    link('game', 'pause', 'fl fl-local', bend=.12)
    link('pause', 'game', 'fl fl-local', 'Resume', bend=.12, lpos=.5, ldx=40)
    link('game', 'results', 'fl fl-res', 'game over', lpos=.45, ldx=-34, ldy=-12)
    link('results', 'game', 'fl fl-res', 'Play Again', bend=.22, lpos=.5, ldx=44, ldy=22)
    link('game', 'recon', 'fl fl-recon', 'my socket drops', lpos=.5, ldx=-58, ldy=8)
    link('recon', 'game', 'fl fl-recon', 'Resync ≤ 45 s', bend=.25, lpos=.5, ldx=40, ldy=-14)
    link('game', 'hostlost', 'fl fl-recon', 'host silent 9 s', lpos=.6, ldx=-66, ldy=10)
    for k, lbl in [('pause', 'Leave → Home'), ('results', 'Home → Home'), ('hostlost', 'after 45 s → Home'),
                   ('recon', 'grace expired → Home')]:
        cx, cy, _ = N[k]
        s.note(cx + W / 2 + 14 if k != 'pause' else cx + W / 2 + 18, cy + 6, lbl, 16)
    # legend
    ly = 660
    items = [('fl fl-local', 'local'), ('fl fl-host', 'host'), ('fl fl-join', 'join'),
             ('fl fl-recon', 'reconnect'), ('fl fl-res', 'results')]
    s.text(40, ly + 6, 'Paths:', 19, 'h')
    for i, (cls, lbl) in enumerate(items):
        x = 110 + i * 170
        s.add('anno', f'<line x1="{x}" y1="{ly}" x2="{x + 60}" y2="{ly}" class="{cls}"/>')
        s.text(x + 70, ly + 6, lbl, 18, 'h')
    s.callout(1, 300 - W / 2 - 4, 330 - H / 2 - 4)
    s.callout(2, 1010 - (W + 30) / 2 - 4, 330 - (H + 24) / 2 - 4)
    s.callout(3, 1190 - W / 2 - 4, 440 + H / 2 + 4)
    return figure(s.render('App map'), 'App map: every screen and the paths between them', [
        'Home is the hub. A saved local game adds Continue, which goes straight to the Game.',
        'Every mode ends in the same Game screen; only the controller behind it differs.',
        'Reconnecting is an overlay on the Game, not a separate route. A Resync within 45 s returns to the same turn.',
    ])


# --- Section 2: Board spec ---------------------------------------------------

def board_spec_sheet():
    s = S(1440, 800)
    B = Board(60, 40, 720)
    draw_board(s, B, indices=True)
    c = B.c
    # turn order: clockwise arc around the board
    cx, cy, R = B.x + B.size / 2, B.y + B.size / 2, B.size / 2 + 22
    o = 18
    for x1, y1, x2, y2 in [(B.x + 2 * c, B.y - o, B.x + 13 * c, B.y - o),
                           (B.x + B.size + o, B.y + 2 * c, B.x + B.size + o, B.y + 13 * c),
                           (B.x + 13 * c, B.y + B.size + o, B.x + 2 * c, B.y + B.size + o),
                           (B.x - o, B.y + 13 * c, B.x - o, B.y + 2 * c)]:
        s.add('anno', f'<line x1="{n(x1)}" y1="{n(y1)}" x2="{n(x2)}" y2="{n(y2)}" class="pb" marker-end="url(#ah)"/>')
    # diagonal steps
    for i in (4, 17, 30, 43):
        x1, y1 = B.cc(*TRACK[i])
        x2, y2 = B.cc(*TRACK[i + 1])
        s.add('anno', f'<line x1="{n(x1)}" y1="{n(y1)}" x2="{n(x2)}" y2="{n(y2)}" class="pb" marker-end="url(#ah)"/>')
    rx = 830
    s.text(rx, 70, 'Board spec (source of truth: spec §1.1)', 30, 'h')
    rows = [
        ('Colour', 'Start', 'Star', 'rel 50', 'Home column 51→55'),
        ('Red ●', '0 (13,6)', '8 (8,2)', '(14,7)', '(13,7) … (9,7) ↑'),
        ('Blue ■', '13 (6,1)', '21 (2,6)', '(7,0)', '(7,1) … (7,5) →'),
        ('Yellow ▲', '26 (1,8)', '34 (6,12)', '(0,7)', '(1,7) … (5,7) ↓'),
        ('Green ★', '39 (8,13)', '47 (12,8)', '(7,14)', '(7,13) … (7,9) ←'),
    ]
    xs = [rx, rx + 112, rx + 210, rx + 315, rx + 400]
    for j, row in enumerate(rows):
        y = 122 + j * 36
        for k, cell in enumerate(row):
            s.text(xs[k], y, cell, 18 if j else 17, 'b', weight=700 if j == 0 else None)
        s.line(rx, y + 12, rx + 590, y + 12, 's1')
    notes = [
        '• 52 track cells, numbered in movement order from Red\'s start.',
        '• Turn order and movement are clockwise: Red → Blue → Yellow → Green.',
        '• Safe cells: the 4 S cells and the 4 stars (8, 21, 34, 47). No captures there.',
        '• Corner steps 4→5, 17→18, 30→31, 43→44 are diagonal (blue arrows).',
        '• Blue arrows outside the board: turn order, clockwise.',
        '• Token progress: −1 base, 0–50 track, 51–55 own home column, 56 HOME.',
        '  Absolute index = (start + rel) mod 52. 56 steps from start to HOME.',
        '• Entry arrows sit on each colour\'s rel-50 cell and point into its column.',
        '• Hatched cells are home columns; they never take part in captures.',
        '• Yards: 6×6 corners, white inner square, 4 slots at cell-corner points.',
    ]
    for i, t in enumerate(notes):
        s.text(rx, 330 + i * 30, t, 18, 'b')
    s.note(rx, 640, 'Flame layout: world = 15 × 15 units, one unit per cell.\n'
                    'cellCentre(r, c) = ((c + 0.5)·cell, (r + 0.5)·cell).\n'
                    'Board side = min(W − 2·margin, H − cards − status).', 20)
    s.callout(1, B.x + 6 * c - 14, B.y + 13.5 * c)
    s.callout(2, B.x + 4.5 * c + 16, B.y + 9 * c - 8)
    s.callout(3, B.x + 7.5 * c, B.y + 7.5 * c)
    return figure(s.render('Annotated board'), 'Board spec: the reference for the Flame layout', [
        'Track index 0 is Red\'s start cell (13,6); the loop closes 51 → 0.',
        'Diagonal corner step 4 → 5, one of four.',
        'HOME: four triangles, each coloured for the home column pointing into it.',
    ])


# --- Section 3: Start --------------------------------------------------------

def splash(s, w, h):
    statusbar(s, w)
    s.xbox(w / 2 - 70, h / 2 - 150, 140, 140, rx=34)
    s.text(w / 2, h / 2 + 40, 'Ludo Unbiased', 40, 'h', 'middle')
    s.lines(w / 2 - 80, h / 2 + 70, 160, 1)
    spinner(s, w / 2, h - 120, 14)
    s.callout(1, w / 2 + 82, h / 2 - 150)
    s.callout(2, w / 2 + 30, h - 140)


def home_screen(cont=False):
    def draw(s, w, h):
        statusbar(s, w)
        s.xbox(16, 60, 48, 48, rx=14)
        s.text(76, 92, 'Ludo Unbiased', 26, 'h')
        icon_btn(s, w - 56, 64, 'gear')
        y = 130
        s.rect(16, y, w - 32, 56, 's1 g1', rx=16)
        s.circle(46, y + 28, 18, 's1 fw')
        glyph(s, 46, y + 28, 'person', 14)
        s.text(74, y + 26, 'Playing as', 13, 'b m')
        s.text(74, y + 44, 'Asha', 18, 'b', weight=700)
        s.text(w - 32, y + 34, 'Edit', 15, 'b', 'end', 700)
        y = 206
        if cont:
            s.rect(16, y, w - 32, 128, 's3 fw', rx=18)
            s.text(32, y + 32, 'Continue your game', 21, 'h')
            s.text(32, y + 56, "Red's turn · 4 players · saved 2 min ago", 14, 'b m')
            btn(s, 32, y + 72, 190, 42, 'Continue', 'primary', 17)
            btn(s, 234, y + 72, w - 32 - 234 - 16, 42, 'Discard', 'secondary', 16)
            s.callout(1, w - 26, y + 6)
            y += 148
        btn(s, 16, y, w - 32, 92, 'Quick Play vs AI', 'primary', 23)
        s.text(w / 2, y + 76, 'You (Red) vs 1 Normal AI', 13, 'b w', 'middle')
        y += 108
        for label, icon in [('Play Local', 'person'), ('Host Wi-Fi Game', 'wifi'), ('Join Wi-Fi Game', 'qr')]:
            btn(s, 16, y, w - 32, 64, label, 'secondary', 19, icon)
            y += 76
        btn(s, 16, y + 4, (w - 44) / 2, 52, 'Settings', 'secondary', 17)
        btn(s, 28 + (w - 44) / 2, y + 4, (w - 44) / 2, 52, 'How to Play', 'secondary', 17)
        s.rect(w / 2 - 67, h - 14, 134, 5, 'ink', rx=2.5)
        if not cont:
            s.callout(1, w - 26, 206)
            s.callout(2, w - 26, 316)
            s.callout(3, 30, 130)
        else:
            s.callout(2, w - 26, 354)
    return draw


def how_to_play(s, w, h):
    statusbar(s, w)
    topbar(s, w, 'How to Play', right='close', back=False)
    s.rect(16, 120, w - 32, 560, 's fw', rx=22)
    s.xbox(32, 136, w - 64, 280, rx=14)
    s.note(w / 2, 286, 'illustration 1 of 5', 18, 'middle')
    s.text(36, 456, 'Roll a 6 to leave base', 25, 'h')
    s.lines(36, 490, w - 72, 4, 20)
    for i in range(5):
        s.circle(w / 2 - 40 + i * 20, 712, 6, 'ink' if i == 0 else 's1 fw')
    btn(s, 16, 744, (w - 44) / 2, 52, 'Back', 'disabled', 17)
    btn(s, 28 + (w - 44) / 2, 744, (w - 44) / 2, 52, 'Next', 'primary', 17)
    s.callout(1, w - 34, 128)
    s.callout(2, w / 2 + 64, 712)


# --- Section 4: Local ------------------------------------------------------

def local_setup(count):
    def draw(s, w, h):
        statusbar(s, w)
        topbar(s, w, 'Local game')
        s.text(16, 134, 'Players', 15, 'b m', weight=700)
        seg(s, 16, 144, w - 32, 46, ['2', '3', '4'], count - 2, 18)
        if count == 2:
            rows = [('red', 'Asha', 'Human', None), ('yellow', 'Moss', 'AI', 'Normal')]
        else:
            rows = [('red', 'Asha', 'Human', None), ('blue', 'Kiwi', 'AI', 'Easy'),
                    ('yellow', 'Ravi', 'Human', None), ('green', 'Moss', 'AI', 'Normal')]
        y = 214
        for col, nm, kind, lvl in rows:
            hh = 132 if kind == 'AI' else 92
            s.rect(16, y, w - 32, hh, 's fw', rx=16)
            s.circle(48, y + 34, 18, 's1 g1')
            sym(s, 48, y + 34, 7, col)
            s.text(76, y + 30, NAME[col], 14, 'b m', weight=700)
            s.text(76, y + 50, nm, 19, 'b', weight=700)
            s.text(w - 34, y + 30, 'Colour ▾', 14, 'b', 'end', 700)
            seg(s, 32, y + 64, w - 64, 34, ['Human', 'AI'], 0 if kind == 'Human' else 1, 15)
            if kind == 'AI':
                s.text(32, y + 122, 'Difficulty', 14, 'b m', weight=700)
                for k, lv in enumerate(['Easy', 'Normal']):
                    bx = 130 + k * 100
                    s.rect(bx, y + 104, 88, 26, 's1 g2' if lv == lvl else 's1 fw', rx=13)
                    s.text(bx + 44, y + 122, lv, 14, 'b', 'middle', 700 if lv == lvl else None)
            y += hh + 12
        if count == 2:
            s.note(24, y + 24, '2 players use opposite colours\n(Red + Yellow); tap Colour to change.', 17)
        btn(s, 16, h - 104, w - 32, 60, 'Start game', 'primary', 20)
        s.rect(w / 2 - 67, h - 14, 134, 5, 'ink', rx=2.5)
        s.callout(1, w - 26, 150)
        s.callout(2, w - 26, 214)
        s.callout(3, w - 26, 278)
    return draw


def quick_play(s, w, h):
    seats = {'red': 'You', 'yellow': 'Moss (AI)'}
    toks = [t for t in BASE_TOKENS if t[0] in seats]
    toks = [(c, t, -1) for c, t, r in toks]
    game(s, w, h, 'red', 1.0, 'tap', toks, status="Red's turn. Tap the dice to roll.", seats=seats,
         title='Quick Play', toast_text='You vs Moss (Normal AI)')
    L = game_layout(w, h)
    s.callout(1, L['bx'] + L['cw'] + L['gap'] + L['cw'] - 4, L['cards']['yellow'][1])
    s.callout(2, L['bx'] + L['cw'] - 30, L['cards']['red'][1])
    s.callout(3, w / 2 + 130, L['by'] + L['board'] / 2 - 26)


# --- Section 5: Multiplayer ------------------------------------------------

def seat_row(s, x, y, w, col, name, status, kind='human', ready=None, action=None):
    s.rect(x, y, w, 62, 's fw' if name else 's1 dash fw', rx=14)
    s.circle(x + 30, y + 31, 17, 's1 g1')
    sym(s, x + 30, y + 31, 7, col)
    s.text(x + 58, y + 27, name or f'{NAME[col]} seat', 18, 'b' if name else 'b m', weight=700)
    s.text(x + 58, y + 47, status, 13, 'b m')
    if ready is not None:
        s.rect(x + w - 92, y + 17, 78, 28, 's1 ink' if ready else 's1 fw', rx=14)
        s.text(x + w - 53, y + 36, 'Ready' if ready else 'Not ready', 13, 'b w' if ready else 'b', 'middle', 700)
    if action:
        s.rect(x + w - 92, y + 17, 78, 28, 's1 fw', rx=14)
        s.text(x + w - 53, y + 36, action, 13, 'b', 'middle', 700)


def host_lobby(full):
    def draw(s, w, h):
        statusbar(s, w)
        topbar(s, w, 'Host game')
        s.rect(16, 116, w - 32, 150, 's fw', rx=18)
        s.text(32, 146, 'Room code', 14, 'b m', weight=700)
        s.text(32, 192, 'KQ7M', 46, 'h')
        s.text(32, 222, '192.168.1.5:47821  (Wi-Fi)', 14, 'b', weight=700)
        s.text(32, 244, '192.168.43.1:47821  (hotspot)', 14, 'b', weight=700)
        s.xbox(w - 148, 128, 120, 120, rx=8)
        glyph(s, w - 88, 188, 'qr', 26)
        y = 286
        s.text(16, y, 'Seats', 15, 'b m', weight=700)
        y += 10
        if full:
            rows = [('red', 'Asha (you, host)', 'Host', 'human', True, None),
                    ('blue', 'Kiwi', 'AI · Normal', 'ai', None, 'Remove'),
                    ('yellow', 'Priya', 'Connected', 'human', True, None),
                    ('green', 'Sam', 'Connected', 'human', True, None)]
        else:
            rows = [('red', 'Asha (you, host)', 'Host', 'human', True, None),
                    ('blue', None, 'Waiting for a player…', 'empty', None, 'Add AI'),
                    ('yellow', 'Priya', 'Connected', 'human', False, None),
                    ('green', None, 'Waiting for a player…', 'empty', None, 'Add AI')]
        for col, nm, st, kind, rd, act in rows:
            seat_row(s, 16, y, w - 32, col, nm, st, kind, rd, act)
            y += 72
        s.text(16, y + 26, 'Replace leavers with AI', 17, 'b', weight=700)
        s.text(16, y + 46, 'Off: a seat empty for 45 s is removed.', 13, 'b m')
        toggle(s, w - 64, y + 8, False)
        y += 70
        if full:
            btn(s, 16, h - 104, w - 32, 60, 'Start game', 'primary', 20)
        else:
            btn(s, 16, h - 104, w - 32, 60, 'Waiting for Priya to be ready', 'disabled', 17)
        s.text(w / 2, h - 116, 'Keep this app open while you host.', 13, 'b m', 'middle', 700)
        s.rect(w / 2 - 67, h - 14, 134, 5, 'ink', rx=2.5)
        s.callout(1, 30, 116)
        s.callout(2, w - 30, 120)
        s.callout(3, 30, 218)
        s.callout(4, w - 26, 296 + (82 if not full else 10))
        s.callout(5, w - 26, y - 70)
        s.callout(6, w - 26, h - 110)
    return draw


def join_list(s, w, h):
    statusbar(s, w)
    topbar(s, w, 'Join game')
    spinner(s, 38, 140, 10)
    s.text(60, 146, 'Looking for games on this network…', 16, 'b', weight=700)
    y = 172
    for nm, room, free in [("Asha's game", 'KQ7M', '2 seats free'), ("Sam's game", 'T4BX', '1 seat free')]:
        s.rect(16, y, w - 32, 72, 's fw', rx=16)
        s.text(32, y + 30, nm, 19, 'b', weight=700)
        s.text(32, y + 52, f'Room {room} · {free}', 14, 'b m')
        btn(s, w - 116, y + 16, 84, 40, 'Join', 'primary', 16)
        y += 84
    s.line(16, y + 20, w - 16, y + 20, 's1 dash')
    s.text(w / 2, y + 25, '  or  ', 14, 'b m', 'middle')
    y += 66
    field(s, 16, y, w - 32, 'Host address', 'e.g. 192.168.1.5:47821', placeholder=True)
    btn(s, 16, y + 64, w - 32, 52, 'Connect', 'secondary', 17)
    btn(s, 16, y + 128, w - 32, 52, 'Scan QR code', 'secondary', 17, 'qr')
    s.note(24, y + 230, 'Hotspot? The host screen lists its address,\nusually 192.168.43.1 (Android)\nor 172.20.10.1 (iPhone).', 16)
    s.rect(w / 2 - 67, h - 14, 134, 5, 'ink', rx=2.5)
    s.callout(1, w - 26, 140)
    s.callout(2, w - 26, 172)
    s.callout(3, w - 26, y)


def join_error(s, w, h):
    statusbar(s, w)
    topbar(s, w, 'Join game')
    y = 150
    field(s, 16, y, w - 32, 'Host address', '192.168.1.300', err='Each number must be 0–255.')
    btn(s, 16, y + 92, w - 32, 52, 'Connect', 'disabled', 17)
    s.text(16, y + 192, 'Accepted formats', 15, 'b m', weight=700)
    for i, f in enumerate(['192.168.1.5', '192.168.1.5:47821', 'ws://192.168.1.5:47821',
                           'ludo://192.168.1.5:47821/KQ7M', 'pixel-7.local:47821']):
        s.text(28, y + 224 + i * 28, f, 16, 'b mono')
    s.note(24, y + 400, 'Validates as you type. Never throws:\nbad octets, port 0 or 65536, empty,\n"ws://", spaces and junk all show a message.', 16)
    s.rect(w / 2 - 67, h - 14, 134, 5, 'ink', rx=2.5)
    s.callout(1, w - 26, y)
    s.callout(2, w - 26, y + 92)


def qr_scan(s, w, h):
    s.rect(0, 0, w, h, 'ink', rx=52)
    s.dark = True
    statusbar(s, w)
    icon_btn(s, 16, 56, 'close')
    s.text(w / 2, 84, 'Scan QR code', 24, 'h', 'middle')
    s.dark = False
    q = 240
    x, y = (w - q) / 2, 250
    for dx, dy in [(0, 0), (1, 0), (0, 1), (1, 1)]:
        cx, cy = x + dx * q, y + dy * q
        sx = 1 if dx == 0 else -1
        sy = 1 if dy == 0 else -1
        s.path(f'M{n(cx)} {n(cy + sy * 40)} L{n(cx)} {n(cy)} L{n(cx + sx * 40)} {n(cy)}', 'sw')
    s.line(x + 14, y + q / 2, x + q - 14, y + q / 2, 'sw dash')
    s.text(w / 2, y + q + 60, "Point at the QR code on the host's screen.", 16, 'b w', 'middle', 700)
    s.text(w / 2, y + q + 86, 'Camera permission is asked the first time.', 14, 'b w', 'middle')
    s.rect(16, h - 120, w - 32, 56, 'sw', rx=14)
    s.text(w / 2, h - 86, 'Enter address instead', 17, 'b w', 'middle', 700)
    s.callout(1, x + q - 4, y)
    s.callout(2, w - 26, h - 120)


def joined_lobby(s, w, h):
    statusbar(s, w)
    topbar(s, w, 'Room KQ7M')
    s.text(16, 136, "Asha's game", 24, 'h')
    s.text(16, 160, 'Waiting for the host to start.', 15, 'b m')
    y = 186
    for col, nm, st, rd, act in [('red', 'Asha', 'Host', True, None), ('blue', 'Kiwi', 'AI · Normal', None, None),
                                 ('yellow', 'Priya (you)', 'Connected', False, None),
                                 ('green', None, 'Waiting for a player…', None, None)]:
        seat_row(s, 16, y, w - 32, col, nm, st, 'human', rd, act)
        y += 72
    s.rect(16, y + 16, w - 32, 80, 's3 fw', rx=18)
    s.text(36, y + 52, "I'm ready", 22, 'h')
    s.text(36, y + 76, 'The host starts when everyone is ready.', 13, 'b m')
    toggle(s, w - 80, y + 42, False)
    btn(s, 16, h - 104, w - 32, 56, 'Leave room', 'secondary', 17)
    s.rect(w / 2 - 67, h - 14, 134, 5, 'ink', rx=2.5)
    s.callout(1, w - 26, 186 + 144)
    s.callout(2, w - 26, y + 16)


# --- Section 6: Game ---------------------------------------------------------

def game_main_sheet():
    s = S(1440, 900)
    pad = 28
    phone_frame(s, 60, pad, 390, 844)
    s.off = (60, pad)
    toks = with_tokens({})
    B, L = game(s, 390, 844, 'red', .64, 6, toks, movable={('red', 0), ('red', 1), ('red', 2), ('red', 3)},
                ghosts=[('red', 0), ('red', 18), ('red', 36)], status='Red rolled 6, extra roll after this move',
                chip=None, homes={'green': 1})
    c = B.c
    co = [
        (1, L['m'] + 20, L['top'] + 4),
        (2, L['cards']['red'][0] - 2, L['cards']['red'][1] - 4),
        (3, L['cards']['red'][0] + L['cw'] - 30, L['cards']['red'][1] + L['ch'] - 4),
        (4, L['cards']['yellow'][0] + L['cw'] - 2, L['cards']['yellow'][1] - 4),
        (5, B.slot('red', 1)[0] + c * .9, B.slot('red', 1)[1] - c * .9),
        (6, B.cc(13, 6)[0] - c * .9, B.cc(13, 6)[1] + c * .2),
        (7, L['bx'] + L['board'] - 4, L['status_y'] - 2),
        (8, L['bx'] - 2, L['by'] - 2),
    ]
    for num, x, y in co:
        s.callout(num, x, y)
    s.off = (0, 0)
    # right side: card anatomy at 2x
    ax, ay = 560, 70
    s.text(ax, ay, 'Player card anatomy (2×)', 28, 'h')
    sc = 2
    # draw the card at 2x by building it in a nested group
    inner = S(400, 200)
    card(inner, 10, 10, L['cw'], 72, 'red', 'Asha', 'left', 'inactive', True, .64, 6, 2)
    body = ''.join(inner.planes[0]['base'])
    txt = ''.join(inner.planes[0]['text'])
    s.add('base', f'<g transform="translate({ax} {ay + 24}) scale({sc})">{body}</g>')
    s.add('text', f'<g transform="translate({ax} {ay + 24}) scale({sc})">{txt}</g>')
    cb = ay + 24 + 82 * sc
    labels = [
        (ax + 4, cb + 46, 'avatar + colour symbol', ax + 34 * sc, cb - 14),
        (ax + 190, cb + 76, 'name (ellipsis) · 4 home pips', ax + 82 * sc, cb - 18),
        (ax + 430, ay + 24 + 20, 'dice sits on the active\ncard; tap to roll', ax + 156 * sc, ay + 24 + 46 * sc),
        (ax + 430, ay + 24 + 120, '30 s timer ring traces the\ncard edge; glow + 3.5 px\nborder when active', ax + 183 * sc + 4, ay + 24 + 60 * sc),
    ]
    for lx, ly, t, tx, ty in labels:
        s.note(lx, ly + 20, t, 18)
        s.arrow(lx + 4, ly, tx, ty, .12)
    s.text(ax, cb + 128, f'Same {L["cw"]:.0f} × 72 dp box in every state. Active changes colour, glow and ring only.', 18, 'b', weight=700)
    # timer stages
    tx0, ty0 = 560, 440
    s.text(tx0, ty0, 'Turn timer: one 30 s budget, two stages', 26, 'h')
    s.rect(tx0, ty0 + 24, 760, 40, 's fw', rx=8)
    s.rect(tx0, ty0 + 24, 300, 40, 's1 g2', rx=8)
    s.text(tx0 + 150, ty0 + 50, 'waiting to roll', 17, 'b', 'middle', 700)
    s.text(tx0 + 530, ty0 + 50, 'waiting to choose a move', 17, 'b', 'middle', 700)
    s.note(tx0 + 300, ty0 + 92, '↑ roll committed: deadline unchanged', 17, 'middle')
    s.note(tx0, ty0 + 128, 'Starts at 30 s when a turn begins; resets to 30 s on every extra roll.\n'
                           'On expiry: not rolled → host rolls (normal animation). Then 0 moves → pass,\n'
                           '1 move → play it, several → timeout policy: home > capture > leave base\n'
                           '> safe cell > furthest along; tie → lowest token index.', 18)
    s.text(tx0, ty0 + 240, 'Layout at 390 × 844', 26, 'h')
    s.note(tx0, ty0 + 274, f'margin 16 · cards {L["cw"]:.0f} × 72 · gap 10 · board {L["board"]:.0f} · status 40\n'
                           'Board side = min(W − 2·margin, H − top bar − 2·card − gaps − status).\n'
                           'Cards align to the board edges; each sits beside its own yard.', 18)
    return figure(s.render('Game screen'), 'Game screen, main sheet (390 × 844)', [
        'Pause. Local games stop the timer; online it only opens the menu.',
        'Active player card, next to its yard, with the timer ring and glow.',
        'Dice on the active card. Tap to roll; shows the result after landing.',
        'Inactive card: same size, no dice. Home pips count tokens home (0–4).',
        'Pulsing ring on every movable token. Base tokens on a 6 count as one choice.',
        'Ghost marker on each destination cell. Several base tokens share one ghost.',
        'Status line: "Red rolled 6, extra roll", "Captured Blue!", "No moves".',
        'Board: square, as large as fits, drawn from the §1.1 geometry.',
    ])


def state_sheets():
    figs = []
    L = game_layout(390, 844)

    def mk(label, caption, items, **kw):
        extra_draw = kw.pop('after', None)

        def draw(s, w, h):
            B, LL = game(s, w, h, **kw)
            if extra_draw:
                extra_draw(s, B, LL)
        sh = phone_sheet(label, draw)
        figs.append(figure(sh.render(label), caption, items))

    red_card = L['cards']['red']

    def a_awaiting(s, B, LL):
        x, y, _ = LL['cards']['red']
        s.callout(1, x + LL['cw'] - 6, y - 6)
        s.callout(2, x + LL['cw'] - 34, y + LL['ch'] + 12)
    mk('Awaiting roll', 'Awaiting roll, timer ring running', [
        'The ring traces the card edge and drains over 30 s. Last 5 s: tick sound and a faster pulse.',
        'Dice shows "tap". Only the current player\'s dice responds.',
    ], active='red', ring=.72, die='tap', status="Red's turn. Tap the dice.", after=a_awaiting)

    def a_rolling(s, B, LL):
        x, y, _ = LL['cards']['red']
        s.callout(1, x + LL['cw'] - 30, y - 8)
    mk('Dice rolling', 'Dice rolling', [
        '800 ms tumble with a bounce and a haptic tick. Input is locked until it lands.',
    ], active='red', ring=.7, die='roll', status='Rolling…', after=a_rolling)

    def a_legal(s, B, LL):
        c = B.c
        x, y = B.cc(*cell_of('red', 18))
        s.callout(1, B.slot('red', 0)[0] - c, B.slot('red', 0)[1] - c)
        s.callout(2, B.cc(13, 6)[0] + c * .9, B.cc(13, 6)[1])
        s.callout(3, x + c * .9, y - c * .4)
    mk('Legal moves', 'Legal-move highlights and destination ghosts', [
        'Pulsing rings mark movable tokens. Two base tokens are one choice.',
        'Ghost on the destination. Leaving base lands on the start cell S.',
        'This ghost is on a Blue token: landing captures it.',
    ], active='red', ring=.64, die=6, movable={('red', 0), ('red', 1), ('red', 2), ('red', 3)},
       ghosts=[('red', 0), ('red', 18), ('red', 36)], status='Choose a token to move', after=a_legal)

    def a_hop(s, B, LL):
        c = B.c
        pts = [B.cc(*cell_of('red', r)) for r in range(30, 35)]
        for (x1, y1), (x2, y2) in zip(pts, pts[1:]):
            mx, my = (x1 + x2) / 2, (y1 + y2) / 2 - c * .6
            s.add('anno', f'<path d="M{n(x1)} {n(y1 - c * .3)} Q{n(mx)} {n(my)} {n(x2)} {n(y2 - c * .3)}" class="pb" marker-end="url(#ah)"/>')
        s.alpha = .35
        for x, y in pts[1:-1]:
            token(s, x, y, c * .3, 'red')
        s.alpha = 1
        token(s, pts[-1][0], pts[-1][1] - c * .25, c * .36, 'red')
        s.callout(1, pts[1][0] + c * .2, pts[1][1] + c * .9)
        s.callout(2, pts[-1][0] + c * .8, pts[-1][1] - c * .8)
    mk('Token hopping', 'Token hopping cell by cell', [
        'The corner step 30 → 31 is diagonal and animates along the diagonal.',
        '~150 ms per hop, small arc and shadow, a tick per step. Lands on the star (safe).',
    ], active='red', ring=.55, die=4, tokens=with_tokens({}), hide={('red', 3)}, status='Red moves 4', after=a_hop)

    def a_cap(s, B, LL):
        c = B.c
        x, y = B.cc(*cell_of('red', 18))
        for k in range(8):
            a = k * math.pi / 4
            s.line(x + math.cos(a) * c * .55, y + math.sin(a) * c * .55, x + math.cos(a) * c * .85,
                   y + math.sin(a) * c * .85, 's1')
        sx, sy = B.slot('blue', 1)
        s.add('anno', f'<path d="M{n(x)} {n(y - c * .3)} Q{n(x - c * 4)} {n(y - c * 5)} {n(sx)} {n(sy)}" class="pb dash" marker-end="url(#ah)"/>')
        s.alpha = .4
        token(s, sx, sy, c * .36, 'blue')
        s.alpha = 1
        s.callout(1, x + c * .9, y + c * .2)
        s.callout(2, x - c * 3.4, y - c * 3.8)
    mk('Capture', 'Capture', [
        'Red lands; Blue is knocked back with a puff and a "bonk".',
        'Blue flies back along a curve to its base slot (~600 ms). Capture grants one extra roll.',
    ], active='red', ring=1.0, die=6, tokens=with_tokens({('red', 2): 18, ('blue', 1): 5}),
       hide={('blue', 1)}, status='Captured Blue! Extra roll.', homes={}, after=a_cap)

    def a_home(s, B, LL):
        c = B.c
        pts = [B.cc(*cell_of('red', r)) for r in (53, 54, 55)] + [B.pt(*FINISH['red'])]
        for (x1, y1), (x2, y2) in zip(pts, pts[1:]):
            s.add('anno', f'<path d="M{n(x1 + c * .4)} {n(y1)} Q{n(x1 + c * .9)} {n((y1 + y2) / 2)} {n(x2 + c * .4)} {n(y2)}" class="pb" marker-end="url(#ah)"/>')
        fx, fy = pts[-1]
        for k in range(6):
            a = k * math.pi / 3 + .3
            s.line(fx + math.cos(a) * c * .55, fy + math.sin(a) * c * .55, fx + math.cos(a) * c * .95,
                   fy + math.sin(a) * c * .95, 's1')
        s.callout(1, fx + c * 1.2, fy + c * .4)
    mk('Token home', 'Token reaches HOME', [
        'Slides into the red triangle with a sparkle. +1 home pip, one extra roll. All 4 home: crown burst and confetti.',
    ], active='red', ring=1.0, die=3, tokens=with_tokens({('red', 2): 56}), homes={'red': 1},
       status='Red token home! Extra roll.', after=a_home)

    def a_extra(s, B, LL):
        x, y, _ = LL['cards']['red']
        s.callout(1, B.x + B.size / 2 + 90, B.y + B.size / 2 - 24)
        s.callout(2, x + LL['cw'] - 6, y - 6)
    mk('Extra roll', 'Extra-roll toast', [
        'Toast for 1 s: "Extra roll!" with the reason in the status line.',
        'Ring resets to the full 30 s. Six, capture and home never stack: one extra roll per move.',
    ], active='red', ring=1.0, die='tap', toast_text='Extra roll!', status='Rolled a 6. Roll again.', after=a_extra)

    def a_three(s, B, LL):
        x, y, _ = LL['cards']['red']
        for k in range(3):
            dice(s, B.x + B.size / 2 - 50 + k * 50, B.y + B.size / 2 + 56, 34, 6)
        s.line(B.x + B.size / 2 + 34, B.y + B.size / 2 + 40, B.x + B.size / 2 + 66, B.y + B.size / 2 + 72, 's3')
        s.callout(1, B.x + B.size / 2 + 96, B.y + B.size / 2 + 50)
    mk('Three sixes', 'Three 6s in a row: turn forfeited', [
        'The third 6 is not played. Moves made earlier this turn stand. Turn passes to Blue.',
    ], active='red', ring=.9, die=6, toast_text='Third 6. Turn over.', status="Three 6s. Blue's turn next.",
       after=a_three)

    def a_nomove(s, B, LL):
        x, y, _ = LL['cards']['blue']
        s.callout(1, x + LL['cw'] - 30, y + LL['ch'] + 10)
    mk('No moves', 'No legal move: turn passes', [
        'Blue rolled 4 with every token in base. Status shows it for 1 s, then the turn passes.',
    ], active='blue', ring=.95, die=4, tokens=with_tokens({('blue', 1): -1}),
       status="No moves. Yellow's turn.", after=a_nomove)

    def a_auto(s, B, LL):
        c = B.c
        x, y = B.cc(*cell_of('red', 30))
        s.add('base', f'<circle cx="{n(x)}" cy="{n(y)}" r="{n(c * .62)}" pathLength="100" stroke-dasharray="70 100" class="ring" '
                      f'transform="rotate(-90 {n(x)} {n(y)})"/>')
        s.callout(1, x + c * .9, y - c * .8)
    mk('Auto-move', 'Only one legal move: auto-move countdown', [
        'One choice, so it plays itself 1120 ms after the roll commits, and never before the dice has landed. Tapping it sooner moves at once.',
    ], active='red', ring=.8, die=2, tokens=with_tokens({('red', 2): -1}), movable={('red', 3)},
       ghosts=[('red', 32)], status='One move. Playing it for you…', after=a_auto)

    def a_ai(s, B, LL):
        x, y, _ = LL['cards']['green']
        s.callout(1, x + 4, y + LL['ch'] + 10)
    mk('AI thinking', 'AI thinking', [
        'The AI card shows "Thinking…" for 600–900 ms, then the move animates. Highlights are hidden on AI turns.',
    ], active='green', ring=.9, die=None, states={'green': 'thinking'}, subs={'green': 'Thinking…'},
       status="Moss's turn (AI)", after=a_ai)

    def a_recon(s, B, LL):
        x, y, _ = LL['cards']['blue']
        s.callout(1, x + LL['cw'] - 6, y - 6)
        s.callout(2, x + LL['cw'] - 30, y + LL['ch'] + 12)
    mk('Opponent reconnecting', 'Opponent reconnecting', [
        'Blue lost connection: card dims, wifi-off badge, countdown from 0:45.',
        "It's Blue's turn, so the ring keeps draining. On expiry the host plays for them; the game never stalls.",
    ], active='blue', ring=.58, die=None, states={'blue': 'disconnected'}, subs={'blue': 'Reconnecting…'},
       status="Blue's turn. Waiting for Kiwi…", title='Room KQ7M',
       seats={'red': 'Asha', 'blue': 'Kiwi', 'yellow': 'Ravi', 'green': 'Moss (AI)'}, after=a_recon)

    def a_stack(s, B, LL):
        c = B.c
        x, y = B.cc(*cell_of('red', 12))
        pw, ph = 196, 70
        px, py = x - 30, y - c * 1.2 - ph
        s.plane()
        s.rect(px, py, pw, ph, 's3 fw', rx=14)
        for k in range(3):
            tx = px + 36 + k * 62
            token(s, tx, py + 28, 13, 'red')
            s.text(tx, py + 60, f'#{k + 1}', 12, 'b', 'middle', 700)
        s.line(x, y - c * .6, x, py + ph, 's1')
        s.callout(1, x + c * .9, y + c * .5)
        s.callout(2, px + pw + 4, py)
        sx, sy = B.cc(*TRACK[34])
        s.callout(3, sx + c * .8, sy + c * .6)
    mk('Stacks', 'Stacks, count badge and long-press picker', [
        'Three Red tokens on one cell: a cluster with a count badge.',
        'Tap moves the first token; long-press opens this picker to choose one.',
        'Two tokens of different colours on a safe star sit offset. No capture there.',
    ], active='red', ring=.6, die=5,
       tokens=with_tokens({('red', 0): 12, ('red', 2): 12, ('red', 3): 12, ('yellow', 3): 8, ('green', 0): 47}),
       movable={('red', 0)}, status='Long-press a stack to pick a token', after=a_stack)
    return figs


# --- Section 7: Small screen -------------------------------------------------

def small_screen_sheet():
    def draw(s, w, h):
        B, L = game(s, w, h, 'red', .66, 6, with_tokens({}), movable={('red', 2), ('red', 3), ('red', 0), ('red', 1)},
                    ghosts=[('red', 0), ('red', 18), ('red', 36)], status='Choose a token',
                    seats={'red': 'Christopher', 'blue': 'Kiwi (AI)', 'yellow': 'Ravi', 'green': 'Moss (AI)'})
        bx, by = L['bx'], L['by']
        s.dim(0, 24, w, 24, f'{w} dp', lx=w / 2 + 60, ly=40)
        s.dim(bx, by + B.size / 2, bx + B.size, by + B.size / 2, f'board {B.size:.0f}', lx=w / 2, ly=by + B.size / 2 - 8)
        x, y, _ = L['cards']['red']
        s.dim(x, y + L['ch'] + 6, x + L['cw'], y + L['ch'] + 6, f'{L["cw"]:.0f}', lx=x + L['cw'] / 2, ly=y + L['ch'] + 22)
        x2, y2, _ = L['cards']['green']
        s.dim(x2 + L['cw'] + 6, y2, x2 + L['cw'] + 6, y2 + L['ch'], f'{L["ch"]}', lx=x2 + L['cw'] + 4, ly=y2 - 6)
        s.callout(1, x + 40, y - 8)
        s.callout(2, L['bx'] + B.size / 2 + 70, L['by'] - 4)
    sh = phone_sheet('Game at 320 dp', draw, 320, 640, pad=40, right=10)
    f1 = figure(sh.render('Game at 320 dp'), 'Game at 320 × 640', [
        'Below 160 dp cards go compact: small symbol avatar and dice, so "Christopher" keeps 6 letters before the ellipsis. Every card stays 140 × 64.',
        'Margin 12, gap 8. Nothing overflows; board 296 is the largest square that fits.',
    ])
    s = S(760, 640)
    states = [('inactive', False, None, None, 'Inactive'), ('active', True, .64, 6, 'Active'),
              ('disconnected', False, None, None, 'Disconnected'), ('finished', False, None, None, 'Finished')]
    for i, (st, act, ring, die, lbl) in enumerate(states):
        x, y = 40 + (i % 2) * 360, 70 + (i // 2) * 280
        inner = S(400, 200)
        sub = 'Reconnecting…' if st == 'disconnected' else ('1st · all home' if st == 'finished' else None)
        card(inner, 0, 0, 140, 64, 'red', 'Christopher', 'left', st, act, ring, die, 2, sub)
        body = ''.join(inner.planes[0]['base'])
        txt = ''.join(inner.planes[0]['text'])
        s.add('base', f'<g transform="translate({x} {y}) scale(2)">{body}</g>')
        s.add('text', f'<g transform="translate({x} {y}) scale(2)">{txt}</g>')
        s.text(x, y - 26, lbl, 24, 'h')
        s.dim(x, y + 148, x + 280, y + 148, '140 dp', lx=x + 140, ly=y + 172)
        s.dim(x + 294, y, x + 294, y + 128, '64', lx=x + 316, ly=y + 70)
    s.note(40, 620, 'Identical box in all four states; a widget test compares sizes before and after the turn changes.', 18)
    f2 = figure(s.render('Card states at identical size'), 'Card states at 320 dp, drawn at 2×', [],
                note='Active adds glow and ring outside the box, so layout never moves.')
    return [f1, f2]


# --- Section 8: Overlays -----------------------------------------------------

def scrim(s, w, h):
    s.plane()
    s.rect(0, 0, w, h, 'scrim', rx=52)


def dialog(s, w, h, y, hh, title, body_lines, buttons):
    x, ww = 24, w - 48
    s.rect(x, y, ww, hh, 's3 fw', rx=22)
    s.text(x + 22, y + 44, title, 26, 'h')
    for i, t in enumerate(body_lines):
        s.text(x + 22, y + 78 + i * 22, t, 15, 'b')
    bw = (ww - 44 - 12 * (len(buttons) - 1)) / len(buttons)
    for i, (lbl, kind) in enumerate(buttons):
        btn(s, x + 22 + i * (bw + 12), y + hh - 72, bw, 50, lbl, kind, 17)


def bg_game(s, w, h, **kw):
    game(s, w, h, title=kw.pop('title', 'Local game'), status=kw.pop('status', "Red's turn"), **kw)


def overlay_sheets():
    figs = []

    def pause(s, w, h):
        bg_game(s, w, h, die='tap')
        scrim(s, w, h)
        y = 170
        s.rect(20, y, w - 40, 560, 's3 fw', rx=24)
        s.text(w / 2, y + 48, 'Paused', 30, 'h', 'middle')
        btn(s, 40, y + 72, w - 80, 54, 'Resume', 'primary', 18)
        btn(s, 40, y + 138, w - 80, 48, 'Rules', 'secondary', 17)
        yy = y + 216
        for lbl, on in [('Sound effects', True), ('Music', False), ('Haptics', True)]:
            s.text(44, yy + 20, lbl, 17, 'b', weight=700)
            toggle(s, w - 92, yy, on)
            yy += 48
        s.text(44, yy + 14, 'Appearance', 15, 'b m', weight=700)
        seg(s, 40, yy + 24, w - 80, 40, ['System', 'Light', 'Dark'], 0, 15)
        btn(s, 40, y + 480, w - 80, 52, 'Leave game', 'danger', 17)
        s.callout(1, w - 30, y + 30)
        s.callout(2, w - 30, y + 216)
        s.callout(3, w - 30, y + 480)
    sh = phone_sheet('Pause', pause)
    figs.append(figure(sh.render('Pause'), 'Pause menu', [
        'Local: the timer stops. Online: an overlay only, the timer keeps running (noted under the title there).',
        'Sound, Music and Haptics really mute; the choice is saved.',
        'Leave asks for confirmation first.',
    ]))

    def leave(s, w, h):
        bg_game(s, w, h, die='tap')
        scrim(s, w, h)
        dialog(s, w, h, 300, 230, 'Leave this game?', ['Your seat is removed and the others', 'keep playing. You can\'t rejoin.'],
               [('Stay', 'secondary'), ('Leave', 'danger')])
        s.callout(1, w - 34, 300)
    sh = phone_sheet('Leave confirm', leave)
    figs.append(figure(sh.render('Leave confirm'), 'Leave confirmation', [
        'Online, leaving ranks you below everyone who finishes. Local games offer to save instead.',
    ]))

    def recon_self(s, w, h):
        bg_game(s, w, h, die=None, active='blue', title='Room KQ7M')
        scrim(s, w, h)
        s.rect(24, 250, w - 48, 300, 's3 fw', rx=22)
        spinner(s, w / 2, 316, 20)
        s.text(w / 2, 384, 'Reconnecting…', 28, 'h', 'middle')
        s.text(w / 2, 414, '0:38 left to rejoin', 18, 'b', 'middle', 700)
        s.text(w / 2, 440, 'Trying 192.168.1.5:47821', 14, 'b m', 'middle')
        btn(s, 48, 470, w - 96, 52, 'Leave game', 'secondary', 17)
        s.callout(1, w - 34, 250)
    sh = phone_sheet('Reconnecting (self)', recon_self)
    figs.append(figure(sh.render('Reconnecting'), 'Reconnecting (this device)', [
        'Retries at 0.5 s, 1 s, 2 s, then every 3 s. On Resync it closes and the board jumps to the current state.',
    ]))

    def host_lost(s, w, h):
        bg_game(s, w, h, die=None, active='blue', title='Room KQ7M')
        scrim(s, w, h)
        s.rect(24, 250, w - 48, 300, 's3 fw', rx=22)
        glyph(s, w / 2, 318, 'wifioff', 34)
        s.text(w / 2, 384, 'Host lost', 28, 'h', 'middle')
        s.text(w / 2, 414, "Waiting for Asha's phone… 0:41", 17, 'b', 'middle', 700)
        s.text(w / 2, 440, 'Ask the host to reopen the app.', 14, 'b m', 'middle')
        btn(s, 48, 470, w - 96, 52, 'Return home', 'secondary', 17)
        s.callout(1, w - 34, 250)
    sh = phone_sheet('Host lost', host_lost)
    figs.append(figure(sh.render('Host lost'), 'Host lost', [
        'After 45 s with no host it returns Home with "The host ended the game."',
    ]))

    def join_bg(s, w, h):
        statusbar(s, w)
        topbar(s, w, 'Join game')
        for k in range(2):
            s.rect(16, 172 + k * 84, w - 32, 72, 's fw', rx=16)
            s.lines(32, 200 + k * 84, 150, 2, 18)

    def room_full(s, w, h):
        join_bg(s, w, h)
        scrim(s, w, h)
        dialog(s, w, h, 300, 210, 'Room KQ7M is full', ['All four seats are taken.', 'Try another game.'], [('OK', 'primary')])
    sh = phone_sheet('Room full', room_full)
    figs.append(figure(sh.render('Room full'), 'Room full', []))

    def version(s, w, h):
        join_bg(s, w, h)
        scrim(s, w, h)
        dialog(s, w, h, 300, 232, 'Update needed', ['The host runs version 1.2;', 'you have 1.1. Update both', 'phones to the same version.'],
               [('OK', 'primary')])
    sh = phone_sheet('Version mismatch', version)
    figs.append(figure(sh.render('Version mismatch'), 'Version mismatch', []))

    def kicked(s, w, h):
        join_bg(s, w, h)
        scrim(s, w, h)
        dialog(s, w, h, 300, 210, 'Removed from room', ['The host removed you', 'from room KQ7M.'], [('OK', 'primary')])
    sh = phone_sheet('Kicked', kicked)
    figs.append(figure(sh.render('Kicked'), 'Kicked', [], note='Not in the spec\'s overlay list but listed under connection dialogs (§1.7.11).'))
    return figs


# --- Section 9: Results ------------------------------------------------------

def results(players):
    def draw(s, w, h):
        statusbar(s, w)
        for k in range(26):
            x = 20 + (k * 53) % (w - 40)
            y = 60 + (k * 37) % 110
            if k % 3 == 0:
                s.rect(x, y, 8, 5, 'ink', extra=f' transform="rotate({k * 23} {x} {y})"')
            elif k % 3 == 1:
                s.circle(x, y, 3, 'ink')
            else:
                s.poly([(x, y - 4), (x + 4, y + 3), (x - 4, y + 3)], 'ink')
        s.text(w / 2, 150, 'Asha wins!', 38, 'h', 'middle')
        s.text(w / 2, 178, 'Game took 18 min', 15, 'b m', 'middle')
        y = 206
        heads = ['home', 'caps', 'lost', '6s']
        for k, hd in enumerate(heads):
            s.text(w - 150 + k * 36, y + 4, hd, 12, 'b m', 'middle', 700)
        y += 14
        for i, (col, nm, st) in enumerate(players):
            hh = 76
            s.rect(16, y, w - 32, hh, 's3 fw' if i == 0 else 's fw', rx=16)
            s.circle(46, y + hh / 2, 18, 's1 g2' if i < 3 else 's1 fw')
            s.text(46, y + hh / 2 + 7, str(i + 1), 20, 'h', 'middle')
            if i == 0:
                glyph(s, 46, y + 10, 'crown', 9)
            s.circle(90, y + hh / 2, 16, 's1 g1')
            sym(s, 90, y + hh / 2, 6, col)
            s.text(114, y + hh / 2 - 2, nm, 18, 'b', weight=700)
            s.text(114, y + hh / 2 + 18, ['1st', '2nd', '3rd', '4th'][i], 13, 'b m')
            for k, v in enumerate(st[:4]):
                s.text(w - 150 + k * 36, y + hh / 2 + 6, str(v), 17, 'b', 'middle', 700)
            y += hh + 10
        btn(s, 16, h - 172, w - 32, 58, 'Play Again', 'primary', 19)
        btn(s, 16, h - 104, w - 32, 54, 'Home', 'secondary', 17)
        s.rect(w / 2 - 67, h - 14, 134, 5, 'ink', rx=2.5)
        s.callout(1, w - 26, 220)
        s.callout(2, 30, 120)
        s.callout(3, w - 26, h - 172)
    return draw


def results_sheets():
    p4 = [('red', 'Asha', [4, 5, 1, 9]), ('yellow', 'Ravi', [4, 3, 2, 7]), ('blue', 'Kiwi (AI)', [4, 2, 4, 6]),
          ('green', 'Moss (AI)', [2, 1, 4, 5])]
    p2 = [('red', 'You', [4, 4, 1, 8]), ('yellow', 'Moss (AI)', [3, 1, 4, 6])]
    a = phone_sheet('Results 4p', results(p4))
    b = phone_sheet('Results 2p', results(p2))
    items = ['Per player: tokens home, captures made, times captured, sixes rolled.',
             'Confetti and medals for the top 3; the winner\'s row gets a crown and heavier border.',
             'Play Again keeps the same seats and AI levels.']
    return [figure(a.render('Results 4 players'), 'Results, 4 players', items),
            figure(b.render('Results 2 players'), 'Results, 2 players', [], note='Same layout; rows shrink to the players who played. A player who left shows "left" and ranks below finishers.')]


# --- Section 10: Settings + dark --------------------------------------------

def settings_screen(s, w, h):
    statusbar(s, w)
    topbar(s, w, 'Settings')
    y = 126
    s.text(16, y, 'Appearance', 15, 'b m', weight=700)
    seg(s, 16, y + 10, w - 32, 46, ['System', 'Light', 'Dark'], 0, 16)
    s.text(16, y + 78, 'System follows your phone live.', 13, 'b m')
    y += 108
    for lbl, sub, on in [('Sound effects', 'Dice, moves, captures, timer', True), ('Music', 'One calm loop', False),
                         ('Haptics', 'Dice and step ticks', True)]:
        s.rect(16, y, w - 32, 64, 's fw', rx=14)
        s.text(32, y + 28, lbl, 18, 'b', weight=700)
        s.text(32, y + 48, sub, 13, 'b m')
        toggle(s, w - 80, y + 18, on)
        y += 74
    s.text(16, y + 12, 'Animation speed', 15, 'b m', weight=700)
    s.line(32, y + 44, w - 32, y + 44, 's')
    for k, lb in enumerate(['Slow', 'Normal', 'Fast']):
        xx = 32 + k * (w - 64) / 2
        s.line(xx, y + 36, xx, y + 52, 's1')
        s.text(xx, y + 74, lb, 13, 'b', 'middle', 700 if k == 1 else None)
    s.circle(32 + (w - 64) / 2, y + 44, 11, 's ink')
    s.text(16, y + 98, 'Local games only. Online games run at normal speed.', 13, 'b m')
    y += 130
    field(s, 16, y, w - 32, 'Player name', 'Asha')
    y += 78
    s.text(16, y, 'Default AI difficulty', 15, 'b m', weight=700)
    seg(s, 16, y + 10, w - 32, 44, ['Easy', 'Normal'], 1, 16)
    s.rect(w / 2 - 67, h - 14, 134, 5, 'ink', rx=2.5)
    s.callout(1, w - 26, 132)
    s.callout(2, w - 26, 234)
    s.callout(3, w - 26, 234 + 222)


def dark_game_sheet():
    def draw(s, w, h):
        s.rect(0, 0, w, h, 'fw', rx=52)
        game(s, w, h, 'blue', .5, 3, with_tokens({('red', 2): 18, ('blue', 1): 2}), movable={('blue', 1)},
             ghosts=[('blue', 5)], status="Blue's turn", homes={'green': 1})
    sh = phone_sheet('Dark game', draw, dark=True, right=420)
    s = sh
    x0 = 390 + 48 + 30
    s.text(x0, 70, 'Dark mode tokens (spec §1.9)', 26, 'h')
    rows = [('Board base', '#171A24'), ('Cells', '#232838'), ('Grid lines', '#343A4F'),
            ('Stars (outline)', '#E6E8F0'), ('App background', '#12141C'), ('Surfaces', '#1D2030 / #262A3C'),
            ('Text', '#F2F3F7 / #A9AEC2'), ('Player colours', '10% less saturated'),
            ('Yards, home columns', 'soft glow'), ('Tokens and dice', 'same hue + light rim')]
    for i, (k, v) in enumerate(rows):
        s.text(x0, 116 + i * 34, k, 17, 'b', weight=700)
        s.text(x0 + 200, 116 + i * 34, v, 17, 'b mono')
    s.note(x0, 480, 'Colours come only from AppColors and\nBoardPalette ThemeExtensions. Flame\ncomponents re-read the palette when the\nmode changes; the game does not restart.\n\nBoth modes must pass WCAG AA (tested).', 18)
    s.arrow(x0 - 6, 470, 300, 420, -.15)
    return figure(sh.render('Game in dark mode'), 'Game screen in dark mode', [
        'Same layout and sizes as light. Only palette tokens change.',
    ])


# --- Section 11: Tablet ------------------------------------------------------

def tablet_sheets():
    def g(s, w, h):
        B, L = game(s, w, h, 'red', .7, 6, with_tokens({}), movable={('red', 2), ('red', 3), ('red', 0), ('red', 1)},
                    ghosts=[('red', 0), ('red', 18), ('red', 36)], status='Red rolled 6. Choose a token.',
                    title='Local game')
        s.dim(L['bx'], L['by'] - 8, L['bx'] + B.size, L['by'] - 8, f'board {B.size:.0f}', lx=w / 2, ly=L['by'] - 14)
        s.callout(1, L['bx'] + L['cw'] - 4, L['cards']['blue'][1] - 6)
    a = phone_sheet('Tablet game', g, 800, 1280, pad=30, tablet=True)

    def lobby(s, w, h):
        statusbar(s, w)
        topbar(s, w, 'Host game', y=60)
        col = (w - 40 * 2 - 32) / 2
        s.rect(40, 130, col, 420, 's fw', rx=22)
        s.text(64, 176, 'Room code', 18, 'b m', weight=700)
        s.text(64, 240, 'KQ7M', 64, 'h')
        s.xbox(64, 270, 200, 200, rx=10)
        glyph(s, 164, 370, 'qr', 40)
        s.text(64, 500, '192.168.1.5:47821 (Wi-Fi)', 17, 'b', weight=700)
        s.text(64, 526, '192.168.43.1:47821 (hotspot)', 17, 'b', weight=700)
        x2 = 40 + col + 32
        s.text(x2, 150, 'Seats', 18, 'b m', weight=700)
        y = 166
        for c, nm, st, rd, act in [('red', 'Asha (you, host)', 'Host', True, None), ('blue', 'Kiwi', 'AI · Normal', None, 'Remove'),
                                   ('yellow', 'Priya', 'Connected', True, None), ('green', 'Sam', 'Connected', False, None)]:
            seat_row(s, x2, y, col, c, nm, st, 'human', rd, act)
            y += 76
        s.text(x2, y + 30, 'Replace leavers with AI', 19, 'b', weight=700)
        toggle(s, x2 + col - 56, y + 10, False)
        btn(s, 40, h - 150, w - 80, 70, 'Waiting for Sam to be ready', 'disabled', 20)
        s.callout(1, 40 + col - 6, 130)
        s.callout(2, x2 + col - 6, 166)
    b = phone_sheet('Tablet lobby', lobby, 800, 1280, pad=30, tablet=True)
    tb = game_layout(800, 1280)
    return [figure(a.render('Tablet game'), 'Game on a 10" tablet (800 × 1280)', [
        f'Same structure; cards grow to {tb["ch"]} dp tall and the board to {tb["board"]:.0f}. Text and touch targets scale up.']),
            figure(b.render('Tablet lobby'), 'Host lobby on a tablet', [
                'Room code and QR on the left, large enough to scan across a table.',
                'Seat list on the right; same rows as the phone.'])]


# --- Page ----------------------------------------------------------------------

CSS = r"""
:root{
  --desk:#E8ECEF; --sheet:#FFFFFF; --ink:#23272B; --muted:#5C666F;
  --pencil-blue:#1C6DD0; --mark:#D92D20; --rule:#C6CED5;
  --display:'Patrick Hand','Chalkboard SE','Comic Sans MS',cursive;
  --body:'Nunito',system-ui,sans-serif;
  --g1:#EEF1F3; --g2:#DCE1E5; --g3:#B7C0C7; --hl:#FFEC99;
  color-scheme: light;
}
/* Layout: one centred column of pinned paper sheets on a desk; sheets tile in wide / two / four grids. */
@media (prefers-reduced-motion: no-preference){ html{ scroll-behavior:smooth } }
body{ background:var(--desk); color:var(--ink); font-family:var(--body); font-size:16px; line-height:1.5 }
body::before{ content:""; position:fixed; inset:0 0 auto; height:env(safe-area-inset-top,0px); z-index:10; background:var(--desk) }
.page{ max-width:1500px; margin:0 auto; display:grid; grid-template-columns:minmax(0,1fr); gap:40px;
  padding-block:32px 64px;
  padding-left:max(16px, env(safe-area-inset-left,0px)); padding-right:max(16px, env(safe-area-inset-right,0px)) }
h1,h2,h3{ font-family:var(--display); font-weight:400; text-wrap:balance; margin:0; line-height:1.05 }
h1{ font-size:clamp(44px,8vw,76px) }
.lead{ color:var(--muted); max-width:65ch; margin:12px 0 0; font-size:17px }
nav{ position:sticky; top:env(safe-area-inset-top,0px); z-index:5; background:var(--desk);
  border-bottom:1.5px dashed var(--rule); margin-inline:-4px }
nav ul{ list-style:none; margin:0; padding:12px 4px; display:flex; gap:10px; overflow-x:auto; scrollbar-width:thin }
nav a{ display:inline-block; white-space:nowrap; font-family:var(--display); font-size:21px; line-height:1;
  padding:8px 14px 7px; border:1.5px solid var(--ink); border-radius:12px; background:var(--sheet);
  color:var(--ink); text-decoration:none }
nav a:hover, nav a:focus-visible{ background:var(--hl); outline:2px solid var(--pencil-blue); outline-offset:1px }
.stack{ display:grid; grid-template-columns:minmax(0,1fr); gap:40px; min-width:0 }
.page > *{ min-width:0 }
.decisions{ background:var(--sheet); border:2px solid var(--mark); border-radius:14px; padding:20px 24px }
.decisions h2{ color:var(--mark); font-size:28px }
.decisions ul{ margin:12px 0 0; padding-left:20px; display:grid; gap:8px; max-width:110ch }
.decisions b{ font-weight:700 }
section{ scroll-margin-top:80px; display:grid; grid-template-columns:minmax(0,1fr); gap:14px; min-width:0 }
section > h2{ font-size:36px }
section > .note{ color:var(--muted); margin:-8px 0 6px; max-width:65ch }
.grid{ display:grid; gap:28px; align-items:start }
.wide{ grid-template-columns:1fr }
.two{ grid-template-columns:repeat(auto-fill,minmax(min(100%,560px),1fr)) }
.four{ grid-template-columns:repeat(auto-fill,minmax(min(100%,300px),1fr)) }
figure.sheet{ position:relative; margin:0; background:var(--sheet); padding:18px 18px 16px; min-width:0;
  box-shadow:0 1px 0 var(--rule), 0 3px 10px rgba(35,39,43,.10) }
figure.sheet::before{ content:""; position:absolute; top:7px; left:50%; width:12px; height:12px; margin-left:-6px;
  border-radius:50%; background:var(--mark); box-shadow:0 1px 2px rgba(35,39,43,.35) }
figure.sheet svg{ display:block; width:100%; height:auto }
figcaption{ margin-top:12px; font-size:15px; color:var(--ink) }
figcaption strong{ font-family:var(--display); font-weight:400; font-size:22px; display:block; line-height:1.15 }
figcaption p{ margin:4px 0 0; color:var(--muted) }
figcaption ol{ margin:8px 0 0; padding-left:0; list-style:none; counter-reset:c; display:grid; gap:5px }
figcaption li{ counter-increment:c; display:grid; grid-template-columns:24px 1fr; gap:8px; align-items:start }
figcaption li::before{ content:counter(c); width:22px; height:22px; border-radius:50%; background:var(--mark);
  color:#fff; font:700 13px/22px var(--body); text-align:center; margin-top:1px }
/* SVG drawing classes */
svg .s,svg .s1,svg .s2,svg .s3{ fill:none; stroke:var(--ink); stroke-linecap:round; stroke-linejoin:round }
svg .s{ stroke-width:2 } svg .s1{ stroke-width:1.3 } svg .s2{ stroke-width:2.4 } svg .s3{ stroke-width:3.5 }
svg .dash{ stroke-dasharray:5 5 }
svg .fw{ fill:var(--sheet) } svg .g1{ fill:var(--g1) } svg .g2{ fill:var(--g2) } svg .g3{ fill:var(--g3) }
svg .ink{ fill:var(--ink) } svg .lite{ opacity:.55 }
svg .hatch{ fill:url(#hatch) }
svg .ghost{ fill:none }
svg .shadow{ fill:var(--g3); opacity:.6 }
svg .glow{ fill:none; stroke:var(--g3); stroke-width:7; opacity:.55 }
svg .ringtrack{ fill:none; stroke:var(--g2); stroke-width:4 }
svg .ring{ fill:none; stroke:var(--ink); stroke-width:4.5; stroke-linecap:round }
svg .scrim{ fill:var(--ink); opacity:.5 }
svg .sw{ fill:none; stroke:#fff; stroke-width:3; stroke-linecap:round }
svg text{ font-family:var(--display); fill:var(--ink) }
svg text.b{ font-family:var(--body) } svg text.m{ fill:var(--muted) } svg text.w{ fill:#fff }
svg text.mono{ font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:14px }
svg text.nb{ fill:var(--pencil-blue); font-family:var(--display) }
svg text.dimlbl{ paint-order:stroke; stroke:var(--sheet); stroke-width:5px }
svg .pb{ fill:none; stroke:var(--pencil-blue); stroke-width:2; stroke-linecap:round }
svg .pb.thin{ stroke-width:1.4 } svg .pb.dash{ stroke-dasharray:7 6 }
svg .co{ fill:var(--mark) } svg text.cot{ fill:#fff; font-family:var(--body); font-weight:700 }
svg .fl{ fill:none; stroke:var(--ink); stroke-width:2.2; stroke-linecap:round }
svg .fl-host{ stroke-dasharray:12 7 } svg .fl-join{ stroke-dasharray:12 5 2 5 }
svg .fl-recon{ stroke:var(--pencil-blue); stroke-width:2.6 } svg .fl-res{ stroke-dasharray:2 6 }
/* dark-mode drawing: ink-filled phone with white lines */
svg .dk .s,svg .dk .s1,svg .dk .s2,svg .dk .s3{ stroke:#F2F3F7 }
svg .dk .fw{ fill:var(--ink) } svg .dk .g1{ fill:#2F353B } svg .dk .g2{ fill:#3B424A } svg .dk .g3{ fill:#59616A }
svg .dk .ink{ fill:#F2F3F7 } svg .dk .hatch{ fill:url(#hatchd) } svg .dk .shadow{ fill:#000 }
svg .dk .glow{ stroke:#59616A } svg .dk .ringtrack{ stroke:#3B424A } svg .dk .ring{ stroke:#F2F3F7 }
svg .dk text{ fill:#F2F3F7 } svg .dk text.m{ fill:#A9AEC2 } svg .dk text.w{ fill:var(--ink) }
"""

DEFS = """<svg width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false"><defs>
<filter id="wob" x="-3%" y="-3%" width="106%" height="106%"><feTurbulence type="fractalNoise" baseFrequency="0.03" numOctaves="2" seed="7" result="n"/><feDisplacementMap in="SourceGraphic" in2="n" scale="1.2" xChannelSelector="R" yChannelSelector="G"/></filter>
<pattern id="hatch" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(45)"><rect width="6" height="6" fill="#FFFFFF"/><line x1="0" y1="0" x2="0" y2="6" stroke="#23272B" stroke-width="1.1"/></pattern>
<pattern id="hatchd" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(45)"><rect width="6" height="6" fill="#23272B"/><line x1="0" y1="0" x2="0" y2="6" stroke="#F2F3F7" stroke-width="1.1"/></pattern>
<marker id="ah" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="#1C6DD0"/></marker>
<marker id="ahk" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="#23272B"/></marker>
</defs></svg>"""

DECISIONS = [
    '<b>Card position on 320 dp screens.</b> Recommended: keep the four corner cards at 140 × 64 in a compact form (small symbol avatar and dice, about 6 letters of name). Alternative: one strip of four cards above the board, which gives names more room but breaks the card-beside-yard link.',
    '<b>Dice on the card or in the centre.</b> Recommended: on the active card, as drawn. Every player always looks at the same place for their own turn. A centre dice would cover the HOME triangles.',
    '<b>Choosing a token from a mixed stack.</b> Recommended: tap moves your first movable token in the cell; long-press opens a picker with only your tokens. Other colours on a safe cell are never selectable.',
    '<b>"Replace leavers with AI" default.</b> The spec says off: a seat empty for 45 s is removed. On would keep 4-player games at 4 players.',
    '<b>Timer number or ring only.</b> Recommended: ring only, plus a number for the last 10 s. The ring alone is hard to read precisely; a constant number adds visual noise to every turn.',
]

SECTIONS = [
    ('flow', 'Flow', 'Every screen and how you get between them.', 'wide'),
    ('board', 'Board spec', 'The real 15 × 15 grid, numbered exactly as spec §1.1.', 'wide'),
    ('start', 'Start', 'First launch, the hub, and the rules.', 'four'),
    ('local', 'Local', 'Setting up a game on one device.', 'four'),
    ('multiplayer', 'Multiplayer', 'Hosting and joining over Wi-Fi or a hotspot.', 'four'),
    ('game', 'Game', 'The main screen, then each state it passes through.', None),
    ('small', 'Small screen', 'The game at 320 dp, and proof that cards never change size.', 'two'),
    ('overlays', 'Overlays', 'Menus and connection dialogs drawn over the screen beneath.', 'four'),
    ('results', 'Results', 'Ranking and stats at the end of a game.', 'two'),
    ('settings', 'Settings', 'Preferences, and the game screen in dark mode.', 'two'),
    ('tablet', 'Tablet', 'The same layouts on a 10-inch tablet.', 'two'),
]


def build():
    figs = {
        'flow': [flow_sheet()],
        'board': [board_spec_sheet()],
        'start': [
            figure(phone_sheet('Splash', splash).render('Splash'), 'Splash', [
                'App icon and wordmark; light or dark to match the system.', 'Loads settings and checks for a saved game.']),
            figure(phone_sheet('Home', home_screen()).render('Home'), 'Home', [
                'Quick Play: one tap, you (Red) vs 1 Normal AI (Yellow).', 'Local, Host and Join, then Settings and How to Play.',
                'Your player name, used in lobbies; tap to edit.']),
            figure(phone_sheet('Home with Continue', home_screen(True)).render('Home with Continue'), 'Home with a saved game', [
                'Continue appears only when a local game is saved. Discard asks first.', 'Everything below moves down; nothing else changes.']),
            figure(phone_sheet('How to Play', how_to_play).render('How to Play'), 'How to Play', [
                'Five illustrated cards: leave base, move, capture and safe cells, extra rolls, winning.', 'Swipe or use Next; dots show position.']),
        ],
        'local': [
            figure(phone_sheet('Local setup 2p', local_setup(2)).render('Local setup 2 players'), 'Local setup, 2 players', [
                'Player count.', 'One row per seat: colour, name, Human or AI.', 'AI rows add Easy or Normal.']),
            figure(phone_sheet('Local setup 4p', local_setup(4)).render('Local setup 4 players'), 'Local setup, 4 players with AI', [
                'Count 4 adds all colours.', 'Tap Colour to swap seats; colours stay unique.', 'Default difficulty comes from Settings.']),
            figure(phone_sheet('Quick play', quick_play).render('Quick play start'), 'Quick Play, first turn', [
                'Unused seats show a dashed "empty" card at the same size.', 'Your dice says "tap".',
                'A 1.5 s toast introduces the opponent.']),
        ],
        'multiplayer': [
            figure(phone_sheet('Host lobby waiting', host_lobby(False)).render('Host lobby waiting'), 'Host lobby, waiting', [
                'Room code, 4 letters.', 'QR code with ludo://host:port/ROOM.', "This device's real reachable addresses, including a hotspot.",
                'Empty seats offer Add AI.', 'Replace leavers with AI, default off.', 'Start unlocks when every human seat is ready.']),
            figure(phone_sheet('Host lobby ready', host_lobby(True)).render('Host lobby full and ready'), 'Host lobby, full and ready', [
                'Room code.', 'QR.', 'Addresses.', 'AI seat can be removed.', 'Leaver toggle.', 'Start is enabled.']),
            figure(phone_sheet('Join discovering', join_list).render('Join discovering'), 'Join: discovering games', [
                'Searches with Bonjour (and UDP broadcast on Android).', 'Each found game: host name, room and free seats.',
                'Manual address and Scan QR are always available.']),
            figure(phone_sheet('Join error', join_error).render('Join address error'), 'Join: manual address with a validation error', [
                'The message says what is wrong and how to fix it.', 'Connect stays disabled until the address parses.']),
            figure(phone_sheet('QR scanner', qr_scan).render('QR scanner'), 'Join: QR scanner', [
                'Scan frame; a valid code connects at once.', 'Manual entry fallback.']),
            figure(phone_sheet('Joined lobby', joined_lobby).render('Joined lobby'), 'Joined lobby (client)', [
                'Seat list updates live as players join and ready up.', 'Your Ready toggle.']),
        ],
        'game': None,
        'small': small_screen_sheet(),
        'overlays': overlay_sheets(),
        'results': results_sheets(),
        'settings': [
            figure(phone_sheet('Settings', settings_screen).render('Settings'), 'Settings', [
                'Appearance: System (default), Light, Dark. Also in the Pause menu.',
                'Each toggle drives real audio or haptics; a test verifies Sound mutes the audio service.',
                'Animation speed applies to local games only.']),
            dark_game_sheet(),
        ],
        'tablet': tablet_sheets(),
    }
    nav = ''.join(f'<li><a href="#{k}">{t}</a></li>' for k, t, _, _ in SECTIONS)
    body = []
    for key, title, note, kind in SECTIONS:
        if key == 'game':
            grid = (f'<div class="grid wide">{game_main_sheet()}</div>'
                    f'<div class="grid four">{"".join(state_sheets())}</div>')
        else:
            grid = f'<div class="grid {kind}">{"".join(figs[key])}</div>'
        body.append(f'<section id="{key}"><h2>{title}</h2><p class="note">{note}</p>{grid}</section>')
    decisions = ''.join(f'<li>{d}</li>' for d in DECISIONS)
    content = f"""<title>ludo Wireframes</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;700&amp;family=Patrick+Hand&amp;display=swap">
<style>{CSS}</style>
{DEFS}
<div class="page">
<header><h1>ludo Wireframes</h1>
<p class="lead">Grayscale sheets for every screen of Ludo Unbiased: local pass-and-play, Wi-Fi and hotspot multiplayer with 45-second reconnection, and AI seats. The board is drawn from the same geometry tables the Flame board will use. Red numbers on a sheet match the list beneath it; blue pencil explains behaviour.</p></header>
<nav aria-label="Sections"><ul>{nav}</ul></nav>
<aside class="decisions"><h2>Decisions to make</h2><ul>{decisions}</ul></aside>
<main class="stack">{''.join(body)}</main>
</div>
"""
    return content


def main():
    content = build()
    full = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
            '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n'
            + content.replace('<div class="page">', '</head>\n<body>\n<div class="page">', 1)
            + '</body>\n</html>\n')
    full = full.replace('</head>\n<body>\n', '', 1)
    head_end = full.index(DEFS)
    full = full[:head_end] + '</head>\n<body>\n' + full[head_end:]
    out = ROOT / 'design' / 'wireframes.html'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(full, encoding='utf-8')
    print(f'wrote {out} ({len(full) // 1024} KB)')
    if len(sys.argv) > 1:
        pathlib.Path(sys.argv[1]).write_text(content, encoding='utf-8')
        print(f'wrote {sys.argv[1]}')


if __name__ == '__main__':
    main()
