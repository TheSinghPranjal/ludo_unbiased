# Decisions

One line per decision: date, decision, reason.

- 2026-11-11: Build from scratch, keeping only platform scaffolding. The existing project is the unmodified `flutter create` template.
- 2026-11-11: Keep the existing project name and bundle ids, including the Android/iOS id difference. Project default is to keep them.
- 2026-11-11: On a third consecutive 6, the 6 is not played, the turn ends, and moves made earlier in the turn stand. Required by spec §1.2.
- 2026-11-11: Host migration is out of scope; clients return to Home after 45 s without the host. Required by spec §1.5.
- 2026-11-11: Write Riverpod providers by hand. `riverpod_generator` does not resolve against Flutter 3.41.6's pinned `meta` and `json_serializable` 6.14.
- 2026-11-11: Use `very_good_analysis` instead of `flutter_lints`. It is the stricter set, per spec §3.1.
- 2026-11-11: Target Android and iOS only. `dart:io` servers do not compile for web, and desktop is out of scope.
- 2026-11-11: Minimum Android is API 24, not 23. Flutter 3.41 and `flutter_secure_storage` 11 require it.
- 2026-11-11: Discovery uses Bonjour through `nsd` on both platforms and UDP broadcast on Android only, plus QR and manual entry. iOS raw broadcast needs a restricted Apple entitlement.
- 2026-11-11: `music_loop` may be up to 1 MB; other audio stays within 150 KB. 150 KB is too low for 60–90 s of music.
- 2026-11-11: Stay on Flutter 3.41.6. Keeps the build reproducible.
- 2026-11-11: Moves from the same `fromRel` count as one for auto-play; the lowest token index moves. Otherwise a 6 with all tokens in base never auto-plays.
- 2026-11-11: A 6 with no legal move still grants the extra roll and counts toward three 6s. §1.2 passes the turn only on 1–5.
- 2026-11-11: Any non-6 resets the consecutive-6 count. The rule says consecutive.
- 2026-11-11: When a player's last token gets home, the extra roll is dropped and the turn passes. They have nothing left to move.
- 2026-11-11: The last unfinished player ranks above all leavers. Leavers rank below everyone who plays to the end.
- 2026-11-11: The animation speed setting scales hops and FX only, never the 800 ms dice or the 1120 ms auto-move.
- 2026-11-11: `animating` is an engine-enforced phase with a `nextPhase` field and a pure `settle`. One rule then blocks input during animation for taps, AI, timers and network.
- 2026-11-11: `turnSeq` increments per decision point, not per turn. One comparison rejects stale taps, timers and intents.
- 2026-11-11: Online games ignore the animation speed setting and run at 1×. The host's timing must match every client.
- 2026-11-11: Pause stops timers only in local games; online it is an overlay. One player must not stall the others.
- 2026-11-11: Clients connect only to private, link-local or loopback addresses, enforced in app code. `network_security_config.xml` cannot express IP ranges.
- 2026-11-11: Keep-awake uses a small native channel. `wakelock_plus` cannot resolve alongside `network_info_plus` on this SDK.
- 2026-11-11: Host addresses come from `NetworkInterface.list()`. `network_info_plus` misses the address on a device acting as the hotspot.
- 2026-11-11: No background service for the host in v1; the host screen warns to stay in the app. A backgrounded host may be suspended by the OS.
- 2026-11-11: Protocol adds `roomCode` on `Hello`, and `bad_room`, `kicked` and `rate_limited` errors. Required features had no message; `Pong` is per socket.
- 2026-11-11: Accept plain `ws://` for v1. TLS would need self-signed certificate handling on every client; the residual risk is LAN traffic capture.
