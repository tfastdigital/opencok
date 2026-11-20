import 'package:flutter/material.dart';
import 'package:opencok/domain/castle/castle_building/castle_building.dart';
import 'package:opencok/l10n/game_names.dart';
import 'package:opencok/l10n/localization_context.dart';

class CastleBuildingMenu extends StatelessWidget {
  const CastleBuildingMenu({
    super.key,
    required this.building,
    required this.onClose,
    required this.onTrain,
    this.actionLabel,
    this.level,
    this.upgradeLabel,
    this.onUpgrade,
    this.onDetails,
    this.onBuildCity,
    this.onSkins,
  });

  final CastleBuilding building;
  final VoidCallback onClose;
  final VoidCallback? onTrain;
  final String? actionLabel;
  final int? level;
  final String? upgradeLabel;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDetails;
  final VoidCallback? onBuildCity;
  final VoidCallback? onSkins;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(
      milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 180,
    ),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: child,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xf52e3029), Color(0xf5141d20)],
          ),
          border: Border.all(color: const Color(0xffa68b53)),
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 3, right: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      level == null
                          ? context.l10n.gameName(building.nameKey)
                          : '${context.l10n.gameName(building.nameKey)} · Lv.$level',
                      style: const TextStyle(
                        color: Color(0xffffe7ae),
                        fontFamily: 'serif',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    tooltip: context.l10n.closeSelection,
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xffc3b995),
                    ),
                  ),
                ],
              ),
            ),
            if (onTrain != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  0,
                  14,
                  (onUpgrade != null || onBuildCity != null) ? 8 : 14,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: onTrain,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff596944),
                      foregroundColor: const Color(0xffffedbf),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color(0xffb39a61)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    icon: const Icon(Icons.shield_outlined, size: 20),
                    label: Text(
                      actionLabel ?? context.l10n.trainTroops,
                      style: const TextStyle(fontFamily: 'serif', fontSize: 15),
                    ),
                  ),
                ),
              ),
            if (onUpgrade != null && upgradeLabel != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  0,
                  14,
                  onBuildCity != null ? 8 : 14,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onUpgrade,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xffffe7ae),
                      backgroundColor: const Color(0xff1b2732),
                      side: const BorderSide(color: Color(0xffa68b53)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_circle_up_outlined, size: 19),
                    label: Text(
                      upgradeLabel!,
                      style: const TextStyle(fontFamily: 'serif', fontSize: 13),
                    ),
                  ),
                ),
              ),
            if (onBuildCity != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  0,
                  14,
                  (onSkins != null || onDetails != null) ? 8 : 14,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onBuildCity,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xffffe7ae),
                      backgroundColor: const Color(0xff232a22),
                      side: const BorderSide(color: Color(0xffa68b53)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    icon: const Icon(Icons.account_balance_outlined, size: 19),
                    label: const Text(
                      'City & Build Plots',
                      style: TextStyle(fontFamily: 'serif', fontSize: 13),
                    ),
                  ),
                ),
              ),
            if (onSkins != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  0,
                  14,
                  onDetails != null ? 8 : 14,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onSkins,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xffffe7ae),
                      backgroundColor: const Color(0xff1b2732),
                      side: const BorderSide(color: Color(0xffa68b53)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                    label: const Text(
                      'Castle Skins',
                      style: TextStyle(fontFamily: 'serif', fontSize: 13),
                    ),
                  ),
                ),
              ),
            if (onDetails != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: onDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xffd7c18a),
                      side: const BorderSide(color: Color(0xff6b5d40)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    icon: const Icon(Icons.info_outline, size: 17),
                    label: const Text(
                      'Details',
                      style: TextStyle(fontFamily: 'serif', fontSize: 13),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
