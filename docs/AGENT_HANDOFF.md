# OpenCoK (`org.opencok.opencok`) Agent Handoff & Architecture Guide

This document is the complete handoff for the next AI agent working on `org.opencok.opencok` (`https://github.com/tfastdigital/opencok.git`, branch `main-opencok`, latest commit `ef3ac01`).

---

## 1. Repository, Branch & Environment

- **Repo**: `https://github.com/tfastdigital/opencok.git`
- **Active Branch**: `main-opencok`
- **Package / Application ID**: `org.opencok.opencok`
- **Local Toolchain (Windows)**:
  - `JAVA_HOME`: `C:\opencok-sdk\jdk-21.0.13+9`
  - `ANDROID_HOME`: `C:\opencok-sdk\android`
  - `Flutter`: `C:\opencok-sdk\flutter\bin\flutter.bat`
  - `Build Tools`: `C:\opencok-sdk\android\build-tools\36.0.0` (`zipalign.exe`, `apksigner.bat`)
  - `ADB`: `C:\opencok-sdk\android\platform-tools\adb.exe`
  - `Node.js`: `C:\Program Files\nodejs\node.exe`
- **Test Devices**:
  - **Samsung Galaxy A13 (`SM_A135F`)**: USB serial `R58T33ZXRHH`, Wireless ADB `192.168.100.59:5555` (`tcpip 5555` enabled). **32-bit `armeabi-v7a`**, rooted (`1080x2408`).
  - **Samsung Galaxy A16 (`SM_A165F`)**: USB serial `R58Y60LD6PM`, LAN IP `192.168.100.54` (`1080x2340`, 64-bit `arm64-v8a`).
  - **Dev Host LAN IP**: `192.168.100.49` (Firewall rule `OpenCoK Multiplayer 9944` allows inbound TCP `9944`).

---

## 2. What Is Implemented & Verified

### A. Root Testing Flag & Dual-ABI Android Builds
- `app/lib/security/device_security/device_security.dart`: `DeviceSecurity.developmentExemption` honors `--dart-define=ALLOW_ROOTED=true` so rooted test phones (`SM_A135F`) can launch the game while production builds without the flag keep root checks active.
- `app/android/app/src/main/AndroidManifest.xml`: `android:usesCleartextTraffic="true"` enabled for LAN `ws://` multiplayer testing.
- **CRITICAL**: Always build with `--target-platform android-arm,android-arm64` because `SM_A135F` is 32-bit `armeabi-v7a` and will crash with `Could not find 'libflutter.so'` if only `arm64-v8a` is packaged.

### B. City Layout, Castle Progression & Building Systems
- **Castle Visual Progression**: Castle scales/upgrades dynamically by level (`Lv.1`–`Lv.30+`) with level badges (`castle_environment_painter.dart`).
- **Validated City Slots**: `CastleBuildings` (`app/lib/data/castle/castle_buildings/castle_buildings.dart`) and `CitySlotRegistry` (`app/lib/data/castle/city_slot_registry/city_slot_registry.dart`) align all 19 city/military buildings onto non-overlapping courtyard pads (`city_layout_validation_test.dart`).
- **Building Interactions**:
  - Military buildings open `TrainingScreen` (Barracks, Stable, Archery Range, Siege Workshop).
  - Civic/Defense buildings open dedicated interactive sheets (`building_system_sheets.dart`, `hud_status_panels.dart`) for Academy, Embassy, Hall of War, Warehouse, Market, Forge, Hospital, Drill Grounds, Military Tent, Wishing Well, Tavern, Watchtower, Turret, and City Wall.
  - Outer resource plots (`Farm`, `Sawmill`, `Iron Mine`, `Mithril Mine`) support building, upgrading, and resource collection.

### C. World Map, Marching Armies, Throne War, KvK & Civilizations
- **Marching Armies (`world_map_viewport.dart` / `kingdom_controller.dart`)**:
  - `ActiveMarch` renders animated 3-soldier squads, directional chevrons, dashed glowing march lines, live countdown badges, and `Speed Up` buttons.
- **Middle Throne & 16 Royal Offices**:
  - Middle Throne Castle at `(574, 566)` (displayed as `(600, 600)` in lore) with Throne War capture, King crowning, **16 Royal Offices** (Grand Duke, Prime Minister, Archmage, Field Marshal, 8 Blessings, 4 Penalties), and King Skills (*Bumper Harvest*, *Red Envelope*).
- **Cross-Kingdom Viewing & Kingdom Wars**:
  - Users **cannot** create new castles or found new kingdoms in the UI (`showKingdomsAndCastlesSheet` in `hud_status_panels.dart`).
  - Tapping **Enter** on another kingdom (`#1306 · Iron Crown`, `#1307 · Dragonspire`) switches the World Map to view that kingdom's defending castles/Lords (`King_Thorne`, `Duke_Vane`, `Lady_Brienne`, `DragonLord_Kael`, `PyreKnight`), shows a `Viewing K#1306 · Iron Crown` banner with **Start War** and **Home #1305** buttons, and allows scouting/attacking foreign castles for KvK points and loot.
- **Additional Systems**: Dragon Campaign, 5 Civilizations (`Dragon-born`, `Viking`, `Yamato`, `Huaxia`, `Arabia`), Dragons & Heroes (`Scartha`, `Kraken`, `Yukine`, `Kylin`, `Shadow`).

### D. Real-Time LAN / WebSocket Multiplayer
- **Server**: `multiplayer/server.mjs` (zero-dependency Node.js RFC 6455 WebSocket + HTTP `/health` & `/state` on port `9944`, persisting to `multiplayer/state.json`, which is untracked in git).
- **Client**: `app/lib/data/hud/multiplayer_client/multiplayer_client.dart` wired into `KingdomController.attachPersistencePath` when `--dart-define=MULTIPLAYER_URL=ws://<LAN_IP>:9944` is passed (empty in unit tests so tests never open sockets).
- **Synced State**:
  - Unique per-device `playerId`, unique default Lord name (`Lord_XXXX`), editable Lord name (`Lords -> Rename`), and server-assigned non-overlapping coordinates.
  - Other players' castles & nameplates rendered live on the World Map (`[COK] Lord_XXXX · Lv.30`).
  - Live **Lords (N)** sheet (`showMultiplayerLordsSheet`) to view online players, **Rename**, **Scout**, or **Attack**.
  - Real-time PvP march lines visible on both attacker & defender screens, server-side battle/scout resolution delivering reports to `mails` on both devices, shared Throne King/appointments, and live Kingdom/Alliance chat.

---

## 3. Standard Build, Test, Sign & Deploy Commands

```powershell
$env:JAVA_HOME = "C:\opencok-sdk\jdk-21.0.13+9"
$env:ANDROID_HOME = "C:\opencok-sdk\android"
$env:Path = "C:\opencok-sdk\flutter\bin;C:\opencok-sdk\jdk-21.0.13+9\bin;$env:Path"

# 1. Start multiplayer server (keep running in background)
node "C:\UNLOCKTOOL OFFLINE\opencok\multiplayer\server.mjs"

# 2. Run verified unit/widget tests
Set-Location "C:\UNLOCKTOOL OFFLINE\opencok\app"
flutter test test/world_map_viewport_test.dart test/city_layout_validation_test.dart test/kingdom_controller_test.dart test/hud_preview_screen_test.dart lib/ui/training/screens/training_screen/training_screen_test.dart lib/ui/castle/widgets/castle_viewport/castle_viewport_test.dart lib/ui/profile/screens/player_profile_screen/player_profile_screen_test.dart

# 3. Build dual-ABI APK (32-bit + 64-bit) with multiplayer & rooted-test flags
flutter build apk --release --target-platform android-arm,android-arm64 --dart-define=ALLOW_ROOTED=true --dart-define=MULTIPLAYER_URL=ws://192.168.100.49:9944 --android-skip-build-dependency-validation

# 4. Zipalign, sign, and install to both phones
$bt = "C:\opencok-sdk\android\build-tools\36.0.0"
$adb = "C:\opencok-sdk\android\platform-tools\adb.exe"
& "$bt\zipalign.exe" -f -p 4 build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\app-release-aligned.apk
& "$bt\apksigner.bat" sign --ks "$env:USERPROFILE\.android\debug.keystore" --ks-pass pass:android --key-pass pass:android --out build\app\outputs\flutter-apk\app-release-signed.apk build\app\outputs\flutter-apk\app-release-aligned.apk
& $adb -s 192.168.100.59:5555 install -r build\app\outputs\flutter-apk\app-release-signed.apk
& $adb -s R58Y60LD6PM install -r build\app\outputs\flutter-apk\app-release-signed.apk
```

---

## 4. Recommended Next Steps for the Next Agent

1. **Public / Cloud Multiplayer Hosting**: Move `multiplayer/server.mjs` (or integrate its PvP/Throne/Chat protocol into `gameserver/` + `apps/realm/`) behind a public `wss://` domain so players outside the local `192.168.100.x` Wi-Fi can play together without `--dart-define=MULTIPLAYER_URL`.
2. **Cross-Kingdom Real-Time Player Migration / KvK Sync**: Sync `startKingdomWar` / foreign kingdom throne captures in `multiplayer/server.mjs` so multiple real players invading `#1306` / `#1307` see each other's KvK rallies and shared KvK scoreboards.
3. **Production Release Build**: Before shipping to end users, build **without** `--dart-define=ALLOW_ROOTED=true` and sign with a release keystore instead of `debug.keystore`.
4. **Testing Note**: Never use `pumpAndSettle()` in widget tests mounting `HudPreviewScreen` or `CastleScreen` (continuous animations); use `pump()` + `pump(Duration(milliseconds: 500))`. Do not commit `new app/` (`.apks` binary) or `multiplayer/state.json`.
