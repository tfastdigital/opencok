import 'package:flutter/services.dart';
import 'package:opencok/data/hud/kingdom_controller/kingdom_controller.dart';
import 'package:opencok/domain/world_map/map_tile/map_tile.dart';
import 'package:opencok/domain/world_map/world_map_scene/world_map_scene.dart';
import 'package:opencok/generated/world.dart';

List<MapTile> worldObjectTiles(
  WorldMapScene scene,
  Iterable<MapRegionObjectsItem> objects, {
  int? playerCastleLevel,
  List<PlayerCastlePlot> extraCastles = const [],
  bool includeCenterThrone = false,
}) {
  final result = <MapTile>[];
  void addTile(
    int x,
    int y,
    int image,
    Offset offset, {
    int? level,
    Offset? levelOffset,
    Size? customSize,
  }) {
    final sprite = scene.images[image] ?? scene.images[1101];
    if (sprite == null) return;
    result.add(
      MapTile(
        image,
        WorldMapScene.positionForCell(x, y) + offset,
        size: customSize ?? Size(sprite.width.toDouble(), sprite.height.toDouble()),
        level: level == 0 ? null : level,
        levelOffset: levelOffset,
      ),
    );
  }

  (int image, Offset offset, Offset levelOffset, Size? size) castleVisual(
    int level,
  ) {
    if (level >= 30 && scene.images.containsKey(1106)) {
      return (
        1106,
        const Offset(-180, -240),
        const Offset(230, 255),
        const Size(360, 335),
      );
    }
    if (level >= 25 && scene.images.containsKey(1105)) {
      return (1105, const Offset(-176.5, -213), const Offset(225, 220), null);
    }
    if (level >= 19 && scene.images.containsKey(1104)) {
      return (1104, const Offset(-176.5, -213), const Offset(225, 220), null);
    }
    if (level >= 11 && scene.images.containsKey(1103)) {
      return (1103, const Offset(-176.5, -213), const Offset(225, 220), null);
    }
    if (level >= 6 && scene.images.containsKey(1102)) {
      return (1102, const Offset(-176.5, -213), const Offset(225, 220), null);
    }
    return (1101, const Offset(-176.5, -213), const Offset(225, 220), null);
  }

  final sorted = objects.toList()
    ..sort((a, b) {
      final depth = (a.x + a.y).compareTo(b.x + b.y);
      return depth == 0 ? a.id.compareTo(b.id) : depth;
    });
  for (final object in sorted) {
    switch (object.kind) {
      case 1:
        final displayLevel = (playerCastleLevel != null && object.level <= 1)
            ? playerCastleLevel
            : object.level;
        final (img, off, lvOff, sz) = castleVisual(displayLevel);
        addTile(
          object.x,
          object.y,
          img,
          off,
          level: displayLevel,
          levelOffset: lvOff,
          customSize: sz,
        );
      case 2:
        addTile(
          object.x,
          object.y,
          2017,
          const Offset(-128, -70),
          level: object.level,
          levelOffset: const Offset(160, 92),
        );
      case 3:
        addTile(
          object.x,
          object.y,
          2020,
          const Offset(-128, -70),
          level: object.level,
          levelOffset: const Offset(160, 92),
        );
    }
  }

  // Middle Kingdom Throne Palace (574, 566) — larger than normal castles, no level badge
  if (includeCenterThrone) {
    final throneSprite = scene.images.containsKey(1106)
        ? 1106
        : (scene.images.containsKey(1105) ? 1105 : 1101);
    addTile(
      574,
      566,
      throneSprite,
      const Offset(-270, -350),
      level: null,
      customSize: const Size(540, 500),
    );
    for (final (gx, gy, lv) in const [
      (566, 572, 28),
      (572, 575, 26),
      (565, 566, 25),
      (577, 572, 27),
    ]) {
      final (gImg, gOff, gLvOff, gSz) = castleVisual(lv);
      addTile(
        gx,
        gy,
        gImg,
        gOff,
        level: lv,
        levelOffset: gLvOff,
        customSize: gSz,
      );
    }
    for (final (rx, ry, img, lv) in const [
      (568, 568, 2017, 6),
      (572, 568, 2018, 6),
      (568, 574, 2019, 5),
      (574, 573, 2020, 5),
    ]) {
      addTile(
        rx,
        ry,
        img,
        const Offset(-128, -70),
        level: lv,
        levelOffset: const Offset(160, 92),
      );
    }
  }

  for (final castle in extraCastles) {
    final (cImg, cOff, cLvOff, cSz) = castleVisual(castle.level);
    addTile(
      castle.x,
      castle.y,
      cImg,
      cOff,
      level: castle.level,
      levelOffset: cLvOff,
      customSize: cSz,
    );
  }
  return result;
}
