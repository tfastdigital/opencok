# OpenCoK City Layout Audit

## Summary

Audit of all rendered structures in `org.opencok.opencok` (`CastleEnvironment` `6989 x 2544`, playable bounds `3400..6989, 0..2544`) verified via `city_grid.png`, `east_courtyard_check.png`, and `SM_A165F` device screenshots (`verify_1_city.png` through `east_final.png`).

| Building | Slot ID | Before Status | Root Cause | After Status |
| --- | --- | --- | --- | --- |
| `buildingCastle` | `slot_citadel_main` | Missing / too high | Not in `CastleBuildings` | Aligned on upper citadel terrace `(3740, 480)` |
| `buildingWatchtower` | `slot_def_watchtower` | Misplaced on flowerbed | Wrong rect `(3490, 910)` | Centered on western circular pad `(3625, 960)` |
| `buildingSiegeWorkshop` | `slot_mil_siege` | Aligned | — | Aligned `(3928, 1100)` |
| `buildingStable` | `slot_mil_stable` | Aligned | — | Aligned `(4204, 1325)` |
| `buildingArcheryRange` | `slot_mil_archery` | Aligned | — | Aligned `(3674, 1345)` |
| `buildingBarracks` | `slot_mil_barracks` | Aligned | — | Aligned `(3974, 1444)` |
| `buildingAcademy` | `slot_civic_academy` | Offset right-down | Pad center mismatch | Centered on upper-left courtyard pad `(4450, 750)` |
| `buildingEmbassy` | `slot_civic_embassy` | Between two pads | Pad center mismatch | Centered on upper-right courtyard pad `(4985, 835)` |
| `buildingHallOfWar` | `slot_civic_hall_of_war` | Overlapping wall | Shifted too low | Centered on east courtyard pad `(5220, 995)` |
| `buildingWarehouse` | `slot_civic_warehouse` | Aligned on dock | — | Aligned `(5190, 1340)` |
| `buildingMarket` | `slot_civic_market` | Left of pad | X offset `-100` | Centered on south-east pad `(4620, 1585)` |
| `buildingForge` | `slot_civic_forge` | Left-up of pad | X/Y offset | Centered on lower-south pad `(4260, 1745)` |
| `buildingHospital` | `slot_civic_hospital` | Edge of pad | X/Y offset | Centered on east dock pad `(5480, 1210)` |
| `buildingFarm` | `slot_prod_farm_1` | Missing | Not placed | Placed on eastern grass plateau `(5980, 1360)` |
| `buildingSawmill` | `slot_prod_sawmill_1` | Missing | Not placed | Placed on eastern grass plateau `(6310, 1330)` |
| `buildingIronMine` | `slot_prod_iron_1` | Missing | Not placed | Placed on lower clearing `(5830, 1840)` |
| `buildingMithrilMine` | `slot_prod_mithril_1` | Missing | Not placed | Placed on lower-east clearing `(6280, 1860)` |
