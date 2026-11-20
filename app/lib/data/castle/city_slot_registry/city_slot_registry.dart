import 'dart:ui';

import 'package:opencok/domain/castle/castle_building/castle_building.dart';
import 'package:opencok/domain/castle/castle_environment/castle_environment.dart';

enum CitySlotCategory {
  citadel,
  military,
  civic,
  defense,
  production,
}

class BuildingAssetMetadata {
  const BuildingAssetMetadata({
    required this.asset,
    required this.groundAnchor,
    this.visualOffset = Offset.zero,
    this.defaultScale = 1.0,
  });

  final String asset;
  final Offset groundAnchor;
  final Offset visualOffset;
  final double defaultScale;
}

class CitySlot {
  const CitySlot({
    required this.slotId,
    required this.category,
    required this.worldX,
    required this.worldY,
    required this.width,
    required this.height,
    required this.validBuildingKeys,
    required this.renderLayer,
    this.elevation = 0.0,
    this.anchor = const Offset(0.5, 0.85),
    this.unlockCastleLevel = 1,
    this.exclusive = true,
  });

  final String slotId;
  final CitySlotCategory category;
  final double worldX;
  final double worldY;
  final double width;
  final double height;
  final Set<String> validBuildingKeys;
  final int renderLayer;
  final double elevation;
  final Offset anchor;
  final int unlockCastleLevel;
  final bool exclusive;

  Rect get bounds => Rect.fromLTWH(worldX, worldY, width, height);
  Offset get center => bounds.center;
}

enum LayoutViolationKind {
  missingSlot,
  invalidBuildingForSlot,
  duplicateExclusiveSlot,
  outOfPlayableBounds,
  overlappingFootprint,
}

class CityLayoutViolation {
  const CityLayoutViolation({
    required this.kind,
    required this.message,
    this.slotId,
    this.buildingKey,
  });

  final LayoutViolationKind kind;
  final String message;
  final String? slotId;
  final String? buildingKey;
}

class CitySlotRegistry {
  static const Map<String, BuildingAssetMetadata> assetMetadata = {
    'castle.png': BuildingAssetMetadata(
      asset: 'castle.png',
      groundAnchor: Offset(0.5, 0.82),
    ),
    'watchtower.png': BuildingAssetMetadata(
      asset: 'watchtower.png',
      groundAnchor: Offset(0.5, 0.88),
    ),
    'siege_workshop.png': BuildingAssetMetadata(
      asset: 'siege_workshop.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
    'stable.png': BuildingAssetMetadata(
      asset: 'stable.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
    'archery_range.png': BuildingAssetMetadata(
      asset: 'archery_range.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
    'barracks.png': BuildingAssetMetadata(
      asset: 'barracks.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
    'academy.png': BuildingAssetMetadata(
      asset: 'academy.png',
      groundAnchor: Offset(0.5, 0.86),
    ),
    'embassy.png': BuildingAssetMetadata(
      asset: 'embassy.png',
      groundAnchor: Offset(0.5, 0.86),
    ),
    'hall_of_war.png': BuildingAssetMetadata(
      asset: 'hall_of_war.png',
      groundAnchor: Offset(0.5, 0.86),
    ),
    'warehouse.png': BuildingAssetMetadata(
      asset: 'warehouse.png',
      groundAnchor: Offset(0.5, 0.86),
    ),
    'market.png': BuildingAssetMetadata(
      asset: 'market.png',
      groundAnchor: Offset(0.5, 0.86),
    ),
    'forge.png': BuildingAssetMetadata(
      asset: 'forge.png',
      groundAnchor: Offset(0.5, 0.86),
    ),
    'hospital.png': BuildingAssetMetadata(
      asset: 'hospital.png',
      groundAnchor: Offset(0.5, 0.86),
    ),
    'farm.png': BuildingAssetMetadata(
      asset: 'farm.png',
      groundAnchor: Offset(0.5, 0.80),
    ),
    'sawmill.png': BuildingAssetMetadata(
      asset: 'sawmill.png',
      groundAnchor: Offset(0.5, 0.80),
    ),
    'iron_mine.png': BuildingAssetMetadata(
      asset: 'iron_mine.png',
      groundAnchor: Offset(0.5, 0.80),
    ),
    'mithril_mine.png': BuildingAssetMetadata(
      asset: 'mithril_mine.png',
      groundAnchor: Offset(0.5, 0.80),
    ),
    'city_wall.png': BuildingAssetMetadata(
      asset: 'city_wall.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
    'drill_grounds.png': BuildingAssetMetadata(
      asset: 'drill_grounds.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
    'military_tent.png': BuildingAssetMetadata(
      asset: 'military_tent.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
    'wishing_well.png': BuildingAssetMetadata(
      asset: 'wishing_well.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
    'tavern.png': BuildingAssetMetadata(
      asset: 'tavern.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
    'turret.png': BuildingAssetMetadata(
      asset: 'turret.png',
      groundAnchor: Offset(0.5, 0.85),
    ),
  };

  static const List<CitySlot> slots = [
    CitySlot(
      slotId: 'slot_citadel_main',
      category: CitySlotCategory.citadel,
      worldX: 3740,
      worldY: 480,
      width: 680,
      height: 633,
      validBuildingKeys: {'buildingCastle'},
      renderLayer: 10,
      elevation: 2.0,
    ),
    CitySlot(
      slotId: 'slot_def_watchtower',
      category: CitySlotCategory.defense,
      worldX: 3635,
      worldY: 1005,
      width: 210,
      height: 330,
      validBuildingKeys: {'buildingWatchtower'},
      renderLayer: 12,
      elevation: 1.0,
    ),
    CitySlot(
      slotId: 'slot_mil_siege',
      category: CitySlotCategory.military,
      worldX: 3928,
      worldY: 1100,
      width: 345,
      height: 310,
      validBuildingKeys: {'buildingSiegeWorkshop'},
      renderLayer: 14,
      elevation: 1.0,
    ),
    CitySlot(
      slotId: 'slot_mil_stable',
      category: CitySlotCategory.military,
      worldX: 4204,
      worldY: 1325,
      width: 342.5,
      height: 265,
      validBuildingKeys: {'buildingStable'},
      renderLayer: 15,
      elevation: 1.0,
    ),
    CitySlot(
      slotId: 'slot_mil_archery',
      category: CitySlotCategory.military,
      worldX: 3674,
      worldY: 1345,
      width: 352.5,
      height: 290,
      validBuildingKeys: {'buildingArcheryRange'},
      renderLayer: 16,
      elevation: 1.0,
    ),
    CitySlot(
      slotId: 'slot_mil_barracks',
      category: CitySlotCategory.military,
      worldX: 3974,
      worldY: 1444,
      width: 351.25,
      height: 276.25,
      validBuildingKeys: {'buildingBarracks'},
      renderLayer: 17,
      elevation: 1.0,
    ),
    CitySlot(
      slotId: 'slot_civic_academy',
      category: CitySlotCategory.civic,
      worldX: 4450,
      worldY: 750,
      width: 250,
      height: 248,
      validBuildingKeys: {'buildingAcademy'},
      renderLayer: 11,
      elevation: 1.5,
    ),
    CitySlot(
      slotId: 'slot_civic_embassy',
      category: CitySlotCategory.civic,
      worldX: 4985,
      worldY: 835,
      width: 250,
      height: 214,
      validBuildingKeys: {'buildingEmbassy'},
      renderLayer: 12,
      elevation: 1.5,
    ),
    CitySlot(
      slotId: 'slot_civic_hall_of_war',
      category: CitySlotCategory.civic,
      worldX: 5245,
      worldY: 965,
      width: 265,
      height: 258,
      validBuildingKeys: {'buildingHallOfWar'},
      renderLayer: 13,
      elevation: 1.5,
    ),
    CitySlot(
      slotId: 'slot_civic_warehouse',
      category: CitySlotCategory.civic,
      worldX: 5210,
      worldY: 1295,
      width: 265,
      height: 215,
      validBuildingKeys: {'buildingWarehouse'},
      renderLayer: 15,
      elevation: 0.5,
    ),
    CitySlot(
      slotId: 'slot_civic_market',
      category: CitySlotCategory.civic,
      worldX: 4620,
      worldY: 1585,
      width: 225,
      height: 210,
      validBuildingKeys: {'buildingMarket'},
      renderLayer: 18,
      elevation: 0.5,
    ),
    CitySlot(
      slotId: 'slot_civic_forge',
      category: CitySlotCategory.civic,
      worldX: 4300,
      worldY: 1720,
      width: 270,
      height: 190,
      validBuildingKeys: {'buildingForge'},
      renderLayer: 19,
      elevation: 0.5,
    ),
    CitySlot(
      slotId: 'slot_civic_hospital',
      category: CitySlotCategory.civic,
      worldX: 5480,
      worldY: 1210,
      width: 230,
      height: 130,
      validBuildingKeys: {'buildingHospital'},
      renderLayer: 14,
      elevation: 0.5,
    ),
    CitySlot(
      slotId: 'slot_prod_farm_1',
      category: CitySlotCategory.production,
      worldX: 5980,
      worldY: 1360,
      width: 240,
      height: 205,
      validBuildingKeys: {'buildingFarm'},
      renderLayer: 20,
    ),
    CitySlot(
      slotId: 'slot_prod_sawmill_1',
      category: CitySlotCategory.production,
      worldX: 6310,
      worldY: 1330,
      width: 240,
      height: 205,
      validBuildingKeys: {'buildingSawmill'},
      renderLayer: 20,
    ),
    CitySlot(
      slotId: 'slot_prod_iron_1',
      category: CitySlotCategory.production,
      worldX: 5830,
      worldY: 1840,
      width: 240,
      height: 205,
      validBuildingKeys: {'buildingIronMine'},
      renderLayer: 21,
    ),
    CitySlot(
      slotId: 'slot_prod_mithril_1',
      category: CitySlotCategory.production,
      worldX: 6280,
      worldY: 1860,
      width: 240,
      height: 205,
      validBuildingKeys: {'buildingMithrilMine'},
      renderLayer: 21,
    ),
    CitySlot(
      slotId: 'slot_def_walls',
      category: CitySlotCategory.defense,
      worldX: 4000,
      worldY: 1740,
      width: 140,
      height: 160,
      validBuildingKeys: {'buildingWalls'},
      renderLayer: 18,
    ),
    CitySlot(
      slotId: 'slot_mil_drill_grounds',
      category: CitySlotCategory.military,
      worldX: 5140,
      worldY: 1515,
      width: 240,
      height: 182,
      validBuildingKeys: {'buildingDrillGrounds'},
      renderLayer: 13,
    ),
    CitySlot(
      slotId: 'slot_mil_tent',
      category: CitySlotCategory.military,
      worldX: 4930,
      worldY: 1060,
      width: 220,
      height: 122,
      validBuildingKeys: {'buildingMilitaryTent'},
      renderLayer: 14,
    ),
    CitySlot(
      slotId: 'slot_civic_wishing_well',
      category: CitySlotCategory.civic,
      worldX: 4705,
      worldY: 905,
      width: 180,
      height: 152,
      validBuildingKeys: {'buildingWishingWell'},
      renderLayer: 14,
    ),
    CitySlot(
      slotId: 'slot_civic_tavern',
      category: CitySlotCategory.civic,
      worldX: 3790,
      worldY: 1820,
      width: 210,
      height: 132,
      validBuildingKeys: {'buildingTavern'},
      renderLayer: 19,
    ),
    CitySlot(
      slotId: 'slot_def_turret',
      category: CitySlotCategory.defense,
      worldX: 4910,
      worldY: 1470,
      width: 180,
      height: 160,
      validBuildingKeys: {'buildingTurret'},
      renderLayer: 17,
    ),
  ];

  static CitySlot? slotForBuilding(String nameKey) {
    for (final slot in slots) {
      if (slot.validBuildingKeys.contains(nameKey)) return slot;
    }
    return null;
  }

  static List<CityLayoutViolation> validate(List<CastleBuilding> buildings) {
    final violations = <CityLayoutViolation>[];
    final usedSlots = <String>{};
    final playable = CastleEnvironment.playableBounds;

    for (final b in buildings) {
      final slot = slotForBuilding(b.nameKey);
      if (slot == null) {
        violations.add(
          CityLayoutViolation(
            kind: LayoutViolationKind.missingSlot,
            buildingKey: b.nameKey,
            message: 'No registered slot for ${b.nameKey}',
          ),
        );
        continue;
      }
      if (slot.exclusive && !usedSlots.add(slot.slotId)) {
        violations.add(
          CityLayoutViolation(
            kind: LayoutViolationKind.duplicateExclusiveSlot,
            slotId: slot.slotId,
            buildingKey: b.nameKey,
            message: 'Multiple buildings assigned to exclusive slot ${slot.slotId}',
          ),
        );
      }
      if (!slot.validBuildingKeys.contains(b.nameKey)) {
        violations.add(
          CityLayoutViolation(
            kind: LayoutViolationKind.invalidBuildingForSlot,
            slotId: slot.slotId,
            buildingKey: b.nameKey,
            message: '${b.nameKey} is not valid in ${slot.slotId}',
          ),
        );
      }
      if (b.bounds.left < playable.left ||
          b.bounds.right > playable.right ||
          b.bounds.top < playable.top ||
          b.bounds.bottom > playable.bottom) {
        violations.add(
          CityLayoutViolation(
            kind: LayoutViolationKind.outOfPlayableBounds,
            slotId: slot.slotId,
            buildingKey: b.nameKey,
            message: '${b.nameKey} extends outside playableBounds',
          ),
        );
      }
    }

    Rect groundFootprint(CastleBuilding building) {
      final meta = assetMetadata[building.asset];
      final anchor = meta?.groundAnchor ?? const Offset(0.5, 0.85);
      final center = Offset(
        building.bounds.left + building.bounds.width * anchor.dx,
        building.bounds.top + building.bounds.height * anchor.dy,
      );
      return Rect.fromCenter(center: center, width: 110, height: 80);
    }

    for (var i = 0; i < buildings.length; i++) {
      for (var j = i + 1; j < buildings.length; j++) {
        final a = groundFootprint(buildings[i]);
        final b = groundFootprint(buildings[j]);
        if (a.overlaps(b)) {
          violations.add(
            CityLayoutViolation(
              kind: LayoutViolationKind.overlappingFootprint,
              buildingKey: buildings[i].nameKey,
              message:
                  '${buildings[i].nameKey} overlaps ${buildings[j].nameKey}',
            ),
          );
        }
      }
    }
    return violations;
  }
}
