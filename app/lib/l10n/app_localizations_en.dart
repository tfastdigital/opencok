// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get close => 'Close';

  @override
  String get retry => 'Try again';

  @override
  String get ok => 'OK';

  @override
  String get daily => 'Daily';

  @override
  String get items => 'Items';

  @override
  String get mail => 'Mail';

  @override
  String get alliance => 'Alliance';

  @override
  String get chat => 'Chat';

  @override
  String get city => 'City';

  @override
  String get map => 'Map';

  @override
  String get mapInstructions => 'World map. Drag to explore and pinch to zoom.';

  @override
  String get profile => 'Profile';

  @override
  String get experienceShort => 'XP';

  @override
  String get experience => 'Experience';

  @override
  String get energy => 'Energy';

  @override
  String get vip => 'VIP';

  @override
  String get wood => 'Wood';

  @override
  String get food => 'Food';

  @override
  String get iron => 'Iron';

  @override
  String get mithril => 'Mithril';

  @override
  String get power => 'Power';

  @override
  String get gold => 'Gold';

  @override
  String get backToGame => 'Back to game';

  @override
  String get rename => 'Rename';

  @override
  String get ranking => 'Rankings';

  @override
  String get achievements => 'Achievements';

  @override
  String get information => 'Information';

  @override
  String get reset => 'Reset';

  @override
  String get skills => 'Talents';

  @override
  String get settings => 'Settings';

  @override
  String get castleInterior => 'Castle interior';

  @override
  String get castleLoadError => 'Could not load the castle interior.';

  @override
  String get mapLoadError => 'Could not load the map.';

  @override
  String get closeSelection => 'Close selection';

  @override
  String get trainTroops => 'Train troops';

  @override
  String get backToCastle => 'Back to castle';

  @override
  String get unitInformation => 'Unit information';

  @override
  String get combatRelation => 'Unit combat matchups';

  @override
  String get combatRelationButton => 'Unit combat\nmatchups';

  @override
  String get combatRelationDescription =>
      'Combat advantages depend on the kingdom rules.';

  @override
  String get attack => 'Attack';

  @override
  String get defense => 'Defense';

  @override
  String get health => 'HP';

  @override
  String get trainNow => 'Train now!';

  @override
  String get train => 'Train';

  @override
  String get trainingUnavailable => 'Training unavailable';

  @override
  String get trainingUnavailableDescription =>
      'Troop training is unavailable. No units were trained and no resources were spent.';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get trainingBonusHint =>
      'Use bonus items to increase training output!';

  @override
  String get trainingBonus => 'Training bonus';

  @override
  String get trainingBonusDescription =>
      'Bonus items will become available when the inventory is connected.';

  @override
  String get securityCompromised =>
      'The game cannot open on rooted or jailbroken devices.';

  @override
  String get securityPrivileged =>
      'Open the game using a standard account without root or administrator privileges.';

  @override
  String get securityDeveloperMode =>
      'Turn off developer options to open the game.';

  @override
  String get securityDebugger => 'Disconnect the debugger to open the game.';

  @override
  String get securityMobileBrowser => 'Use the app to play on a mobile device.';

  @override
  String get securityVerificationFailed =>
      'Could not verify device security. Try again.';

  @override
  String get verifyAgain => 'Verify again';

  @override
  String get castleInstructions =>
      'Castle interior. Drag to explore, pinch to zoom, and tap a building to select it.';

  @override
  String visualPreview(String label) {
    return '$label · preview';
  }

  @override
  String comingSoon(String label) {
    return '$label · coming soon';
  }

  @override
  String addResource(String label) {
    return 'Add $label';
  }

  @override
  String resourceValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String profileLevel(int level) {
    return 'Profile, level $level';
  }

  @override
  String emptyEquipmentSlot(int slot) {
    return 'Empty equipment slot $slot';
  }

  @override
  String unitLevel(String name, int level) {
    return '$name, level $level';
  }

  @override
  String unitDetails(String name, int level, int attack, int defense, int hp) {
    return '$name · level $level\nAttack: $attack\nDefense: $defense\nHP: $hp';
  }

  @override
  String ownedUnits(String count) {
    return 'Owned: $count';
  }

  @override
  String unitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units',
      one: '1 unit',
    );
    return '$_temp0';
  }

  @override
  String trainingCapacity(int capacity) {
    return 'Training capacity: $capacity';
  }

  @override
  String versionInfo(String client, String server) {
    return 'Client: v$client\nServer: v$server';
  }

  @override
  String trainingHeading(String culture, String building) {
    return '$culture · $building';
  }

  @override
  String get unitStandardInfantry1 => 'Militia';

  @override
  String get unitStandardInfantry2 => 'Infantry';

  @override
  String get unitStandardInfantry3 => 'Spearman';

  @override
  String get unitStandardInfantry4 => 'Infantry IV';

  @override
  String get unitStandardInfantry5 => 'Infantry V';

  @override
  String get unitStandardInfantry6 => 'Infantry VI';

  @override
  String get unitStandardInfantry7 => 'Infantry VII';

  @override
  String get unitStandardInfantry8 => 'Infantry VIII';

  @override
  String get unitStandardInfantry9 => 'Infantry IX';

  @override
  String get unitStandardInfantry10 => 'Infantry X';

  @override
  String get unitStandardCavalry1 => 'Horseman';

  @override
  String get unitStandardCavalry2 => 'Light Cavalry';

  @override
  String get unitStandardCavalry3 => 'Heavy Cavalry';

  @override
  String get unitStandardCavalry4 => 'Cavalry IV';

  @override
  String get unitStandardCavalry5 => 'Cavalry V';

  @override
  String get unitStandardCavalry6 => 'Cavalry VI';

  @override
  String get unitStandardCavalry7 => 'Cavalry VII';

  @override
  String get unitStandardCavalry8 => 'Cavalry VIII';

  @override
  String get unitStandardCavalry9 => 'Cavalry IX';

  @override
  String get unitStandardCavalry10 => 'Cavalry X';

  @override
  String get unitStandardArcher1 => 'Archer';

  @override
  String get unitStandardArcher2 => 'Crossbowman';

  @override
  String get unitStandardArcher3 => 'Longbowman';

  @override
  String get unitStandardArcher4 => 'Archer IV';

  @override
  String get unitStandardArcher5 => 'Archer V';

  @override
  String get unitStandardArcher6 => 'Archer VI';

  @override
  String get unitStandardArcher7 => 'Archer VII';

  @override
  String get unitStandardArcher8 => 'Archer VIII';

  @override
  String get unitStandardArcher9 => 'Archer IX';

  @override
  String get unitStandardArcher10 => 'Archer X';

  @override
  String get unitStandardSiege1 => 'Battering Ram';

  @override
  String get unitStandardSiege2 => 'Catapult';

  @override
  String get unitStandardSiege3 => 'Siege Tower';

  @override
  String get unitStandardSiege4 => 'Siege IV';

  @override
  String get unitStandardSiege5 => 'Siege V';

  @override
  String get unitStandardSiege6 => 'Siege VI';

  @override
  String get unitStandardSiege7 => 'Siege VII';

  @override
  String get unitStandardSiege8 => 'Siege VIII';

  @override
  String get unitStandardSiege9 => 'Siege IX';

  @override
  String get unitStandardSiege10 => 'Siege X';

  @override
  String get unitSlaughterCavalry => 'Slaughter Cavalry';

  @override
  String get unitRangerKnight => 'Ranger Knight';

  @override
  String get unitEliteInfantry1 => 'Sky Guardians';

  @override
  String get unitEliteInfantry2 => 'Oathbreaker Executioner';

  @override
  String get unitEliteInfantry3 => 'Icepiercer Guard';

  @override
  String get unitEliteInfantry4 => 'Frostplate Defender';

  @override
  String get unitEliteInfantry5 => 'Froststeel Shieldbearer';

  @override
  String get unitEliteInfantry6 => 'Froststeel Spearman';

  @override
  String get unitEliteInfantry7 => 'Frost Guardian';

  @override
  String get unitEliteInfantry8 => 'Frostwing Sentinel';

  @override
  String get unitEliteCavalry1 => 'Nightmare Rider';

  @override
  String get unitEliteCavalry2 => 'Radiant Guard';

  @override
  String get unitEliteCavalry3 => 'Spectral Frostwolf Rider';

  @override
  String get unitEliteCavalry4 => 'Elkbreaker Rider';

  @override
  String get unitEliteCavalry5 => 'Stampeding War Bull';

  @override
  String get unitEliteCavalry6 => 'Yeti Thrower';

  @override
  String get unitEliteCavalry7 => 'Griffin Vanguard';

  @override
  String get unitEliteCavalry8 => 'Sabertooth Rider';

  @override
  String get unitEliteArcher1 => 'Justice Hunter';

  @override
  String get unitEliteArcher2 => 'Black Raven Hunter';

  @override
  String get unitEliteArcher3 => 'Blackraven Marksman';

  @override
  String get unitEliteArcher4 => 'Grafted Undead Archer';

  @override
  String get unitEliteArcher5 => 'Void-Eye Undead Archer';

  @override
  String get unitEliteArcher6 => 'Raven Marksman';

  @override
  String get unitEliteArcher7 => 'Frenzied Undead Archer';

  @override
  String get unitEliteArcher8 => 'Bloodraven Reaper';

  @override
  String get unitEliteSiege1 => 'Divine Punisher';

  @override
  String get unitEliteSiege2 => 'Abyssal Brute';

  @override
  String get unitEliteSiege3 => 'Ironhorn Crusher';

  @override
  String get unitEliteSiege4 => 'Arcane Golem';

  @override
  String get unitEliteSiege5 => 'Voidflow Titan';

  @override
  String get unitEliteSiege6 => 'Splitstrike Annihilator';

  @override
  String get unitEliteSiege7 => 'Forsaken Archmage';

  @override
  String get unitEliteSiege8 => 'Cannonback Ravager';

  @override
  String get unitHighArcher11 => 'Furious Crossbowman';

  @override
  String get unitHighArcher12 => 'Shura Archer';

  @override
  String get unitHighCavalry12 => 'Pegasus Knight';

  @override
  String get unitHighSiege11 => 'Fearless Artillery';

  @override
  String get unitHighSiege12 => 'Phoenix Wings';

  @override
  String get unitHighInfantry11 => 'Voulge Spearman';

  @override
  String get unitHighInfantry12 => 'Savage Warrior';

  @override
  String get buildingSiegeWorkshop => 'Siege Workshop';

  @override
  String get buildingStable => 'Stable';

  @override
  String get buildingArcheryRange => 'Archery Range';

  @override
  String get buildingBarracks => 'Barracks';

  @override
  String get cultureSimple => 'Standard';

  @override
  String get cultureSimpleTitle => 'Basic units';

  @override
  String get cultureViking => 'Viking';

  @override
  String get cultureVikingTitle => 'Viking units';

  @override
  String get cultureJapanese => 'Japanese';

  @override
  String get cultureJapaneseTitle => 'Japanese units';

  @override
  String get cultureChinese => 'Chinese';

  @override
  String get cultureChineseTitle => 'Chinese units';

  @override
  String get culturePersian => 'Persian';

  @override
  String get culturePersianTitle => 'Persian units';

  @override
  String get cultureElite => 'Elite';

  @override
  String get cultureEliteTitle => 'Elite troops';

  @override
  String errorMessage(String error) {
    String _temp0 = intl.Intl.selectLogic(error, {
      'unexpected':
          'An unexpected error occurred. Close this message and try again.',
      'music': 'Could not play the game music.',
      'other':
          'An unexpected error occurred. Close this message and try again.',
    });
    return '$_temp0';
  }

  @override
  String get unitVikingInfantry => 'Viking Warrior';

  @override
  String get unitVikingCavalry => 'Viking Rider';

  @override
  String get unitVikingArcher => 'Viking Archer';

  @override
  String get unitVikingSiege => 'Viking Siege';

  @override
  String get unitJapaneseInfantry => 'Samurai';

  @override
  String get unitJapaneseCavalry => 'Japanese Rider';

  @override
  String get unitJapaneseArcher => 'Japanese Archer';

  @override
  String get unitJapaneseSiege => 'Japanese Siege';

  @override
  String get unitChineseInfantry => 'Chinese Warrior';

  @override
  String get unitChineseCavalry => 'Chinese Rider';

  @override
  String get unitChineseArcher => 'Chinese Archer';

  @override
  String get unitChineseSiege => 'Chinese Siege';

  @override
  String get unitPersianInfantry => 'Persian Warrior';

  @override
  String get unitPersianCavalry => 'Persian Rider';

  @override
  String get unitPersianArcher => 'Persian Archer';

  @override
  String get unitPersianSiege => 'Persian Siege';

  @override
  String get loading => 'Loading';

  @override
  String get connectingToServer => 'Connecting to server…';

  @override
  String get reconnectingToServer => 'Connection lost. Reconnecting…';
}
