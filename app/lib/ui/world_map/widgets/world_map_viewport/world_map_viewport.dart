import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opencok/core/network/game_connection/game_connection.dart';
import 'package:opencok/data/hud/kingdom_controller/kingdom_controller.dart';
import 'package:opencok/data/world_map/world_object_tiles/world_object_tiles.dart';
import 'package:opencok/domain/world_map/map_tile/map_tile.dart';
import 'package:opencok/generated/world.dart';
import 'package:opencok/l10n/localization_context.dart';
import 'package:opencok/domain/world_map/world_map_scene/world_map_scene.dart';
import 'package:opencok/ui/hud/widgets/hud_panels/hud_status_panels.dart';
import 'package:opencok/ui/shared/medieval_panel/medieval_panel.dart';
import 'package:opencok/ui/world_map/painters/world_map_painter/world_map_painter.dart';

class WorldMapViewport extends StatefulWidget {
  const WorldMapViewport({
    super.key,
    required this.scene,
    this.connection,
    this.controller,
    this.onEnterCity,
  });
  final WorldMapScene scene;
  final GameConnection? connection;
  final KingdomController? controller;
  final VoidCallback? onEnterCity;

  @override
  State<WorldMapViewport> createState() => _WorldMapViewportState();
}

class _WorldMapViewportState extends State<WorldMapViewport> {
  final _camera = TransformationController();
  Size? _viewport;
  Timer? _queryTimer;
  int _generation = 0;
  String? _regionKey;
  bool _online = false;
  bool _queryError = false;
  List<MapTile> _objects = [];

  @override
  void initState() {
    super.initState();
    _camera.addListener(_scheduleQuery);
    widget.connection?.addListener(_connectionChanged);
    _online = widget.connection?.online ?? false;
  }

  @override
  void didUpdateWidget(WorldMapViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.connection != widget.connection ||
        oldWidget.scene != widget.scene) {
      oldWidget.connection?.removeListener(_connectionChanged);
      widget.connection?.addListener(_connectionChanged);
      _online = widget.connection?.online ?? false;
      _invalidate();
    }
  }

  void _invalidate() {
    ++_generation;
    _regionKey = null;
    _objects = [];
    _queryError = false;
    _scheduleQuery();
  }

  void _connectionChanged() {
    final online = widget.connection?.online ?? false;
    if (online == _online) return;
    _online = online;
    setState(_invalidate);
  }

  void _scheduleQuery() {
    _queryTimer?.cancel();
    ++_generation;
    _queryTimer = Timer(
      const Duration(milliseconds: 180),
      () => unawaited(_query()),
    );
  }

  Future<void> _query() async {
    final connection = widget.connection;
    final viewport = _viewport;
    if (connection == null || !connection.online || viewport == null) return;
    final corners = [
      Offset.zero,
      Offset(viewport.width, 0),
      Offset(0, viewport.height),
      viewport.bottomRight(Offset.zero),
    ].map((p) => WorldMapScene.cellAt(_camera.toScene(p))).toList();
    final minX = (corners.map((p) => p.dx).reduce(math.min).floor() - 4).clamp(
      1,
      1200,
    );
    final minY = (corners.map((p) => p.dy).reduce(math.min).floor() - 4).clamp(
      1,
      1200,
    );
    final maxX = (corners.map((p) => p.dx).reduce(math.max).ceil() + 4).clamp(
      1,
      1200,
    );
    final maxY = (corners.map((p) => p.dy).reduce(math.max).ceil() + 4).clamp(
      1,
      1200,
    );
    final key = '$minX,$minY,$maxX,$maxY';
    if (key == _regionKey && !_queryError) return;
    final generation = _generation;
    try {
      final objects = <int, MapRegionObjectsItem>{};
      var chunks = 0;
      for (var y = minY; y <= maxY; y += 64) {
        for (var x = minX; x <= maxX; x += 64) {
          if (chunks++ > 0) {
            await Future<void>.delayed(const Duration(milliseconds: 150));
          }
          if (!mounted || generation != _generation) return;
          final region = await connection.queryMap(
            minX: x,
            minY: y,
            maxX: math.min(x + 63, maxX),
            maxY: math.min(y + 63, maxY),
          );
          if (region.status != 0 ||
              region.kingdomId != 1 ||
              region.columns != 1200 ||
              region.rows != 1200) {
            throw const FormatException('Map unavailable');
          }
          for (final object in region.objects) {
            objects[object.id] = object;
          }
        }
      }
      if (!mounted || generation != _generation) return;
      setState(() {
        _objects = worldObjectTiles(
          widget.scene,
          objects.values,
          playerCastleLevel: widget.controller?.buildingLevel('buildingCastle'),
          extraCastles: widget.controller?.playerCastles ?? const [],
          includeCenterThrone: widget.controller != null,
        );
        _regionKey = key;
        _queryError = false;
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _queryError = true);
      }
    }
  }

  @override
  void dispose() {
    ++_generation;
    _queryTimer?.cancel();
    widget.connection?.removeListener(_connectionChanged);
    _camera.dispose();
    super.dispose();
  }

  void _onMapTap(Offset scenePoint) {
    final ctrl = widget.controller;
    if (ctrl == null) return;
    // Check remote players' castles first
    for (final remote in ctrl.remotePlayers) {
      final pos = WorldMapScene.positionForCell(remote.x, remote.y);
      if ((scenePoint - pos).distance <= 68) {
        unawaited(_showRemotePlayerSheet(ctrl, remote));
        return;
      }
    }
    final candidates = _objects.isNotEmpty ? _objects : widget.scene.objects;
    MapTile? hit;
    for (final tile in candidates.reversed) {
      final bounds = tile.position & tile.size;
      if (bounds.contains(scenePoint)) {
        hit = tile;
        break;
      }
    }
    if (hit == null) return;
    final cell = WorldMapScene.cellAt(hit.position + hit.size.center(Offset.zero));
    final cx = cell.dx.round().clamp(1, 1200);
    final cy = cell.dy.round().clamp(1, 1200);
    if ((cx - 574).abs() <= 4 && (cy - 566).abs() <= 4) {
      unawaited(showKingdomWarSheet(context, ctrl));
      return;
    }
    unawaited(_showWorldTileSheet(ctrl, hit, cx, cy));
  }

  Future<void> _showRemotePlayerSheet(
    KingdomController controller,
    RemotePlayer remote,
  ) => showMedievalSheet<void>(
    context,
    title: '[${remote.allianceTag}] ${remote.playerName}',
    subtitle:
        'Castle Lv.${remote.castleLevel} · (${remote.x}, ${remote.y}) · ${remote.online ? "Online" : "Offline"}',
    bodyBuilder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Power: ${remote.power} · Faction: ${remote.factionId}',
            style: const TextStyle(
              color: MedievalPanelColors.mutedText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          medievalActionButton(
            label: 'Scout ${remote.playerName}',
            icon: Icons.visibility_outlined,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              controller.scoutRemotePlayer(remote);
            },
          ),
          const SizedBox(height: 8),
          medievalActionButton(
            label: 'Attack ${remote.playerName} (-10 Energy)',
            icon: Icons.gavel_outlined,
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
  );

  Future<void> _showWorldTileSheet(
    KingdomController controller,
    MapTile tile,
    int cx,
    int cy,
  ) {
    final isCastle = tile.image >= 1101 && tile.image <= 1105;
    final (title, subtitle, resourceKey) = switch (tile.image) {
      >= 1101 && <= 1105 => (
        'Castle · Lv.${tile.level ?? controller.buildingLevel('buildingCastle')}',
        'Coordinates ($cx, $cy) · Kingdom #${controller.activeKingdomId}',
        'castle',
      ),
      2017 => (
        'Fertile Farm · Lv.${tile.level ?? 1}',
        'Coordinates ($cx, $cy) · Food Resource Tile',
        'food',
      ),
      2018 => (
        'Ancient Sawmill · Lv.${tile.level ?? 1}',
        'Coordinates ($cx, $cy) · Wood Resource Tile',
        'wood',
      ),
      2019 => (
        'Iron Deposit · Lv.${tile.level ?? 1}',
        'Coordinates ($cx, $cy) · Iron Resource Tile',
        'iron',
      ),
      2020 => (
        'Mithril Vein · Lv.${tile.level ?? 1}',
        'Coordinates ($cx, $cy) · Mithril Resource Tile',
        'mithril',
      ),
      _ => (
        'Kingdom Landmark',
        'Coordinates ($cx, $cy)',
        'wood',
      ),
    };

    return showMedievalSheet<void>(
      context,
      title: title,
      subtitle: subtitle,
      bodyBuilder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isCastle) ...[
              if (widget.onEnterCity != null) ...[
                medievalActionButton(
                  label: 'Enter City',
                  icon: Icons.castle_outlined,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    widget.onEnterCity?.call();
                  },
                ),
                const SizedBox(height: 8),
              ],
              medievalActionButton(
                label: 'Scout Castle',
                icon: Icons.visibility_outlined,
                onPressed: () {
                  final home = controller.playerCastles.first;
                  Navigator.of(sheetContext).pop();
                  controller.launchMarch(
                    kind: 'scout',
                    label: 'Scouting ($cx, $cy)',
                    fromX: home.x,
                    fromY: home.y,
                    toX: cx,
                    toY: cy,
                    duration: const Duration(seconds: 4),
                    onComplete: () {
                      controller.mails.insert(
                        0,
                        MailItem(
                          id: 'scout_${DateTime.now().millisecondsSinceEpoch}',
                          category: 'Reports',
                          sender: 'Outrider Captain',
                          subject: 'Scout Report ($cx, $cy)',
                          body:
                              'Castle garrisoned with 18,400 Infantry & Archers. Estimated loot: 25K Wood, 25K Food, 10K Iron, 250 Gold.',
                          timestamp: 'Now',
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              medievalActionButton(
                label: 'Attack Castle (-10 Energy)',
                icon: Icons.gavel_outlined,
                onPressed: controller.energyCurrent >= 10
                    ? () {
                        final home = controller.playerCastles.first;
                        controller.addEnergy(-0.085);
                        Navigator.of(sheetContext).pop();
                        controller.launchMarch(
                          kind: 'attack',
                          label: 'Attacking ($cx, $cy)',
                          fromX: home.x,
                          fromY: home.y,
                          toX: cx,
                          toY: cy,
                          duration: const Duration(seconds: 6),
                          onComplete: () {
                            controller.addResources(
                              wood: 25000,
                              food: 25000,
                              iron: 10000,
                              gold: 250,
                            );
                            controller.addExperience(0.05);
                            controller.mails.insert(
                              0,
                              MailItem(
                                id: 'battle_${DateTime.now().millisecondsSinceEpoch}',
                                category: 'Reports',
                                sender: 'Garrison Marshal',
                                subject: 'Victory at ($cx, $cy)!',
                                body:
                                    'Your ${controller.currentFaction.name} army breached the enemy defenses at ($cx, $cy) and returned with 25K Wood, 25K Food, 10K Iron, and 250 Gold.',
                                timestamp: 'Now',
                              ),
                            );
                          },
                        );
                      }
                    : null,
              ),
            ] else ...[
              medievalActionButton(
                label: 'March & Gather (+25K)',
                icon: Icons.agriculture_outlined,
                onPressed: () {
                  final home = controller.playerCastles.first;
                  Navigator.of(sheetContext).pop();
                  controller.launchMarch(
                    kind: 'gather',
                    label: 'Gathering ($cx, $cy)',
                    fromX: home.x,
                    fromY: home.y,
                    toX: cx,
                    toY: cy,
                    duration: const Duration(seconds: 5),
                    onComplete: () {
                      switch (resourceKey) {
                        case 'food':
                          controller.addResources(food: 25000);
                        case 'wood':
                          controller.addResources(wood: 25000);
                        case 'iron':
                          controller.addResources(iron: 15000);
                        case 'mithril':
                          controller.addResources(mithril: 10000);
                      }
                      controller.addExperience(0.03);
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final viewport = constraints.biggest;
      final scene = widget.scene;
      final minimumScale = math.max(
        0.35,
        math.max(
          viewport.width / scene.size.width,
          viewport.height / scene.size.height,
        ),
      );
      if (_viewport != viewport) {
        final focus = _viewport == null
            ? scene.focus
            : _camera.toScene(_viewport!.center(Offset.zero));
        final scale = math.max(
          minimumScale,
          _viewport == null ? 0.7 : _camera.value.getMaxScaleOnAxis(),
        );
        final x = (viewport.width / 2 - focus.dx * scale)
            .clamp(viewport.width - scene.size.width * scale, 0.0)
            .toDouble();
        final y = (viewport.height / 2 - focus.dy * scale)
            .clamp(viewport.height - scene.size.height * scale, 0.0)
            .toDouble();

        _camera.value = Matrix4.diagonal3Values(scale, scale, scale)
          ..setTranslationRaw(x, y, 0);
        _viewport = viewport;
        _scheduleQuery();
      }
      final map = Semantics(
        label: context.l10n.mapInstructions,
        child: RepaintBoundary(
          child: InteractiveViewer(
            transformationController: _camera,
            constrained: false,
            alignment: Alignment.topLeft,
            minScale: minimumScale,
            maxScale: math.max(1.5, minimumScale),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _onMapTap(details.localPosition),
              child: CustomPaint(
                size: scene.size,
                painter: WorldMapPainter(
                  scene,
                  _camera,
                  viewport,
                  objects: widget.connection == null ? null : _objects,
                ),
              ),
            ),
          ),
        ),
      );
      return Stack(
        children: [
          Positioned.fill(child: map),
          if (widget.controller case final controller?)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_camera, controller]),
                builder: (context, _) {
                  if (controller.activeMarches.isEmpty &&
                      controller.remotePlayers.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IgnorePointer(
                    child: CustomPaint(
                      size: viewport,
                      painter: _MarchOverlayPainter(
                        camera: _camera,
                        marches: controller.activeMarches,
                        remotePlayers: controller.remotePlayers,
                        selfName: controller.playerName,
                        selfCoords: controller.playerCastles.isNotEmpty
                            ? (
                                controller.playerCastles.first.x,
                                controller.playerCastles.first.y,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (widget.controller case final controller?)
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                if (controller.activeMarches.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  left: 12,
                  top: 126,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final march in controller.activeMarches)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xe6141d20),
                            border: Border.all(
                              color: const Color(0xffa68b53),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                march.kind == 'attack'
                                    ? Icons.gavel
                                    : march.kind == 'scout'
                                    ? Icons.visibility
                                    : Icons.agriculture,
                                color: const Color(0xffffe7ae),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${march.label} (${march.remainingSeconds}s)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => controller.speedUpMarch(march.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff596944),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Speed Up',
                                    style: TextStyle(
                                      color: Color(0xffffedbf),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
          if (_queryError)
            Positioned(
              left: 16,
              right: 16,
              bottom: 100,
              child: Material(
                color: const Color(0xdd101822),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(child: Text(context.l10n.mapLoadError)),
                      IconButton(
                        tooltip: context.l10n.retry,
                        onPressed: _scheduleQuery,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _MarchOverlayPainter extends CustomPainter {
  _MarchOverlayPainter({
    required this.camera,
    required this.marches,
    this.remotePlayers = const [],
    this.selfName = '',
    this.selfCoords,
  });

  final TransformationController camera;
  final List<ActiveMarch> marches;
  final List<RemotePlayer> remotePlayers;
  final String selfName;
  final (int, int)? selfCoords;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw self nameplate if remote players exist
    if (selfCoords != null && selfName.isNotEmpty) {
      final selfPos = MatrixUtils.transformPoint(
        camera.value,
        WorldMapScene.positionForCell(selfCoords!.$1, selfCoords!.$2),
      );
      final selfTag = TextPainter(
        text: TextSpan(
          text: '★ $selfName (You)',
          style: const TextStyle(
            color: Color(0xff9eff8f),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            backgroundColor: Color(0xcc101822),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      selfTag.paint(
        canvas,
        Offset(selfPos.dx - selfTag.width / 2, selfPos.dy + 22),
      );
    }

    // Draw remote players' castles & nameplates
    for (final remote in remotePlayers) {
      final pos = MatrixUtils.transformPoint(
        camera.value,
        WorldMapScene.positionForCell(remote.x, remote.y),
      );
      final castleColor = remote.online
          ? const Color(0xffe05a47)
          : const Color(0xff7f8c8d);
      final rect = Rect.fromCenter(center: pos, width: 34, height: 34);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = castleColor.withValues(alpha: 0.9),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = const Color(0xffffe7ae)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final castleIcon = TextPainter(
        text: TextSpan(
          text: 'Lv.${remote.castleLevel}',
          style: const TextStyle(
            color: Color(0xfffff3d1),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      castleIcon.paint(
        canvas,
        Offset(pos.dx - castleIcon.width / 2, pos.dy - castleIcon.height / 2),
      );

      final nameTag = TextPainter(
        text: TextSpan(
          text: '[${remote.allianceTag}] ${remote.playerName}',
          style: const TextStyle(
            color: Color(0xffffe7ae),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            backgroundColor: Color(0xd9141d20),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      nameTag.paint(
        canvas,
        Offset(pos.dx - nameTag.width / 2, pos.dy + 20),
      );
    }

    for (final march in marches) {
      final start = MatrixUtils.transformPoint(
        camera.value,
        WorldMapScene.positionForCell(march.fromX, march.fromY),
      );
      final end = MatrixUtils.transformPoint(
        camera.value,
        WorldMapScene.positionForCell(march.toX, march.toY),
      );
      final lineColor = switch (march.kind) {
        'attack' || 'rally' => Colors.redAccent,
        'scout' => Colors.lightBlueAccent,
        _ => const Color(0xff68d847),
      };

      final delta = end - start;
      final dist = delta.distance;
      if (dist > 4) {
        final dir = delta / dist;
        final perp = Offset(-dir.dy, dir.dx);
        // Dashed glowing march line
        for (double d = 0; d < dist; d += 18) {
          final segEnd = (d + 10).clamp(0.0, dist);
          canvas.drawLine(
            start + dir * d,
            start + dir * segEnd,
            Paint()
              ..color = lineColor.withValues(alpha: 0.85)
              ..strokeWidth = 3.5
              ..strokeCap = StrokeCap.round,
          );
        }
        // Directional chevron arrow halfway
        final mid = Offset.lerp(start, end, 0.5)!;
        final arrowPath = Path()
          ..moveTo(mid.dx + dir.dx * 8, mid.dy + dir.dy * 8)
          ..lineTo(
            mid.dx - dir.dx * 4 + perp.dx * 7,
            mid.dy - dir.dy * 4 + perp.dy * 7,
          )
          ..lineTo(
            mid.dx - dir.dx * 4 - perp.dx * 7,
            mid.dy - dir.dy * 4 - perp.dy * 7,
          )
          ..close();
        canvas.drawPath(arrowPath, Paint()..color = lineColor);

        // Moving 3-soldier army formation with banner
        final current = Offset.lerp(start, end, march.progress)!;
        final bob = math.sin(march.progress * math.pi * 16) * 2.5;
        final squadOffsets = [
          Offset(0, -8 + bob),
          Offset(-10, 6 - bob),
          Offset(10, 6 + bob),
        ];
        for (final so in squadOffsets) {
          final pos = current + so;
          canvas.drawCircle(
            pos + const Offset(0, 3),
            6.5,
            Paint()..color = Colors.black54,
          );
          canvas.drawCircle(pos, 6.5, Paint()..color = lineColor);
          canvas.drawCircle(
            pos,
            6.5,
            Paint()
              ..color = const Color(0xffffe7ae)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6,
          );
        }

        final label = TextPainter(
          text: TextSpan(
            text: '${march.label} · ${march.remainingSeconds}s',
            style: const TextStyle(
              color: Color(0xffffe7ae),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              backgroundColor: Color(0xcc141d20),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(
          canvas,
          Offset(current.dx - label.width / 2, current.dy - 28),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MarchOverlayPainter oldDelegate) => true;
}
