import 'package:flutter/material.dart';
import 'package:opencok/data/castle/castle_buildings/castle_buildings.dart';
import 'package:opencok/data/castle/city_slot_registry/city_slot_registry.dart';

class CityLayoutDebugOverlay extends StatelessWidget {
  const CityLayoutDebugOverlay({
    super.key,
    required this.camera,
    required this.viewport,
  });

  final TransformationController camera;
  final Size viewport;

  @override
  Widget build(BuildContext context) {
    final violations = CityLayoutValidatorHelper.validateAll();
    final violatedKeys = {
      for (final v in violations)
        if (v.buildingKey != null) v.buildingKey!,
    };

    return AnimatedBuilder(
      animation: camera,
      builder: (context, _) => IgnorePointer(
        child: CustomPaint(
          size: viewport,
          painter: _CityDebugPainter(
            camera: camera,
            violatedKeys: violatedKeys,
          ),
        ),
      ),
    );
  }
}

class CityLayoutValidatorHelper {
  static List<CityLayoutViolation> validateAll() =>
      CitySlotRegistry.validate(CastleBuildings.all);
}

class _CityDebugPainter extends CustomPainter {
  _CityDebugPainter({
    required this.camera,
    required this.violatedKeys,
  });

  final TransformationController camera;
  final Set<String> violatedKeys;

  @override
  void paint(Canvas canvas, Size size) {
    for (final slot in CitySlotRegistry.slots) {
      final topLeft = MatrixUtils.transformPoint(camera.value, slot.bounds.topLeft);
      final bottomRight = MatrixUtils.transformPoint(
        camera.value,
        slot.bounds.bottomRight,
      );
      final rect = Rect.fromPoints(topLeft, bottomRight);
      if (!rect.overlaps(Offset.zero & size)) continue;

      final isViolated = slot.validBuildingKeys.any(violatedKeys.contains);
      final color = isViolated ? Colors.redAccent : const Color(0xff4cd964);
      canvas.drawRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );

      final center = rect.center;
      canvas.drawCircle(center, 3.5, Paint()..color = color);

      final tp = TextPainter(
        text: TextSpan(
          text: '${slot.slotId} (L${slot.renderLayer})',
          style: TextStyle(
            color: color,
            fontSize: 9,
            backgroundColor: const Color(0xbb000000),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.left + 2, rect.top + 2));
    }

    for (var i = 0; i < CastleBuildings.emptyResourcePlots.length; i++) {
      final plot = CastleBuildings.emptyResourcePlots[i];
      final rect = Rect.fromPoints(
        MatrixUtils.transformPoint(camera.value, plot.topLeft),
        MatrixUtils.transformPoint(camera.value, plot.bottomRight),
      );
      if (!rect.overlaps(Offset.zero & size)) continue;
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.cyanAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CityDebugPainter oldDelegate) => true;
}
