class AppConfig {
  String waifuName;
  String avatarPath;            // assets/images/...
  String personality;           // sweet | tsundere | playful
  int coins;                    // mağaza için basit ekonomi
  List<String> ownedSkus;       // satın alınan öğeler

  AppConfig({
    this.waifuName = 'urWaifu',
    this.avatarPath = 'assets/images/waifu_default.png',
    this.personality = 'sweet',
    this.coins = 200,
    List<String>? ownedSkus,
  }) : ownedSkus = ownedSkus ?? <String>[];

  AppConfig copyWith({
    String? waifuName,
    String? avatarPath,
    String? personality,
    int? coins,
    List<String>? ownedSkus,
  }) {
    return AppConfig(
      waifuName: waifuName ?? this.waifuName,
      avatarPath: avatarPath ?? this.avatarPath,
      personality: personality ?? this.personality,
      coins: coins ?? this.coins,
      ownedSkus: ownedSkus ?? List<String>.from(this.ownedSkus),
    );
  }
}
