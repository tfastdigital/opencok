import 'package:flutter/material.dart';

class MedievalPanelColors {
  static const backgroundTop = Color(0xf52e3029);
  static const backgroundBottom = Color(0xf5141d20);
  static const card = Color(0xff1b2732);
  static const cardDark = Color(0xff121922);
  static const goldBorder = Color(0xffa68b53);
  static const goldBright = Color(0xffffe7ae);
  static const goldText = Color(0xffd7c18a);
  static const mutedText = Color(0xffb5afa0);
  static const actionGreen = Color(0xff596944);
  static const actionText = Color(0xffffedbf);
}

Future<T?> showMedievalSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  String? iconAsset,
  required WidgetBuilder bodyBuilder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (sheetContext) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.84,
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MedievalPanelColors.backgroundTop,
                MedievalPanelColors.backgroundBottom,
              ],
            ),
            border: Border.all(
              color: MedievalPanelColors.goldBorder,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xff5e4f33)),
                  ),
                ),
                child: Row(
                  children: [
                    if (iconAsset != null) ...[
                      Image.asset(iconAsset, width: 28, height: 28),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: MedievalPanelColors.goldBright,
                              fontFamily: 'serif',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: MedievalPanelColors.mutedText,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: MedievalPanelColors.goldText,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(child: bodyBuilder(sheetContext)),
            ],
          ),
        ),
      ),
    ),
  ),
);

Widget medievalActionButton({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
  bool compact = false,
}) => FilledButton(
  onPressed: onPressed,
  style: FilledButton.styleFrom(
    backgroundColor: MedievalPanelColors.actionGreen,
    disabledBackgroundColor: const Color(0xff2c3329),
    foregroundColor: MedievalPanelColors.actionText,
    disabledForegroundColor: const Color(0xff787b70),
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 12 : 16,
      vertical: compact ? 8 : 12,
    ),
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: onPressed == null
            ? const Color(0xff4a493e)
            : MedievalPanelColors.goldBorder,
      ),
      borderRadius: BorderRadius.circular(4),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) ...[
        Icon(icon, size: compact ? 16 : 18),
        const SizedBox(width: 6),
      ],
      Text(
        label,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: compact ? 13 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
);
