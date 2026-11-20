import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencok/core/audio/background_music/background_music.dart';
import 'package:opencok/core/audio/music_track/music_track.dart';
import 'package:opencok/core/platform/platform_ui/platform_ui.dart';
import 'package:opencok/data/hud/kingdom_controller/kingdom_controller.dart';
import 'package:opencok/domain/castle/castle_building/castle_building.dart';
import 'package:opencok/domain/hud/hud_action/hud_action.dart';
import 'package:opencok/ui/castle/screens/castle_screen/castle_screen.dart';
import 'package:opencok/ui/castle/widgets/building_system_sheets/building_system_sheets.dart';
import 'package:opencok/ui/hud/widgets/game_hud/game_hud.dart';
import 'package:opencok/ui/hud/widgets/hud_panels/hud_navigation_panels.dart';
import 'package:opencok/ui/hud/widgets/hud_panels/hud_status_panels.dart';
import 'package:opencok/ui/profile/screens/player_profile_screen/player_profile_screen.dart';
import 'package:opencok/ui/world_map/widgets/world_map/world_map.dart';

class HudPreviewScreen extends StatefulWidget {
  const HudPreviewScreen({super.key});

  @override
  State<HudPreviewScreen> createState() => _HudPreviewScreenState();
}

class _HudPreviewScreenState extends State<HudPreviewScreen> {
  final _controller = KingdomController();
  bool _worldMap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(
      BackgroundMusic.of(context)
          .play(_worldMap ? MusicTrack.world : MusicTrack.city),
    );
  }

  void _onAction(HudAction action) {
    switch (action) {
      case HudAction.profile:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PlayerProfileScreen(
              data: _controller.hudData,
              playerName: _controller.playerName,
              controller: _controller,
            ),
          ),
        );
      case HudAction.map:
        setState(() => _worldMap = !_worldMap);
        unawaited(
          BackgroundMusic.of(context)
              .play(_worldMap ? MusicTrack.world : MusicTrack.city),
        );
      case HudAction.experience:
      case HudAction.energy:
        unawaited(showLordStatusSheet(context, _controller));
      case HudAction.vip:
        unawaited(showVipSheet(context, _controller));
      case HudAction.wood:
      case HudAction.food:
      case HudAction.iron:
      case HudAction.mithril:
        unawaited(showResourceDetailSheet(context, _controller, action));
      case HudAction.power:
        unawaited(showPowerBreakdownSheet(context, _controller));
      case HudAction.gold:
        unawaited(showGoldTreasurySheet(context, _controller));
      case HudAction.daily:
        unawaited(showDailyQuestsSheet(context, _controller));
      case HudAction.items:
        unawaited(showInventorySheet(context, _controller));
      case HudAction.mail:
        unawaited(showMailSheet(context, _controller));
      case HudAction.alliance:
        unawaited(showAllianceSheet(context, _controller));
      case HudAction.chat:
        unawaited(showChatSheet(context, _controller));
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid) {
      _controller.attachPersistencePath(
        '/data/user/0/org.opencok.opencok/files/kingdom_state.json',
      );
    }
    if (!usesMobileSystemUi) return;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.black,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    if (usesMobileSystemUi) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    super.dispose();
  }

  void _onCityBuildingAction(CastleBuilding building) {
    switch (building.nameKey) {
      case 'buildingCastle':
      case 'buildingHallOfWar':
        unawaited(showPowerBreakdownSheet(context, _controller));
      case 'buildingWalls':
        unawaited(showWallsSheet(context, _controller));
      case 'buildingDrillGrounds':
        unawaited(showDrillGroundsSheet(context, _controller));
      case 'buildingMilitaryTent':
        unawaited(showMilitaryTentSheet(context, _controller));
      case 'buildingWishingWell':
        unawaited(showWishingWellSheet(context, _controller));
      case 'buildingTavern':
        unawaited(showTavernSheet(context, _controller));
      case 'buildingTurret':
        unawaited(showTurretSheet(context, _controller));
      case 'buildingWatchtower':
        unawaited(showLordStatusSheet(context, _controller));
      case 'buildingHospital':
        unawaited(showHospitalHealSheet(context, _controller));
      case 'buildingAcademy':
        unawaited(showAcademyResearchSheet(context, _controller));
      case 'buildingMarket':
        unawaited(showGoldTreasurySheet(context, _controller));
      case 'buildingEmbassy':
        unawaited(showAllianceSheet(context, _controller));
      case 'buildingWarehouse':
      case 'buildingSawmill':
        unawaited(showResourceDetailSheet(context, _controller, HudAction.wood));
      case 'buildingFarm':
        unawaited(showResourceDetailSheet(context, _controller, HudAction.food));
      case 'buildingIronMine':
        unawaited(showResourceDetailSheet(context, _controller, HudAction.iron));
      case 'buildingMithrilMine':
        unawaited(
          showResourceDetailSheet(context, _controller, HudAction.mithril),
        );
      case 'buildingForge':
        unawaited(showCityBuildingsSheet(context, _controller));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: ClipRect(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Stack(
            children: [
              GameHud(
                data: _controller.hudData,
                onAction: _onAction,
                onWorldMap: _worldMap,
                child: _worldMap
                    ? WorldMap(
                        controller: _controller,
                        onEnterCity: () => setState(() => _worldMap = false),
                      )
                    : CastleScreen(
                        onCityBuildingAction: _onCityBuildingAction,
                        controller: _controller,
                      ),
              ),
              if (_worldMap)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 132,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton.icon(
                            onPressed: () => unawaited(
                              showKingdomWarSheet(context, _controller),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xe63b1f1b),
                              foregroundColor: const Color(0xffffe7ae),
                              side: const BorderSide(color: Color(0xffa68b53)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.flag_outlined, size: 17),
                            label: const Text('KvK War'),
                          ),
                          const SizedBox(width: 6),
                          FilledButton.icon(
                            onPressed: () => unawaited(
                              showMultiplayerLordsSheet(context, _controller),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xe61e3528),
                              foregroundColor: const Color(0xffb8ffad),
                              side: const BorderSide(color: Color(0xff6da665)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.people_outline, size: 17),
                            label: Text('Lords (${_controller.remotePlayers.length})'),
                          ),
                          const SizedBox(width: 6),
                          FilledButton.icon(
                            onPressed: () => unawaited(
                              showKingdomsAndCastlesSheet(context, _controller),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xe61b2732),
                              foregroundColor: const Color(0xffffe7ae),
                              side: const BorderSide(color: Color(0xffa68b53)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.public, size: 17),
                            label: Text('K#${_controller.activeKingdomId} · Castles'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
