import 'package:flutter/material.dart';
import 'package:opencok/data/hud/kingdom_controller/kingdom_controller.dart';
import 'package:opencok/l10n/localization_context.dart';
import 'package:opencok/ui/shared/medieval_panel/medieval_panel.dart';

Future<void> showDailyQuestsSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.daily,
  subtitle: 'Complete kingdom tasks to earn Gold & Resources',
  iconAsset: 'assets/ui/hud/navigation/daily_tasks_icon.png',
  bodyBuilder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(14),
      itemCount: controller.dailyQuests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final quest = controller.dailyQuests[index];
        final ratio = (quest.progress / quest.target).clamp(0.0, 1.0);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedievalPanelColors.card,
            border: Border.all(
              color: quest.claimable
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
                      quest.title,
                      style: const TextStyle(
                        color: MedievalPanelColors.goldBright,
                        fontFamily: 'serif',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      quest.description,
                      style: const TextStyle(
                        color: MedievalPanelColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: MedievalPanelColors.cardDark,
                        color: quest.completed
                            ? const Color(0xff68d847)
                            : const Color(0xff20d5f5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '+${quest.goldReward} Gold · +${KingdomController.formatCompact(quest.woodReward)} Wood · +${KingdomController.formatCompact(quest.foodReward)} Food',
                      style: const TextStyle(
                        color: MedievalPanelColors.goldText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              medievalActionButton(
                compact: true,
                label: quest.claimed
                    ? 'Claimed'
                    : quest.claimable
                    ? 'Claim'
                    : '${quest.progress}/${quest.target}',
                onPressed: quest.claimable
                    ? () => controller.claimDailyQuest(quest.id)
                    : null,
              ),
            ],
          ),
        );
      },
    ),
  ),
);

Future<void> showInventorySheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.items,
  subtitle: 'Tap Use to apply crates, boosts & chests',
  iconAsset: 'assets/ui/hud/navigation/inventory_icon.png',
  bodyBuilder: (context) => _InventoryBody(controller: controller),
);

class _InventoryBody extends StatefulWidget {
  const _InventoryBody({required this.controller});
  final KingdomController controller;

  @override
  State<_InventoryBody> createState() => _InventoryBodyState();
}

class _InventoryBodyState extends State<_InventoryBody> {
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    const categories = ['All', 'Resources', 'Boosts', 'Chests'];
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final items = widget.controller.inventory
            .where((i) => _category == 'All' || i.category == _category)
            .toList();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final cat in categories) ...[
                      ChoiceChip(
                        label: Text(cat),
                        selected: _category == cat,
                        onSelected: (_) => setState(() => _category = cat),
                        selectedColor: MedievalPanelColors.actionGreen,
                        backgroundColor: MedievalPanelColors.cardDark,
                        labelStyle: TextStyle(
                          color: _category == cat
                              ? MedievalPanelColors.goldBright
                              : MedievalPanelColors.mutedText,
                          fontSize: 12,
                        ),
                        side: const BorderSide(color: Color(0xff5e4f33)),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(14),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MedievalPanelColors.card,
                      border: Border.all(color: const Color(0xff4c555e)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: MedievalPanelColors.cardDark,
                            border: Border.all(
                              color: MedievalPanelColors.goldBorder,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Image.asset(item.iconAsset),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.name} (x${item.quantity})',
                                style: const TextStyle(
                                  color: MedievalPanelColors.goldBright,
                                  fontFamily: 'serif',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
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
                          label: item.quantity > 0 ? 'Use' : 'Empty',
                          onPressed: item.quantity > 0
                              ? () => widget.controller.useInventoryItem(item.id)
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> showMailSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.mail,
  subtitle: 'System notices, scout reports & alliance dispatches',
  iconAsset: 'assets/ui/hud/navigation/mail_icon.png',
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
                '${controller.mailCount} unread',
                style: const TextStyle(
                  color: MedievalPanelColors.goldText,
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: controller.mailCount > 0
                    ? controller.markAllMailRead
                    : null,
                child: const Text('Mark All Read'),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(14),
            itemCount: controller.mails.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final mail = controller.mails[index];
              return InkWell(
                onTap: () => controller.markMailRead(mail.id),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mail.read
                        ? MedievalPanelColors.cardDark
                        : MedievalPanelColors.card,
                    border: Border.all(
                      color: mail.read
                          ? const Color(0xff38414a)
                          : MedievalPanelColors.goldBorder,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff2c3742),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              mail.category,
                              style: const TextStyle(
                                color: MedievalPanelColors.goldText,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mail.subject,
                              style: TextStyle(
                                color: mail.read
                                    ? MedievalPanelColors.mutedText
                                    : MedievalPanelColors.goldBright,
                                fontFamily: 'serif',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            mail.timestamp,
                            style: const TextStyle(
                              color: MedievalPanelColors.mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mail.body,
                        style: const TextStyle(
                          color: Color(0xffcfd4d8),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      if (mail.goldAttachment > 0 ||
                          mail.woodAttachment > 0 ||
                          mail.foodAttachment > 0) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gift: +${mail.goldAttachment} Gold'
                              '${mail.woodAttachment > 0 ? ' · +${KingdomController.formatCompact(mail.woodAttachment)} Wood' : ''}',
                              style: const TextStyle(
                                color: MedievalPanelColors.goldText,
                                fontSize: 12,
                              ),
                            ),
                            medievalActionButton(
                              compact: true,
                              label: mail.attachmentClaimed
                                  ? 'Claimed'
                                  : 'Claim Gift',
                              onPressed: mail.hasUnclaimedAttachment
                                  ? () => controller.claimMailAttachment(mail.id)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);

Future<void> showAllianceSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.alliance,
  subtitle:
      '[${controller.allianceTag}] ${controller.allianceName} · Kingdom #${controller.activeKingdomId}',
  iconAsset: 'assets/ui/hud/navigation/alliance_icon.png',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${controller.allianceTag}] ${controller.allianceName}',
                  style: const TextStyle(
                    color: MedievalPanelColors.goldBright,
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tech Lv.${controller.allianceTechLevel} · Honor: ${KingdomController.formatWithCommas(controller.allianceHonor)} · Rank #1',
                  style: const TextStyle(
                    color: MedievalPanelColors.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    medievalActionButton(
                      compact: true,
                      label: controller.allianceHelpCount > 0
                          ? 'Help Allies (${controller.allianceHelpCount})'
                          : 'Allies Helped',
                      icon: Icons.handshake_outlined,
                      onPressed: controller.allianceHelpCount > 0
                          ? controller.sendAllianceHelp
                          : null,
                    ),
                    medievalActionButton(
                      compact: true,
                      label: 'Donate Tech (10K W/F)',
                      icon: Icons.science_outlined,
                      onPressed: controller.wood >= 10000 &&
                              controller.food >= 10000
                          ? controller.donateToAllianceTech
                          : null,
                    ),
                    medievalActionButton(
                      compact: true,
                      label: controller.allianceGiftClaimed
                          ? 'Gift Claimed'
                          : 'Claim Gift',
                      icon: Icons.card_giftcard_outlined,
                      onPressed: controller.allianceGiftClaimed
                          ? null
                          : controller.claimAllianceGift,
                    ),
                    medievalActionButton(
                      compact: true,
                      label: 'Create / Switch',
                      icon: Icons.edit_outlined,
                      onPressed: () =>
                          _showAllianceSwitchDialog(context, controller),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Alliance Officers & Online Members',
            style: TextStyle(
              color: MedievalPanelColors.goldText,
              fontFamily: 'serif',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          for (final (name, rank, power) in [
            (controller.playerName, 'R4 · Marshal', KingdomController.formatWithCommas(controller.power)),
            ('LadySeraphina', 'R5 · Leader', '412,880,120'),
            ('★JUϟ★', 'R4 · Strategist', '388,120,400'),
            ('SirAldric', 'R3 · Vanguard', '215,440,900'),
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: MedievalPanelColors.cardDark,
                border: Border.all(color: const Color(0xff38414a)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield,
                    color: MedievalPanelColors.goldBorder,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: MedievalPanelColors.goldBright,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          rank,
                          style: const TextStyle(
                            color: MedievalPanelColors.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    power,
                    style: const TextStyle(
                      color: MedievalPanelColors.goldText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  ),
);

Future<void> _showAllianceSwitchDialog(
  BuildContext context,
  KingdomController controller,
) async {
  final tagCtrl = TextEditingController(text: controller.allianceTag);
  final nameCtrl = TextEditingController(text: controller.allianceName);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: MedievalPanelColors.card,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: MedievalPanelColors.goldBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      title: const Text(
        'Create or Join Alliance',
        style: TextStyle(
          color: MedievalPanelColors.goldBright,
          fontFamily: 'serif',
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tagCtrl,
            maxLength: 4,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Alliance Tag (e.g. COK)',
              labelStyle: TextStyle(color: MedievalPanelColors.mutedText),
            ),
          ),
          TextField(
            controller: nameCtrl,
            maxLength: 24,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Alliance Name',
              labelStyle: TextStyle(color: MedievalPanelColors.mutedText),
            ),
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
          label: 'Save',
          onPressed: () {
            controller.setAlliance(tagCtrl.text, nameCtrl.text);
            Navigator.of(dialogContext).pop();
          },
        ),
      ],
    ),
  );
  tagCtrl.dispose();
  nameCtrl.dispose();
}

Future<void> showChatSheet(
  BuildContext context,
  KingdomController controller,
) => showMedievalSheet<void>(
  context,
  title: context.l10n.chat,
  subtitle: 'Kingdom 1305 & Alliance Channels',
  iconAsset: 'assets/ui/hud/chat/translate_icon.png',
  bodyBuilder: (context) => _ChatBody(controller: controller),
);

class _ChatBody extends StatefulWidget {
  const _ChatBody({required this.controller});
  final KingdomController controller;

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  String _channel = 'Kingdom';
  bool _translated = false;
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    widget.controller.sendChatMessage(_channel, text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final messages = widget.controller.chatMessages
          .where((m) => m.channel == _channel)
          .toList();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final ch in const ['Kingdom', 'Alliance']) ...[
                          ChoiceChip(
                            label: Text(ch),
                            selected: _channel == ch,
                            onSelected: (_) => setState(() => _channel = ch),
                            selectedColor: MedievalPanelColors.actionGreen,
                            backgroundColor: MedievalPanelColors.cardDark,
                            labelStyle: TextStyle(
                              color: _channel == ch
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
                TextButton.icon(
                  onPressed: () => setState(() => _translated = !_translated),
                  icon: Image.asset(
                    'assets/ui/hud/chat/translate_icon.png',
                    width: 18,
                  ),
                  label: Text(_translated ? 'Original' : 'Translate'),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(14),
              itemCount: messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: MedievalPanelColors.card,
                    border: Border.all(color: const Color(0xff3e4852)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff4a391e),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              msg.vipLabel,
                              style: const TextStyle(
                                color: MedievalPanelColors.goldBright,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              msg.sender,
                              style: const TextStyle(
                                color: MedievalPanelColors.goldText,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            msg.time,
                            style: const TextStyle(
                              color: MedievalPanelColors.mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _translated ? msg.translatedText : msg.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              14,
              6,
              14,
              12 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    onSubmitted: (_) => _send(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Message $_channel chat...',
                      hintStyle: const TextStyle(
                        color: MedievalPanelColors.mutedText,
                      ),
                      filled: true,
                      fillColor: MedievalPanelColors.cardDark,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                ),
                const SizedBox(width: 8),
                medievalActionButton(
                  label: 'Send',
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
