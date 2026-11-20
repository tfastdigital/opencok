import 'package:flutter_test/flutter_test.dart';
import 'package:opencok/data/castle/castle_buildings/castle_buildings.dart';
import 'package:opencok/data/castle/city_slot_registry/city_slot_registry.dart';

void main() {
  test('all city buildings map to valid non-overlapping slots with asset metadata', () {
    final violations = CitySlotRegistry.validate(CastleBuildings.all);
    expect(
      violations,
      isEmpty,
      reason: violations.map((v) => v.message).join('\n'),
    );

    for (final building in CastleBuildings.all) {
      expect(
        CitySlotRegistry.assetMetadata.containsKey(building.asset),
        isTrue,
        reason: 'Missing asset metadata for ${building.asset}',
      );
    }
  });
}
