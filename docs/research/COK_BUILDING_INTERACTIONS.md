# Official Clash of Kings (`com.hcg.cok.gp`) Building Interactions

## Evidence Categories
- **VERIFIED**: Directly observed on `SM_A165F` (`official_cok2.png`, `official_cok_city2.png`) and in `split_InstallPack.apk` (`database.local.xml`, `Imperial_22.plistf`, `Imperial_28.plistf`).
- **HISTORICAL**: Standard Clash of Kings city mechanics.
- **PROPOSED**: Original OpenCoK client/controller implementation.

## Observations
- **VERIFIED**: Top HUD displays Lord Portrait & Level, VIP level, Total Power, Gold, Wood, and Food.
- **VERIFIED**: Bottom HUD displays live Chat bar above City/World toggle, Daily, Items, Mail, and Alliance buttons.
- **VERIFIED**: City architecture separates the elevated Castle citadel, tiered civic/military courtyards with circular stone construction pads, and outer production clearings.
- **VERIFIED**: `com.hcg.cok.gp` features 5 selectable Factions/Civilizations (`Dragon-Born/Imperial`, `Viking`, `Yamato`, `Huaxia`, `Crescent`) with distinct architectural styles and combat/economy bonuses.
- **PROPOSED**: OpenCoK implements `CitySlotRegistry`, `CityLayoutDebugOverlay` (dev-only), `CastleBuildingMenu` with contextual `Train`/`Inspect`/`Collect`, `Upgrade`, `Details`, `Castle Skins`, `Academy Research`, `Hospital Heal`, `+ Build` outer resource plots, `ActiveMarch` animated World Map army marches (Attack/Scout/Gather), and Faction switching backed by `KingdomController`.
