# LAN Protocol, version 1

The wire protocol between a host and its clients. The host is authoritative: it alone runs the engine and rolls the dice.

## 1. Transport

| Item | Value |
|---|---|
| Transport | WebSocket over `dart:io`, path `/ws`, default port 47821 |
| Discovery | Bonjour `_ludo._tcp`; UDP broadcast on 47820 (Android only) |
| QR payload | `ludo://<host>:<port>/<ROOM>` |
| Frames | Text only, one JSON message per frame, 64 KB maximum |
| Heartbeat | Every 3 s each way. A peer is disconnected after 9 s of no traffic. |
| Rate limit | 20 messages per second per socket. A socket that keeps exceeding it is dropped. |
| Handshake limit | A socket that sends no valid `Hello` or `Reconnect` within 5 s is closed |
| Connections | At most 8 open sockets per host |

Bonjour TXT records and UDP replies carry `room`, `name`, `free` (open seats), `v` (protocol version) and `port`. They never carry session data.

## 2. Envelope

```json
{ "v": 1, "type": "MoveRequest", "seq": 42, "data": { "turnSeq": 17, "tokenId": 2 } }
```

| Field | Rules |
|---|---|
| `v` | Must be 1. Otherwise `Error{version_mismatch}`, then close. |
| `type` | A known message type for that direction |
| `seq` | Non-negative integer. Each sender numbers its own messages. |
| `data` | Object matching the type's schema exactly |

**Decoding is strict.** Unknown fields are rejected, so a `RollRequest` carrying a `dice` value is malformed and not silently ignored. The decoder returns `null` for bad input and never throws.

## 3. Client → host

| Type | Data | Notes |
|---|---|---|
| `Hello` | `name: string (1–16)`, `appVersion: string`, `roomCode?: string` | First message on a new connection. `roomCode` comes from the QR code or discovery and is checked if present. |
| `Reconnect` | `roomCode`, `playerId`, `reconnectToken`, `lastSeq` | First message on a reconnecting socket |
| `Ready` | `ready: bool` | Lobby only |
| `RollRequest` | `turnSeq: int` | |
| `MoveRequest` | `turnSeq: int`, `tokenId: int (0..3)` | |
| `Ping` | none | |
| `Leave` | none | Removes the seat at once, with no grace period |

## 4. Host → one client (private)

These are written only to the owner's socket.

| Type | Data |
|---|---|
| `Welcome` | `playerId`, `color` (null until a seat is assigned), `reconnectToken` |
| `Resync` | `state`, `remainingTurnMs`, `seq` |
| `Error` | `code`, `message` |
| `Pong` | none. Sent to one socket, in reply to `Ping` and on the host's own 3 s heartbeat. It carries no data. |

## 5. Host → all (broadcast)

| Type | Data |
|---|---|
| `LobbyState` | `roomCode`, `seats[]` (`color`, `playerId?`, `name?`, `kind`, `aiLevel?`, `connection`, `ready`), `replaceLeaversWithAi` |
| `GameStarted` | `state`, `remainingTurnMs` |
| `Events` | `events[]`, `state`, `seq` |
| `TimerSync` | `turnSeq`, `remainingMs` |
| `PlayerConnection` | `playerId`, `connection`, `graceRemainingMs?` |
| `GameOver` | `ranking[]`, `stats` |

`TimerSync` is sent at every settle and every 5 s. Clients compute deadlines from their own clock and `remainingMs`, so device clocks do not need to agree.

## 6. Public state

`PublicGameStateSerializer` builds every `state` value. It accepts only a `GameState` and has no access to `SessionManager`.

```json
{
  "gameId": "f3a9…",
  "players": [{ "id": "p1", "color": "red", "name": "Asha", "kind": "remote",
                "connection": "connected", "finishedRank": null,
                "stats": { "tokensHome": 0, "captures": 1, "timesCaptured": 0, "sixes": 2 } }],
  "tokens": [{ "id": 0, "color": "red", "rel": 12 }],
  "currentColor": "blue",
  "phase": "rolled",
  "nextPhase": null,
  "dice": 4,
  "sixesThisTurn": 0,
  "turnSeq": 17,
  "ranking": [],
  "leavers": [],
  "eventSeq": 58
}
```

`turnDeadline` is host-local and is not serialised. `remainingMs` and `remainingTurnMs` carry timing instead.

## 7. Host validation

Checks run in this order. The first failure sends an `Error` and changes nothing.

1. Text frame within the size limit, and under the rate limit.
2. Valid JSON, valid envelope, exact schema (`malformed`).
3. Protocol version (`version_mismatch`).
4. Socket is authenticated, or this is a `Hello` or `Reconnect` (`unknown_player`).
5. For game intents, the socket owns a seat in this game (`unknown_player`).
6. Game not over (`game_over`).
7. `turnSeq` equals the current value (`stale_turn`).
8. Seat is the current player (`not_your_turn`).
9. Engine accepts the command (`illegal_move`).

Intents never name a player. The host derives the seat from the authenticated socket, so one seat cannot be impersonated from another's connection.

## 8. Reconnect

1. The client sends `Reconnect` on a new socket.
2. The host checks the room code (`bad_room`) and player id (`unknown_player`).
3. A seat already removed returns `grace_expired`.
4. The host compares `sha256(reconnectToken)` to the stored hash in constant time (`bad_token`).
5. On success, the host cancels the grace timer, closes any earlier socket for that seat, replies with `Resync`, and broadcasts `PlayerConnection`.

The token is 128 bits from `Random.secure()`, base64url-encoded. It appears only in that player's `Welcome` and in their own `Reconnect`. It never appears in a broadcast, log, saved game or error.

Traffic is unencrypted `ws://`, so someone capturing packets on the same network could read it. This is accepted for v1 and logged in `DECISIONS.md`.

`lastSeq` is informational in v1. `Resync` always carries full state, so events are never replayed.

## 9. Error codes

| Code | Meaning | Closes socket |
|---|---|---|
| `malformed` | Invalid JSON or schema | After repeats |
| `version_mismatch` | Wrong protocol or app version | Yes |
| `room_full` | No free seat | Yes |
| `not_your_turn` | Not the current player | No |
| `illegal_move` | Engine rejected it, including during animation | No |
| `stale_turn` | `turnSeq` out of date | No |
| `unknown_player` | Unknown id, or socket owns no seat | Yes |
| `bad_token` | Token check failed | Yes |
| `grace_expired` | Seat already removed | Yes |
| `game_over` | The game has ended | No |
| `bad_room` | *Added.* Room code does not match | Yes |
| `kicked` | *Added.* Host removed this player from the lobby | Yes |
| `rate_limited` | *Added.* Sent before dropping an abusive socket | Yes |

## 10. Additions to the spec

The spec's message list was extended only where a required feature had no message:

- `roomCode` on `Hello`, so a QR join reaches the right room.
- `bad_room`, `kicked` and `rate_limited` errors. The Kicked dialog (§1.7) had no code behind it.
- `Pong` is sent per socket rather than broadcast, because it answers one peer.
