import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opencok/data/hud/kingdom_controller/kingdom_controller.dart';
import 'package:opencok/domain/hud/hud_action/hud_action.dart';
import 'package:opencok/l10n/localization_context.dart';
import 'package:opencok/ui/shared/medieval_panel/medieval_panel.dart';

Future<void> showVipSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'SVIP ${controller.vipLevel}',
  subtitle: 'Royal VIP Privileges & Active Bonuses',
  iconAsset: 'assets/ui/hud/profile/level_badge.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final nextTarget = (controller.vipLevel + 1) * 10000;
      final progress = (controller.vipPoints / nextTarget).clamp(0.0, 1.0);
      return SingleChildScrollView(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SVIP ${controller.vipLevel}',
                        style: const TextStyle(
                          color: MedievalPanelColors.goldBright,
                          fontFamily: 'serif',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${KingdomController.formatWithCommas(controller.vipPoints)} / ${KingdomController.formatWithCommas(nextTarget)} pts',
                        style: const TextStyle(
                          color: MedievalPanelColors.goldText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: MedievalPanelColors.cardDark,
                      color: MedievalPanelColors.goldBorder,
                    ),
                  ),
                  const SizedBox(height: 12),
                  medievalActionButton(
                    label: 'Claim Daily +1,500 VIP Points',
                    icon: Icons.workspace_premium,
                    onPressed: () => controller.addVipPoints(1500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final (perk, bonus) in const [
              ('Resource Production', '+35%'),
              ('Troop Training Speed', '+25%'),
              ('March Speed', '+30%'),
              ('Construction Speed', '+25%'),
              ('Free Build Speedup', '20 min'),
            ])
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: MedievalPanelColors.cardDark,
                  border: Border.all(color: const Color(0xff38414a)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      perk,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    Text(
                      bonus,
                      style: const TextStyle(
                        color: Color(0xff68d847),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    },
  ),
);

Future<void> showResourceDetailSheet(
  BuildContext context,
  KingdomController controller,
  HudAction action,
) {
  final (title, icon, getter, rate, onHarvest) = switch (action) {
    HudAction.wood => (
      context.l10n.wood,
      'assets/ui/hud/resources/wood_icon.png',
      () => controller.wood,
      '42,500 / hr',
      () => controller.addResources(wood: 25000),
    ),
    HudAction.food => (
      context.l10n.food,
      'assets/ui/hud/resources/food_icon.png',
      () => controller.food,
      '48,000 / hr',
      () => controller.addResources(food: 25000),
    ),
    HudAction.iron => (
      context.l10n.iron,
      'assets/ui/hud/resources/iron_icon.png',
      () => controller.iron,
      '14,200 / hr',
      () => controller.addResources(iron: 10000),
    ),
    _ => (
      context.l10n.mithril,
      'assets/ui/hud/resources/mithril_icon.png',
      () => controller.mithril,
      '6,800 / hr',
      () => controller.addResources(mithril: 5000),
    ),
  };

  return showMedievalSheet<void>(
    context,
    title: title,
    subtitle: 'Warehouse Stockpile & Production',
    iconAsset: icon,
    bodyBuilder: (context) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final amount = getter();
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MedievalPanelColors.card,
                  border: Border.all(color: MedievalPanelColors.goldBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    _metricRow('Current Stockpile', KingdomController.formatWithCommas(amount)),
                    const SizedBox(height: 8),
                    _metricRow('Hourly Production', rate),
                    const SizedBox(height: 8),
                    _metricRow('Protected Warehouse Cap', '500,000'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              medievalActionButton(
                label: 'Collect City Production',
                icon: Icons.agriculture_outlined,
                onPressed: onHarvest,
              ),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> showPowerBreakdownSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.power,
  subtitle: 'Kingdom Military & Citadel Strength',
  iconAsset: 'assets/ui/hud/profile/level_badge.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final total = controller.power;
      final troops = (total * 0.52).round();
      final buildings = (total * 0.21).round();
      final research = (total * 0.14).round();
      final lord = (total * 0.08).round();
      final gear = total - troops - buildings - research - lord;
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(color: MedievalPanelColors.goldBorder),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _metricRow('Total Power', KingdomController.formatWithCommas(total), highlight: true),
              const Divider(color: Color(0xff4c555e), height: 20),
              _metricRow('Troops Power', KingdomController.formatWithCommas(troops)),
              const SizedBox(height: 8),
              _metricRow('Building Power', KingdomController.formatWithCommas(buildings)),
              const SizedBox(height: 8),
              _metricRow('Research Power', KingdomController.formatWithCommas(research)),
              const SizedBox(height: 8),
              _metricRow('Lord & Skills', KingdomController.formatWithCommas(lord)),
              const SizedBox(height: 8),
              _metricRow('Equipment Power', KingdomController.formatWithCommas(gear)),
            ],
          ),
        ),
      );
    },
  ),
);

Future<void> showGoldTreasurySheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.gold,
  subtitle: 'Royal Treasury & Resource Exchange',
  iconAsset: 'assets/ui/hud/resources/gold_coins_icon.png',
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
            child: _metricRow(
              'Treasury Balance',
              '${KingdomController.formatWithCommas(controller.gold)} Gold',
              highlight: true,
            ),
          ),
          const SizedBox(height: 12),
          for (final (title, desc, cost, wood, food, iron, mithril) in const [
            ('100K Wood Supply', 'Exchange 250 Gold for 100,000 Wood', 250, 100000, 0, 0, 0),
            ('100K Food Supply', 'Exchange 250 Gold for 100,000 Food', 250, 0, 100000, 0, 0),
            ('40K Iron Supply', 'Exchange 300 Gold for 40,000 Iron', 300, 0, 0, 40000, 0),
            ('20K Mithril Supply', 'Exchange 400 Gold for 20,000 Mithril', 400, 0, 0, 0, 20000),
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MedievalPanelColors.cardDark,
                border: Border.all(color: const Color(0xff3c454e)),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                  const SizedBox(width: 8),
                  medievalActionButton(
                    compact: true,
                    label: '$cost Gold',
                    onPressed: controller.gold >= cost
                        ? () => controller.exchangeGoldForPack(
                            cost,
                            wood: wood,
                            food: food,
                            iron: iron,
                            mithril: mithril,
                          )
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

Future<void> showLordStatusSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: '${controller.playerName} · Lv.${controller.level}',
  subtitle: 'Lord Experience & Stamina',
  iconAsset: 'assets/ui/profile/experience.png',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _metricRow(
                  'Experience',
                  '${(controller.experience * 100).round()}%',
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: controller.experience,
                  minHeight: 8,
                  backgroundColor: MedievalPanelColors.cardDark,
                  color: const Color(0xff20d5f5),
                ),
                const SizedBox(height: 12),
                _metricRow(
                  'Energy',
                  '${controller.energyCurrent}/120',
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: controller.energy,
                  minHeight: 8,
                  backgroundColor: MedievalPanelColors.cardDark,
                  color: const Color(0xff68d847),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: medievalActionButton(
                  label: '+10% Lord XP',
                  onPressed: () => controller.addExperience(0.10),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: medievalActionButton(
                  label: '+30 Energy',
                  onPressed: controller.energy < 1.0
                      ? () => controller.addEnergy(0.25)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

Widget _metricRow(String label, String value, {bool highlight = false}) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      label,
      style: const TextStyle(
        color: MedievalPanelColors.mutedText,
        fontSize: 13,
      ),
    ),
    Text(
      value,
      style: TextStyle(
        color: highlight
            ? MedievalPanelColors.goldBright
            : Colors.white,
        fontFamily: highlight ? 'serif' : null,
        fontSize: highlight ? 16 : 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  ],
);

Future<void> showCityBuildingsSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'City Buildings & Construction',
  subtitle: 'Construct and upgrade kingdom structures',
  iconAsset: 'assets/ui/hud/navigation/city_icon.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(14),
      itemCount: controller.cityBuildings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = controller.cityBuildings[index];
        final nextLevel = item.level + 1;
        final woodCost = nextLevel * 15000;
        final foodCost = nextLevel * 12000;
        final canAfford =
            item.level < item.maxLevel &&
            controller.wood >= woodCost &&
            controller.food >= foodCost;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(
              color: item.level > 0
                  ? MedievalPanelColors.goldBorder
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
                      item.level == 0
                          ? '${item.name} (Empty Plot)'
                          : '${item.name} · Lv.${item.level}',
                      style: const TextStyle(
                        color: MedievalPanelColors.goldBright,
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.bonus,
                      style: const TextStyle(
                        color: MedievalPanelColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cost: ${KingdomController.formatCompact(woodCost)} Wood · ${KingdomController.formatCompact(foodCost)} Food',
                      style: const TextStyle(
                        color: MedievalPanelColors.goldText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              medievalActionButton(
                compact: true,
                label: item.level == 0
                    ? 'Build'
                    : (item.level >= item.maxLevel ? 'Max' : 'Upgrade'),
                onPressed: canAfford
                    ? () => controller.buildOrUpgradeCityConstructible(item.id)
                    : null,
              ),
            ],
          ),
        );
      },
    ),
  ),
);

Future<void> showKingdomsAndCastlesSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Kingdoms & Castles',
  subtitle: 'Switch or Found Kingdoms · Build World Castles',
  iconAsset: 'assets/ui/hud/navigation/world_map_icon.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kingdoms',
                style: TextStyle(
                  color: MedievalPanelColors.goldBright,
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              medievalActionButton(
                compact: true,
                label: 'Found Kingdom',
                icon: Icons.public,
                onPressed: () => _showCreateKingdomDialog(context, controller),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final kingdom in controller.kingdoms)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kingdom.id == controller.activeKingdomId
                    ? MedievalPanelColors.card
                    : MedievalPanelColors.cardDark,
                border: Border.all(
                  color: kingdom.id == controller.activeKingdomId
                      ? MedievalPanelColors.goldBorder
                      : const Color(0xff38414a),
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
                          '#${kingdom.id} · ${kingdom.name}',
                          style: const TextStyle(
                            color: MedievalPanelColors.goldBright,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${kingdom.castlesCount} Castles',
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
                    label: kingdom.id == controller.activeKingdomId
                        ? 'Active'
                        : 'Enter',
                    onPressed: kingdom.id == controller.activeKingdomId
                        ? null
                        : () => controller.switchKingdom(kingdom.id),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Castles',
                style: TextStyle(
                  color: MedievalPanelColors.goldBright,
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              medievalActionButton(
                compact: true,
                label: 'Build Castle (50K W/F)',
                icon: Icons.castle_outlined,
                onPressed: controller.wood >= 50000 && controller.food >= 50000
                    ? () => _showBuildCastleDialog(context, controller)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final castle in controller.playerCastles)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MedievalPanelColors.card,
                border: Border.all(color: const Color(0xff4c555e)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${castle.name} · Lv.${castle.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Kingdom #${castle.kingdomId} · (${castle.x}, ${castle.y})',
                        style: const TextStyle(
                          color: MedievalPanelColors.goldText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.location_city,
                    color: MedievalPanelColors.goldBorder,
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  ),
);

Future<void> _showCreateKingdomDialog(
  BuildContext context,
  KingdomController controller,
) async {
  final nextId = controller.kingdoms.map((k) => k.id).reduce((a, b) => a > b ? a : b) + 1;
  final nameCtrl = TextEditingController(text: 'New Kingdom $nextId');
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: MedievalPanelColors.card,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: MedievalPanelColors.goldBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(
        'Found Kingdom #$nextId',
        style: const TextStyle(
          color: MedievalPanelColors.goldBright,
          fontFamily: 'serif',
        ),
      ),
      content: TextField(
        controller: nameCtrl,
        maxLength: 24,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: 'Kingdom Name',
          labelStyle: TextStyle(color: MedievalPanelColors.mutedText),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.close),
        ),
        medievalActionButton(
          compact: true,
          label: 'Found',
          onPressed: () {
            controller.createKingdom(nextId, nameCtrl.text);
            Navigator.of(dialogContext).pop();
          },
        ),
      ],
    ),
  );
  nameCtrl.dispose();
}

Future<void> _showBuildCastleDialog(
  BuildContext context,
  KingdomController controller,
) async {
  final nameCtrl = TextEditingController(
    text: 'Fortress ${controller.playerCastles.length + 1}',
  );
  final xCtrl = TextEditingController(
    text: '${520 + controller.playerCastles.length * 14}',
  );
  final yCtrl = TextEditingController(
    text: '${515 + controller.playerCastles.length * 11}',
  );
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: MedievalPanelColors.card,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: MedievalPanelColors.goldBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(
        'Build Castle in Kingdom #${controller.activeKingdomId}',
        style: const TextStyle(
          color: MedievalPanelColors.goldBright,
          fontFamily: 'serif',
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            maxLength: 24,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Castle Name',
              labelStyle: TextStyle(color: MedievalPanelColors.mutedText),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: xCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'X',
                    labelStyle: TextStyle(color: MedievalPanelColors.mutedText),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: yCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Y',
                    labelStyle: TextStyle(color: MedievalPanelColors.mutedText),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.close),
        ),
        medievalActionButton(
          compact: true,
          label: 'Build',
          onPressed: () {
            final x = int.tryParse(xCtrl.text) ?? 520;
            final y = int.tryParse(yCtrl.text) ?? 520;
            controller.buildWorldCastle(nameCtrl.text, x, y);
            Navigator.of(dialogContext).pop();
          },
        ),
      ],
    ),
  );
  nameCtrl.dispose();
  xCtrl.dispose();
  yCtrl.dispose();
}

Future<void> showKingdomWarSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Kingdom vs Kingdom War',
  subtitle: 'Middle Throne (600, 600) · Rules & Victory Prizes',
  iconAsset: 'assets/ui/hud/navigation/world_map_icon.png',
  bodyBuilder: (context) => _KingdomWarBody(controller: controller),
);

class _KingdomWarBody extends StatefulWidget {
  const _KingdomWarBody({required this.controller});
  final KingdomController controller;

  @override
  State<_KingdomWarBody> createState() => _KingdomWarBodyState();
}

class _KingdomWarBodyState extends State<_KingdomWarBody> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final ctrl = widget.controller;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (idx, label) in const [
                    (0, 'Throne & KvK'),
                    (1, 'Dragon Campaign'),
                    (2, 'War Rules'),
                    (3, 'KvK Prizes'),
                  ]) ...[
                    ChoiceChip(
                      label: Text(label),
                      selected: _tab == idx,
                      onSelected: (_) => setState(() => _tab = idx),
                      selectedColor: MedievalPanelColors.actionGreen,
                      backgroundColor: MedievalPanelColors.cardDark,
                      labelStyle: TextStyle(
                        color: _tab == idx
                            ? MedievalPanelColors.goldBright
                            : MedievalPanelColors.mutedText,
                      ),
                      side: const BorderSide(color: Color(0xff5e4f33)),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: switch (_tab) {
                0 => _buildWarTab(ctrl),
                1 => _buildDragonCampaignTab(ctrl),
                2 => _buildRulesTab(),
                _ => _buildPrizesTab(ctrl),
              },
            ),
          ),
        ],
      );
    },
  );

  Widget _buildWarTab(KingdomController ctrl) => Column(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kingdom #${ctrl.activeKingdomId} vs Kingdom #1306',
              style: const TextStyle(
                color: MedievalPanelColors.goldBright,
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _metricRow(
              'Our KvK Score',
              KingdomController.formatWithCommas(ctrl.kvkPoints),
              highlight: true,
            ),
            const SizedBox(height: 4),
            _metricRow(
              'Enemy Kingdom Score',
              KingdomController.formatWithCommas(ctrl.kvkEnemyPoints),
            ),
            const SizedBox(height: 4),
            _metricRow('Middle Throne (600, 600)', ctrl.throneHolder),
            const SizedBox(height: 4),
            _metricRow(
              'Current King',
              ctrl.isKing ? '👑 ${ctrl.kingName} (You)' : ctrl.kingName,
              highlight: ctrl.isKing,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      medievalActionButton(
        label: ctrl.isKing
            ? 'Reinforce Throne (You are King)'
            : 'Attack & Capture Throne (-10 Energy)',
        icon: Icons.flag_outlined,
        onPressed: ctrl.energyCurrent >= 10
            ? () {
                final home = ctrl.playerCastles.first;
                Navigator.of(context).pop();
                ctrl.launchMarch(
                  kind: 'rally',
                  label: 'Marching to Throne (574, 566)',
                  fromX: home.x,
                  fromY: home.y,
                  toX: 574,
                  toY: 566,
                  duration: const Duration(seconds: 6),
                  onComplete: ctrl.rallyMiddleThrone,
                );
              }
            : null,
      ),
      const SizedBox(height: 8),
      medievalActionButton(
        label: 'Invade Kingdom #1306 (-10 Energy · +2,500 Pts)',
        icon: Icons.gavel_outlined,
        onPressed: ctrl.energyCurrent >= 10
            ? () {
                final home = ctrl.playerCastles.first;
                Navigator.of(context).pop();
                ctrl.launchMarch(
                  kind: 'attack',
                  label: 'Invading K#1306',
                  fromX: home.x,
                  fromY: home.y,
                  toX: 566,
                  toY: 572,
                  duration: const Duration(seconds: 6),
                  onComplete: () => ctrl.invadeEnemyKingdom(1306),
                );
              }
            : null,
      ),
      if (ctrl.isKing) ...[
        const SizedBox(height: 14),
        const Text(
          'Royal Palace · Appoint Officers',
          style: TextStyle(
            color: MedievalPanelColors.goldBright,
            fontFamily: 'serif',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final entry in ctrl.royalAppointments.entries)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        entry.key,
                        style: const TextStyle(
                          color: MedievalPanelColors.goldBright,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Appointed: ${entry.value} · ${KingdomController.royalOfficeEffects[entry.key] ?? ''}',
                        style: const TextStyle(
                          color: MedievalPanelColors.mutedText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                medievalActionButton(
                  compact: true,
                  label: 'Appoint',
                  onPressed: () =>
                      _showAppointLordDialog(context, ctrl, entry.key),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        medievalActionButton(
          label: ctrl.royalGiftIssued
              ? 'Kingdom Gift Issued'
              : 'Issue Royal Kingdom Gift (+500 Gold · +50K W/F)',
          icon: Icons.card_giftcard_outlined,
          onPressed: ctrl.royalGiftIssued ? null : ctrl.issueKingdomGift,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            medievalActionButton(
              compact: true,
              label: 'Skill: Bumper Harvest',
              onPressed: () => ctrl.activateKingSkill('Bumper Harvest'),
            ),
            medievalActionButton(
              compact: true,
              label: 'Skill: Red Envelope',
              onPressed: () => ctrl.activateKingSkill('Red Envelope'),
            ),
          ],
        ),
      ],
    ],
  );

  Widget _buildDragonCampaignTab(KingdomController ctrl) => Column(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dragon Campaign (Alliance Tournament)',
              style: TextStyle(
                color: MedievalPanelColors.goldBright,
                fontFamily: 'serif',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            _metricRow(
              '[${ctrl.allianceTag}] Camp Points',
              '${ctrl.dragonCampaignCampPoints}',
              highlight: true,
            ),
            const SizedBox(height: 4),
            _metricRow(
              '[DRG] Opponent Points',
              '${ctrl.dragonCampaignEnemyPoints}',
            ),
            const SizedBox(height: 4),
            _metricRow('Dragonglass Crystals', '${ctrl.crystals}'),
            const SizedBox(height: 6),
            const Text(
              'No permanent troop deaths · Faster free healing · Capture towers for Camp Points & Crystals.',
              style: TextStyle(
                color: MedievalPanelColors.mutedText,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      for (final (tower, pts, desc) in const [
        ('Crystal Mine', 40, '+40 Camp Pts & +150 Crystals'),
        ('Blessing Tower', 30, '+30 Camp Pts · Attack/Defense Boost'),
        ('Hall of Healing', 25, '+25 Camp Pts · Faster Healing'),
        ('Dragon Tower', 60, '+60 Camp Pts · Area Superweapon'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: medievalActionButton(
            label: 'Capture $tower ($desc)',
            icon: Icons.castle_outlined,
            onPressed: () => ctrl.captureDragonCampaignTower(tower, pts),
          ),
        ),
    ],
  );

  Future<void> _showAppointLordDialog(
    BuildContext context,
    KingdomController ctrl,
    String title,
  ) async {
    const candidates = [
      'LadySeraphina',
      '★JUϟ★',
      'SirAldric',
      'LordVanguard',
    ];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MedievalPanelColors.card,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: MedievalPanelColors.goldBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'Appoint $title',
          style: const TextStyle(
            color: MedievalPanelColors.goldBright,
            fontFamily: 'serif',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final lord in candidates)
              ListTile(
                title: Text(lord, style: const TextStyle(color: Colors.white)),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: MedievalPanelColors.goldBorder,
                ),
                onTap: () {
                  ctrl.appointLord(title, lord);
                  Navigator.of(dialogContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesTab() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: MedievalPanelColors.card,
      border: Border.all(color: MedievalPanelColors.goldBorder),
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kingdom War (KvK) Rules',
          style: TextStyle(
            color: MedievalPanelColors.goldBright,
            fontFamily: 'serif',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '1. Middle Throne Control: Capture and hold the Middle Throne Castle at (600, 600) to earn +5,000 War Points and crown your Alliance.\n\n'
          '2. Cross-Kingdom Raids: Invade enemy kingdoms (#1306 / #1307) to defeat rival castles and earn +2,500 War Points plus resource spoils.\n\n'
          '3. Contested Resource Zones: Gathering at high-level Farms, Sawmills, Iron & Mithril Mines near the center grants bonus XP and resources.\n\n'
          '4. Victory Prizes: Reach 2,500, 5,000, and 10,000 War Points to unlock Gold, Mithril, and SVIP Honor rewards.',
          style: TextStyle(
            color: Color(0xffd5d8dc),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    ),
  );

  Widget _buildPrizesTab(KingdomController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (tier, req, title, reward) in const [
        (1, 2500, 'Tier I · Vanguard Chest', '+500 Gold · +50K Wood · +50K Food'),
        (2, 5000, 'Tier II · Warlord Chest', '+1,200 Gold · +100K Wood · +30K Iron'),
        (3, 10000, 'Tier III · Sovereign Crown', '+3,000 Gold · +20K Mithril · +2,000 VIP'),
      ])
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(
              color: ctrl.kvkPoints >= req
                  ? MedievalPanelColors.goldBorder
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
                      '$title (${KingdomController.formatWithCommas(req)} Pts)',
                      style: const TextStyle(
                        color: MedievalPanelColors.goldBright,
                        fontFamily: 'serif',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reward,
                      style: const TextStyle(
                        color: MedievalPanelColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              medievalActionButton(
                compact: true,
                label: ctrl.kvkClaimedTiers.contains(tier)
                    ? 'Claimed'
                    : (ctrl.kvkPoints >= req ? 'Claim' : 'Locked'),
                onPressed:
                    !ctrl.kvkClaimedTiers.contains(tier) && ctrl.kvkPoints >= req
                    ? () => ctrl.claimKvkPrize(tier)
                    : null,
              ),
            ],
          ),
        ),
    ],
  );
}

Future<void> showMultiplayerLordsSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Live Lords · Kingdom #${controller.activeKingdomId}',
  subtitle: controller.multiplayerConnected
      ? 'Multiplayer Connected · Tap Scout or Attack'
      : 'Connecting to Multiplayer Server...',
  iconAsset: 'assets/ui/hud/navigation/world_map_icon.png',
  bodyBuilder: (sheetContext) => ListenableBuilder(
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '★ ${controller.playerName} (You)',
                        style: const TextStyle(
                          color: Color(0xff9eff8f),
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '[${controller.allianceTag}] ${controller.allianceName} · (${controller.playerCastles.first.x}, ${controller.playerCastles.first.y})',
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
                  label: 'Rename',
                  onPressed: () {
                    final nameCtrl = TextEditingController(
                      text: controller.playerName,
                    );
                    unawaited(
                      showDialog<void>(
                        context: context,
                        builder: (dlgCtx) => AlertDialog(
                          backgroundColor: MedievalPanelColors.cardDark,
                          title: const Text(
                            'Change Lord Name',
                            style: TextStyle(
                              color: MedievalPanelColors.goldBright,
                            ),
                          ),
                          content: TextField(
                            controller: nameCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Enter Lord Name',
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dlgCtx).pop(),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                controller.renamePlayer(nameCtrl.text);
                                Navigator.of(dlgCtx).pop();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Other Lords (${controller.remotePlayers.length})',
            style: const TextStyle(
              color: MedievalPanelColors.goldBright,
              fontFamily: 'serif',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (controller.remotePlayers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Waiting for other players to join this Kingdom...',
                style: TextStyle(color: MedievalPanelColors.mutedText),
              ),
            ),
          for (final remote in controller.remotePlayers)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MedievalPanelColors.cardDark,
                border: Border.all(
                  color: remote.online
                      ? const Color(0xff5b8c5a)
                      : const Color(0xff38414a),
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
                          '[${remote.allianceTag}] ${remote.playerName} · ${remote.online ? "Online" : "Offline"}',
                          style: const TextStyle(
                            color: MedievalPanelColors.goldBright,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Castle Lv.${remote.castleLevel} · (${remote.x}, ${remote.y}) · Power ${remote.power}',
                          style: const TextStyle(
                            color: MedievalPanelColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  medievalActionButton(
                    compact: true,
                    label: 'Scout',
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      controller.scoutRemotePlayer(remote);
                    },
                  ),
                  const SizedBox(width: 6),
                  medievalActionButton(
                    compact: true,
                    label: 'Attack',
                    onPressed: controller.energyCurrent >= 10
                        ? () {
                            Navigator.of(sheetContext).pop();
                            controller.attackRemotePlayer(remote);
                          }
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
