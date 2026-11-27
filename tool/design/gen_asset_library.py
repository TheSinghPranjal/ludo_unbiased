#!/usr/bin/env python3
"""Generates design/asset_library.html from the exported assets.

Every image and sound on the page is the real file from assets/, embedded as a
data URI, so the page is self-contained. Run after tool/export_assets.py and
tool/design/gen_audio.py.

Usage: python3 tool/design/gen_asset_library.py [fragment_out.html]
"""
import base64
import html
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from gen_art import COLORS, PALETTE, contrast  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parents[2]
MAN = json.loads((ROOT / 'assets' / 'manifest.json').read_text())
BY_ID = {e['id']: e for e in MAN['images']}
_cache = {}


def esc(t):
    return html.escape(str(t), quote=True)


def file_for(e, mode=None, prefer=2):
    rel = e['path'].replace('{mode}', mode) if mode else e['path']
    p = pathlib.PurePosixPath(rel)
    if prefer in e['scales'] and prefer != 1:
        p = p.parent / f'{prefer:.1f}x' / p.name
    return ROOT / str(p), rel


def uri(path):
    if path not in _cache:
        mime = {'.png': 'image/png', '.m4a': 'audio/mp4', '.ogg': 'audio/ogg'}[path.suffix]
        _cache[path] = f'data:{mime};base64,' + base64.b64encode(path.read_bytes()).decode()
    return _cache[path]


def src_attrs(e):
    """src for light, plus data-light / data-dark when the asset has both modes."""
    if isinstance(e['modes'], list):
        l, _ = file_for(e, 'light')
        d, _ = file_for(e, 'dark')
        return f'src="{uri(l)}" data-light="{uri(l)}" data-dark="{uri(d)}"'
    f, _ = file_for(e)
    return f'src="{uri(f)}"'


def label(e):
    rel = e['path']
    return rel.split('/')[-1].replace('{mode}', '{light|dark}') if isinstance(e['modes'], list) else rel.split('/')[-1]


def sprite(e, show_w=None, alt=None):
    w, h = e['size']
    sw = show_w or w
    sh = sw * h / w
    meta = f'{w}×{h}' + (' · 9-slice' if e['nineSlice'] else '') + (' · tinted' if e['modes'] == 'tinted' else '')
    return (f'<div class="cell"><div class="chk"><img {src_attrs(e)} width="{sw:g}" height="{sh:g}" alt="{esc(alt or e["id"])}" '
            f'loading="lazy"></div><code>{esc(label(e))}</code><span class="meta">{meta}</span></div>')


def sheet(ids, title=None, show_w=None, cls=''):
    cells = ''.join(sprite(BY_ID[i], show_w(BY_ID[i]) if callable(show_w) else show_w) for i in ids)
    cap = f'<figcaption>{title}</figcaption>' if title else ''
    return f'<figure class="sheet {cls}"><div class="sprites">{cells}</div>{cap}</figure>'


# --- Board composition ---------------------------------------------------------

TRACK = [(13, 6), (12, 6), (11, 6), (10, 6), (9, 6), (8, 5), (8, 4), (8, 3), (8, 2), (8, 1), (8, 0), (7, 0), (6, 0), (6, 1),
         (6, 2), (6, 3), (6, 4), (6, 5), (5, 6), (4, 6), (3, 6), (2, 6), (1, 6), (0, 6), (0, 7), (0, 8), (1, 8), (2, 8),
         (3, 8), (4, 8), (5, 8), (6, 9), (6, 10), (6, 11), (6, 12), (6, 13), (6, 14), (7, 14), (8, 14), (8, 13), (8, 12),
         (8, 11), (8, 10), (8, 9), (9, 8), (10, 8), (11, 8), (12, 8), (13, 8), (14, 8), (14, 7), (14, 6)]
START = {'red': 0, 'blue': 13, 'yellow': 26, 'green': 39}
STARS = {8, 21, 34, 47}
ENTRY = {50: ('red', 0), 11: ('blue', 90), 24: ('yellow', 180), 37: ('green', 270)}
HOME_COL = {'red': [(13, 7), (12, 7), (11, 7), (10, 7), (9, 7)], 'blue': [(7, 1), (7, 2), (7, 3), (7, 4), (7, 5)],
            'yellow': [(1, 7), (2, 7), (3, 7), (4, 7), (5, 7)], 'green': [(7, 13), (7, 12), (7, 11), (7, 10), (7, 9)]}
YARD = {'blue': (0, 0), 'yellow': (0, 9), 'green': (9, 9), 'red': (9, 0)}


def cell_of(col, rel):
    return TRACK[(START[col] + rel) % 52] if rel <= 50 else HOME_COL[col][rel - 51]


def slot(col, tid):
    r0, c0 = YARD[col]
    dr, dc = [(2, 2), (2, 4), (4, 2), (4, 4)][tid]
    return r0 + dr, c0 + dc


class Comp:
    """Absolutely positioned images in a W×H design space, expressed in %, so it scales."""

    def __init__(self, W, H, mode=None):
        self.W, self.H, self.mode, self.parts = W, H, mode, []

    def img(self, asset_id, x, y, w, h, extra='', cls=''):
        e = BY_ID[asset_id]
        if self.mode and isinstance(e['modes'], list):
            f, _ = file_for(e, self.mode, prefer=1)
            src = f'src="{uri(f)}"'
        elif isinstance(e['modes'], list):
            l, _ = file_for(e, 'light', prefer=1)
            d, _ = file_for(e, 'dark', prefer=1)
            src = f'src="{uri(l)}" data-light="{uri(l)}" data-dark="{uri(d)}"'
        else:
            f, _ = file_for(e, prefer=1)
            src = f'src="{uri(f)}"'
        self.parts.append(f'<img {src} alt="" class="{cls}" style="{self.box(x, y, w, h)}{extra}">')

    def box(self, x, y, w, h):
        return (f'left:{x / self.W * 100:.3f}%;top:{y / self.H * 100:.3f}%;'
                f'width:{w / self.W * 100:.3f}%;height:{h / self.H * 100:.3f}%;')

    def raw(self, s):
        self.parts.append(s)


def draw_board(comp, bx, by, size, tokens=(), extra=None):
    c = size / 15
    comp.img('board_bg', bx, by, size, size)
    for col, (r0, c0) in YARD.items():
        comp.img(f'board_yard_{col}', bx + c0 * c, by + r0 * c, 6 * c, 6 * c)
    for i, (r, cc) in enumerate(TRACK):
        x, y = bx + cc * c, by + r * c
        if i in START.values():
            col = [k for k, v in START.items() if v == i][0]
            comp.img(f'board_cell_start_{col}', x, y, c, c)
        elif i in STARS:
            comp.img('board_cell_safe_star', x, y, c, c)
        elif i in ENTRY:
            col, rot = ENTRY[i]
            comp.img(f'board_arrow_{col}', x, y, c, c, f'transform:rotate({rot}deg);')
        else:
            comp.img('board_cell', x, y, c, c)
    for col, cells in HOME_COL.items():
        for r, cc in cells:
            comp.img(f'board_home_column_{col}', bx + cc * c, by + r * c, c, c)
    comp.img('board_centre_home', bx + 6 * c, by + 6 * c, 3 * c, 3 * c)
    ts = c * 1.16
    for col, tid, rel, state in tokens:
        if rel == -1:
            r, cc = slot(col, tid)
            cx, cy = bx + cc * c, by + r * c
        else:
            r, cc = cell_of(col, rel)
            cx, cy = bx + (cc + .5) * c, by + (r + .5) * c
        comp.img('token_shadow', cx - ts / 2, cy - ts / 2, ts, ts)
        comp.img(f'token_{col}_{state}', cx - ts / 2, cy - ts / 2, ts, ts)
    if extra:
        extra(comp, bx, by, c)


BOARD_TOKENS = [('red', 0, -1, 'idle'), ('red', 1, -1, 'idle'), ('red', 2, 12, 'idle'), ('red', 3, 30, 'idle'),
                ('blue', 0, -1, 'idle'), ('blue', 1, 5, 'idle'), ('blue', 2, -1, 'idle'), ('blue', 3, -1, 'idle'),
                ('yellow', 0, -1, 'idle'), ('yellow', 1, -1, 'idle'), ('yellow', 2, -1, 'idle'), ('yellow', 3, 20, 'idle'),
                ('green', 0, 44, 'idle'), ('green', 1, -1, 'idle'), ('green', 2, -1, 'idle'), ('green', 3, -1, 'idle')]


def full_board():
    comp = Comp(720, 720)
    draw_board(comp, 0, 0, 720, BOARD_TOKENS)
    return f'<div class="comp board-comp">{"".join(comp.parts)}</div>'


# --- In-context mockup ---------------------------------------------------------

def mockup(mode):
    p = PALETTE[mode]
    W, H = 390, 844
    comp = Comp(W, H, mode)
    m, top, gap, ch, cw, board = 16, 50, 10, 72, 174, 358
    y0 = 171
    by = y0 + ch + gap
    cards = {'blue': (m, y0, 'left'), 'yellow': (m + cw + gap, y0, 'right'),
             'red': (m, by + board + gap, 'left'), 'green': (m + cw + gap, by + board + gap, 'right')}
    names = {'red': ('Asha', 'avatar_01_fox', 1), 'blue': ('Kiwi', 'avatar_06_penguin', 0),
             'yellow': ('Ravi', 'avatar_03_cat', 0), 'green': ('Moss', 'avatar_05_frog', 2)}
    comp.raw(f'<div class="fill" style="background:{p["bg"]}"></div>')
    comp.raw(f'<span class="t" style="{comp.box(28, 18, 60, 20)}color:{p["text"]};font:700 3.6cqw/1 var(--body)">9:41</span>')
    comp.img('ui_button_icon_normal', m, top + 2, 44, 44)
    comp.raw(f'<span class="mask" style="{comp.box(m + 10, top + 10, 24, 24)}background:{p["text"]};'
             f'-webkit-mask-image:url({uri(file_for(BY_ID["icon_pause"])[0])});mask-image:url({uri(file_for(BY_ID["icon_pause"])[0])})"></span>')
    comp.raw(f'<span class="t" style="{comp.box(0, top + 12, W, 26)}justify-content:center;color:{p["text"]};font:600 5.1cqw/1 var(--display)">Local game</span>')
    for col, (x, y, side) in cards.items():
        active = col == 'blue'
        comp.img(f'card_{col}_{"active" if active else "inactive"}', x - 8, y - 8, cw + 16, ch + 16)
        if active:
            ring = uri(file_for(BY_ID['card_timer_ring_fill'])[0])
            track = uri(file_for(BY_ID['card_timer_ring_track'])[0])
            for u, bg in ((track, f'{p[col]}'), (ring, f'conic-gradient({p[col]} 0 64%, transparent 0)')):
                comp.raw(f'<span class="mask" style="{comp.box(x - 8, y - 8, cw + 16, ch + 16)}background:{bg};'
                         f'-webkit-mask-image:url({u});mask-image:url({u});-webkit-mask-size:100% 100%;mask-size:100% 100%"></span>')
        nm, av, home = names[col]
        ax = x + 10 if side == 'left' else x + cw - 54
        comp.img(av, ax, y + 14, 44, 44, 'border-radius:50%;')
        dx = x + cw - 62 if side == 'left' else x + 10
        tx = ax + 52 if side == 'left' else dx + 60
        comp.raw(f'<span class="t" style="{comp.box(tx, y + 18, 70, 22)}color:{p["text"]};font:700 4.4cqw/1 var(--body)">{nm}</span>')
        dots = ''.join(f'<i style="background:{p[col] if k < home else "transparent"};border-color:{p[col]}"></i>' for k in range(4))
        comp.raw(f'<span class="pips" style="{comp.box(tx, y + 44, 70, 12)}">{dots}</span>')
        if active:
            comp.img(f'dice_tray_{col}', dx, y + 10, 52, 52)
            comp.img('dice_face_4', dx + 4, y + 14, 44, 44)
        else:
            comp.raw(f'<span class="slot" style="{comp.box(dx + 6, y + 14, 44, 44)}border-color:{p["border"]}"></span>')

    def capture_fx(comp, bx, byy, c):
        r, cc = cell_of('yellow', 20)
        cx, cy = bx + (cc + .5) * c, byy + (r + .5) * c
        comp.img('fx_capture_puff_03', cx - c * 1.4, cy - c * 1.4, c * 2.8, c * 2.8)
        tx, ty = bx + 10.2 * c, byy + 9.4 * c
        sr, sc = slot('yellow', 3)
        ex, ey = bx + sc * c, byy + sr * c
        comp.raw(f'<svg class="fill" viewBox="0 0 {W} {H}" preserveAspectRatio="none"><path d="M{cx:.1f} {cy:.1f} Q{tx + 30:.1f} {ty - 60:.1f} '
                 f'{ex:.1f} {ey + c * .6:.1f}" fill="none" stroke="{p["yellow"]}" stroke-width="2" stroke-dasharray="3 5" '
                 f'stroke-linecap="round" vector-effect="non-scaling-stroke"/></svg>')
        ts = c * 1.3
        comp.img('token_yellow_hop', tx + 20 - ts / 2, ty - 40 - ts / 2, ts, ts, 'opacity:.92;')
        comp.img('token_blue_hop', cx - c * .65, cy - c * .7, c * 1.3, c * 1.3)

    toks = [t for t in BOARD_TOKENS if not (t[0] == 'yellow' and t[1] == 3) and not (t[0] == 'blue' and t[1] == 1)]
    toks.append(('blue', 0, 0, 'idle'))
    comp.img('board_frame', m - 16, by - 16, board + 32, board + 32)
    draw_board(comp, m, by, board, toks, capture_fx)
    sy = by + board + gap + ch + gap
    comp.raw(f'<span class="t status" style="{comp.box(m, sy, board, 40)}background:{p["surface2"]};color:{p["text"]};'
             f'border:1px solid {p["border"]};font:700 4.1cqw/1 var(--body)">Blue captured Yellow! Extra roll.</span>')
    comp.raw(f'<span class="homebar" style="{comp.box(W / 2 - 67, H - 14, 134, 5)}background:{p["text"]}"></span>')
    return f'<div class="phone comp" style="aspect-ratio:{W}/{H}">{"".join(comp.parts)}</div>'


# --- Colour specs --------------------------------------------------------------------

def palette_table(mode):
    p = PALETTE[mode]
    rows = [('App background', 'bg', 'text'), ('Surface', 'surface', 'text'), ('Surface, secondary text', 'surface', 'text2'),
            ('Surface 2', 'surface2', 'text'), ('Primary button', 'primary', 'on_primary'), ('Danger button', 'danger', 'on_danger'),
            ('Grid line (decorative)', 'cell', 'grid'), ('Safe-cell star', 'cell', 'star')]
    rows += [(f'{c.title()} token symbol', c, None) for c in COLORS]
    out = ''
    for lbl, a, b in rows:
        fg = p[b] if b else ('#3B2F00' if a == 'yellow' else '#FFFFFF')
        bg = p[a]
        r = contrast(fg, bg)
        need = None if b == 'grid' else (3.0 if a in COLORS or b == 'star' else 4.5)
        if need is None:
            verdict, cls = 'exempt: decorative, spec value', 'ex'
        else:
            cls = 'AA' if r >= need else 'fail'
            verdict = f'{cls} ({need:g}:1)'
        out += (f'<tr><td><span class="sw" style="background:{bg}"></span><span class="sw" style="background:{fg}"></span>{esc(lbl)}</td>'
                f'<td><code>{bg} / {fg}</code></td><td class="num">{r:.2f}</td><td class="{cls}">{verdict}</td></tr>')
    swatches = ''.join(f'<span class="chip"><span class="sw lg" style="background:{p[c]}"></span><code>{c} {p[c]}</code></span>'
                       for c in COLORS + ['board', 'cell', 'grid', 'bg', 'surface', 'surface2', 'text', 'text2', 'primary'])
    return (f'<figure class="sheet"><h3>{mode.title()}</h3><div class="chips">{swatches}</div>'
            f'<div class="tw"><table><thead><tr><th>Pair</th><th>Background / foreground</th><th>Ratio</th><th>WCAG</th></tr></thead>'
            f'<tbody>{out}</tbody></table></div></figure>')


AUDIO_DESC = {'dice_roll': 'Dice tumbling, 0.8 s', 'dice_land': 'Dice comes to rest', 'step': 'One token hop',
              'leave_base': 'Token enters the board', 'capture': 'The bonk when a token is sent home', 'home': 'Token reaches HOME',
              'extra_roll': 'Extra roll earned', 'timer_tick': 'Last 5 s of the timer', 'win': 'Player finishes',
              'ui_tap': 'Button tap', 'music_loop': '76.8 s seamless loop, 100 BPM'}


def audio_rows():
    out = ''
    for a in MAN['audio']:
        m4a = ROOT / a['path'].replace('{format}', 'm4a')
        ogg = ROOT / a['path'].replace('{format}', 'ogg')
        kb = f'{ogg.stat().st_size // 1024} KB ogg · {m4a.stat().st_size // 1024} KB m4a'
        out += (f'<div class="aud"><div><code>{a["id"]}</code><span class="meta">{esc(AUDIO_DESC[a["id"]])} · {kb}</span></div>'
                f'<audio controls preload="none" aria-label="{a["id"]}"><source src="{uri(m4a)}" type="audio/mp4">'
                f'<source src="{uri(ogg)}" type="audio/ogg"></audio></div>')
    return f'<figure class="sheet"><div class="auds">{out}</div></figure>'


# --- Page ------------------------------------------------------------------------------

CSS = r"""
:root{
  --band:#2B2F3A; --paper:#F1F4F8; --sheet:#FFFFFF; --muted:#566070; --line:#CBD3DD;
  --sun:#FFC93C; --road:#1C5FBF;
  --display:'Fredoka','Trebuchet MS',sans-serif; --body:'Nunito',system-ui,sans-serif;
  --ink:#1B1E28; --chk-a:#FFFFFF; --chk-b:#EEF1F5;
  color-scheme:light;
}
/* Layout: dark title band, then one 1240 px column of white sprite sheets on paper. */
body{ background:var(--paper); color:var(--ink); font:16px/1.5 var(--body) }
body::before{ content:""; position:fixed; inset:0 0 auto; height:env(safe-area-inset-top,0px); z-index:10; background:var(--paper) }
.wrap{ max-width:1240px; margin:0 auto; padding-left:max(16px, env(safe-area-inset-left,0px)); padding-right:max(16px, env(safe-area-inset-right,0px)) }
header.band{ background:var(--band); color:#fff; border-bottom:6px dashed var(--sun); position:relative }
header.band .wrap{ padding-block:44px 52px }
header.band h1{ font:700 clamp(44px,8vw,72px)/1 var(--display); color:var(--sun); margin:0; text-wrap:balance }
header.band p{ color:#DDE3EC; max-width:62ch; margin:14px 0 0 }
.strip{ position:absolute; left:0; right:0; bottom:0; height:8px; display:grid; grid-template-columns:repeat(4,1fr) }
.strip i:nth-child(1){ background:#D9342B } .strip i:nth-child(2){ background:#3E8EDE }
.strip i:nth-child(3){ background:#ECCB3A } .strip i:nth-child(4){ background:#3D9142 }
nav.top{ position:sticky; top:env(safe-area-inset-top,0px); z-index:5; background:var(--paper); border-bottom:1px solid var(--line) }
nav.top .wrap{ display:flex; align-items:center; gap:16px; padding-block:10px }
nav.top ul{ list-style:none; margin:0; padding:2px; display:flex; gap:18px; overflow-x:auto; flex:1; min-width:0; scrollbar-width:thin }
nav.top a{ font:500 17px/1.6 var(--display); color:var(--road); text-decoration:none; white-space:nowrap; border-radius:4px }
nav.top a:hover{ text-decoration:underline }
nav.top a:focus-visible, .toggle:focus-visible{ outline:2px solid var(--road); outline-offset:2px }
.toggle{ flex:none; font:500 16px/1 var(--display); color:var(--ink); background:var(--sheet); border:1px solid var(--line);
  border-radius:999px; padding:8px 14px; cursor:pointer; display:flex; gap:8px; align-items:center }
.toggle b{ font-weight:600 }
main.wrap{ display:grid; grid-template-columns:minmax(0,1fr); gap:52px; padding-block:44px 80px }
section{ display:grid; grid-template-columns:minmax(0,1fr); gap:14px; scroll-margin-top:70px; min-width:0 }
h2{ font:600 32px/1.1 var(--display); margin:0; text-wrap:balance }
h3{ font:600 22px/1.2 var(--display); margin:0 0 12px }
.note{ color:var(--muted); max-width:65ch; margin:-6px 0 0 }
figure.sheet{ margin:0; background:var(--sheet); border:1px solid var(--line); border-radius:14px; padding:20px; min-width:0 }
figure.sheet figcaption{ color:var(--muted); font-size:14px; margin-top:12px }
.sprites{ display:flex; flex-wrap:wrap; gap:14px; align-items:flex-end }
.cell{ display:grid; gap:4px; justify-items:start; max-width:100% }
.chk{ padding:10px; border-radius:10px; max-width:100%;
  background:repeating-conic-gradient(var(--chk-a) 0 25%, var(--chk-b) 0 50%) 0 0/16px 16px }
.chk img{ display:block; max-width:100%; height:auto }
[data-mode="dark"] .chk{ --chk-a:#1D2030; --chk-b:#262A3C }
.cell code, code{ font:12px/1.35 ui-monospace,SFMono-Regular,Menlo,monospace; color:var(--ink); overflow-wrap:anywhere }
.meta{ font-size:12px; color:var(--muted) }
.grid2{ display:grid; grid-template-columns:repeat(auto-fit,minmax(min(100%,420px),1fr)); gap:20px }
.comp{ position:relative; overflow:hidden }
.comp > *{ position:absolute }
.comp > img{ display:block }
.board-comp{ width:min(100%,640px); aspect-ratio:1; border-radius:8px }
[data-mode="dark"] .board-wrap{ background:#12141C }
.board-wrap{ padding:20px; border-radius:12px; background:#F4F5F9; display:grid; justify-items:center }
.phone{ width:100%; border-radius:28px; box-shadow:0 0 0 6px #1B1E28, 0 10px 30px rgba(27,30,40,.25); container-type:inline-size }
.phone .fill{ inset:0; width:100%; height:100% }
.phone .t{ display:flex; align-items:center; white-space:nowrap; overflow:hidden }
.phone .status{ justify-content:center; border-radius:12px; box-sizing:border-box }
.phone .pips{ display:flex; gap:4%; align-items:center }
.phone .pips i{ width:9%; aspect-ratio:1; border-radius:50%; border:1.5px solid; box-sizing:border-box }
.phone .slot{ border:2px dashed; border-radius:12px; box-sizing:border-box }
.phone .homebar{ border-radius:3px }
.phone .mask{ -webkit-mask-repeat:no-repeat; mask-repeat:no-repeat; -webkit-mask-size:100% 100%; mask-size:100% 100% }
.context{ display:grid; grid-template-columns:minmax(0,3fr) minmax(0,2fr); gap:28px; align-items:start }
.phones{ display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:28px; padding:8px }
.phones figure{ margin:0; display:grid; gap:12px }
.phones figcaption{ font:600 18px/1 var(--display); text-align:center }
@media (max-width:760px){ .context{ grid-template-columns:minmax(0,1fr) } }
@media (max-width:480px){ .phones{ grid-template-columns:minmax(0,1fr) } }
.rules h3{ margin-top:18px } .rules h3:first-child{ margin-top:0 }
.rules dl{ display:grid; grid-template-columns:auto 1fr; gap:6px 14px; margin:0 }
.rules dt{ font-weight:700 } .rules dd{ margin:0; color:var(--ink) }
.num{ font-variant-numeric:tabular-nums; text-align:right }
.tw{ overflow-x:auto }
table{ border-collapse:collapse; width:100%; font-size:14px }
th,td{ text-align:left; padding:7px 10px; border-bottom:1px solid var(--line); vertical-align:middle }
th{ font:600 15px/1.2 var(--display) }
td.AA{ color:#1E7A35; font-weight:700 } td.fail{ color:#B42318; font-weight:700 } td.ex{ color:var(--muted) }
.sw{ display:inline-block; width:14px; height:14px; border-radius:4px; border:1px solid rgba(0,0,0,.18); vertical-align:-2px; margin-right:4px }
.sw.lg{ width:26px; height:26px; border-radius:7px; vertical-align:middle }
.chips{ display:flex; flex-wrap:wrap; gap:10px 16px; margin-bottom:14px }
.chip{ display:flex; gap:8px; align-items:center }
.type{ display:grid; gap:10px }
.type p{ margin:0 }
.auds{ display:grid; grid-template-columns:repeat(auto-fill,minmax(min(100%,340px),1fr)); gap:14px }
.aud{ display:grid; gap:8px; padding:12px; border:1px solid var(--line); border-radius:10px }
.aud > div{ display:grid }
.aud audio{ width:100% }
.icons .chk{ padding:12px }
@media (prefers-reduced-motion:no-preference){ html{ scroll-behavior:smooth } }
"""

JS = r"""
(function(){
  var root=document.getElementById('sheets'), btn=document.getElementById('modeToggle'), label=btn.querySelector('b');
  function apply(m){
    root.setAttribute('data-mode',m);
    btn.setAttribute('aria-pressed', m==='dark' ? 'true' : 'false');
    label.textContent = m==='dark' ? 'Dark' : 'Light';
    root.querySelectorAll('img[data-light]').forEach(function(i){ i.src = i.getAttribute('data-'+m); });
  }
  var saved='light'; try{ saved=localStorage.getItem('assetMode')||'light'; }catch(e){}
  apply(saved);
  btn.addEventListener('click', function(){
    var m = root.getAttribute('data-mode')==='dark' ? 'light' : 'dark';
    apply(m); try{ localStorage.setItem('assetMode', m); }catch(e){}
  });
})();
"""


def ids(prefix):
    return [e['id'] for e in MAN['images'] if e['id'].startswith(prefix)]


def build():
    half = lambda e: min(e['size'][0], 320)  # noqa: E731
    sections = []

    def sec(key, title, note, body):
        sections.append((key, title, f'<section id="{key}"><h2>{title}</h2><p class="note">{note}</p>{body}</section>'))

    sec('brand', 'Brand', 'The four-triangle HOME mark, the launcher icon set and the wordmark. The mark is the board\'s own centre, so the icon reads as Ludo at 48 px.',
        sheet(['brand_app_icon', 'brand_adaptive_foreground', 'brand_adaptive_background'], 'Launcher masters at 1024 px (shown at 200). flutter_launcher_icons builds the iOS and Android sets from these.', 200)
        + sheet(['brand_splash_logo', 'brand_wordmark'], 'Splash logo and wordmark: light and dark variants.'))
    sec('board', 'Board pieces', 'Flame draws the board from the §1.1 geometry and places these pieces on it. One cell is 48 px at 1x.',
        sheet(['board_cell', 'board_cell_safe_star'] + [f'board_cell_start_{c}' for c in COLORS] + [f'board_home_column_{c}' for c in COLORS]
              + [f'board_arrow_{c}' for c in COLORS] + ['board_centre_home', 'board_frame'], 'Cells, home columns, entry arrows (rotated per colour), the centre and the 9-slice frame.', 96)
        + sheet([f'board_yard_{c}' for c in COLORS], 'Yards: 6×6 cells with a white inner square and four slot rings.', 220))
    sec('render', 'Full board render', 'Every piece above, composed at the real §1.1 coordinates with tokens in a mid-game position. Use the toggle to switch modes.',
        f'<figure class="sheet"><div class="board-wrap">{full_board()}</div></figure>')
    tok = []
    for c in COLORS:
        tok += [f'token_{c}_{s}' for s in ['idle', 'movable', 'selected', 'hop', 'ghost']]
    sec('tokens', 'Tokens', 'A glossy top-view pawn with its colour-blind symbol: Red ●, Blue ■, Yellow ▲, Green ★. Dark mode adds a light rim.',
        sheet(tok, 'Per colour: idle, movable (pulse ring), selected, hop, ghost (destination marker).', 64)
        + sheet(['token_shadow', 'token_stack_badge_2', 'token_stack_badge_3', 'token_stack_badge_4'], 'Shadow and stack badges.', 64))
    sec('dice', 'Dice', 'Faces, the eight 100 ms tumble frames played over 800 ms, the shadow and a tray per colour.',
        sheet([f'dice_face_{k}' for k in range(1, 7)] + ['dice_shadow'], None, 64)
        + sheet([f'dice_roll_{k:02d}' for k in range(1, 9)], 'Tumble frames 01–08.', 64)
        + sheet([f'dice_tray_{c}' for c in COLORS], 'Trays sit on the active card.', 72))
    cards = []
    for c in COLORS:
        cards += [f'card_{c}_{s}' for s in ['inactive', 'active', 'disconnected', 'finished']]
    sec('cards', 'Player cards', 'Inactive, active, disconnected and finished, side by side. Every state is exactly 190 × 88 px (a 174 × 72 card plus an 8 px glow margin), so the layout never moves.',
        sheet(cards, '9-slice backgrounds; Flutter draws avatar, name, pips and dice on top.', 190)
        + sheet(['card_timer_ring_track', 'card_timer_ring_fill', 'card_rank_1', 'card_rank_2', 'card_rank_3', 'card_rank_4', 'card_crown', 'card_wifi_off'],
                'Timer ring (tinted with the player colour), medals, crown and the disconnected badge.', lambda e: 190 if 'ring' in e['id'] else e['size'][0]))
    sec('avatars', 'Avatars', 'Twelve original round avatars, 256 px masters shown at 96.', sheet(ids('avatar_'), None, 96))
    sec('ui', 'UI kit', 'Buttons in three states, panels, dialog, toast and banner. All are 9-slice; text and icons are drawn by Flutter.',
        sheet([f'ui_button_{k}_{s}' for k in ['primary', 'secondary', 'danger', 'icon'] for s in ['normal', 'pressed', 'disabled']], None)
        + sheet(['ui_panel', 'ui_dialog', 'ui_toast', 'ui_banner'], None))
    sec('icons', 'Icons', '24-pixel grid, 2 px rounded stroke, single colour. The app tints them with the current text or accent colour.',
        sheet(ids('icon_'), None, 48, 'icons'))
    sec('fx', 'FX', 'Capture puff (6 frames over ~240 ms), sparkle, star burst and confetti in six shapes and four colours.',
        sheet(ids('fx_capture_puff'), None, 96) + sheet(['fx_sparkle', 'fx_star_burst'], None) + sheet(ids('fx_confetti'), None, 24))
    sec('htp', 'How-to-Play art', 'Five cards: leave base on a 6, move by the dice, capture and safe stars, extra rolls, winning.',
        sheet(ids('htp_'), None, 320))
    type_html = ('<figure class="sheet type"><p style="font:700 44px/1.1 var(--display)">Fredoka 700 · Red rolled 6!</p>'
                 '<p style="font:600 30px/1.2 var(--display)">Fredoka 600 · Extra roll 0123456789</p>'
                 '<p style="font:700 18px/1.4 var(--body)">Nunito 700 · Waiting for Priya to be ready</p>'
                 '<p style="font:400 16px/1.5 var(--body)">Nunito 400 · Rolling a 6 lets a token leave base onto its start cell.</p>'
                 '<p class="meta">Bundled in assets/fonts (SIL Open Font License 1.1). Fredoka for display and numbers, Nunito for body.</p></figure>')
    sec('specs', 'Colour &amp; type specs', 'Both palettes with WCAG contrast ratios. Text pairs need 4.5:1; meaningful graphics (safe-cell stars, token symbols) need 3:1. Grid lines are decorative and keep the values set in the spec, so they are exempt. A Flutter test repeats these checks.',
        f'<div class="grid2">{palette_table("light")}{palette_table("dark")}</div>{type_html}')
    sec('audio', 'Audio', 'All sounds are synthesised by tool/design/gen_audio.py and dedicated CC0. Each ships as Ogg (Android) and M4A (iOS).', audio_rows())
    rules = """
<figure class="sheet rules">
<h3>Outlines and shadows</h3>
<dl><dt>Tokens</dt><dd>Darker rim, white inner ring, gloss at top-left. Dark mode adds a 1.5 px light rim.</dd>
<dt>Shadows</dt><dd>Soft ellipse under tokens and dice: 22% black in light, 55% in dark.</dd>
<dt>Cards</dt><dd>2 px border inactive, 3 px plus glow active, dashed disconnected, gold finished.</dd></dl>
<h3>Spacing scale</h3>
<dl><dt>4 · 8 · 12 · 16</dt><dd>Inside cards and controls</dd><dt>24 · 32</dt><dd>Between groups and sections</dd>
<dt>Margin</dt><dd>16 dp phone, 12 dp under 360 dp, 40 dp tablet</dd></dl>
<h3>Card sizes</h3>
<dl><dt>Phone</dt><dd>174 × 72 dp</dd><dt>Small phone</dt><dd>140 × 64 dp, compact</dd><dt>Tablet</dt><dd>352 × 104 dp</dd>
<dt>All states</dt><dd>Identical box; glow and ring stay outside it</dd></dl>
<h3>Token size</h3>
<dl><dt>On board</dt><dd>Sprite 1.16 × cell; pawn 0.76 × cell</dd><dt>Stacks</dt><dd>2 offset; 3–4 cluster with badge</dd></dl>
<h3>Motion</h3>
<dl><dt>Dice</dt><dd>800 ms, 8 frames + bounce</dd><dt>Hop</dt><dd>150 ms per cell, small arc</dd>
<dt>Capture</dt><dd>Puff 240 ms, return 600 ms on a curve</dd><dt>Auto-move</dt><dd>1120 ms after the roll commits</dd>
<dt>AI think</dt><dd>600–900 ms</dd><dt>Toast</dt><dd>1 s</dd><dt>Reduce motion</dt><dd>Same timings, no arcs or particles</dd></dl>
</figure>"""
    context = (f'<div class="context"><div class="phones"><figure>{mockup("light")}<figcaption>Light</figcaption></figure>'
               f'<figure>{mockup("dark")}<figcaption>Dark</figcaption></figure></div>{rules}</div>')
    sec('context', 'In context', 'The Game screen built only from the assets above: four players, Blue mid-capture with the timer ring at 64%.', context)

    nav = ''.join(f'<li><a href="#{k}">{t}</a></li>' for k, t, _ in sections)
    body = ''.join(s for _, _, s in sections)
    return f"""<title>ludo Asset Library</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&amp;family=Nunito:wght@400;700&amp;display=swap">
<style>{CSS}</style>
<header class="band"><div class="wrap"><h1>ludo Asset Library</h1>
<p>Every image, sound and font that ships in Ludo Unbiased, rendered from the real files in assets/. Sprites switch between their light and dark variants with the toggle; the page itself stays light. The last section builds the Game screen from these pieces alone.</p></div>
<div class="strip" aria-hidden="true"><i></i><i></i><i></i><i></i></div></header>
<nav class="top" aria-label="Sections"><div class="wrap"><ul>{nav}</ul>
<button type="button" class="toggle" id="modeToggle" aria-pressed="false">Sprites: <b>Light</b></button></div></nav>
<main class="wrap" id="sheets" data-mode="light">{body}</main>
<script>{JS}</script>
"""


def main():
    content = build()
    full = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
            '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n')
    head, rest = content.split('<header class="band">', 1)
    full += head + '</head>\n<body>\n<header class="band">' + rest + '</body>\n</html>\n'
    out = ROOT / 'design' / 'asset_library.html'
    out.write_text(full, encoding='utf-8')
    print(f'wrote {out} ({len(full) / 1e6:.1f} MB)')
    if len(sys.argv) > 1:
        pathlib.Path(sys.argv[1]).write_text(content, encoding='utf-8')
        print(f'wrote {sys.argv[1]}')


if __name__ == '__main__':
    main()
