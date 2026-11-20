import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opencok/data/hud/kingdom_controller/kingdom_controller.dart';

void main() {
  test('training troops, upgrading buildings, and building city plots update state', () {
    final controller = KingdomController();
    final initialPower = controller.power;
    final initialWood = controller.wood;
    final initialTroops = controller.troopsTrained;

    final trained = controller.trainTroopsWithCost(
      count: 100,
      woodCost: 5000,
      foodCost: 4000,
      ironCost: 1000,
      mithrilCost: 500,
    );
    expect(trained, isTrue);
    expect(controller.troopsTrained, initialTroops + 100);
    expect(controller.wood, initialWood - 5000);
    expect(controller.power, initialPower + 1200);

    final barracksLevel = controller.buildingLevel('buildingBarracks');
    final upgraded = controller.upgradeBuilding('buildingBarracks');
    expect(upgraded, isTrue);
    expect(controller.buildingLevel('buildingBarracks'), barracksLevel + 1);
    expect(controller.power, initialPower + 1200 + 15000);

    final built = controller.buildOrUpgradeCityConstructible('academy');
    expect(built, isTrue);
    expect(
      controller.cityBuildings.firstWhere((b) => b.id == 'academy').level,
      1,
    );

    controller.setAlliance('WAR', 'Iron Vanguard');
    expect(controller.allianceTag, 'WAR');
    expect(controller.donateToAllianceTech(), isTrue);
    expect(controller.allianceTechLevel, 9);

    controller.createKingdom(1308, 'Stormhold');
    expect(controller.activeKingdomId, 1308);
    expect(controller.buildWorldCastle('North Keep', 400, 420), isTrue);
    expect(controller.playerCastles.length, 2);

    expect(controller.repairWalls(), isTrue);
    expect(controller.wallDurability, 100);
    expect(controller.makeWish('Gold'), isNotNull);

    controller.rallyMiddleThrone();
    expect(controller.isKing, isTrue);
    controller.appointLord('Prime Minister', 'LadySeraphina');
    expect(controller.royalAppointments['Prime Minister'], 'LadySeraphina');
    controller.issueKingdomGift();
    expect(controller.royalGiftIssued, isTrue);
    expect(controller.kvkPoints, greaterThanOrEqualTo(6500));
    expect(controller.claimKvkPrize(1), isTrue);
    expect(controller.claimKvkPrize(2), isTrue);

    controller.setFaction('viking');
    expect(controller.currentFaction.name, 'Viking');

    var marchDone = false;
    controller.launchMarch(
      kind: 'attack',
      label: 'Attacking (600, 600)',
      fromX: 512,
      fromY: 512,
      toX: 600,
      toY: 600,
      onComplete: () => marchDone = true,
    );
    expect(controller.activeMarches.length, 1);
    controller.speedUpMarch(controller.activeMarches.first.id);
    expect(marchDone, isTrue);
    expect(controller.activeMarches, isEmpty);

    final tmpDir = Directory.systemTemp.createTempSync('opencok_state_test');
    addTearDown(() => tmpDir.deleteSync(recursive: true));
    final statePath = '${tmpDir.path}/kingdom_state.json';
    controller.attachPersistencePath(statePath);
    controller.renamePlayer('LordTester');

    final reloaded = KingdomController()..attachPersistencePath(statePath);
    expect(reloaded.playerName, 'LordTester');
    expect(reloaded.buildingLevel('buildingBarracks'), barracksLevel + 1);
  });
}
