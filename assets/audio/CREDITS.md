# Audio credits

Every sound in this folder is original. Each one was synthesised from sine
waves, filtered noise and simple resonators by `tool/design/gen_audio.py`.
No samples, loops or third-party recordings were used.

The authors dedicate these files to the public domain under
[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

| File | What it is |
|---|---|
| `dice_roll` | Dice tumbling, 0.8 s |
| `dice_land` | Dice coming to rest |
| `step` | One token hop |
| `leave_base` | Token entering the board |
| `capture` | The "bonk" when a token is sent home |
| `home` | Token reaching HOME |
| `extra_roll` | Extra roll earned |
| `timer_tick` | Last 5 seconds of the turn timer |
| `win` | Player finishes |
| `ui_tap` | Button tap |
| `music_loop` | 76.8 s seamless loop, 100 BPM |

Formats: `.ogg` (Vorbis) for Android and `.m4a` (AAC) for iOS, which cannot play Ogg.

To regenerate: `python3 tool/design/gen_audio.py`.

Fonts in `assets/fonts/` are not covered here. Fredoka and Nunito are licensed
under the SIL Open Font License 1.1; see `OFL-Fredoka.txt` and `OFL-Nunito.txt`.
