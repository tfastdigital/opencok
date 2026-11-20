# OpenCoK Building Feature Matrix

| Building | Frontend UI | State / Controller | Universal Upgrade & Details | Test Status |
| --- | --- | --- | --- | --- |
| Castle (`buildingCastle`) | `CastleViewport` + `CastleBuildingMenu` + `showCastleSkinsSheet` + `showCityBuildingsSheet` | `KingdomController` | Implemented | Verified |
| Watchtower (`buildingWatchtower`) | `CastleBuildingMenu` + `showLordStatusSheet` | `KingdomController` | Implemented | Verified |
| Barracks (`buildingBarracks`) | `TrainingScreen` (Infantry) | `KingdomController.trainTroopsWithCost` | Implemented | Verified |
| Stable (`buildingStable`) | `TrainingScreen` (Cavalry) | `KingdomController.trainTroopsWithCost` | Implemented | Verified |
| Archery Range (`buildingArcheryRange`) | `TrainingScreen` (Archers) | `KingdomController.trainTroopsWithCost` | Implemented | Verified |
| Siege Workshop (`buildingSiegeWorkshop`) | `TrainingScreen` (Siege) | `KingdomController.trainTroopsWithCost` | Implemented | Verified |
| Academy (`buildingAcademy`) | `showAcademyResearchSheet` | `KingdomController` | Implemented | Verified |
| Hospital (`buildingHospital`) | `showHospitalHealSheet` | `KingdomController` | Implemented | Verified |
| Warehouse (`buildingWarehouse`) | `showResourceDetailSheet` | `KingdomController` | Implemented | Verified |
| Forge (`buildingForge`) | `showCityBuildingsSheet` + `showEquipmentSlotSheet` | `KingdomController` | Implemented | Verified |
| Embassy (`buildingEmbassy`) | `showAllianceSheet` | `KingdomController` | Implemented | Verified |
| Hall of War (`buildingHallOfWar`) | `showPowerBreakdownSheet` | `KingdomController` | Implemented | Verified |
| Market (`buildingMarket`) | `showGoldTreasurySheet` | `KingdomController` | Implemented | Verified |
| Farm / Sawmill / Iron / Mithril | `showResourceDetailSheet` + `+ Build` plots | `KingdomController.buildOnResourcePlot` | Implemented | Verified |
