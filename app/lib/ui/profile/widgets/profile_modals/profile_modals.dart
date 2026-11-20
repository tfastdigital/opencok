import 'package:flutter/material.dart';
import 'package:opencok/data/hud/kingdom_controller/kingdom_controller.dart';
import 'package:opencok/l10n/localization_context.dart';
import 'package:opencok/ui/castle/widgets/building_system_sheets/building_system_sheets.dart';
import 'package:opencok/ui/shared/medieval_panel/medieval_panel.dart';

Future<void> showRenameLordDialog(
  BuildContext context,
  KingdomController controller,
) async {
  final textController = TextEditingController(text: controller.playerName);
  final next = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: MedievalPanelColors.card,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: MedievalPanelColors.goldBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(
        context.l10n.rename,
        style: const TextStyle(
          color: MedievalPanelColors.goldBright,
          fontFamily: 'serif',
        ),
      ),
      content: TextField(
        controller: textController,
        autofocus: true,
        maxLength: 20,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Enter Lord name',
          hintStyle: const TextStyle(color: MedievalPanelColors.mutedText),
          filled: true,
          fillColor: MedievalPanelColors.cardDark,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff5e4f33)),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: MedievalPanelColors.goldBorder,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.close),
        ),
        medievalActionButton(
          compact: true,
          label: 'Confirm',
          onPressed: () =>
              Navigator.of(dialogContext).pop(textController.text.trim()),
        ),
      ],
    ),
  );
  textController.dispose();
  if (next != null && next.isNotEmpty) {
    controller.renamePlayer(next);
  }
}

Future<void> showEquipmentSlotSheet(
  BuildContext context,
  KingdomController controller,
  int slotIndex,
) {
  const catalog = <(String name, String bonus)>[
    ('Royal Longsword', '+8% Infantry Attack · +50,000 Power'),
    ('Knightly Greathelm', '+6% Cavalry Defense · +50,000 Power'),
    ('Dragonscale Cuirass', '+10% Troop Health · +50,000 Power'),
    ('Sovereign Gauntlets', '+7% Archer Attack · +50,000 Power'),
    ('Ironstride Greaves', '+12% March Speed · +50,000 Power'),
    ('Ring of Valor', '+8% Gathering Speed · +50,000 Power'),
  ];
  return showMedievalSheet<void>(
    context,
    title: 'Equipment Slot ${slotIndex + 1}',
    subtitle: 'Select forged gear to equip (+50,000 Power)',
    iconAsset: 'assets/ui/profile/empty_slot.png',
    bodyBuilder: (context) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final equipped = controller.equippedGear[slotIndex];
        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(14),
          itemCount: catalog.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final (name, bonus) = catalog[index];
            final isEquipped = equipped == name;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MedievalPanelColors.card,
                border: Border.all(
                  color: isEquipped
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
                          name,
                          style: const TextStyle(
                            color: MedievalPanelColors.goldBright,
                            fontFamily: 'serif',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bonus,
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
                    label: isEquipped ? 'Unequip' : 'Equip',
                    onPressed: () => controller.toggleEquipment(slotIndex, name),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

Future<void> showRankingSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.ranking,
  subtitle: 'Kingdom 1305 Lord Power Leaderboard',
  iconAsset: 'assets/ui/profile/ranking.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final entries = <(String name, String alliance, int power)>[
        ('LadySeraphina', 'COK', 412880120),
        ('★JUϟ★', 'COK', 388120400),
        (controller.playerName, 'COK', controller.power),
        ('LordVanguard', 'WAR', 261400330),
        ('SirAldric', 'COK', 215440900),
      ]..sort((a, b) => b.$3.compareTo(a.$3));

      return ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(14),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final (name, tag, power) = entries[index];
          final isMe = name == controller.playerName;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xff26343e)
                  : MedievalPanelColors.cardDark,
              border: Border.all(
                color: isMe
                    ? MedievalPanelColors.goldBorder
                    : const Color(0xff38414a),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: MedievalPanelColors.goldBright,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '[$tag] $name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  KingdomController.formatWithCommas(power),
                  style: const TextStyle(
                    color: MedievalPanelColors.goldText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  ),
);

Future<void> showAchievementsSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.achievements,
  subtitle: 'Lord Milestones & Gold Honors',
  iconAsset: 'assets/ui/profile/achievements.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(14),
      itemCount: controller.achievements.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final ach = controller.achievements[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(
              color: ach.claimable
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
                      ach.title,
                      style: const TextStyle(
                        color: MedievalPanelColors.goldBright,
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ach.description,
                      style: const TextStyle(
                        color: MedievalPanelColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reward: +${ach.goldReward} Gold',
                      style: const TextStyle(
                        color: MedievalPanelColors.goldText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              medievalActionButton(
                compact: true,
                label: ach.claimed
                    ? 'Claimed'
                    : ach.claimable
                    ? 'Claim'
                    : 'Locked',
                onPressed: ach.claimable
                    ? () => controller.claimAchievement(ach.id)
                    : null,
              ),
            ],
          ),
        );
      },
    ),
  ),
);

Future<void> showLordInformationSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.information,
  subtitle: 'Lord & Citadel Statistics',
  iconAsset: 'assets/ui/profile/scroll.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Padding(
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
            for (final (label, value) in [
              ('Lord Name', controller.playerName),
              ('Faction', '${controller.currentFaction.name} (${controller.currentFaction.bonus})'),
              ('Kingdom', '#${controller.activeKingdomId}'),
              ('Lord Level', 'Lv.${controller.level}'),
              ('VIP Status', 'SVIP ${controller.vipLevel}'),
              ('Total Power', KingdomController.formatWithCommas(controller.power)),
              ('Troops Trained', KingdomController.formatWithCommas(controller.troopsTrained)),
              ('Equipped Gear', '${controller.equippedGear.length} / 8 slots'),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  ),
);

Future<void> showSkillsSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.skills,
  subtitle: 'Allocate Lord Skill Points',
  iconAsset: 'assets/ui/profile/skills.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Skill Points: ${controller.skillPoints}',
                style: const TextStyle(
                  color: MedievalPanelColors.goldBright,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: controller.resetSkills,
                child: Text(context.l10n.reset),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(14),
            itemCount: controller.skills.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final skill = controller.skills[index];
              final canUpgrade =
                  controller.skillPoints > 0 && skill.level < skill.maxLevel;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MedievalPanelColors.card,
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
                            '${skill.name} (Lv.${skill.level}/${skill.maxLevel})',
                            style: const TextStyle(
                              color: MedievalPanelColors.goldBright,
                              fontFamily: 'serif',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${skill.branch} · ${skill.bonusPerLevel} per level',
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
                      label: '+1',
                      onPressed: canUpgrade
                          ? () => controller.upgradeSkill(skill.id)
                          : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);

Future<void> showResetSkillsDialog(
  BuildContext context,
  KingdomController controller,
) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    backgroundColor: MedievalPanelColors.card,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: MedievalPanelColors.goldBorder),
      borderRadius: BorderRadius.circular(8),
    ),
    title: Text(
      context.l10n.reset,
      style: const TextStyle(
        color: MedievalPanelColors.goldBright,
        fontFamily: 'serif',
      ),
    ),
    content: const Text(
      'Refund all allocated Lord Skill Points so you can redistribute them?',
      style: TextStyle(color: Colors.white),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(dialogContext).pop(),
        child: Text(context.l10n.close),
      ),
      medievalActionButton(
        compact: true,
        label: 'Reset Skills',
        onPressed: () {
          controller.resetSkills();
          Navigator.of(dialogContext).pop();
        },
      ),
    ],
  ),
);

Future<void> showSettingsSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.settings,
  subtitle: 'Audio & Kingdom Client Preferences',
  iconAsset: 'assets/ui/profile/settings.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            value: controller.musicEnabled,
            onChanged: controller.setMusicEnabled,
            activeThumbColor: MedievalPanelColors.goldBright,
            title: const Text(
              'Background Music',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Play medieval city and world map themes',
              style: TextStyle(color: MedievalPanelColors.mutedText, fontSize: 12),
            ),
          ),
          SwitchListTile(
            value: controller.sfxEnabled,
            onChanged: controller.setSfxEnabled,
            activeThumbColor: MedievalPanelColors.goldBright,
            title: const Text(
              'Interface Sound Effects',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Play confirmation chimes on button taps',
              style: TextStyle(color: MedievalPanelColors.mutedText, fontSize: 12),
            ),
          ),
          SwitchListTile(
            value: controller.highGraphics,
            onChanged: controller.setHighGraphics,
            activeThumbColor: MedievalPanelColors.goldBright,
            title: const Text(
              'High Graphics & Particles',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Water shimmer, clouds, and gold glint effects',
              style: TextStyle(color: MedievalPanelColors.mutedText, fontSize: 12),
            ),
          ),
          SwitchListTile(
            value: controller.marchAlerts,
            onChanged: controller.setMarchAlerts,
            activeThumbColor: MedievalPanelColors.goldBright,
            title: const Text(
              'March & Rally Notifications',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SwitchListTile(
            value: controller.allianceAlerts,
            onChanged: controller.setAllianceAlerts,
            activeThumbColor: MedievalPanelColors.goldBright,
            title: const Text(
              'Alliance Help & Gift Alerts',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SwitchListTile(
            value: controller.buildAlerts,
            onChanged: controller.setBuildAlerts,
            activeThumbColor: MedievalPanelColors.goldBright,
            title: const Text(
              'Construction & Training Alerts',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Divider(color: Color(0xff4c555e)),
          ListTile(
            title: const Text(
              'Language',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              controller.languageCode == 'pt' ? 'Português' : 'English',
              style: const TextStyle(color: MedievalPanelColors.goldText, fontSize: 12),
            ),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'pt', label: Text('PT')),
              ],
              selected: {controller.languageCode},
              onSelectionChanged: (values) =>
                  controller.setLanguageCode(values.first),
            ),
          ),
          ListTile(
            title: const Text(
              'Faction / Civilization',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${controller.currentFaction.name} · ${controller.currentFaction.bonus}',
              style: const TextStyle(color: MedievalPanelColors.goldText, fontSize: 12),
            ),
            trailing: medievalActionButton(
              compact: true,
              label: 'Switch',
              onPressed: () => showFactionSelectorSheet(context, controller),
            ),
          ),
          ListTile(
            title: const Text(
              'Dragon Cave',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${controller.activeDragon} · Lv.${controller.dragonLevel} · Bond ${controller.dragonBond}%',
              style: const TextStyle(color: MedievalPanelColors.goldText, fontSize: 12),
            ),
            trailing: medievalActionButton(
              compact: true,
              label: 'Open',
              onPressed: () => showDragonsSheet(context, controller),
            ),
          ),
          ListTile(
            title: const Text(
              'Account & Kingdom',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${controller.playerName} · Kingdom #${controller.activeKingdomId} · org.opencok.opencok',
              style: const TextStyle(color: MedievalPanelColors.goldText, fontSize: 12),
            ),
          ),
        ],
      ),
    ),
  ),
);

Future<void> showFactionSelectorSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: 'Select Faction / Civilization',
  subtitle: 'Choose your kingdom culture & combat bonuses',
  iconAsset: 'assets/ui/profile/ranking.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popularity: ${controller.popularityLabel}',
                style: const TextStyle(
                  color: MedievalPanelColors.goldBright,
                  fontWeight: FontWeight.w700,
                ),
              ),
              medievalActionButton(
                compact: true,
                label: 'Boost (10K Wood)',
                onPressed:
                    controller.civilizationPopularity < 5 &&
                        controller.wood >= 10000
                    ? controller.boostPopularity
                    : null,
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(14),
            itemCount: KingdomController.factions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final faction = KingdomController.factions[index];
              final selected = controller.factionId == faction.id;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MedievalPanelColors.card,
                  border: Border.all(
                    color: selected
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
                            faction.name,
                            style: const TextStyle(
                              color: MedievalPanelColors.goldBright,
                              fontFamily: 'serif',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            faction.bonus,
                            style: const TextStyle(
                              color: Color(0xff68d847),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            faction.description,
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
                      label: selected ? 'Active' : 'Select',
                      onPressed: selected
                          ? null
                          : () => controller.setFaction(faction.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);
