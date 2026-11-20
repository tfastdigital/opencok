import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:opencok/data/hud/multiplayer_client/multiplayer_client.dart';
import 'package:opencok/data/hud/reference_hud_data/reference_hud_data.dart';
import 'package:opencok/domain/hud/hud_data/hud_data.dart';

class RemotePlayer {
  const RemotePlayer({
    required this.playerId,
    required this.playerName,
    required this.allianceTag,
    required this.allianceName,
    required this.castleLevel,
    required this.power,
    required this.factionId,
    required this.x,
    required this.y,
    required this.online,
  });

  final String playerId;
  final String playerName;
  final String allianceTag;
  final String allianceName;
  final int castleLevel;
  final int power;
  final String factionId;
  final int x;
  final int y;
  final bool online;

  factory RemotePlayer.fromJson(Map<String, dynamic> json) => RemotePlayer(
    playerId: (json['playerId'] as String?) ?? '',
    playerName: (json['playerName'] as String?) ?? 'Lord',
    allianceTag: (json['allianceTag'] as String?) ?? 'COK',
    allianceName: (json['allianceName'] as String?) ?? 'Crown Order',
    castleLevel: (json['castleLevel'] as int?) ?? 30,
    power: (json['power'] as int?) ?? 0,
    factionId: (json['factionId'] as String?) ?? 'dragon_born',
    x: (json['x'] as int?) ?? 570,
    y: (json['y'] as int?) ?? 570,
    online: (json['online'] as bool?) ?? false,
  );
}

class DailyQuestItem {
  DailyQuestItem({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.goldReward,
    required this.woodReward,
    required this.foodReward,
    this.claimed = false,
  });

  final String id;
  final String title;
  final String description;
  int progress;
  final int target;
  final int goldReward;
  final int woodReward;
  final int foodReward;
  bool claimed;

  bool get completed => progress >= target;
  bool get claimable => completed && !claimed;
}

class InventoryItem {
  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.iconAsset,
    required this.quantity,
    this.woodGain = 0,
    this.foodGain = 0,
    this.ironGain = 0,
    this.mithrilGain = 0,
    this.goldGain = 0,
    this.energyGain = 0,
    this.xpGain = 0,
    this.vipGain = 0,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String iconAsset;
  int quantity;
  final int woodGain;
  final int foodGain;
  final int ironGain;
  final int mithrilGain;
  final int goldGain;
  final double energyGain;
  final double xpGain;
  final int vipGain;
}

class MailItem {
  MailItem({
    required this.id,
    required this.category,
    required this.sender,
    required this.subject,
    required this.body,
    required this.timestamp,
    this.read = false,
    this.goldAttachment = 0,
    this.woodAttachment = 0,
    this.foodAttachment = 0,
    this.attachmentClaimed = false,
  });

  final String id;
  final String category;
  final String sender;
  final String subject;
  final String body;
  final String timestamp;
  bool read;
  final int goldAttachment;
  final int woodAttachment;
  final int foodAttachment;
  bool attachmentClaimed;

  bool get hasUnclaimedAttachment =>
      !attachmentClaimed &&
      (goldAttachment > 0 || woodAttachment > 0 || foodAttachment > 0);
}

class ChatMessageItem {
  const ChatMessageItem({
    required this.channel,
    required this.vipLabel,
    required this.sender,
    required this.text,
    required this.translatedText,
    required this.time,
  });

  final String channel;
  final String vipLabel;
  final String sender;
  final String text;
  final String translatedText;
  final String time;
}

class AchievementItem {
  AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.goldReward,
    this.claimed = false,
  });

  final String id;
  final String title;
  final String description;
  final int progress;
  final int target;
  final int goldReward;
  bool claimed;

  bool get claimable => progress >= target && !claimed;
}

class SkillNode {
  SkillNode({
    required this.id,
    required this.branch,
    required this.name,
    required this.bonusPerLevel,
    required this.level,
    required this.maxLevel,
  });

  final String id;
  final String branch;
  final String name;
  final String bonusPerLevel;
  int level;
  final int maxLevel;
}

class CityConstructible {
  CityConstructible({
    required this.id,
    required this.name,
    required this.bonus,
    required this.level,
    required this.maxLevel,
  });

  final String id;
  final String name;
  final String bonus;
  int level;
  final int maxLevel;
}

class KingdomInfo {
  KingdomInfo({
    required this.id,
    required this.name,
    required this.castlesCount,
  });

  final int id;
  final String name;
  int castlesCount;
}

class PlayerCastlePlot {
  const PlayerCastlePlot({
    required this.name,
    required this.kingdomId,
    required this.x,
    required this.y,
    required this.level,
  });

  final String name;
  final int kingdomId;
  final int x;
  final int y;
  final int level;
}

class FactionInfo {
  const FactionInfo({
    required this.id,
    required this.name,
    required this.bonus,
    required this.description,
  });

  final String id;
  final String name;
  final String bonus;
  final String description;
}

class ActiveMarch {
  ActiveMarch({
    required this.id,
    required this.kind,
    required this.label,
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.startedAt,
    required this.duration,
    required this.onComplete,
  });

  final String id;
  final String kind; // 'attack', 'scout', 'gather', 'rally'
  final String label;
  final int fromX;
  final int fromY;
  final int toX;
  final int toY;
  final DateTime startedAt;
  final Duration duration;
  final VoidCallback onComplete;
  bool completed = false;

  double get progress {
    final elapsed = DateTime.now().difference(startedAt).inMilliseconds;
    return (elapsed / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  int get remainingSeconds {
    final left =
        duration.inMilliseconds -
        DateTime.now().difference(startedAt).inMilliseconds;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }
}

class KingdomController extends ChangeNotifier {
  KingdomController() {
    _initDefaults();
  }

  String _playerName = 'OpenCoK';
  int _level = referenceHudData.level;
  double _experience = referenceHudData.experience;
  double _energy = referenceHudData.energy;
  int _vipLevel = 20;
  int _vipPoints = 184500;
  int _wood = 1900000;
  int _food = 1900000;
  int _iron = 736300;
  int _mithril = 551500;
  int _power = 295097198;
  int _gold = 979586;
  int _mailUnreadExtra = 89;
  int _skillPoints = 12;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  int _allianceHelpCount = 4;
  int _troopsTrained = 124500;

  final List<DailyQuestItem> dailyQuests = [];
  final List<InventoryItem> inventory = [];
  final List<MailItem> mails = [];
  final List<ChatMessageItem> chatMessages = [];
  final List<AchievementItem> achievements = [];
  final List<SkillNode> skills = [];
  final Map<int, String> equippedGear = {};
  final Map<String, int> buildingLevels = {
    'buildingCastle': 30,
    'buildingBarracks': 22,
    'buildingStable': 20,
    'buildingArcheryRange': 20,
    'buildingSiegeWorkshop': 18,
    'buildingWatchtower': 20,
    'buildingWall': 25,
    'buildingAcademy': 21,
    'buildingEmbassy': 19,
    'buildingHallOfWar': 18,
    'buildingWarehouse': 22,
    'buildingMarket': 17,
    'buildingForge': 18,
    'buildingHospital': 20,
    'buildingFarm': 18,
    'buildingSawmill': 18,
    'buildingIronMine': 16,
    'buildingMithrilMine': 14,
    'buildingWalls': 25,
    'buildingDrillGrounds': 20,
    'buildingMilitaryTent': 19,
    'buildingWishingWell': 16,
    'buildingTavern': 15,
    'buildingTurret': 20,
  };
  int _wallDurability = 85;
  int _wishesRemaining = 5;
  int _kvkPoints = 1500;
  int _kvkEnemyPoints = 1200;
  String _throneHolder = '[WAR] Iron Vanguard';
  String _kingName = 'LordVanguard';
  bool _royalGiftIssued = false;
  String _factionId = 'dragon_born';
  final Set<int> kvkClaimedTiers = {};
  final List<ActiveMarch> activeMarches = [];
  Timer? _marchTimer;
  File? _persistenceFile;
  String _playerId = '';
  final List<RemotePlayer> remotePlayers = [];
  MultiplayerClient? _mpClient;
  bool _multiplayerConnected = false;
  static const _multiplayerUrl = String.fromEnvironment('MULTIPLAYER_URL');

  String get playerId => _playerId;
  bool get multiplayerConnected => _multiplayerConnected;

  static const List<FactionInfo> factions = [
    FactionInfo(
      id: 'dragon_born',
      name: 'Dragon-born',
      bonus: 'T12 Pegasus Knight · Dragon Scartha',
      description: 'European dragon-crested citadels and elite crossbowmen/knights.',
    ),
    FactionInfo(
      id: 'viking',
      name: 'Viking',
      bonus: 'T12 Savage Warlord · Dragon Kraken',
      description: 'Fierce northern raiders with Slaughter Cavalry and Frost/Water fury.',
    ),
    FactionInfo(
      id: 'yamato',
      name: 'Yamato',
      bonus: 'T12 Shura Archer · Dragon Yukine',
      description: 'Swift ranged regiments, Fearless Artillery, and White Dragon.',
    ),
    FactionInfo(
      id: 'huaxia',
      name: 'Huaxia',
      bonus: 'T12 Phoenix Wings · Dragon Kylin',
      description: 'Imperial scholars, Voulgeman guards, and Auspicious Dragon Kylin.',
    ),
    FactionInfo(
      id: 'crescent',
      name: 'Crescent',
      bonus: 'T13 War Elephant (+20% HP) · Fire Dragon',
      description: 'Desert horsemen, Supreme War Elephants, and defensive mastery.',
    ),
  ];

  final Map<String, String> royalAppointments = {
    'Queen': 'Unassigned',
    'Prime Minister': 'Unassigned',
    'Judge': 'Unassigned',
    'Financial Officer': 'Unassigned',
    'Knight': 'Unassigned',
    'Guard Captain': 'Unassigned',
    'Scholar': 'Unassigned',
    'Blacksmith': 'Unassigned',
    'Maid': 'Unassigned',
    'Groom': 'Unassigned',
    'Clown': 'Unassigned',
    'Civilian': 'Unassigned',
    'Scout': 'Unassigned',
    'Bandit': 'Unassigned',
    'Criminal': 'Unassigned',
    'Fool': 'Unassigned',
  };

  static const Map<String, String> royalOfficeEffects = {
    'Queen': 'Resource Income +15%, Protection +20%',
    'Prime Minister': 'Build / Research / Train Speed +5%',
    'Judge': 'Resource Income +10%, Train Speed +5%',
    'Financial Officer': 'Resource Income +5%, Food -10%',
    'Knight': 'Troop Attack +5%, March Speed +10%',
    'Guard Captain': 'Troop Attack +5%, Defense +5%',
    'Scholar': 'Research Speed +10%',
    'Blacksmith': 'Build Speed +10%',
    'Maid': 'Debuff: Attack -10%, Income -5%',
    'Groom': 'Debuff: Income -5%, Food -10%',
    'Clown': 'Debuff: March -5%, Train -10%',
    'Civilian': 'Debuff: Defense -5%, Income -10%',
    'Scout': 'Debuff: Attack -8%, Defense -8%',
    'Bandit': 'Debuff: Resource Protection -20%',
    'Criminal': 'Debuff: March Speed -15%',
    'Fool': 'Debuff: Research Speed -15%',
  };

  int _dragonCampaignCampPoints = 420;
  int _dragonCampaignEnemyPoints = 380;
  int _crystals = 1200;
  int _civilizationPopularity = 2; // 0..5 (Hostile..Worship)
  String _activeDragon = 'Black Dragon';
  int _dragonLevel = 18;
  int _dragonBond = 85;
  final Map<String, int> heroLevels = {
    'Queen of War': 22,
    'Thorn Flower': 18,
    'Sanada Yukimura': 15,
    'Bernard': 12,
  };
  String _allianceTag = 'COK';
  String _allianceName = 'Knights of OpenCoK';
  int _allianceHonor = 12400;
  int _allianceTechLevel = 8;
  bool _allianceGiftClaimed = false;
  int _activeKingdomId = 1305;
  bool _highGraphics = true;
  bool _marchAlerts = true;
  bool _allianceAlerts = true;
  bool _buildAlerts = true;
  String _languageCode = 'en';

  final List<KingdomInfo> kingdoms = [
    KingdomInfo(id: 1305, name: 'Realm of Avalon', castlesCount: 184),
    KingdomInfo(id: 1306, name: 'Iron Crown', castlesCount: 92),
    KingdomInfo(id: 1307, name: 'Dragonspire', castlesCount: 41),
  ];

  final List<PlayerCastlePlot> playerCastles = [
    const PlayerCastlePlot(
      name: 'Main Citadel',
      kingdomId: 1305,
      x: 570,
      y: 570,
      level: 30,
    ),
  ];
  final List<CityConstructible> cityBuildings = [
    CityConstructible(
      id: 'academy',
      name: 'Academy',
      bonus: '+5% Research Speed per level',
      level: 0,
      maxLevel: 30,
    ),
    CityConstructible(
      id: 'embassy',
      name: 'Embassy',
      bonus: '+10,000 Alliance Reinforcement Cap per level',
      level: 0,
      maxLevel: 30,
    ),
    CityConstructible(
      id: 'hospital',
      name: 'Hospital',
      bonus: '+5,000 Wounded Capacity per level',
      level: 0,
      maxLevel: 30,
    ),
    CityConstructible(
      id: 'forge',
      name: 'Forge',
      bonus: '+4% Equipment Forging Speed per level',
      level: 0,
      maxLevel: 30,
    ),
    CityConstructible(
      id: 'warehouse',
      name: 'Warehouse',
      bonus: '+100,000 Protected Storage per level',
      level: 0,
      maxLevel: 30,
    ),
    CityConstructible(
      id: 'market',
      name: 'Market',
      bonus: '+5% Resource Trade Efficiency per level',
      level: 0,
      maxLevel: 30,
    ),
  ];

  void _initDefaults() {
    dailyQuests.addAll([
      DailyQuestItem(
        id: 'harvest',
        title: 'Gather Kingdom Resources',
        description: 'Collect Wood and Food from city production.',
        progress: 1,
        target: 1,
        goldReward: 200,
        woodReward: 25000,
        foodReward: 25000,
      ),
      DailyQuestItem(
        id: 'train',
        title: 'Reinforce the Garrison',
        description: 'Inspect or train troops in military barracks.',
        progress: 1,
        target: 1,
        goldReward: 350,
        woodReward: 15000,
        foodReward: 30000,
      ),
      DailyQuestItem(
        id: 'alliance_help',
        title: 'Stand With Allies',
        description: 'Assist alliance members or check alliance hall.',
        progress: 1,
        target: 1,
        goldReward: 250,
        woodReward: 20000,
        foodReward: 20000,
      ),
      DailyQuestItem(
        id: 'scout',
        title: 'Survey Kingdom 1305',
        description: 'Explore the World Map and locate nearby castles.',
        progress: 1,
        target: 3,
        goldReward: 500,
        woodReward: 50000,
        foodReward: 50000,
      ),
      DailyQuestItem(
        id: 'upgrade',
        title: 'Fortify the Citadel',
        description: 'Boost Lord power by training or using items.',
        progress: 0,
        target: 2,
        goldReward: 600,
        woodReward: 60000,
        foodReward: 60000,
      ),
    ]);

    inventory.addAll([
      InventoryItem(
        id: 'wood_crate',
        name: '50K Wood Crate',
        category: 'Resources',
        description: 'Adds 50,000 Wood directly to your city stockpile.',
        iconAsset: 'assets/ui/hud/resources/wood_icon.png',
        quantity: 6,
        woodGain: 50000,
      ),
      InventoryItem(
        id: 'food_crate',
        name: '50K Food Crate',
        category: 'Resources',
        description: 'Adds 50,000 Food directly to your city stockpile.',
        iconAsset: 'assets/ui/hud/resources/food_icon.png',
        quantity: 6,
        foodGain: 50000,
      ),
      InventoryItem(
        id: 'iron_crate',
        name: '20K Iron Crate',
        category: 'Resources',
        description: 'Adds 20,000 Iron directly to your city stockpile.',
        iconAsset: 'assets/ui/hud/resources/iron_icon.png',
        quantity: 4,
        ironGain: 20000,
      ),
      InventoryItem(
        id: 'mithril_crate',
        name: '10K Mithril Crate',
        category: 'Resources',
        description: 'Adds 10,000 Mithril directly to your city stockpile.',
        iconAsset: 'assets/ui/hud/resources/mithril_icon.png',
        quantity: 3,
        mithrilGain: 10000,
      ),
      InventoryItem(
        id: 'energy_potion',
        name: 'Lord Stamina Potion',
        category: 'Boosts',
        description: 'Restores 30 Lord Energy for marching and monster hunts.',
        iconAsset: 'assets/ui/profile/energy.png',
        quantity: 5,
        energyGain: 0.25,
      ),
      InventoryItem(
        id: 'xp_tome',
        name: '10% Lord XP Tome',
        category: 'Boosts',
        description: 'Grants 10% Lord Experience toward your next level.',
        iconAsset: 'assets/ui/profile/experience.png',
        quantity: 4,
        xpGain: 0.10,
      ),
      InventoryItem(
        id: 'vip_chest',
        name: 'SVIP Honor Chest',
        category: 'Chests',
        description: 'Grants +1,000 VIP Points and 500 Gold.',
        iconAsset: 'assets/ui/hud/resources/gold_coins_icon.png',
        quantity: 3,
        goldGain: 500,
        vipGain: 1000,
      ),
    ]);

    mails.addAll([
      MailItem(
        id: 'welcome',
        category: 'System',
        sender: 'Royal Steward',
        subject: 'Welcome to Kingdom 1305',
        body:
            'My Lord, your citadel stands ready. Collect your daily tribute below and inspect the garrisons to train new troops.',
        timestamp: 'Today 05:40',
        goldAttachment: 1000,
        woodAttachment: 50000,
        foodAttachment: 50000,
      ),
      MailItem(
        id: 'scout_1',
        category: 'Reports',
        sender: 'Outrider Captain',
        subject: 'Scout Report: Barbarian Encampment (412, 628)',
        body:
            'Scouts report light resistance at coordinates (412, 628). Estimated spoils: 45,000 Wood, 38,000 Food, and 12,000 Iron.',
        timestamp: 'Today 04:15',
      ),
      MailItem(
        id: 'alliance_notice',
        category: 'Alliance',
        sender: '[COK] Lord Commander',
        subject: 'Kingdom Rally & Territory Defense',
        body:
            'All Knights of OpenCoK: keep your city shields stocked and assist allies with construction and research helps.',
        timestamp: 'Yesterday',
        goldAttachment: 500,
      ),
      MailItem(
        id: 'battle_1',
        category: 'Reports',
        sender: 'Garrison Marshal',
        subject: 'Victory at Iron Mine Lv.6',
        body:
            'Your cavalry vanguard secured the Iron Mine with minimal losses. Troops returned with full cargo.',
        timestamp: 'Yesterday',
        read: true,
      ),
    ]);

    chatMessages.addAll([
      const ChatMessageItem(
        channel: 'Kingdom',
        vipLabel: 'SVIP 25',
        sender: '(1305) ★JUϟ★',
        text: '[Red Envelope]Tes…',
        translatedText: '[Red Envelope] Testing Kingdom 1305 alliance rally!',
        time: '05:58',
      ),
      const ChatMessageItem(
        channel: 'Kingdom',
        vipLabel: 'SVIP 18',
        sender: '(1305) SirAldric',
        text: 'Anyone running monster rallies near Throne?',
        translatedText: 'Anyone running monster rallies near Throne?',
        time: '05:59',
      ),
      const ChatMessageItem(
        channel: 'Alliance',
        vipLabel: 'SVIP 20',
        sender: 'LadySeraphina',
        text: 'Welcome new members! Tap Help to speed up builds.',
        translatedText: 'Welcome new members! Tap Help to speed up builds.',
        time: '05:50',
      ),
    ]);

    achievements.addAll([
      AchievementItem(
        id: 'power_100m',
        title: 'Sovereign of the Realm',
        description: 'Reach 100,000,000 Total Power.',
        progress: 295097198,
        target: 100000000,
        goldReward: 2000,
      ),
      AchievementItem(
        id: 'svip_10',
        title: 'Royal Patron',
        description: 'Achieve VIP Level 10 or higher.',
        progress: 20,
        target: 10,
        goldReward: 1500,
      ),
      AchievementItem(
        id: 'troops_100k',
        title: 'Iron Legion',
        description: 'Maintain 100,000 trained troops.',
        progress: 124500,
        target: 100000,
        goldReward: 1000,
        claimed: true,
      ),
    ]);

    skills.addAll([
      SkillNode(
        id: 'attack',
        branch: 'War',
        name: 'Infantry Attack',
        bonusPerLevel: '+3% Attack',
        level: 4,
        maxLevel: 10,
      ),
      SkillNode(
        id: 'march',
        branch: 'War',
        name: 'March Capacity',
        bonusPerLevel: '+2,000 Troops',
        level: 3,
        maxLevel: 10,
      ),
      SkillNode(
        id: 'construction',
        branch: 'Development',
        name: 'Construction Speed',
        bonusPerLevel: '+5% Speed',
        level: 5,
        maxLevel: 10,
      ),
      SkillNode(
        id: 'gathering',
        branch: 'Development',
        name: 'Resource Gathering',
        bonusPerLevel: '+6% Yield',
        level: 4,
        maxLevel: 10,
      ),
      SkillNode(
        id: 'stamina',
        branch: 'Support',
        name: 'Energy Recovery',
        bonusPerLevel: '+4% Recovery',
        level: 2,
        maxLevel: 10,
      ),
    ]);
  }

  String get playerName => _playerName;
  int get level => _level;
  double get experience => _experience;
  double get energy => _energy;
  int get energyCurrent => (_energy * 120).round();
  int get vipLevel => _vipLevel;
  int get vipPoints => _vipPoints;
  int get wood => _wood;
  int get food => _food;
  int get iron => _iron;
  int get mithril => _mithril;
  int get power => _power;
  int get gold => _gold;
  int get skillPoints => _skillPoints;
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  int get allianceHelpCount => _allianceHelpCount;
  int get troopsTrained => _troopsTrained;

  int get dailyCount => dailyQuests.where((q) => q.claimable).length;

  int get mailCount =>
      mails.where((m) => !m.read).length + _mailUnreadExtra;

  ChatMessageItem get latestChat => chatMessages.last;

  HudData get hudData => HudData(
    level: _level,
    experience: _experience,
    energy: _energy,
    vip: 'SVIP $_vipLevel',
    wood: formatCompact(_wood),
    food: formatCompact(_food),
    iron: formatCompact(_iron),
    mithril: formatCompact(_mithril),
    power: formatWithCommas(_power),
    gold: formatWithCommas(_gold),
    dailyCount: dailyCount,
    mailCount: mailCount,
    portrait: referenceHudData.portrait,
    chatVip: latestChat.vipLabel,
    chat: '${latestChat.sender}: ${latestChat.text}',
  );

  static String formatCompact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  static String formatWithCommas(int value) {
    final str = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      final remaining = str.length - i;
      if (i > 0 && remaining % 3 == 0) {
        buf.write(',');
      }
      buf.write(str[i]);
    }
    return buf.toString();
  }

  void renamePlayer(String nextName) {
    final trimmed = nextName.trim();
    if (trimmed.isEmpty) return;
    _playerName = trimmed;
    _sendPlayerProfile('profile_update');
    notifyListeners();
  }

  void addExperience(double amount) {
    _experience += amount;
    while (_experience >= 1.0) {
      _experience -= 1.0;
      _level += 1;
      _skillPoints += 2;
      _power += 25000;
    }
    notifyListeners();
  }

  void addEnergy(double amount) {
    _energy = (_energy + amount).clamp(0.0, 1.0);
    notifyListeners();
  }

  void addResources({
    int wood = 0,
    int food = 0,
    int iron = 0,
    int mithril = 0,
    int gold = 0,
  }) {
    _wood += wood;
    _food += food;
    _iron += iron;
    _mithril += mithril;
    _gold += gold;
    notifyListeners();
  }

  void addVipPoints(int points) {
    _vipPoints += points;
    while (_vipPoints >= (_vipLevel + 1) * 10000) {
      _vipLevel += 1;
    }
    notifyListeners();
  }

  void claimDailyQuest(String id) {
    final quest = dailyQuests.firstWhere((q) => q.id == id);
    if (!quest.claimable) return;
    quest.claimed = true;
    _gold += quest.goldReward;
    _wood += quest.woodReward;
    _food += quest.foodReward;
    addExperience(0.05);
  }

  void useInventoryItem(String id) {
    final item = inventory.firstWhere((i) => i.id == id);
    if (item.quantity <= 0) return;
    item.quantity -= 1;
    _wood += item.woodGain;
    _food += item.foodGain;
    _iron += item.ironGain;
    _mithril += item.mithrilGain;
    _gold += item.goldGain;
    if (item.energyGain > 0) {
      _energy = (_energy + item.energyGain).clamp(0.0, 1.0);
    }
    if (item.vipGain > 0) {
      addVipPoints(item.vipGain);
    }
    if (item.xpGain > 0) {
      addExperience(item.xpGain);
    } else {
      notifyListeners();
    }
  }

  void markMailRead(String id) {
    final mail = mails.firstWhere((m) => m.id == id);
    if (mail.read) return;
    mail.read = true;
    notifyListeners();
  }

  void markAllMailRead() {
    for (final mail in mails) {
      mail.read = true;
    }
    _mailUnreadExtra = 0;
    notifyListeners();
  }

  void claimMailAttachment(String id) {
    final mail = mails.firstWhere((m) => m.id == id);
    if (!mail.hasUnclaimedAttachment) return;
    mail.attachmentClaimed = true;
    mail.read = true;
    _gold += mail.goldAttachment;
    _wood += mail.woodAttachment;
    _food += mail.foodAttachment;
    notifyListeners();
  }

  void sendChatMessage(String channel, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    chatMessages.add(
      ChatMessageItem(
        channel: channel,
        vipLabel: 'SVIP $_vipLevel',
        sender: _playerName,
        text: trimmed,
        translatedText: trimmed,
        time: 'Now',
      ),
    );
    _mpClient?.send({
      'type': 'send_chat',
      'channel': channel,
      'senderId': _playerId,
      'sender': _playerName,
      'allianceTag': _allianceTag,
      'text': trimmed,
    });
    notifyListeners();
  }

  void sendAllianceHelp() {
    if (_allianceHelpCount <= 0) return;
    _allianceHelpCount = 0;
    _gold += 100;
    _power += 5000;
    notifyListeners();
  }

  bool exchangeGoldForPack(int goldCost, {int wood = 0, int food = 0, int iron = 0, int mithril = 0}) {
    if (_gold < goldCost) return false;
    _gold -= goldCost;
    _wood += wood;
    _food += food;
    _iron += iron;
    _mithril += mithril;
    notifyListeners();
    return true;
  }

  void claimAchievement(String id) {
    final ach = achievements.firstWhere((a) => a.id == id);
    if (!ach.claimable) return;
    ach.claimed = true;
    _gold += ach.goldReward;
    notifyListeners();
  }

  void upgradeSkill(String id) {
    if (_skillPoints <= 0) return;
    final skill = skills.firstWhere((s) => s.id == id);
    if (skill.level >= skill.maxLevel) return;
    skill.level += 1;
    _skillPoints -= 1;
    _power += 15000;
    notifyListeners();
  }

  void resetSkills() {
    var refunded = 0;
    for (final skill in skills) {
      refunded += skill.level;
      skill.level = 0;
    }
    _skillPoints += refunded;
    _power = (_power - refunded * 15000).clamp(1000000, 999999999);
    notifyListeners();
  }

  void toggleEquipment(int slotIndex, String itemName) {
    if (equippedGear[slotIndex] == itemName) {
      equippedGear.remove(slotIndex);
      _power -= 50000;
    } else {
      final wasEmpty = !equippedGear.containsKey(slotIndex);
      equippedGear[slotIndex] = itemName;
      if (wasEmpty) {
        _power += 50000;
      }
    }
    notifyListeners();
  }

  void trainTroops(int count, {int powerPerUnit = 12}) {
    _troopsTrained += count;
    _power += count * powerPerUnit;
    notifyListeners();
  }

  bool trainTroopsWithCost({
    required int count,
    required int woodCost,
    required int foodCost,
    required int ironCost,
    required int mithrilCost,
    int goldCost = 0,
    int powerPerUnit = 12,
  }) {
    if (goldCost > 0) {
      if (_gold < goldCost) return false;
      _gold -= goldCost;
    } else {
      if (_wood < woodCost ||
          _food < foodCost ||
          _iron < ironCost ||
          _mithril < mithrilCost) {
        return false;
      }
      _wood -= woodCost;
      _food -= foodCost;
      _iron -= ironCost;
      _mithril -= mithrilCost;
    }
    _troopsTrained += count;
    _power += count * powerPerUnit;
    notifyListeners();
    return true;
  }

  int buildingLevel(String key) => buildingLevels[key] ?? 1;

  (int wood, int food) upgradeCost(String key) {
    final nextLevel = buildingLevel(key) + 1;
    return (nextLevel * 12000, nextLevel * 10000);
  }

  bool upgradeBuilding(String key) {
    final (woodCost, foodCost) = upgradeCost(key);
    if (_wood < woodCost || _food < foodCost) return false;
    _wood -= woodCost;
    _food -= foodCost;
    buildingLevels[key] = buildingLevel(key) + 1;
    _power += 15000;
    notifyListeners();
    return true;
  }

  bool buildOrUpgradeCityConstructible(String id) {
    final item = cityBuildings.firstWhere((b) => b.id == id);
    if (item.level >= item.maxLevel) return false;
    final nextLevel = item.level + 1;
    final woodCost = nextLevel * 15000;
    final foodCost = nextLevel * 12000;
    if (_wood < woodCost || _food < foodCost) return false;
    _wood -= woodCost;
    _food -= foodCost;
    item.level = nextLevel;
    _power += 8000;
    notifyListeners();
    return true;
  }

  void setMusicEnabled(bool value) {
    _musicEnabled = value;
    notifyListeners();
  }

  void setSfxEnabled(bool value) {
    _sfxEnabled = value;
    notifyListeners();
  }

  String get allianceTag => _allianceTag;
  String get allianceName => _allianceName;
  int get allianceHonor => _allianceHonor;
  int get allianceTechLevel => _allianceTechLevel;
  bool get allianceGiftClaimed => _allianceGiftClaimed;
  int get activeKingdomId => _activeKingdomId;
  bool get highGraphics => _highGraphics;
  bool get marchAlerts => _marchAlerts;
  bool get allianceAlerts => _allianceAlerts;
  bool get buildAlerts => _buildAlerts;
  String get languageCode => _languageCode;

  void setHighGraphics(bool value) {
    _highGraphics = value;
    notifyListeners();
  }

  void setMarchAlerts(bool value) {
    _marchAlerts = value;
    notifyListeners();
  }

  void setAllianceAlerts(bool value) {
    _allianceAlerts = value;
    notifyListeners();
  }

  void setBuildAlerts(bool value) {
    _buildAlerts = value;
    notifyListeners();
  }

  void setLanguageCode(String code) {
    _languageCode = code;
    notifyListeners();
  }

  void setAlliance(String tag, String name) {
    final cleanTag = tag.trim().toUpperCase();
    final cleanName = name.trim();
    if (cleanTag.isEmpty || cleanName.isEmpty) return;
    _allianceTag = cleanTag;
    _allianceName = cleanName;
    notifyListeners();
  }

  bool donateToAllianceTech() {
    if (_wood < 10000 || _food < 10000) return false;
    _wood -= 10000;
    _food -= 10000;
    _allianceHonor += 500;
    _allianceTechLevel += 1;
    _power += 5000;
    notifyListeners();
    return true;
  }

  void claimAllianceGift() {
    if (_allianceGiftClaimed) return;
    _allianceGiftClaimed = true;
    _gold += 300;
    _wood += 25000;
    _food += 25000;
    notifyListeners();
  }

  int get homeKingdomId => 1305;
  bool get isViewingForeignKingdom => _activeKingdomId != homeKingdomId;
  String get activeKingdomName => kingdoms
      .firstWhere(
        (k) => k.id == _activeKingdomId,
        orElse: () => KingdomInfo(
          id: _activeKingdomId,
          name: 'Kingdom #$_activeKingdomId',
          castlesCount: 1,
        ),
      )
      .name;

  static const Map<int, List<RemotePlayer>> _foreignKingdomCastles = {
    1306: [
      RemotePlayer(
        playerId: 'npc_1306_king',
        playerName: 'King_Thorne',
        allianceTag: 'IRN',
        allianceName: 'Iron Crown',
        castleLevel: 30,
        power: 342000000,
        factionId: 'viking',
        x: 571,
        y: 563,
        online: true,
      ),
      RemotePlayer(
        playerId: 'npc_1306_duke',
        playerName: 'Duke_Vane',
        allianceTag: 'IRN',
        allianceName: 'Iron Crown',
        castleLevel: 28,
        power: 215000000,
        factionId: 'dragon_born',
        x: 576,
        y: 569,
        online: true,
      ),
      RemotePlayer(
        playerId: 'npc_1306_lady',
        playerName: 'Lady_Brienne',
        allianceTag: 'ASH',
        allianceName: 'Ashen Guard',
        castleLevel: 27,
        power: 184000000,
        factionId: 'yamato',
        x: 568,
        y: 568,
        online: true,
      ),
    ],
    1307: [
      RemotePlayer(
        playerId: 'npc_1307_king',
        playerName: 'DragonLord_Kael',
        allianceTag: 'DRG',
        allianceName: 'Dragonspire',
        castleLevel: 30,
        power: 368000000,
        factionId: 'huaxia',
        x: 572,
        y: 563,
        online: true,
      ),
      RemotePlayer(
        playerId: 'npc_1307_pyre',
        playerName: 'PyreKnight',
        allianceTag: 'DRG',
        allianceName: 'Dragonspire',
        castleLevel: 29,
        power: 248000000,
        factionId: 'arabia',
        x: 577,
        y: 568,
        online: true,
      ),
    ],
  };

  List<RemotePlayer> get visibleKingdomCastles {
    if (!isViewingForeignKingdom) return remotePlayers;
    return _foreignKingdomCastles[_activeKingdomId] ??
        const [
          RemotePlayer(
            playerId: 'npc_foreign_lord',
            playerName: 'Foreign_Warden',
            allianceTag: 'WAR',
            allianceName: 'Foreign Guard',
            castleLevel: 29,
            power: 240000000,
            factionId: 'viking',
            x: 572,
            y: 565,
            online: true,
          ),
        ];
  }

  void switchKingdom(int kingdomId) {
    _activeKingdomId = kingdomId;
    notifyListeners();
  }

  void startKingdomWar(int targetKingdomId) {
    if (targetKingdomId == homeKingdomId) return;
    _activeKingdomId = targetKingdomId;
    final home = playerCastles.first;
    _kvkPoints += 1500;
    launchMarch(
      kind: 'attack',
      label: 'KvK War: K#$targetKingdomId',
      fromX: home.x,
      fromY: home.y,
      toX: 574,
      toY: 566,
      duration: const Duration(seconds: 5),
      onComplete: () {
        _kvkPoints += 2500;
        _wood += 40000;
        _food += 40000;
        _gold += 500;
        _power += 20000;
        mails.insert(
          0,
          MailItem(
            id: 'kw_${DateTime.now().millisecondsSinceEpoch}',
            category: 'Reports',
            sender: 'War Herald',
            subject: 'Kingdom War Strike on #$targetKingdomId!',
            body:
                'Your expedition struck Kingdom #$targetKingdomId ($activeKingdomName), earning +2,500 KvK Points, 40K Wood, 40K Food, and 500 Gold.',
            timestamp: 'Now',
          ),
        );
      },
    );
    notifyListeners();
  }

  void scoutForeignCastle(RemotePlayer target) {
    final home = playerCastles.first;
    launchMarch(
      kind: 'scout',
      label: 'Scouting ${target.playerName}',
      fromX: home.x,
      fromY: home.y,
      toX: target.x,
      toY: target.y,
      duration: const Duration(seconds: 4),
      onComplete: () {
        mails.insert(
          0,
          MailItem(
            id: 'fscout_${DateTime.now().millisecondsSinceEpoch}',
            category: 'Reports',
            sender: 'Outrider Captain',
            subject: 'Scout Report: ${target.playerName} (K#$_activeKingdomId)',
            body:
                '[${target.allianceTag}] ${target.playerName} · Castle Lv.${target.castleLevel} · Power ${target.power}. Ready for Kingdom War attack!',
            timestamp: 'Now',
          ),
        );
      },
    );
  }

  void attackForeignCastle(RemotePlayer target) {
    if (_energy < 0.085) return;
    _energy = (_energy - 0.085).clamp(0.0, 1.0);
    final home = playerCastles.first;
    launchMarch(
      kind: 'attack',
      label: 'Attacking ${target.playerName}',
      fromX: home.x,
      fromY: home.y,
      toX: target.x,
      toY: target.y,
      duration: const Duration(seconds: 5),
      onComplete: () {
        _kvkPoints += 1200;
        _wood += 25000;
        _food += 25000;
        _iron += 10000;
        _gold += 250;
        _power += 15000;
        mails.insert(
          0,
          MailItem(
            id: 'fatk_${DateTime.now().millisecondsSinceEpoch}',
            category: 'Reports',
            sender: 'Garrison Marshal',
            subject: 'Victory vs ${target.playerName} in K#$_activeKingdomId!',
            body:
                'Your army defeated [${target.allianceTag}] ${target.playerName} at (${target.x}, ${target.y}) and looted 25K Wood, 25K Food, 10K Iron, 250 Gold (+1,200 KvK Pts).',
            timestamp: 'Now',
          ),
        );
      },
    );
    notifyListeners();
  }

  void createKingdom(int kingdomId, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (kingdoms.any((k) => k.id == kingdomId)) return;
    kingdoms.add(KingdomInfo(id: kingdomId, name: trimmed, castlesCount: 1));
    _activeKingdomId = kingdomId;
    notifyListeners();
  }

  bool buildWorldCastle(String name, int x, int y) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _wood < 50000 || _food < 50000) return false;
    _wood -= 50000;
    _food -= 50000;
    playerCastles.add(
      PlayerCastlePlot(
        name: trimmed,
        kingdomId: _activeKingdomId,
        x: x.clamp(1, 1199),
        y: y.clamp(1, 1199),
        level: 1,
      ),
    );
    final k = kingdoms.firstWhere((k) => k.id == _activeKingdomId);
    k.castlesCount += 1;
    _power += 35000;
    notifyListeners();
    return true;
  }
  final Map<int, String> builtResourcePlots = {};
  final Map<int, int> builtResourcePlotLevels = {};

  bool buildOnResourcePlot(int plotIndex, String buildingType) {
    if (_wood < 10000 || _food < 10000) return false;
    _wood -= 10000;
    _food -= 10000;
    builtResourcePlots[plotIndex] = buildingType;
    builtResourcePlotLevels[plotIndex] = 1;
    _power += 5000;
    notifyListeners();
    return true;
  }

  bool upgradeResourcePlot(int plotIndex) {
    final lv = builtResourcePlotLevels[plotIndex] ?? 1;
    final cost = (lv + 1) * 8000;
    if (_wood < cost || _food < cost) return false;
    _wood -= cost;
    _food -= cost;
    builtResourcePlotLevels[plotIndex] = lv + 1;
    _power += 6000;
    notifyListeners();
    return true;
  }

  int get wallDurability => _wallDurability;
  int get wishesRemaining => _wishesRemaining;
  int get kvkPoints => _kvkPoints;
  int get kvkEnemyPoints => _kvkEnemyPoints;
  String get throneHolder => _throneHolder;
  String get kingName => _kingName;
  bool get isKing => _kingName == _playerName;
  bool get royalGiftIssued => _royalGiftIssued;
  String get factionId => _factionId;
  int get dragonCampaignCampPoints => _dragonCampaignCampPoints;
  int get dragonCampaignEnemyPoints => _dragonCampaignEnemyPoints;
  int get crystals => _crystals;
  int get civilizationPopularity => _civilizationPopularity;
  String get popularityLabel => const [
    'Hostile',
    'Neutral',
    'Friendly',
    'Respect',
    'Admire',
    'Worship',
  ][_civilizationPopularity.clamp(0, 5)];
  String get activeDragon => _activeDragon;
  int get dragonLevel => _dragonLevel;
  int get dragonBond => _dragonBond;

  void boostPopularity() {
    if (_wood < 10000 || _civilizationPopularity >= 5) return;
    _wood -= 10000;
    _civilizationPopularity += 1;
    _power += 12000;
    notifyListeners();
  }

  void selectDragon(String name) {
    _activeDragon = name;
    notifyListeners();
  }

  void levelUpDragon() {
    if (_dragonLevel >= 40 || _food < 15000) return;
    _food -= 15000;
    _dragonLevel += 1;
    _power += 18000;
    notifyListeners();
  }

  void restoreDragonBond() {
    _dragonBond = 100;
    notifyListeners();
  }

  void sendDragonTravel() {
    _wood += 30000;
    _food += 30000;
    _crystals += 200;
    notifyListeners();
  }

  void upgradeHero(String name) {
    if (_gold < 200) return;
    _gold -= 200;
    heroLevels[name] = (heroLevels[name] ?? 1) + 1;
    _power += 10000;
    notifyListeners();
  }

  void refineDragonglass() {
    if (_crystals < 250) return;
    _crystals -= 250;
    _power += 15000;
    notifyListeners();
  }

  void captureDragonCampaignTower(String towerName, int points) {
    _dragonCampaignCampPoints += points;
    _crystals += 150;
    _power += 8000;
    notifyListeners();
  }

  void activateKingSkill(String skillName) {
    if (!isKing) return;
    if (skillName == 'Bumper Harvest') {
      _wood += 100000;
      _food += 100000;
    } else if (skillName == 'Red Envelope') {
      _gold += 500;
      sendChatMessage('Kingdom', '[Red Envelope] King $_playerName shared 500 Gold!');
      return;
    }
    notifyListeners();
  }
  FactionInfo get currentFaction =>
      factions.firstWhere((f) => f.id == _factionId, orElse: () => factions.first);

  void setFaction(String id) {
    if (!factions.any((f) => f.id == id)) return;
    _factionId = id;
    _sendPlayerProfile('profile_update');
    notifyListeners();
  }

  void launchMarch({
    required String kind,
    required String label,
    required int fromX,
    required int fromY,
    required int toX,
    required int toY,
    Duration duration = const Duration(seconds: 5),
    required VoidCallback onComplete,
  }) {
    final march = ActiveMarch(
      id: 'march_${DateTime.now().microsecondsSinceEpoch}',
      kind: kind,
      label: label,
      fromX: fromX,
      fromY: fromY,
      toX: toX,
      toY: toY,
      startedAt: DateTime.now(),
      duration: duration,
      onComplete: onComplete,
    );
    activeMarches.add(march);
    _marchTimer ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
      var changed = false;
      for (final m in activeMarches.toList()) {
        if (!m.completed && m.progress >= 1.0) {
          m.completed = true;
          m.onComplete();
          activeMarches.remove(m);
          changed = true;
        }
      }
      if (activeMarches.isEmpty) {
        _marchTimer?.cancel();
        _marchTimer = null;
      }
      if (changed || activeMarches.isNotEmpty) {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void speedUpMarch(String id) {
    final idx = activeMarches.indexWhere((m) => m.id == id);
    if (idx < 0) return;
    final march = activeMarches.removeAt(idx);
    if (!march.completed) {
      march.completed = true;
      march.onComplete();
    }
    if (activeMarches.isEmpty) {
      _marchTimer?.cancel();
      _marchTimer = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _marchTimer?.cancel();
    _mpClient?.dispose();
    super.dispose();
  }

  void rallyMiddleThrone() {
    if (_energy < 0.08) return;
    _energy = (_energy - 0.08).clamp(0.0, 1.0);
    _kvkPoints += 5000;
    _throneHolder = '[$_allianceTag] $_allianceName';
    _kingName = _playerName;
    _power += 25000;
    _gold += 1500;
    mails.insert(
      0,
      MailItem(
        id: 'throne_${DateTime.now().millisecondsSinceEpoch}',
        category: 'Alliance',
        sender: 'Royal Herald',
        subject: 'Long Live King $_playerName!',
        body:
            '$_playerName of [$_allianceTag] $_allianceName seized the Middle Throne at (600, 600) and is crowned King of #$_activeKingdomId! You can now appoint Royal Officers and issue Kingdom Gifts.',
        timestamp: 'Now',
      ),
    );
    final home = playerCastles.first;
    _mpClient?.send({
      'type': 'launch_march',
      'march': {
        'id': 'throne_${DateTime.now().microsecondsSinceEpoch}',
        'fromPlayerId': _playerId,
        'fromName': _playerName,
        'toPlayerId': '',
        'kind': 'rally',
        'label': '$_playerName Rallying Throne',
        'fromX': home.x,
        'fromY': home.y,
        'toX': 574,
        'toY': 566,
        'durationMs': 4000,
      },
    });
    _sendPlayerProfile('profile_update');
    notifyListeners();
  }

  void appointLord(String title, String lordName) {
    if (!isKing) return;
    final trimmed = lordName.trim();
    if (trimmed.isEmpty) return;
    royalAppointments[title] = trimmed;
    _mpClient?.send({
      'type': 'appoint_lord',
      'kingId': _playerId,
      'title': title,
      'lordName': trimmed,
    });
    notifyListeners();
  }

  void issueKingdomGift() {
    if (!isKing || _royalGiftIssued) return;
    _royalGiftIssued = true;
    _gold += 500;
    _wood += 50000;
    _food += 50000;
    notifyListeners();
  }

  void invadeEnemyKingdom(int targetKingdomId) {
    if (_energy < 0.08) return;
    _energy = (_energy - 0.08).clamp(0.0, 1.0);
    _kvkPoints += 2500;
    _wood += 40000;
    _food += 40000;
    _iron += 15000;
    _gold += 500;
    _power += 15000;
    mails.insert(
      0,
      MailItem(
        id: 'kvk_${DateTime.now().millisecondsSinceEpoch}',
        category: 'Reports',
        sender: 'War Marshal',
        subject: 'KvK Raid on Kingdom #$targetKingdomId',
        body:
            'Your expeditionary force defeated defenders in Kingdom #$targetKingdomId! Earned +2,500 KvK Points, +40K Wood/Food, +15K Iron, and +500 Gold.',
        timestamp: 'Now',
      ),
    );
    notifyListeners();
  }

  bool claimKvkPrize(int tier) {
    if (kvkClaimedTiers.contains(tier)) return false;
    final required = switch (tier) {
      1 => 2500,
      2 => 5000,
      3 => 10000,
      _ => 999999,
    };
    if (_kvkPoints < required) return false;
    kvkClaimedTiers.add(tier);
    switch (tier) {
      case 1:
        _gold += 500;
        _wood += 50000;
        _food += 50000;
      case 2:
        _gold += 1200;
        _wood += 100000;
        _iron += 30000;
      case 3:
        _gold += 3000;
        _mithril += 20000;
        addVipPoints(2000);
        return true;
    }
    notifyListeners();
    return true;
  }

  bool repairWalls() {
    if (_wallDurability >= 100 || _wood < 5000) return false;
    _wood -= 5000;
    _wallDurability = 100;
    _power += 4000;
    notifyListeners();
    return true;
  }

  String? makeWish(String resourceType) {
    if (_wishesRemaining <= 0) return null;
    _wishesRemaining -= 1;
    switch (resourceType) {
      case 'Wood':
        _wood += 40000;
      case 'Food':
        _food += 40000;
      case 'Iron':
        _iron += 15000;
      case 'Mithril':
        _mithril += 8000;
      case 'Gold':
        _gold += 300;
    }
    notifyListeners();
    return 'Granted $resourceType!';
  }

  void attachPersistencePath(String path) {
    _persistenceFile = File(path);
    loadFromDisk();
    _ensurePlayerIdentity();
    if (_multiplayerUrl.isNotEmpty) {
      connectMultiplayer(_multiplayerUrl);
    }
  }

  void _ensurePlayerIdentity() {
    var changed = false;
    if (_playerId.isEmpty) {
      final rng = math.Random.secure();
      final bytes = List<int>.generate(4, (_) => rng.nextInt(256));
      final hex = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join()
          .toUpperCase();
      _playerId = 'p_$hex';
      changed = true;
    }
    if (_playerName == 'OpenCoK') {
      final suffix = _playerId.length >= 6
          ? _playerId.substring(2, 6)
          : _playerId;
      _playerName = 'Lord_$suffix';
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  void connectMultiplayer(String url) {
    if (url.trim().isEmpty) return;
    _mpClient?.dispose();
    _mpClient = MultiplayerClient(
      uri: Uri.parse(url.trim()),
      onStatus: (connected) {
        _multiplayerConnected = connected;
        if (connected) {
          _sendPlayerProfile('hello');
        }
        notifyListeners();
      },
      onMessage: _handleMultiplayerMessage,
    )..start();
  }

  void _sendPlayerProfile(String type) {
    if (_playerId.isEmpty) return;
    final home = playerCastles.first;
    _mpClient?.send({
      'type': type,
      'player': {
        'playerId': _playerId,
        'playerName': _playerName,
        'allianceTag': _allianceTag,
        'allianceName': _allianceName,
        'castleLevel': buildingLevel('buildingCastle'),
        'power': _power,
        'factionId': _factionId,
        'troopsCount': _troopsTrained,
        'wood': _wood,
        'food': _food,
        'iron': _iron,
        'gold': _gold,
        'x': home.x,
        'y': home.y,
      },
    });
  }

  void scoutRemotePlayer(RemotePlayer target) {
    final home = playerCastles.first;
    final id = 'scout_${DateTime.now().microsecondsSinceEpoch}';
    launchMarch(
      kind: 'scout',
      label: 'Scouting ${target.playerName}',
      fromX: home.x,
      fromY: home.y,
      toX: target.x,
      toY: target.y,
      duration: const Duration(seconds: 4),
      onComplete: () {},
    );
    _mpClient?.send({
      'type': 'launch_march',
      'march': {
        'id': id,
        'fromPlayerId': _playerId,
        'fromName': _playerName,
        'toPlayerId': target.playerId,
        'toName': target.playerName,
        'kind': 'scout',
        'label': '$_playerName scouting ${target.playerName}',
        'fromX': home.x,
        'fromY': home.y,
        'toX': target.x,
        'toY': target.y,
        'durationMs': 4000,
      },
    });
  }

  void attackRemotePlayer(RemotePlayer target) {
    if (_energy < 0.085) return;
    _energy = (_energy - 0.085).clamp(0.0, 1.0);
    final home = playerCastles.first;
    final id = 'atk_${DateTime.now().microsecondsSinceEpoch}';
    launchMarch(
      kind: 'attack',
      label: 'Attacking ${target.playerName}',
      fromX: home.x,
      fromY: home.y,
      toX: target.x,
      toY: target.y,
      duration: const Duration(seconds: 5),
      onComplete: () {},
    );
    _mpClient?.send({
      'type': 'launch_march',
      'march': {
        'id': id,
        'fromPlayerId': _playerId,
        'fromName': _playerName,
        'toPlayerId': target.playerId,
        'toName': target.playerName,
        'kind': 'attack',
        'label': '$_playerName attacking ${target.playerName}',
        'fromX': home.x,
        'fromY': home.y,
        'toX': target.x,
        'toY': target.y,
        'durationMs': 5000,
      },
    });
    notifyListeners();
  }

  void _handleMultiplayerMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    switch (type) {
      case 'welcome_player':
        final p = msg['player'] as Map<String, dynamic>?;
        if (p != null) {
          final ax = p['x'] as int?;
          final ay = p['y'] as int?;
          if (ax != null && ay != null && playerCastles.isNotEmpty) {
            final cur = playerCastles[0];
            playerCastles[0] = PlayerCastlePlot(
              name: cur.name,
              kingdomId: cur.kingdomId,
              x: ax,
              y: ay,
              level: buildingLevel('buildingCastle'),
            );
            notifyListeners();
          }
        }
      case 'world_state':
        final rawPlayers = msg['players'] as List<dynamic>? ?? const [];
        remotePlayers
          ..clear()
          ..addAll(
            rawPlayers
                .whereType<Map<String, dynamic>>()
                .map(RemotePlayer.fromJson)
                .where((p) => p.playerId != _playerId),
          );

        final rawMarches = msg['marches'] as List<dynamic>? ?? const [];
        for (final rm in rawMarches.whereType<Map<String, dynamic>>()) {
          final id = rm['id'] as String? ?? '';
          if (id.isEmpty) continue;
          if ((rm['fromPlayerId'] as String?) == _playerId) continue;
          if (!activeMarches.any((m) => m.id == id)) {
            final durationMs = (rm['durationMs'] as int?) ?? 5000;
            launchMarch(
              kind: (rm['kind'] as String?) ?? 'attack',
              label: (rm['label'] as String?) ?? 'Enemy March',
              fromX: (rm['fromX'] as int?) ?? 570,
              fromY: (rm['fromY'] as int?) ?? 570,
              toX: (rm['toX'] as int?) ?? 574,
              toY: (rm['toY'] as int?) ?? 566,
              duration: Duration(milliseconds: durationMs),
              onComplete: () {},
            );
          }
        }

        final throne = msg['throne'] as Map<String, dynamic>?;
        if (throne != null) {
          final kName = throne['kingName'] as String?;
          final aTag = throne['allianceTag'] as String?;
          final aName = throne['allianceName'] as String?;
          if (kName != null && kName.isNotEmpty) _kingName = kName;
          if (aTag != null && aName != null) {
            _throneHolder = '[$aTag] $aName';
          }
          final appts = throne['royalAppointments'] as Map<String, dynamic>?;
          if (appts != null) {
            for (final e in appts.entries) {
              if (e.value is String) {
                royalAppointments[e.key] = e.value as String;
              }
            }
          }
        }

        final rawChat = msg['chat'] as List<dynamic>? ?? const [];
        for (final c in rawChat.reversed.whereType<Map<String, dynamic>>()) {
          final sender = (c['sender'] as String?) ?? 'Lord';
          final text = (c['text'] as String?) ?? '';
          final channel = (c['channel'] as String?) ?? 'Kingdom';
          if (text.isEmpty) continue;
          final exists = chatMessages.any(
            (m) => m.sender == sender && m.text == text && m.channel == channel,
          );
          if (!exists) {
            chatMessages.add(
              ChatMessageItem(
                channel: channel,
                vipLabel: 'LIVE',
                sender: sender,
                text: text,
                translatedText: text,
                time: 'Live',
              ),
            );
          }
        }
        notifyListeners();
      case 'battle_report':
        final victory = (msg['victory'] as bool?) ?? true;
        final isDefense = (msg['isDefense'] as bool?) ?? false;
        final opp = (msg['opponentName'] as String?) ?? 'Enemy Lord';
        final coords = (msg['opponentCoords'] as String?) ?? '';
        final lw = (msg['lootWood'] as int?) ?? 0;
        final lf = (msg['lootFood'] as int?) ?? 0;
        final li = (msg['lootIron'] as int?) ?? 0;
        final lg = (msg['lootGold'] as int?) ?? 0;
        if (!isDefense && victory) {
          _wood += lw;
          _food += lf;
          _iron += li;
          _gold += lg;
          _power += 15000;
        } else if (isDefense && !victory) {
          _wood = math.max(0, _wood - lw);
          _food = math.max(0, _food - lf);
          _iron = math.max(0, _iron - li);
          _gold = math.max(0, _gold - lg);
          _power = math.max(1000000, _power - 8000);
        }
        mails.insert(
          0,
          MailItem(
            id: 'pvp_${DateTime.now().millisecondsSinceEpoch}',
            category: 'Reports',
            sender: 'Garrison Marshal',
            subject: isDefense
                ? (victory ? 'Defended against $opp!' : 'Castle Raided by $opp!')
                : (victory ? 'PvP Victory vs $opp!' : 'PvP Defeat vs $opp'),
            body: isDefense
                ? (victory
                      ? 'Your garrison repelled $opp $coords!'
                      : '$opp $coords breached your wall and looted ${lw ~/ 1000}K Wood, ${lf ~/ 1000}K Food, ${li ~/ 1000}K Iron, $lg Gold.')
                : (victory
                      ? 'Your army defeated $opp $coords and looted ${lw ~/ 1000}K Wood, ${lf ~/ 1000}K Food, ${li ~/ 1000}K Iron, $lg Gold!'
                      : 'Your army was repelled by $opp $coords.'),
            timestamp: 'Now',
          ),
        );
        notifyListeners();
      case 'scout_report':
        final target = (msg['targetName'] as String?) ?? 'Lord';
        final coords = (msg['targetCoords'] as String?) ?? '';
        final lvl = (msg['castleLevel'] as int?) ?? 30;
        final pwr = (msg['power'] as int?) ?? 0;
        final troops = (msg['troopsCount'] as int?) ?? 0;
        mails.insert(
          0,
          MailItem(
            id: 'scout_${DateTime.now().millisecondsSinceEpoch}',
            category: 'Reports',
            sender: 'Outrider Captain',
            subject: 'Scout Report: $target $coords',
            body:
                '$target (Castle Lv.$lvl) has $troops troops and $pwr Power.',
            timestamp: 'Now',
          ),
        );
        notifyListeners();
    }
  }

  void loadFromDisk() {
    final file = _persistenceFile;
    if (file == null || !file.existsSync()) return;
    try {
      final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      _playerId = (raw['playerId'] as String?) ?? _playerId;
      _playerName = (raw['playerName'] as String?) ?? _playerName;
      final hx = raw['homeX'] as int?;
      final hy = raw['homeY'] as int?;
      if (hx != null && hy != null && playerCastles.isNotEmpty) {
        final cur = playerCastles[0];
        playerCastles[0] = PlayerCastlePlot(
          name: cur.name,
          kingdomId: cur.kingdomId,
          x: hx,
          y: hy,
          level: cur.level,
        );
      }
      _level = (raw['level'] as int?) ?? _level;
      _wood = (raw['wood'] as int?) ?? _wood;
      _food = (raw['food'] as int?) ?? _food;
      _iron = (raw['iron'] as int?) ?? _iron;
      _mithril = (raw['mithril'] as int?) ?? _mithril;
      _gold = (raw['gold'] as int?) ?? _gold;
      _power = (raw['power'] as int?) ?? _power;
      _troopsTrained = (raw['troopsTrained'] as int?) ?? _troopsTrained;
      _activeKingdomId = (raw['activeKingdomId'] as int?) ?? _activeKingdomId;
      _allianceTag = (raw['allianceTag'] as String?) ?? _allianceTag;
      _allianceName = (raw['allianceName'] as String?) ?? _allianceName;
      final levels = raw['buildingLevels'] as Map<String, dynamic>?;
      if (levels != null) {
        for (final entry in levels.entries) {
          if (entry.value is int) buildingLevels[entry.key] = entry.value as int;
        }
      }
      final plots = raw['builtResourcePlots'] as Map<String, dynamic>?;
      if (plots != null) {
        for (final entry in plots.entries) {
          final idx = int.tryParse(entry.key);
          if (idx != null && entry.value is String) {
            builtResourcePlots[idx] = entry.value as String;
          }
        }
      }
      final plotLevels = raw['builtResourcePlotLevels'] as Map<String, dynamic>?;
      if (plotLevels != null) {
        for (final entry in plotLevels.entries) {
          final idx = int.tryParse(entry.key);
          if (idx != null && entry.value is int) {
            builtResourcePlotLevels[idx] = entry.value as int;
          }
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    final file = _persistenceFile;
    if (file == null) return;
    try {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        jsonEncode({
          'playerId': _playerId,
          'playerName': _playerName,
          'homeX': playerCastles.isNotEmpty ? playerCastles.first.x : 570,
          'homeY': playerCastles.isNotEmpty ? playerCastles.first.y : 570,
          'level': _level,
          'wood': _wood,
          'food': _food,
          'iron': _iron,
          'mithril': _mithril,
          'gold': _gold,
          'power': _power,
          'troopsTrained': _troopsTrained,
          'activeKingdomId': _activeKingdomId,
          'allianceTag': _allianceTag,
          'allianceName': _allianceName,
          'buildingLevels': buildingLevels,
          'builtResourcePlots': {
            for (final e in builtResourcePlots.entries) '${e.key}': e.value,
          },
          'builtResourcePlotLevels': {
            for (final e in builtResourcePlotLevels.entries)
              '${e.key}': e.value,
          },
        }),
      );
    } catch (_) {}
  }
}