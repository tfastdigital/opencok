import 'dart:ui';

import 'package:opencok/domain/castle/castle_building/castle_building.dart';

class CastleBuildings {
  static const assetRoot = 'assets/castle/buildings/';
  static const worldResourceRoot = 'assets/world_map/buildings/resources/';

  static const military = [
    CastleBuilding(
      'buildingSiegeWorkshop',
      'siege_workshop.png',
      Rect.fromLTWH(3928, 1100, 345, 310),
    ),
    CastleBuilding(
      'buildingStable',
      'stable.png',
      Rect.fromLTWH(4204, 1325, 342.5, 265),
    ),
    CastleBuilding(
      'buildingArcheryRange',
      'archery_range.png',
      Rect.fromLTWH(3674, 1345, 352.5, 290),
    ),
    CastleBuilding(
      'buildingBarracks',
      'barracks.png',
      Rect.fromLTWH(3974, 1444, 351.25, 276.25),
    ),
  ];

  static const city = [
    CastleBuilding(
      'buildingCastle',
      'castle.png',
      Rect.fromLTWH(3740, 480, 680, 633),
    ),
    CastleBuilding(
      'buildingWatchtower',
      'watchtower.png',
      Rect.fromLTWH(3635, 1005, 210, 330),
    ),
    CastleBuilding(
      'buildingAcademy',
      'academy.png',
      Rect.fromLTWH(4450, 750, 250, 248),
    ),
    CastleBuilding(
      'buildingEmbassy',
      'embassy.png',
      Rect.fromLTWH(4985, 835, 250, 214),
    ),
    CastleBuilding(
      'buildingHallOfWar',
      'hall_of_war.png',
      Rect.fromLTWH(5245, 965, 265, 258),
    ),
    CastleBuilding(
      'buildingWarehouse',
      'warehouse.png',
      Rect.fromLTWH(5210, 1295, 265, 215),
    ),
    CastleBuilding(
      'buildingMarket',
      'market.png',
      Rect.fromLTWH(4620, 1585, 225, 210),
    ),
    CastleBuilding(
      'buildingForge',
      'forge.png',
      Rect.fromLTWH(4300, 1720, 270, 190),
    ),
    CastleBuilding(
      'buildingHospital',
      'hospital.png',
      Rect.fromLTWH(5480, 1210, 230, 130),
    ),
    CastleBuilding(
      'buildingFarm',
      'farm.png',
      Rect.fromLTWH(5980, 1360, 240, 205),
    ),
    CastleBuilding(
      'buildingSawmill',
      'sawmill.png',
      Rect.fromLTWH(6310, 1330, 240, 205),
    ),
    CastleBuilding(
      'buildingIronMine',
      'iron_mine.png',
      Rect.fromLTWH(5830, 1840, 240, 205),
    ),
    CastleBuilding(
      'buildingMithrilMine',
      'mithril_mine.png',
      Rect.fromLTWH(6280, 1860, 240, 205),
    ),
    CastleBuilding(
      'buildingWalls',
      'city_wall.png',
      Rect.fromLTWH(4000, 1740, 140, 160),
    ),
    CastleBuilding(
      'buildingDrillGrounds',
      'drill_grounds.png',
      Rect.fromLTWH(5140, 1515, 240, 182),
    ),
    CastleBuilding(
      'buildingMilitaryTent',
      'military_tent.png',
      Rect.fromLTWH(4930, 1060, 220, 122),
    ),
    CastleBuilding(
      'buildingWishingWell',
      'wishing_well.png',
      Rect.fromLTWH(4705, 905, 180, 152),
    ),
    CastleBuilding(
      'buildingTavern',
      'tavern.png',
      Rect.fromLTWH(3790, 1820, 210, 132),
    ),
    CastleBuilding(
      'buildingTurret',
      'turret.png',
      Rect.fromLTWH(4910, 1470, 180, 160),
    ),
  ];

  static const emptyResourcePlots = [
    Rect.fromLTWH(6580, 1460, 220, 180),
    Rect.fromLTWH(6120, 1610, 220, 180),
    Rect.fromLTWH(6460, 1620, 220, 180),
    Rect.fromLTWH(5550, 1960, 220, 180),
    Rect.fromLTWH(6060, 2080, 220, 180),
    Rect.fromLTWH(6560, 2060, 220, 180),
  ];

  static const all = [...city, ...military];

  static String fullAssetPath(String asset) {
    if (asset == 'farm.png' ||
        asset == 'sawmill.png' ||
        asset == 'iron_mine.png' ||
        asset == 'mithril_mine.png') {
      return '$worldResourceRoot$asset';
    }
    return '$assetRoot$asset';
  }
}
