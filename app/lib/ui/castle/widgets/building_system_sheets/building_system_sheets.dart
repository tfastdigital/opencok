import 'package:flutter/material.dart';
import 'package:opencok/data/castle/city_slot_registry/city_slot_registry.dart';
import 'package:opencok/data/hud/kingdom_controller/kingdom_controller.dart';
import 'package:opencok/domain/castle/castle_building/castle_building.dart';
import 'package:opencok/l10n/game_names.dart';
import 'package:opencok/l10n/localization_context.dart';
import 'package:opencok/ui/shared/medieval_panel/medieval_panel.dart';

Future<void> showUniversalUpgradeSheet(
  BuildContext context,
  KingdomController controller,
  CastleBuilding building,
) {
  final name = context.l10n.gameName(building.nameKey);
  final slot = CitySlotRegistry.slotForBuilding(building.nameKey);
  return showMedievalSheet<void>(
    context,
    title: '$name · Upgrade',
    subtitle: slot == null
        ? 'Building Upgrade'
        : 'Slot ${slot.slotId} (${slot.category.name})',
    bodyBuilder: (sheetContext) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final lv = controller.buildingLevel(building.nameKey);
        final (woodCost, foodCost) = controller.upgradeCost(building.nameKey);
        final canAfford =
            controller.wood >= woodCost && controller.food >= foodCost;
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MedievalPanelColors.card,
                  border: Border.all(color: MedievalPanelColors.goldBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    _row('Current Level', 'Lv.$lv'),
                    const SizedBox(height: 6),
                    _row('Target Level', 'Lv.${lv + 1}'),
                    const SizedBox(height: 6),
                    _row('Power Bonus', '+15,000 Power'),
                    const SizedBox(height: 6),
                    _row(
                      'Wood Required',
                      '${KingdomController.formatCompact(woodCost)} (Have ${KingdomController.formatCompact(controller.wood)})',
                      ok: controller.wood >= woodCost,
                    ),
                    const SizedBox(height: 6),
                    _row(
                      'Food Required',
                      '${KingdomController.formatCompact(foodCost)} (Have ${KingdomController.formatCompact(controller.food)})',
                      ok: controller.food >= foodCost,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              medievalActionButton(
                label: 'Upgrade to Lv.${lv + 1}',
                icon: Icons.arrow_circle_up_outlined,
                onPressed: canAfford
                    ? () {
                        controller.upgradeBuilding(building.nameKey);
                        Navigator.of(sheetContext).pop();
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> showBuildingDetailsSheet(
  BuildContext context,
  KingdomController controller,
  CastleBuilding building,
) {
  final name = context.l10n.gameName(building.nameKey);
  final slot = CitySlotRegistry.slotForBuilding(building.nameKey);
  return showMedievalSheet<void>(
    context,
    title: '$name · Details',
    subtitle: 'Building Statistics & Slot Metadata',
    bodyBuilder: (context) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final lv = controller.buildingLevel(building.nameKey);
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MedievalPanelColors.card,
              border: Border.all(color: MedievalPanelColors.goldBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _row('Building', name),
                const SizedBox(height: 6),
                _row('Level', 'Lv.$lv / 30'),
                const SizedBox(height: 6),
                _row('Building Power', KingdomController.formatWithCommas(lv * 15000)),
                if (slot != null) ...[
                  const SizedBox(height: 6),
                  _row('Slot ID', slot.slotId),
                  const SizedBox(height: 6),
                  _row(
                    'World Coordinates',
                    '(${slot.worldX.round()}, ${slot.worldY.round()})',
                  ),
                  const SizedBox(height: 6),
                  _row('Render Layer', 'Layer ${slot.renderLayer}'),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}

Future<void> showCastleSkinsSheet(
  BuildContext context,
  KingdomController controller,
) {
  const skins = [
    ('classic', 'Royal Turquoise Citadel', 'Unlocked · +5% Construction Speed'),
    ('dragon', 'Dragonspire Keep', 'Unlocked · +5% Troop Attack'),
    ('crescent', 'Crescent Oasis Palace', 'Unlocked · +5% Resource Yield'),
  ];
  return showMedievalSheet<void>(
    context,
    title: 'Castle Skins',
    subtitle: 'Customize your citadel appearance & bonuses',
    iconAsset: 'assets/castle/buildings/castle.png',
    bodyBuilder: (context) => ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(14),
      itemCount: skins.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final (_, title, desc) = skins[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(
              color: index == 0
                  ? MedievalPanelColors.goldBright
                  : const Color(0xff3c454e),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: MedievalPanelColors.goldBright,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: MedievalPanelColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              medievalActionButton(
                compact: true,
                label: index == 0 ? 'Equipped' : 'Preview',
                onPressed: index == 0 ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> showAcademyResearchSheet(
  BuildContext context,
  KingdomController controller,
) {
  const techs = [
    ('Economy: Wood Production', '+8% Sawmill Output · 15K Food', 15000),
    ('Economy: Food Production', '+8% Farm Output · 15K Wood', 15000),
    ('Military: Infantry Armor', '+5% Infantry Defense · 20K Wood', 20000),
    ('Military: Cavalry Charge', '+5% Cavalry Attack · 20K Food', 20000),
    ('Marching: Legion Logistics', '+10% March Speed · 25K Wood', 25000),
  ];
  return showMedievalSheet<void>(
    context,
    title: 'Academy · Research',
    subtitle: 'Research kingdom technologies to boost power & economy',
    iconAsset: 'assets/castle/buildings/academy.png',
    bodyBuilder: (context) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) => ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(14),
        itemCount: techs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final (title, desc, cost) = techs[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MedievalPanelColors.card,
              border: Border.all(color: const Color(0xff4c555e)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: MedievalPanelColors.goldBright,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        desc,
                        style: const TextStyle(
                          color: MedievalPanelColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                medievalActionButton(
                  compact: true,
                  label: 'Research',
                  onPressed: controller.wood >= cost && controller.food >= cost
                      ? () {
                          controller.exchangeGoldForPack(0);
                          controller.addResources(wood: -cost, food: -cost);
                          controller.trainTroops(0, powerPerUnit: 0);
                          controller.addExperience(0.05);
                        }
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Future<void> showHospitalHealSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Hospital · Heal Troops',
  subtitle: 'Recover wounded soldiers from battle',
  iconAsset: 'assets/castle/buildings/hospital.png',
  bodyBuilder: (context) => Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(color: MedievalPanelColors.goldBorder),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              _row('Hospital Capacity', '45,000'),
              const SizedBox(height: 6),
              _row('Wounded Infantry', '1,200'),
              const SizedBox(height: 6),
              _row('Wounded Cavalry', '650'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        medievalActionButton(
          label: 'Heal All (12K Food · 8K Wood)',
          icon: Icons.local_hospital_outlined,
          onPressed: controller.food >= 12000 && controller.wood >= 8000
              ? () {
                  controller.addResources(food: -12000, wood: -8000);
                  controller.trainTroops(1850, powerPerUnit: 10);
                  Navigator.of(context).pop();
                }
              : null,
        ),
      ],
    ),
  ),
);

Widget _row(String label, String value, {bool ok = true}) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      label,
      style: const TextStyle(color: MedievalPanelColors.mutedText, fontSize: 13),
    ),
    Text(
      value,
      style: TextStyle(
        color: ok ? Colors.white : Colors.redAccent,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
);

Future<void> showWallsSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'City Walls · Defense',
  subtitle: 'Wall Durability, Garrison & Fortifications',
  iconAsset: 'assets/castle/buildings/city_wall.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MedievalPanelColors.card,
              border: Border.all(color: MedievalPanelColors.goldBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                _row('Wall Level', 'Lv.${controller.buildingLevel('buildingWalls')}'),
                const SizedBox(height: 6),
                _row('Wall Durability', '${controller.wallDurability}%'),
                const SizedBox(height: 6),
                _row('Garrisoned Troops', KingdomController.formatWithCommas(controller.troopsTrained)),
                const SizedBox(height: 6),
                _row('Defense Bonus', '+45% City Defense'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          medievalActionButton(
            label: controller.wallDurability >= 100
                ? 'Walls at Full Durability'
                : 'Repair Walls (5K Wood)',
            icon: Icons.security_outlined,
            onPressed: controller.wallDurability < 100 && controller.wood >= 5000
                ? controller.repairWalls
                : null,
          ),
        ],
      ),
    ),
  ),
);

Future<void> showDrillGroundsSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Drill Grounds · Army',
  subtitle: 'Army Capacity, Formations & Marching Slots',
  iconAsset: 'assets/castle/buildings/drill_grounds.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final lv = controller.buildingLevel('buildingDrillGrounds');
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(color: MedievalPanelColors.goldBorder),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('Drill Grounds Level', 'Lv.$lv'),
              const SizedBox(height: 6),
              _row('March Capacity', KingdomController.formatWithCommas(50000 + lv * 4000)),
              const SizedBox(height: 6),
              _row('Available March Slots', '4 / 4'),
              const SizedBox(height: 6),
              _row('Total Available Troops', KingdomController.formatWithCommas(controller.troopsTrained)),
            ],
          ),
        ),
      );
    },
  ),
);

Future<void> showMilitaryTentSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Military Tent · Training Boost',
  subtitle: 'Troop Training Capacity & Speed Bonus',
  iconAsset: 'assets/castle/buildings/military_tent.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final lv = controller.buildingLevel('buildingMilitaryTent');
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(color: MedievalPanelColors.goldBorder),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('Military Tent Level', 'Lv.$lv'),
              const SizedBox(height: 6),
              _row('Training Speed Bonus', '+${lv * 2}%'),
              const SizedBox(height: 6),
              _row('Extra Training Capacity', '+${lv * 50} units'),
            ],
          ),
        ),
      );
    },
  ),
);

Future<void> showWishingWellSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Wishing Well',
  subtitle: 'Make a daily wish for kingdom resources',
  iconAsset: 'assets/castle/buildings/wishing_well.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Free Wishes Remaining: ${controller.wishesRemaining}',
            style: const TextStyle(
              color: MedievalPanelColors.goldBright,
              fontFamily: 'serif',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (label, type) in const [
                ('Wish +40K Wood', 'Wood'),
                ('Wish +40K Food', 'Food'),
                ('Wish +15K Iron', 'Iron'),
                ('Wish +8K Mithril', 'Mithril'),
                ('Wish +300 Gold', 'Gold'),
              ])
                medievalActionButton(
                  compact: true,
                  label: label,
                  onPressed: controller.wishesRemaining > 0
                      ? () => controller.makeWish(type)
                      : null,
                ),
            ],
          ),
        ],
      ),
    ),
  ),
);

Future<void> showTavernSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Tavern · Heroes & Dragonglass',
  subtitle: 'Recruit Heroes & Refine Dragonglass (Crystals: ${controller.crystals})',
  iconAsset: 'assets/castle/buildings/tavern.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MedievalPanelColors.card,
              border: Border.all(color: MedievalPanelColors.goldBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dragonglass Refinement',
                      style: TextStyle(
                        color: MedievalPanelColors.goldBright,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Crystals: ${controller.crystals}',
                      style: const TextStyle(
                        color: MedievalPanelColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                medievalActionButton(
                  compact: true,
                  label: 'Refine (250)',
                  onPressed: controller.crystals >= 250
                      ? controller.refineDragonglass
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hero Palace Roster',
            style: TextStyle(
              color: MedievalPanelColors.goldBright,
              fontFamily: 'serif',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in controller.heroLevels.entries)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MedievalPanelColors.cardDark,
                border: Border.all(color: const Color(0xff4c555e)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key} · Lv.${entry.value}',
                          style: const TextStyle(
                            color: MedievalPanelColors.goldBright,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '+10,000 Hero Power per level',
                          style: TextStyle(
                            color: MedievalPanelColors.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  medievalActionButton(
                    compact: true,
                    label: 'Upgrade (200G)',
                    onPressed: controller.gold >= 200
                        ? () => controller.upgradeHero(entry.key)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  ),
);

Future<void> showDragonsSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Dragon Cave',
  subtitle: 'Guardian & Marching Dragons · Bond & Dragon Travel',
  iconAsset: 'assets/castle/buildings/watchtower.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MedievalPanelColors.card,
              border: Border.all(color: MedievalPanelColors.goldBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                _row('Active Dragon', controller.activeDragon),
                const SizedBox(height: 6),
                _row('Dragon Level', 'Lv.${controller.dragonLevel} / 40'),
                const SizedBox(height: 6),
                _row('Dragon Bond', '${controller.dragonBond}%'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              medievalActionButton(
                compact: true,
                label: 'Level Up (15K Food)',
                onPressed:
                    controller.dragonLevel < 40 && controller.food >= 15000
                    ? controller.levelUpDragon
                    : null,
              ),
              medievalActionButton(
                compact: true,
                label: 'Restore Bond',
                onPressed: controller.dragonBond < 100
                    ? controller.restoreDragonBond
                    : null,
              ),
              medievalActionButton(
                compact: true,
                label: 'Dragon Travel (+30K W/F)',
                onPressed: controller.sendDragonTravel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final dragon in const [
            'Black Dragon',
            'Blue Dragon',
            'Red Dragon',
            'Scartha (Dragon-born)',
            'Kraken (Viking)',
            'Yukine (Yamato)',
            'Kylin (Huaxia)',
            'Fire Dragon (Crescent)',
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MedievalPanelColors.cardDark,
                border: Border.all(
                  color: controller.activeDragon == dragon
                      ? MedievalPanelColors.goldBright
                      : const Color(0xff38414a),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dragon, style: const TextStyle(color: Colors.white)),
                  medievalActionButton(
                    compact: true,
                    label: controller.activeDragon == dragon
                        ? 'Active'
                        : 'Select',
                    onPressed: controller.activeDragon == dragon
                        ? null
                        : () => controller.selectDragon(dragon),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  ),
);

Future<void> showTurretSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Fortress Turret · Fortifications',
  subtitle: 'Trap Capacity & Siege Defense',
  iconAsset: 'assets/castle/buildings/turret.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final lv = controller.buildingLevel('buildingTurret');
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(color: MedievalPanelColors.goldBorder),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('Turret Level', 'Lv.$lv'),
              const SizedBox(height: 6),
              _row('Trap Capacity', KingdomController.formatWithCommas(lv * 2500)),
              const SizedBox(height: 6),
              _row('Turret Attack Power', '+${lv * 4}%'),
            ],
          ),
        ),
      );
    },
  ),
);
