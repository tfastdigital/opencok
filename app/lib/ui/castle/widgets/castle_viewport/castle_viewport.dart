import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:opencok/core/platform/platform_ui/platform_ui.dart';
import 'package:opencok/data/castle/castle_buildings/castle_buildings.dart';
import 'package:opencok/data/hud/kingdom_controller/kingdom_controller.dart';
import 'package:opencok/domain/castle/castle_building/castle_building.dart';
import 'package:opencok/domain/castle/castle_environment/castle_environment.dart';
import 'package:opencok/l10n/localization_context.dart';
import 'package:opencok/ui/castle/painters/castle_ambience_painter/castle_ambience_painter.dart';
import 'package:opencok/ui/castle/painters/castle_environment_painter/castle_environment_painter.dart';
import 'package:opencok/ui/castle/painters/castle_water_painter/castle_water_painter.dart';
import 'package:opencok/ui/castle/widgets/building_system_sheets/building_system_sheets.dart';
import 'package:opencok/ui/castle/widgets/castle_building_menu/castle_building_menu.dart';
import 'package:opencok/ui/castle/widgets/city_layout_debug_overlay/city_layout_debug_overlay.dart';
import 'package:opencok/ui/hud/widgets/hud_panels/hud_status_panels.dart';
import 'package:opencok/ui/shared/medieval_panel/medieval_panel.dart';
import 'package:opencok/ui/training/screens/training_screen/training_screen.dart';

class CastleViewport extends StatefulWidget {
  const CastleViewport({
    super.key,
    required this.environment,
    this.showTrainingActions = true,
    this.onCityBuildingAction,
    this.controller,
  });

  final CastleEnvironment environment;
  final bool showTrainingActions;
  final ValueChanged<CastleBuilding>? onCityBuildingAction;
  final KingdomController? controller;

  @override
  State<CastleViewport> createState() => _CastleViewportState();
}

class _CastleViewportState extends State<CastleViewport>
    with TickerProviderStateMixin {
  late final _ambience = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 120),
  );
  late final _cameraMotion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 440),
  );
  Matrix4Tween? _cameraTween;
  CastleBuilding? _selected;
  bool _showLayoutDebug = false;

  @override
  void initState() {
    super.initState();
    _camera.addListener(_constrainCamera);
    _cameraMotion.addListener(() {
      final tween = _cameraTween;
      if (tween != null) {
        _camera.value = tween.transform(
          Curves.easeOutCubic.transform(_cameraMotion.value),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ambience.stop();
    } else {
      _ambience.repeat();
    }
  }

  void _constrainCamera() {
    final viewport = _viewport;
    if (viewport == null) return;
    final scale = _camera.value.getMaxScaleOnAxis();
    final bounds = CastleEnvironment.playableBounds;
    final translation = _camera.value.getTranslation();
    final x = translation.x.clamp(
      viewport.width - bounds.right * scale,
      -bounds.left * scale,
    );
    final y = translation.y.clamp(
      viewport.height - bounds.bottom * scale,
      -bounds.top * scale,
    );
    if ((x - translation.x).abs() < 0.001 &&
        (y - translation.y).abs() < 0.001) {
      return;
    }
    _camera.value = _camera.value.clone()..setTranslationRaw(x, y, 0);
  }

  void _select(Offset position, Size viewport, double minimumScale) {
    CastleBuilding? selected;
    for (final building in CastleBuildings.all.reversed) {
      if (building.bounds.contains(position)) {
        selected = building;
        break;
      }
    }
    setState(() => _selected = selected);
    if (selected == null) {
      final ctrl = widget.controller;
      if (ctrl != null) {
        for (var i = 0; i < CastleBuildings.emptyResourcePlots.length; i++) {
          if (CastleBuildings.emptyResourcePlots[i].contains(position)) {
            unawaited(_openResourcePlotSheet(ctrl, i));
            return;
          }
        }
      }
      return;
    }
    final scale = math
        .max(
          _camera.value.getMaxScaleOnAxis(),
          math.max(minimumScale, viewport.height / 1500),
        )
        .clamp(0.0, 1.5);
    final focus = selected.bounds.center;
    final end = Matrix4.diagonal3Values(scale, scale, scale)
      ..setTranslationRaw(
        (viewport.width / 2 - focus.dx * scale).clamp(
          viewport.width - CastleEnvironment.size.width * scale,
          -CastleEnvironment.playableBounds.left * scale,
        ),
        (viewport.height * 0.43 - focus.dy * scale).clamp(
          viewport.height - CastleEnvironment.size.height * scale,
          0.0,
        ),
        0,
      );
    if (MediaQuery.disableAnimationsOf(context)) {
      _camera.value = end;
    } else {
      _cameraTween = Matrix4Tween(begin: _camera.value.clone(), end: end);
      _cameraMotion.forward(from: 0);
    }
  }

  Future<void> _openResourcePlotSheet(
    KingdomController controller,
    int plotIndex,
  ) => showMedievalSheet<void>(
    context,
    title: 'Resource Plot #${plotIndex + 1}',
    subtitle: 'Build or upgrade Farms, Sawmills, Iron & Mithril Mines',
    bodyBuilder: (sheetContext) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final builtType = controller.builtResourcePlots[plotIndex];
        if (builtType != null) {
          final lv = controller.builtResourcePlotLevels[plotIndex] ?? 1;
          final cost = (lv + 1) * 8000;
          return Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$builtType · Lv.$lv',
                  style: const TextStyle(
                    color: MedievalPanelColors.goldBright,
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                medievalActionButton(
                  label: 'Collect (+15,000)',
                  onPressed: () {
                    switch (builtType) {
                      case 'Farm':
                        controller.addResources(food: 15000);
                      case 'Sawmill':
                        controller.addResources(wood: 15000);
                      case 'Iron Mine':
                        controller.addResources(iron: 15000);
                      case 'Mithril Mine':
                        controller.addResources(mithril: 15000);
                    }
                    Navigator.of(sheetContext).pop();
                  },
                ),
                const SizedBox(height: 8),
                medievalActionButton(
                  label:
                      'Upgrade Lv.${lv + 1} (${KingdomController.formatCompact(cost)} W/F)',
                  onPressed: controller.wood >= cost && controller.food >= cost
                      ? () => controller.upgradeResourcePlot(plotIndex)
                      : null,
                ),
              ],
            ),
          );
        }
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(14),
          children: [
            for (final (type, asset, desc) in const [
              ('Farm', 'assets/world_map/buildings/resources/farm.png', 'Produces Food (+10K W/F)'),
              ('Sawmill', 'assets/world_map/buildings/resources/sawmill.png', 'Produces Wood (+10K W/F)'),
              ('Iron Mine', 'assets/world_map/buildings/resources/iron_mine.png', 'Produces Iron (+10K W/F)'),
              ('Mithril Mine', 'assets/world_map/buildings/resources/mithril_mine.png', 'Produces Mithril (+10K W/F)'),
            ])
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MedievalPanelColors.card,
                  border: Border.all(color: MedievalPanelColors.goldBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Image.asset(asset, width: 44, height: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type,
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
                      label: 'Build',
                      onPressed:
                          controller.wood >= 10000 && controller.food >= 10000
                          ? () => controller.buildOnResourcePlot(
                              plotIndex,
                              type,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    ),
  );

  final _camera = TransformationController();
  Size? _viewport;

  @override
  void dispose() {
    _cameraMotion.dispose();
    _ambience.dispose();
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final viewport = constraints.biggest;
      const size = CastleEnvironment.size;
      final minimumScale = math.max(
        math.max(
          viewport.width / CastleEnvironment.playableBounds.width,
          viewport.height / size.height,
        ),
        usesMobileSystemUi ? viewport.height / 1900 : 0.0,
      );
      if (_viewport != viewport) {
        final focus = _viewport == null
            ? const Offset(4160, 1340)
            : _camera.toScene(_viewport!.center(Offset.zero));
        final scale = math.max(
          minimumScale,
          _viewport == null
              ? viewport.height / (viewport.width < 600 ? 1500 : 1900)
              : _camera.value.getMaxScaleOnAxis(),
        );
        final x = (viewport.width / 2 - focus.dx * scale)
            .clamp(
              viewport.width - size.width * scale,
              -CastleEnvironment.playableBounds.left * scale,
            )
            .toDouble();
        final y = (viewport.height / 2 - focus.dy * scale)
            .clamp(viewport.height - size.height * scale, 0.0)
            .toDouble();

        _viewport = viewport;
        _camera.value = Matrix4.diagonal3Values(scale, scale, scale)
          ..setTranslationRaw(x, y, 0);
      }
      return Stack(
        children: [
          Semantics(
            label: context.l10n.castleInstructions,
            child: InteractiveViewer(
              transformationController: _camera,
              constrained: false,
              alignment: Alignment.topLeft,
              minScale: minimumScale,
              maxScale: math.max(1.5, minimumScale),
              onInteractionStart: (_) => _cameraMotion.stop(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) =>
                    _select(details.localPosition, viewport, minimumScale),
                child: SizedBox.fromSize(
                  size: size,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: CastleEnvironmentPainter(
                            widget.environment,
                            _camera,
                            viewport,
                            backdrop: true,
                          ),
                        ),
                      ),
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: CastleWaterPainter(
                            widget.environment,
                            _ambience,
                            _camera,
                            viewport,
                          ),
                        ),
                      ),
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: CastleEnvironmentPainter(
                            widget.environment,
                            _camera,
                            viewport,
                          ),
                        ),
                      ),
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: CastleAmbiencePainter(
                            widget.environment,
                            _ambience,
                            _camera,
                            viewport,
                            selected: _selected,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.controller case final controller?)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_camera, controller]),
                builder: (context, _) => IgnorePointer(
                  child: Stack(
                    children: [
                      for (final building in CastleBuildings.all)
                        () {
                          final point = MatrixUtils.transformPoint(
                            _camera.value,
                            Offset(
                              building.bounds.center.dx,
                              building.bounds.top + 36,
                            ),
                          );
                          if (point.dx < -30 ||
                              point.dx > viewport.width + 30 ||
                              point.dy < 70 ||
                              point.dy > viewport.height - 130) {
                            return const SizedBox.shrink();
                          }
                        final lv = controller.buildingLevel(building.nameKey);
                        return Positioned(
                          left: point.dx - 16,
                          top: point.dy - 12,
                          child: Container(
                            width: 32,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xee33362c), Color(0xee161d20)],
                              ),
                              border: Border.all(
                                color: const Color(0xffc7a66a),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '$lv',
                              style: const TextStyle(
                                color: Color(0xffffe7ae),
                                fontFamily: 'serif',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        );
                      }(),
                      for (var i = 0;
                          i < CastleBuildings.emptyResourcePlots.length;
                          i++)
                        () {
                          final rect = CastleBuildings.emptyResourcePlots[i];
                          final topLeft = MatrixUtils.transformPoint(
                            _camera.value,
                            rect.topLeft,
                          );
                          final bottomRight = MatrixUtils.transformPoint(
                            _camera.value,
                            rect.bottomRight,
                          );
                          if (bottomRight.dx < -30 ||
                              topLeft.dx > viewport.width + 30 ||
                              bottomRight.dy < 70 ||
                              topLeft.dy > viewport.height - 130) {
                            return const SizedBox.shrink();
                          }
                          final builtType = controller.builtResourcePlots[i];
                          final w = (bottomRight.dx - topLeft.dx).abs();
                          final h = (bottomRight.dy - topLeft.dy).abs();
                          final asset = switch (builtType) {
                            'Farm' =>
                              'assets/world_map/buildings/resources/farm.png',
                            'Sawmill' =>
                              'assets/world_map/buildings/resources/sawmill.png',
                            'Iron Mine' =>
                              'assets/world_map/buildings/resources/iron_mine.png',
                            'Mithril Mine' =>
                              'assets/world_map/buildings/resources/mithril_mine.png',
                            _ => null,
                          };
                          return Positioned(
                            left: topLeft.dx,
                            top: topLeft.dy,
                            width: w,
                            height: h,
                            child: asset != null
                                ? Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Image.asset(asset, fit: BoxFit.contain),
                                      Positioned(
                                        left: w / 2 - 14,
                                        top: -10,
                                        child: Container(
                                          width: 28,
                                          height: 20,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xee161d20),
                                            border: Border.all(
                                              color: const Color(0xffc7a66a),
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${controller.builtResourcePlotLevels[i] ?? 1}',
                                            style: const TextStyle(
                                              color: Color(0xffffe7ae),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xcc1b2732),
                                        border: Border.all(
                                          color: const Color(0xffa68b53),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '+ Build',
                                        style: TextStyle(
                                          color: Color(0xffffe7ae),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                          );
                        }(),
                    ],
                  ),
                ),
              ),
            ),
          if (!kReleaseMode && _showLayoutDebug)
            Positioned.fill(
              child: CityLayoutDebugOverlay(
                camera: _camera,
                viewport: viewport,
              ),
            ),
          if (!kReleaseMode)
            Positioned(
              left: 10,
              top: 124,
              child: FloatingActionButton.small(
                heroTag: 'city-layout-debug-toggle',
                backgroundColor: _showLayoutDebug
                    ? const Color(0xff596944)
                    : const Color(0xcc1b2732),
                foregroundColor: const Color(0xffffe7ae),
                onPressed: () =>
                    setState(() => _showLayoutDebug = !_showLayoutDebug),
                child: const Icon(Icons.grid_on, size: 18),
              ),
            ),
          if (_selected case final building?)
            AnimatedBuilder(
              animation: _camera,
              builder: (context, _) {
                final anchor = MatrixUtils.transformPoint(
                  _camera.value,
                  building.bounds.bottomCenter,
                );
                final width = math.min(280.0, viewport.width - 24);
                return Positioned(
                  left: (anchor.dx - width / 2).clamp(
                    12.0,
                    viewport.width - width - 12,
                  ),
                  top: (anchor.dy + 16).clamp(
                    130.0,
                    math.max(130.0, viewport.height - 280),
                  ),
                  width: width,
                  child: CastleBuildingMenu(
                    key: ValueKey(building.asset),
                    building: building,
                    level: widget.controller?.buildingLevel(building.nameKey),
                    upgradeLabel: widget.controller == null
                        ? null
                        : () {
                            final (w, f) = widget.controller!.upgradeCost(
                              building.nameKey,
                            );
                            return 'Upgrade (${KingdomController.formatCompact(w)}W · ${KingdomController.formatCompact(f)}F)';
                          }(),
                    onUpgrade: widget.controller == null
                        ? null
                        : () {
                            final ctrl = widget.controller!;
                            setState(() => _selected = null);
                            unawaited(
                              showUniversalUpgradeSheet(
                                context,
                                ctrl,
                                building,
                              ),
                            );
                          },
                    onDetails: widget.controller == null
                        ? null
                        : () {
                            final ctrl = widget.controller!;
                            setState(() => _selected = null);
                            unawaited(
                              showBuildingDetailsSheet(
                                context,
                                ctrl,
                                building,
                              ),
                            );
                          },
                    onSkins:
                        widget.controller != null &&
                            building.nameKey == 'buildingCastle'
                        ? () {
                            final ctrl = widget.controller!;
                            setState(() => _selected = null);
                            unawaited(showCastleSkinsSheet(context, ctrl));
                          }
                        : null,
                    onBuildCity:
                        widget.controller != null &&
                            building.nameKey == 'buildingCastle'
                        ? () {
                            setState(() => _selected = null);
                            unawaited(
                              showCityBuildingsSheet(
                                context,
                                widget.controller!,
                              ),
                            );
                          }
                        : null,
                    onClose: () => setState(() => _selected = null),
                    actionLabel: CastleBuildings.military.contains(building)
                        ? null
                        : 'Inspect',
                    onTrain: CastleBuildings.military.contains(building)
                        ? () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TrainingScreen(
                                building: building,
                                controller: widget.controller,
                              ),
                            ),
                          )
                        : () {
                            setState(() => _selected = null);
                            widget.onCityBuildingAction?.call(building);
                          },
                  ),
                );
              },
            ),
        ],
      );
    },
  );
}
