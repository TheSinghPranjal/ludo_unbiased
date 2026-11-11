# Phase 0 Audit

Audited 2026-11-11. No project code was changed during this audit.

## 1. Summary

**The project has no game in it.** `lib/main.dart` (122 lines) and `test/widget_test.dart` (30 lines) are the unmodified `flutter create` counter app. The build therefore starts fresh, keeping only the platform scaffolding and project identifiers.

Other facts that shape the work:

- `ref/ludo_board_reference.png` is missing. No copy exists in the project, `~/Downloads` or `~/Desktop`.
- The folder is not a git repository.
- The §1.1 board tables are correct (section 6).
- Several spec items cannot be met as written on this toolchain or platform, or leave a rule undefined (sections 7 and 8).

## 2. Current architecture

| Area | Current state |
|---|---|
| Architecture | One file: `MyApp` and `MyHomePage` (`StatefulWidget` counter) |
| State management | `setState` only |
| Dependencies | `flutter`, `cupertino_icons`; dev: `flutter_test`, `flutter_lints` |
| Networking | None |
| Assets, fonts, audio | None; no `assets` or `fonts` section in `pubspec.yaml` |
| Toolchain | Flutter 3.41.6, Dart 3.11.4, channel `user-branch` (unknown source) |
| Android id | `com.the_lazy_bear_club.ludo_unbiased` |
| iOS id | `com.thelazybearclub.ludoUnbiased` |
| App name | iOS display name `Ludo Unbiased`; Android label `ludo_unbiased` |

## 3. What works and can be reused

- Platform scaffolding: `android/`, `ios/`, including Kotlin `MainActivity` and the Runner project.
- iOS deployment target is already 13.0 (`ios/Runner.xcodeproj/project.pbxproj:353`).
- Bundle identifiers and project name (kept, per the project defaults).

## 4. Bugs and incomplete features

### The four known problems

Both Dart files were read in full and contain no game code. A search of `lib/`, `test/`, `android/app/src` and `ios/Runner` for `reconnect`, `WebSocket`, `1120`, `Ludo`, `dice` and `sound` matched only the app name in `ios/Runner/Info.plist`.

| # | Problem | Result |
|---|---|---|
| 1 | Reconnect token exposure | **Not present.** No networking or reconnect code exists. Must be built correctly (§1.5, §6.3). |
| 2 | Incomplete reconnection | **Not present.** No 45 s constant or flow exists. Must be built in full. |
| 3 | Automatic move timing | **Not present.** No auto-move exists. Must be built (§1.3). |
| 4 | Sound toggle without sound | **Not present.** No toggle or audio exists. Must be built with real audio. |

### Platform configuration that must change

| Location | Issue | Fixed in |
|---|---|---|
| `ios/Runner/Info.plist:59-60`, `:64-67` | Landscape and upside-down allowed; spec is portrait only | M6 (orientation also locked in Dart at M2) |
| `android/app/src/main/AndroidManifest.xml` | No `INTERNET`, Wi-Fi, multicast or `CAMERA` permissions; no network security config | M5/M6 |
| `android/app/src/main/AndroidManifest.xml:3` | Label is `ludo_unbiased` rather than a display name | M6 |
| `ios/Runner/Info.plist` | No `NSLocalNetworkUsageDescription`, `NSBonjourServices` or `NSCameraUsageDescription` | M5/M6 |
| `android/app/build.gradle.kts:27` | `minSdk = flutter.minSdkVersion`, which is 24 (see 7.1) | M6 |
| `android/app/build.gradle.kts:23`, `:35` | Template `TODO`s | M6 |
| `android/app/build.gradle.kts:37` | Release build signs with debug keys | M6; needs your keystore for store release |
| `analysis_options.yaml:10` | `flutter_lints`; `very_good_analysis` is stricter and replaces it | M1 |

## 5. Address formats and test suite

**Address formats currently supported: none.** The formats in §1.5 are the full required set.

`flutter analyze`:

```
Analyzing ludo_unbiased...
No issues found! (ran in 2.4s)
```

`flutter test`:

```
00:00 +0: Counter increments smoke test
00:00 +1: All tests passed!
```

The suite holds one test, which exercises only the template counter.

## 6. Board table verification

A script checked every §1.1 table. All checks passed:

- 52 track cells, all unique, closed loop, every consecutive pair adjacent.
- Diagonal steps are exactly at 4→5, 17→18, 30→31 and 43→44.
- Starts, stars (start + 8), and relative-50 cells match for all four colours.
- Each home column begins next to its relative-50 cell.
- The 20 home-column cells are unique and overlap neither the track, the yards nor the centre.

## 7. Spec items that cannot be met as written

**7.1 Minimum Android API 23 is not available.** Flutter 3.41 sets its minimum at API 24 (`FlutterExtension.kt:26`, `gradle_utils.dart:54`), and its tooling treats 16–23 as too old. `flutter_secure_storage` 11.2.0 also requires 24. *Recommendation: API 24.*

**7.2 UDP broadcast fallback is not usable on iOS without Apple's approval.** iOS 14 and later require the restricted `com.apple.developer.networking.multicast` entitlement for raw broadcast or multicast sockets. The same restriction rules out the pure-Dart `multicast_dns` package there. Bonjour through the `nsd` plugin needs only the `Info.plist` keys. *Recommendation: `nsd` on both platforms, UDP fallback on Android only, QR and manual entry everywhere.*

**7.3 `riverpod_generator` does not resolve.** Flutter 3.41.6 pins `meta` 1.17.0. The generator conflicts with `riverpod_annotation` 4.0.3 and `json_serializable` 6.14.1. Pinning the annotation to 3.x conflicts with `flutter_riverpod` 3.3.2. *Decision: hand-written Riverpod providers; `freezed` and `json_serializable` still work.*

**7.4 `network_security_config.xml` cannot express IP ranges.** It matches domain names, so "cleartext only for local addresses" cannot be written for arbitrary `192.168.x.x` hosts. *Plan: enforce private-range-only connections in app code after address resolution, ship the tightest config that works, and verify its effect on `dart:io` sockets on a device at M6.*

**7.5 The 150 KB audio limit conflicts with a 60–90 s music loop.** It allows about 13–20 kbps, which is audibly poor. AAC encoder padding also makes gapless looping in M4A unreliable, and iOS cannot play OGG. *Recommendation: exempt `music_loop` up to 1 MB, and check the loop point on a device.*

**7.6 "Latest stable" Flutter.** The installed 3.41.6 dates from March 2026 and is on a non-standard channel. A newer stable may exist. *Recommendation: stay on 3.41.6 for a reproducible build; upgrading is possible but is a change to your machine.*

## 8. Rules the spec leaves undefined

Defaults below will be used and logged in `DECISIONS.md` unless you change them.

| # | Situation | Default |
|---|---|---|
| 8.1 | A 6 with all four tokens in base gives four identical legal moves, so "exactly one legal move" never triggers auto-play | Moves from the same `fromRel` count as one for auto-play. The lowest token index moves. |
| 8.2 | A 6 with no legal move | Still grants the extra roll and counts toward three 6s, since §1.2 passes the turn only on 1–5 |
| 8.3 | Non-6 extra roll (capture or home) between 6s | Any non-6 resets the consecutive count |
| 8.4 | A player's last token gets home, earning an extra roll | No tokens remain, so the extra roll is dropped and the turn passes |
| 8.5 | Last unfinished player when others have left: "ranked last" versus "leavers rank below" | The remaining player ranks above all leavers |
| 8.6 | Animation speed setting versus fixed 800 ms dice and 1120 ms auto-move | The setting scales hops and FX only; those two timings stay fixed |

## 9. Risks to carry forward

- **Plain `ws://` on the LAN.** The reconnect token is private at application level, but anyone capturing traffic on the same network could read it. TLS would need self-signed certificate handling on every client. Recommended to accept for v1 and record in `DECISIONS.md`.
- **Hotspot discovery.** mDNS is often unreliable on phone hotspots, so QR and manual entry are the dependable paths there. The host screen will show real IPs.
- **Physical device coverage.** Two iOS devices are visible wirelessly (iPhone 14, iPad A16). No physical Android device is attached; a Pixel 9a emulator exists but cannot test Wi-Fi or hotspot behaviour. The M6 test steps need you to run them, and need an Android phone for Android hotspot coverage.
- **Android licences** are not accepted. Run `flutter doctor --android-licenses` before Android builds.
- **Dice fairness test.** `SecureDiceService` cannot be seeded, so a χ² threshold at p = 0.001 will falsely fail about 1 run in 1000. The ±3% band is about 4.6 standard deviations and is not a practical concern.
- **Asset tooling.** `rsvg-convert` and `oggenc` are absent, and this `ffmpeg` has only the experimental Vorbis encoder. Phase 3 needs `brew install librsvg vorbis-tools`.
- **Web and desktop folders.** `dart:io` servers do not compile for web. Android and iOS are the only supported targets. The other platform folders stay untouched.

## 10. Reuse / refactor / replace

| Module | Action | Reason |
|---|---|---|
| `lib/main.dart` | Replace | Template counter |
| `test/widget_test.dart` | Replace | Tests only the counter |
| `pubspec.yaml` | Refactor | Add dependencies, assets, fonts |
| `analysis_options.yaml` | Refactor | Move to `very_good_analysis` |
| `android/` | Refactor | Keep id; add permissions, network config, min SDK, icons, signing |
| `ios/` | Refactor | Keep id; add privacy keys, portrait lock, icons |
| `macos/`, `linux/`, `windows/`, `web/` | Leave | Out of scope, unused |
| Engine, network, UI, Flame, AI, audio, storage | Build new | Nothing exists |

## 11. Implementation plan

Packages confirmed to resolve together on this SDK:

- **Runtime:** `flame` 1.38, `flame_audio` 2.12, `flame_riverpod` 5.5, `flutter_riverpod` 3.3, `go_router` 17.5, `freezed_annotation` 3.1, `json_annotation` 4.12, `nsd` 5.0, `network_info_plus` 8.2, `mobile_scanner` 7.5, `qr_flutter` 4.1, `shared_preferences` 2.5, `flutter_secure_storage` 11.2.
- **Dev:** `build_runner` 2.15, `freezed` 3.2, `json_serializable` 6.14, `very_good_analysis` 10.2, `fake_async` 1.3, `mocktail` 1.0, `flutter_launcher_icons` 0.14, `flutter_native_splash` 2.4.

All plugins checked support iOS 13.

| Step | Output | Depends on |
|---|---|---|
| Phase 1 | `ARCHITECTURE.md`, `PROTOCOL.md`, using the §3.3 folder layout unchanged | This audit |
| Phase 2 | `design/wireframes.html` | Phase 1 |
| Phase 3 | `assets/**`, manifest, `design/asset_library.html` | Phase 2, reference image, Homebrew tools |
| M1 | Pure-Dart engine and all domain tests in `lib/features/game/` and `lib/features/ai/` | Phase 1 |
| M2 | Local controller, timers, auto-play, save and resume | M1 |
| M3 | Flame board and animation queue | M2, assets |
| M4 | Full UI, audio, theming, goldens | M3 |
| M5 | Protocol, host, client, discovery, reconnection | M2 |
| M6 | Platform config, icons, performance pass, device test steps | M4, M5 |
