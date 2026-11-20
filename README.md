# OpenCoK

OpenCoK is an independent Clash of Kings mod with an open-source server that lets communities run their own realms and customize the game rules.

The project is developing its own Flutter client for Android, iOS, Linux, Windows, and Web, aiming to preserve the look and feel of Clash of Kings. The Elex client will not be used.

## Implemented Gameplay & Features

- **Citadel & City Building System**:
  - Visual Castle level progression (Lv.1–Lv.30+ scaling, badges, and upgradeable city buildings validated by `CitySlotRegistry`).
  - Interactive building panels for Barracks, Stable, Archery Range, Siege Workshop, Academy, Embassy, Hall of War, Warehouse, Market, Forge, Hospital, Drill Grounds, Military Tent, Wishing Well, Tavern, Watchtower, Turret, and City Wall.
  - Outer resource plots (Farm, Sawmill, Iron Mine, Mithril Mine) with resource production and collection.
- **World Map, Marching Armies & PvP**:
  - Animated marching formations (3-soldier squads, directional arrows, dashed march lines, speed-ups, and live timers) for Scouting, Attacking, Gathering, and Throne Rallies.
  - Middle Throne Castle at `(600, 600)` with Throne War capture mechanics, King crowning, **16 Royal Offices** (Grand Duke, Prime Minister, Archmage, Field Marshal, plus 8 Blessings and 4 Penalties), and King Skills (*Bumper Harvest*, *Red Envelope*).
  - **Kingdom vs Kingdom (KvK)** invasion & prize tiers, **Dragon Campaign**, **5 Civilizations** (*Dragon-born*, *Viking*, *Yamato*, *Huaxia*, *Arabia*), and **Dragons & Heroes**.
- **Real-Time LAN / WebSocket Multiplayer**:
  - Lightweight Node.js multiplayer server ([multiplayer/server.mjs](multiplayer/server.mjs)) syncing unique per-device Lord identities, editable Lord names, World Map castle coordinates, live PvP attack/scout marches, battle & scout mail reports, shared Middle Throne state, and Kingdom/Alliance chat.

## Running the Multiplayer Server

Requires Node.js:

```sh
node multiplayer/server.mjs
```

By default, the server listens on `ws://0.0.0.0:9944` (with `GET /health` and `GET /state` diagnostics).

## Building & Running the Flutter Client

```sh
cd app
flutter test
```

### Android Release Build (32-bit + 64-bit)

```sh
cd app
flutter build apk --release --target-platform android-arm,android-arm64 --dart-define=MULTIPLAYER_URL=ws://<YOUR_LAN_IP>:9944
```

Optional testing flags:
- `--dart-define=ALLOW_ROOTED=true` — allows running on rooted test devices.

## License

OpenCoK's original code and documentation are available under the [MIT license](LICENSE). The Elex client, Clash of Kings assets, and other third-party materials are not covered by this license and remain subject to the rights and terms of their respective owners.

OpenCoK is not affiliated with or endorsed by Elex.
