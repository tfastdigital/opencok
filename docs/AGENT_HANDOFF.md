# OpenCoK (`org.opencok.opencok`) Agent Handoff & Architecture Guide

This document describes the current state of `org.opencok.opencok` on branch `main-opencok`, what was restored and completed, and how future AI agents should build, test, and extend the application.

---

## 1. Current Baseline & Package Identity

- **Package / Application ID**: `org.opencok.opencok` (configured in `app/android/app/build.gradle.kts` and `app/android/app/src/main/kotlin/org/opencok/opencok/MainActivity.kt`).
- **Branch**: `main-opencok` (branched from `02207ee` English localization on top of upstream `develop` `5aeffc5`).
- **Removed Experimental Work**: `GuestKingdomScreen`, `live_kingdom_hud`, and `org.opencok.kingdoms` release overrides were removed so the app uses the authentic Clash of Kings interface (`GameHud`, `CastleScreen`, `WorldMap`, `PlayerProfileScreen`, `TrainingScreen`).
- **USB Debugging / Security Gate**: `MainActivity.kt` exposes the `org.opencok/android_security` `MethodChannel` (`isDebuggerAttached` via `Debug.isDebuggerConnected() || Debug.waitingForDebugger()`), and `app/lib/security/device_security/device_security.dart` uses it instead of `isDevMode` so release builds can run on ADB-connected test phones with USB debugging enabled.

---

## 2. City & Castle Architecture

- **Castle Buildings Registry**: `app/lib/data/castle/castle_buildings/castle_buildings.dart`
  - `CastleBuildings.military`: `siege_workshop.png`, `stable.png`, `archery_range.png`, `barracks.png` (loaded from `assets/castle/buildings/`).
  - `CastleBuildings.city`:
    - `buildingCastle` (`player_castle_level_5.png`) on the upper stone citadel terrace `(3880, 560, 520, 480)`
    - `buildingWatchtower` (`castle_tower.png`) on the western circular stone pad `(3490, 910, 250, 260)`
    - `buildingGoldMine` (`gold_mine.png`) on the lower-right stone pad `(4430, 1690, 260, 240)`
    - `buildingSawmill` (`sawmill.png`) on the eastern plateau `(4760, 1390, 270, 240)`
    - `buildingFarm` (`farm.png`) on the southern grass paths `(4050, 1850, 280, 240)`
    - `buildingIronMine` (`iron_mine.png`) in the woodland clearing `(3480, 1680, 270, 240)`
    - `buildingMithrilMine` (`mithril_mine.png`) on the upper-right bank `(4620, 860, 270, 240)`
  - `CastleBuildings.all`: `[...city, ...military]`.
  - `CastleBuildings.fullAssetPath(asset)` resolves paths across `assets/castle/buildings/`, `assets/world_map/buildings/castle/`, and `assets/world_map/buildings/resources/`.
- **Loader & Painter**:
  - `app/lib/data/castle/castle_environment_loader/castle_environment_loader.dart` loads all buildings in `CastleBuildings.all`.
  - `app/lib/ui/castle/painters/castle_environment_painter/castle_environment_painter.dart` draws `CastleBuildings.all` (guarding `environment.images.containsKey(building.asset)` so unit tests with partial mock image maps continue to work).
- **Building Selection**:
  - `app/lib/ui/castle/widgets/castle_viewport/castle_viewport.dart` hit-tests `CastleBuildings.all.reversed`.
  - Military buildings open `TrainingScreen` via `Train Troops`.
  - City buildings (`Castle`, `Watchtower`, resource mines/farms) invoke `onCityBuildingAction` to open the corresponding `KingdomController` sheet (`Power Breakdown`, `Lord Status`, `Gold Treasury`, or `Resource Detail`).
- **Localization Names**: `app/lib/l10n/game_names.dart` maps all `building*` keys for both `en` and `pt`.

---

## 3. Live State & Finished Preview Features

All former `"preview"` / `"coming soon"` snackbars in `HudPreviewScreen` and `PlayerProfileScreen` are backed by a live `ChangeNotifier` state controller:

- **Controller**: `app/lib/data/hud/kingdom_controller/kingdom_controller.dart` (`KingdomController`)
  - Holds live `wood`, `food`, `iron`, `mithril`, `gold`, `power`, `level`, `experience`, `energy`, `vipLevel`, `vipPoints`, `playerName`, `dailyQuests`, `inventory`, `mails`, `chatMessages`, `achievements`, `skills`, `equippedGear`, and audio toggles.
  - Exposes `hudData` (`HudData`) formatted identically to `referenceHudData` so `GameHud` and `PlayerProfileScreen` update immediately on any action.
- **Shared Medieval Theme**: `app/lib/ui/shared/medieval_panel/medieval_panel.dart`
  - `MedievalPanelColors`, `showMedievalSheet(...)`, and `medievalActionButton(...)`.
- **HUD Panels**:
  - `app/lib/ui/hud/widgets/hud_panels/hud_navigation_panels.dart`:
    - `showDailyQuestsSheet`: Claimable quests that grant Gold/Resources/XP and decrement the `Daily` badge.
    - `showInventorySheet`: Category-filtered bag (`All`, `Resources`, `Boosts`, `Chests`) with `Use` actions.
    - `showMailSheet`: Inbox with `Mark All Read` and claimable gift attachments updating the `Mail` badge.
    - `showAllianceSheet`: `[COK] Knights of OpenCoK` roster and `Help Allies` button.
    - `showChatSheet`: `Kingdom` and `Alliance` channels, `Translate` toggle, and live message composer that updates the HUD bottom chat bar.
  - `app/lib/ui/hud/widgets/hud_panels/hud_status_panels.dart`:
    - `showVipSheet`, `showResourceDetailSheet`, `showPowerBreakdownSheet`, `showGoldTreasurySheet`, `showLordStatusSheet`.
- **Profile Panels**:
  - `app/lib/ui/profile/widgets/profile_modals/profile_modals.dart`:
    - `showRenameLordDialog`, `showEquipmentSlotSheet` (8 equippable slots), `showRankingSheet`, `showAchievementsSheet`, `showLordInformationSheet`, `showSkillsSheet`, `showResetSkillsDialog`, `showSettingsSheet`.
  - Wired in both `app/lib/ui/profile/screens/player_profile_screen/player_profile_screen.dart` and `app/lib/ui/profile/widgets/desktop_player_profile/desktop_player_profile.dart`.
- **Training Troops, Upgrading & Building**:
  - **Training Troops**: `TrainingScreen`, `TrainingPanel`, and `TrainingActions` accept an optional `KingdomController? controller`. When provided, **Train** deducts `woodCost`, `foodCost`, `ironCost`, `mithrilCost`, and **Train Now** deducts Gold; both call `trainTroopsWithCost(...)` to increment `troopsTrained` and `power`.
  - **Upgrading Buildings**: `CastleBuildingMenu` shows each building's current level (`Lv.X`) and an **Upgrade** button (`upgradeBuilding(key)`) that deducts Wood/Food, increments the building level, and adds `+15,000 Power`.
  - **City & Build Plots**: Tapping the Castle opens a **City & Build Plots** button (`showCityBuildingsSheet` in `hud_status_panels.dart`) where players can construct and upgrade `Academy`, `Embassy`, `Hospital`, `Forge`, `Warehouse`, and `Market` (`buildOrUpgradeCityConstructible`).

---

## 4. Build, Test, Sign & Deploy Commands (Windows)

Use the local SDK toolchain in `C:\opencok-sdk`:

```powershell
$env:JAVA_HOME = "C:\opencok-sdk\jdk-21.0.13+9"
$env:ANDROID_HOME = "C:\opencok-sdk\android"
$env:Path = "C:\opencok-sdk\flutter\bin;C:\opencok-sdk\jdk-21.0.13+9\bin;$env:Path"
Set-Location "C:\UNLOCKTOOL OFFLINE\opencok\app"
```

### Analyze & Run Tests
```powershell
flutter analyze
flutter test test/ lib/
```

### Build Release ARM64 APK
Note: `--android-skip-build-dependency-validation` is required because `app/android` uses AGP 9.1.0 with Flutter 3.50.1:
```powershell
flutter build apk --release --target-platform android-arm64 --android-skip-build-dependency-validation
```

### Sign, Install & Launch on Connected Android Device
```powershell
$bt = "C:\opencok-sdk\android\build-tools\36.0.0"
$adb = "C:\opencok-sdk\android\platform-tools\adb.exe"
$inApk = "build\app\outputs\flutter-apk\app-release.apk"
$alignedApk = "build\app\outputs\flutter-apk\app-release-aligned.apk"
$signedApk = "build\app\outputs\flutter-apk\app-release-signed.apk"

& "$bt\zipalign.exe" -f -p 4 $inApk $alignedApk
& "$bt\apksigner.bat" sign --ks "$env:USERPROFILE\.android\debug.keystore" --ks-pass pass:android --key-pass pass:android --out $signedApk $alignedApk
& $adb install -r $signedApk
& $adb shell monkey -p org.opencok.opencok -c android.intent.category.LAUNCHER 1
```

---

## 5. Notes for Future AI Agents

1. **Do not** replace `HudPreviewScreen`, `GameHud`, `CastleScreen`, or `PlayerProfileScreen` with custom placeholder screens—keep the authentic Clash of Kings assets and layouts.
2. **Avoid `pumpAndSettle()`** in widget tests that mount `HudPreviewScreen` or `CastleScreen` because `GoldGlint`, `CastleAmbiencePainter`, and `CastleWaterPainter` run continuous animations; use `await tester.pump(); await tester.pump(const Duration(milliseconds: 500));`.
3. **Preserve `PlayerProfileScreen(data: referenceHudData)`** default constructor compatibility so responsive layout tests (`player_profile_screen_test.dart`) continue to work standalone.
4. **When wiring real backend RPCs** (e.g., via `GameConnection` / `GATEWAY_URL` in `app/.env`), hook them into `KingdomController` methods so UI widgets remain decoupled from transport details.
