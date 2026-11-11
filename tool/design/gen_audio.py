#!/usr/bin/env python3
"""Synthesises every Ludo Unbiased sound from scratch (no samples).

Writes assets/audio/<name>.ogg (Vorbis, Android) and <name>.m4a (AAC, iOS).
All output is original and dedicated to the public domain (CC0); see
assets/audio/CREDITS.md.

Needs numpy (tool/requirements.txt), oggenc (brew install vorbis-tools) and ffmpeg.
Usage: python3 tool/design/gen_audio.py
"""
import pathlib
import subprocess
import tempfile
import wave

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets' / 'audio'
SR = 44100
rng = np.random.default_rng(20261111)


def t_axis(dur):
    return np.arange(int(dur * SR)) / SR


def env_exp(dur, decay, attack=0.002):
    t = t_axis(dur)
    a = np.clip(t / attack, 0, 1) if attack > 0 else 1
    return a * np.exp(-t / decay)


def tone(freq, dur, decay, attack=0.002, partials=((1, 1.0),)):
    t = t_axis(dur)
    sig = sum(amp * np.sin(2 * np.pi * freq * mul * t) for mul, amp in partials)
    return sig * env_exp(dur, decay, attack)


def sweep(f0, f1, dur, decay, attack=0.002, curve=3.0):
    t = t_axis(dur)
    f = f1 + (f0 - f1) * np.exp(-t * curve / dur)
    phase = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(phase) * env_exp(dur, decay, attack)


def noise(dur, decay, attack=0.001, smooth=1):
    n = rng.standard_normal(int(dur * SR))
    if smooth > 1:
        n = np.convolve(n, np.ones(smooth) / smooth, mode='same')
    return n * env_exp(dur, decay, attack)


def wood(freq, dur=0.06, decay=0.012):
    """A short knock: damped resonance plus a click of noise."""
    return tone(freq, dur, decay, 0.0005, ((1, 1), (2.76, .35), (5.4, .12))) + noise(dur, 0.003, 0.0002) * 0.35


def place(buf, sig, at):
    i = int(at * SR)
    j = min(len(buf), i + len(sig))
    buf[i:j] += sig[:j - i]


def bell(freq, dur, decay):
    return tone(freq, dur, decay, 0.003, ((1, 1), (2.0, .25), (3.01, .12), (4.2, .06)))


def note(name):
    names = {'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5, 'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11}
    return 440.0 * 2 ** ((names[name[:-1]] + 12 * (int(name[-1]) + 1) - 69) / 12)


# --- Effects ------------------------------------------------------------------

def dice_roll():
    buf = np.zeros(int(0.8 * SR))
    t = 0.0
    gap = 0.045
    while t < 0.72:
        place(buf, wood(rng.uniform(1900, 3400), 0.05, rng.uniform(.006, .014)) * rng.uniform(.5, 1), t)
        if rng.random() < .5:
            place(buf, wood(rng.uniform(700, 1100), 0.06, .01) * .4, t + .006)
        t += gap * rng.uniform(.6, 1.4)
        gap *= 1.07
    return buf * np.linspace(1, .8, len(buf))


def dice_land():
    buf = np.zeros(int(0.28 * SR))
    place(buf, tone(140, 0.25, 0.05, 0.001, ((1, 1), (2, .3))), 0)
    place(buf, wood(2300, 0.06, 0.012) * .8, 0)
    place(buf, wood(2600, 0.06, 0.01) * .35, 0.07)
    return buf


def step():
    return wood(980, 0.09, 0.02) * .9 + tone(1960, 0.09, 0.01) * .15


def leave_base():
    buf = np.zeros(int(0.36 * SR))
    place(buf, sweep(260, 920, 0.3, 0.09, 0.003, 4), 0)
    place(buf, tone(1240, 0.2, 0.05, 0.002) * .35, 0.06)
    return buf


def capture():
    buf = np.zeros(int(0.55 * SR))
    place(buf, sweep(560, 170, 0.45, 0.12, 0.002, 5) * 1.0, 0)
    place(buf, sweep(1120, 340, 0.3, 0.06, 0.002, 5) * .3, 0)
    place(buf, noise(0.35, 0.08, 0.01, 12) * .5, 0.04)
    return buf


def home():
    buf = np.zeros(int(1.0 * SR))
    for k, nm in enumerate(['C6', 'E6', 'G6', 'C7']):
        place(buf, bell(note(nm), 0.8, 0.28) * (1 - k * .08), k * 0.07)
    return buf


def extra_roll():
    buf = np.zeros(int(0.46 * SR))
    for k, nm in enumerate(['G5', 'D6']):
        place(buf, tone(note(nm), 0.3, 0.11, 0.004, ((1, 1), (3, .18), (5, .06))), k * 0.11)
    return buf


def timer_tick():
    return wood(2500, 0.06, 0.006) * .8


def win():
    buf = np.zeros(int(2.3 * SR))
    for k, nm in enumerate(['C5', 'E5', 'G5', 'C6']):
        place(buf, tone(note(nm), 0.5, 0.18, 0.004, ((1, 1), (2, .3), (3, .15))), k * 0.12)
    t = t_axis(1.7)
    chord = sum(np.sin(2 * np.pi * note(nm) * t) for nm in ['C5', 'E5', 'G5', 'C6']) / 3
    chord *= np.clip(t / 0.03, 0, 1) * np.exp(-t / 0.7) * (1 + .12 * np.sin(2 * np.pi * 6 * t))
    place(buf, chord, 0.5)
    for k in range(7):
        place(buf, bell(rng.uniform(2400, 4200), 0.4, 0.08) * .25, 0.55 + k * 0.17)
    return buf


def ui_tap():
    return tone(1250, 0.05, 0.008, 0.0008, ((1, 1), (2.4, .2))) + noise(0.05, 0.002, 0.0002) * .15


# --- Music ----------------------------------------------------------------------

def music_loop():
    """32 bars at 100 BPM = 76.8 s. Rendered over three passes; the middle one is
    kept, so decays from the end of the loop continue seamlessly into its start."""
    bpm = 100
    beat = 60 / bpm
    bars = 32
    L = bars * 4 * beat
    total = 3 * L + 2
    buf = np.zeros(int(total * SR))
    prog = [('C', ['C4', 'E4', 'G4', 'B4']), ('A', ['A3', 'C4', 'E4', 'G4']),
            ('F', ['F3', 'A3', 'C4', 'E4']), ('G', ['G3', 'B3', 'D4', 'F4'])]
    bass = {'C': 'C2', 'A': 'A1', 'F': 'F2', 'G': 'G2'}
    arp_pat = [0, 2, 1, 3, 2, 1, 3, 2]
    for loop in range(3):
        base = loop * L
        for bar in range(bars):
            root, chord = prog[(bar // 2) % 4]
            t0 = base + bar * 4 * beat
            if bar % 2 == 0:
                dur = 8 * beat + 1.5
                tt = t_axis(dur)
                pad = sum(np.sin(2 * np.pi * note(nm) * tt) + .5 * np.sin(2 * np.pi * note(nm) * 1.003 * tt) for nm in chord)
                pad *= np.clip(tt / 1.2, 0, 1) * np.clip((dur - tt) / 1.5, 0, 1) * .045
                place(buf, pad, t0)
            for b in range(4):
                place(buf, tone(note(bass[root]), beat * 1.2, beat * .5, 0.01, ((1, 1), (2, .3))) * (.32 if b % 2 == 0 else .2),
                      t0 + b * beat)
            if bar >= 2 or loop > 0:
                for e in range(8):
                    nm = chord[arp_pat[e]]
                    octv = nm[:-1] + str(int(nm[-1]) + 1)
                    place(buf, bell(note(octv), beat * 1.4, beat * .35) * .11, t0 + e * beat / 2)
            for e in range(8):
                if e % 2 == 1:
                    place(buf, noise(0.06, 0.012, 0.001, 3) * .05, t0 + e * beat / 2)
            if bar % 8 == 7:
                place(buf, bell(note('G6'), 1.5, .5) * .06, t0 + 3.5 * beat)
    seg = buf[int(L * SR):int(2 * L * SR)]
    return seg


# --- Output ----------------------------------------------------------------------

def normalise(sig, peak_db):
    sig = sig - np.mean(sig)
    peak = np.max(np.abs(sig)) or 1
    return sig / peak * 10 ** (peak_db / 20)


def fade_edges(sig, ms=3):
    k = int(SR * ms / 1000)
    sig = sig.copy()
    sig[:k] *= np.linspace(0, 1, k)
    sig[-k:] *= np.linspace(1, 0, k)
    return sig


def write(name, sig, music=False):
    sig = normalise(sig, -3.0 if music else -1.0)
    if not music:
        sig = fade_edges(sig)
    pcm = (np.clip(sig, -1, 1) * 32767).astype('<i2')
    with tempfile.TemporaryDirectory() as d:
        wav = pathlib.Path(d) / f'{name}.wav'
        with wave.open(str(wav), 'wb') as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(pcm.tobytes())
        subprocess.run(['oggenc', '-Q', '-q', '3' if music else '4', '-o', str(OUT / f'{name}.ogg'), str(wav)], check=True)
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', str(wav), '-c:a', 'aac', '-b:a', '80k' if music else '96k',
                        '-movflags', '+faststart', str(OUT / f'{name}.m4a')], check=True)
    sizes = [(OUT / f'{name}.{e}').stat().st_size // 1024 for e in ('ogg', 'm4a')]
    print(f'{name:12s} {len(sig) / SR:6.2f} s  ogg {sizes[0]:4d} KB  m4a {sizes[1]:4d} KB')


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for fn in [dice_roll, dice_land, step, leave_base, capture, home, extra_roll, timer_tick, win, ui_tap]:
        write(fn.__name__, fn())
    write('music_loop', music_loop(), music=True)


if __name__ == '__main__':
    main()
